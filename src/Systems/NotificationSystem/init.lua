--[[
    NotificationSystem.lua
    Handles push notifications, alerts, and engagement triggers
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotificationService = game:GetService("NotificationService")
local DataStoreService = game:GetService("DataStoreService")

-- Import EffectsSystem for notification animations
local EffectsSystem = require(game.ReplicatedStorage.Systems.EffectsSystem)

local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

-- Notification types and their configurations
local NOTIFICATION_CONFIG = {
    STREAK_WARNING = {
        TITLE = "Streak at Risk!",
        ICON = "rbxassetid://streak_warning",
        SOUND = "rbxassetid://warning_chime",
        PRIORITY = 1, -- Higher priority = more urgent
        COOLDOWN = 3600 -- 1 hour between notifications
    },
    EVENT_ALERT = {
        TITLE = "Special Event!",
        ICON = "rbxassetid://event_icon",
        SOUND = "rbxassetid://event_chime",
        PRIORITY = 2,
        COOLDOWN = 7200 -- 2 hours between notifications
    },
    VIP_BONUS = {
        TITLE = "VIP Bonus!",
        ICON = "rbxassetid://vip_icon",
        SOUND = "rbxassetid://vip_chime",
        PRIORITY = 3,
        COOLDOWN = 14400 -- 4 hours between notifications
    },
    DROP_RATE_BOOST = {
        TITLE = "Drop Rate Boost!",
        ICON = "rbxassetid://boost_icon",
        SOUND = "rbxassetid://boost_chime",
        PRIORITY = 2,
        COOLDOWN = 3600 -- 1 hour between notifications
    }
}

-- Default notification settings
local DEFAULT_SETTINGS = {
    ENABLED = true,
    SOUND_ENABLED = true,
    TYPES = {
        STREAK_WARNING = true,
        EVENT_ALERT = true,
        VIP_BONUS = true,
        DROP_RATE_BOOST = true
    },
    QUIET_HOURS = {
        START = 22, -- 10 PM
        END = 8 -- 8 AM
    }
}

function NotificationSystem.new(player)
    local self = setmetatable({}, NotificationSystem)
    
    -- Store references
    self.player = player
    self.dataStore = DataStoreService:GetDataStore("NotificationSettings_" .. player.UserId)
    self.effectsSystem = EffectsSystem.new()
    
    -- Load player settings
    self:loadSettings()
    
    -- Initialize notification queue
    self.notificationQueue = {}
    self.lastNotificationTimes = {}
    
    -- Start notification processor
    self:startNotificationProcessor()
    
    return self
end

function NotificationSystem:loadSettings()
    local success, data = pcall(function()
        return self.dataStore:GetAsync("notification_settings")
    end)
    
    if success and data then
        self.settings = data
    else
        -- Initialize with default settings
        self.settings = table.clone(DEFAULT_SETTINGS)
        self:saveSettings()
    end
end

function NotificationSystem:saveSettings()
    local success, err = pcall(function()
        self.dataStore:SetAsync("notification_settings", self.settings)
    end)
    
    return success
end

function NotificationSystem:updateSettings(newSettings)
    -- Update only provided settings
    for key, value in pairs(newSettings) do
        if type(self.settings[key]) == "table" then
            -- Merge table settings
            for subKey, subValue in pairs(value) do
                self.settings[key][subKey] = subValue
            end
        else
            -- Update simple settings
            self.settings[key] = value
        end
    end
    
    -- Save updated settings
    self:saveSettings()
end

function NotificationSystem:canSendNotification(notificationType)
    -- Check if notifications are enabled
    if not self.settings.ENABLED then
        return false
    end
    
    -- Check if this type is enabled
    if not self.settings.TYPES[notificationType] then
        return false
    end
    
    -- Check quiet hours
    local hour = tonumber(os.date("%H"))
    if hour >= self.settings.QUIET_HOURS.START or hour < self.settings.QUIET_HOURS.END then
        return false
    end
    
    -- Check cooldown
    local lastTime = self.lastNotificationTimes[notificationType]
    if lastTime then
        local timeSince = os.time() - lastTime
        if timeSince < NOTIFICATION_CONFIG[notificationType].COOLDOWN then
            return false
        end
    end
    
    return true
end

function NotificationSystem:queueNotification(notificationType, message, data)
    if not self:canSendNotification(notificationType) then
        return false
    end
    
    -- Create notification data
    local config = NOTIFICATION_CONFIG[notificationType]
    local notification = {
        type = notificationType,
        title = config.TITLE,
        message = message,
        icon = config.ICON,
        sound = config.SOUND,
        priority = config.PRIORITY,
        data = data,
        timestamp = os.time()
    }
    
    -- Add to queue
    table.insert(self.notificationQueue, notification)
    
    -- Update last notification time
    self.lastNotificationTimes[notificationType] = os.time()
    
    return true
end

function NotificationSystem:startNotificationProcessor()
    -- Process notifications every second
    game:GetService("RunService").Heartbeat:Connect(function()
        if #self.notificationQueue > 0 then
            -- Sort by priority
            table.sort(self.notificationQueue, function(a, b)
                return a.priority > b.priority
            end)
            
            -- Process next notification
            local notification = table.remove(self.notificationQueue, 1)
            self:showNotification(notification)
        end
    end)
end

function NotificationSystem:showNotification(notification)
    -- Send push notification
    if game:GetService("RunService"):IsStudio() then
        -- Studio testing
        print("Push Notification:", notification.title, notification.message)
    else
        -- Real device notification
        NotificationService:ScheduleNotification(
            self.player,
            notification.title,
            notification.message,
            notification.icon
        )
    end
    
    -- Show in-game notification
    if self.notificationUI then
        self.notificationUI:show(notification)
    end
    
    -- Play sound if enabled
    if self.settings.SOUND_ENABLED then
        local sound = Instance.new("Sound")
        sound.SoundId = notification.sound
        sound.Parent = self.player.PlayerGui
        sound:Play()
        game:GetService("Debris"):AddItem(sound, sound.TimeLength)
    end
end

-- Notification trigger functions
function NotificationSystem:notifyStreakWarning(streakDays)
    return self:queueNotification(
        "STREAK_WARNING",
        string.format("Don't lose your %d day streak! Log in now to keep it going!", streakDays),
        {streakDays = streakDays}
    )
end

function NotificationSystem:notifyEventPet(petName, timeLeft)
    return self:queueNotification(
        "EVENT_ALERT",
        string.format("Limited-time %s available! Only %s left to get yours!", petName, timeLeft),
        {petName = petName, timeLeft = timeLeft}
    )
end

function NotificationSystem:notifyVIPBonus(bonusType, multiplier)
    return self:queueNotification(
        "VIP_BONUS",
        string.format("VIP Exclusive: %dx %s bonus active now!", multiplier, bonusType),
        {bonusType = bonusType, multiplier = multiplier}
    )
end

function NotificationSystem:notifyDropRateBoost(boostAmount, duration)
    return self:queueNotification(
        "DROP_RATE_BOOST",
        string.format("%dx Drop rate boost active for %s!", boostAmount, duration),
        {boostAmount = boostAmount, duration = duration}
    )
end

function NotificationSystem:destroy()
    self.effectsSystem:destroy()
end

return NotificationSystem 