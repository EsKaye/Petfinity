--[[
    NotificationUI.lua
    UI component for displaying in-game notifications with cute animations
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import EffectsSystem for notification animations
local EffectsSystem = require(game.ReplicatedStorage.Systems.EffectsSystem)

local NotificationUI = {}
NotificationUI.__index = NotificationUI

-- UI Configuration
local UI_CONFIG = {
    NOTIFICATION_SIZE = UDim2.new(0.3, 0, 0.1, 0),
    NOTIFICATION_SPACING = 0.12, -- Space between notifications
    MAX_NOTIFICATIONS = 3, -- Maximum number of notifications shown at once
    DISPLAY_TIME = 5, -- How long notifications stay visible
    COLORS = {
        BACKGROUND = Color3.fromRGB(30, 30, 35),
        TEXT = Color3.fromRGB(240, 240, 240),
        STREAK_WARNING = Color3.fromRGB(255, 100, 100),
        EVENT_ALERT = Color3.fromRGB(100, 255, 150),
        VIP_BONUS = Color3.fromRGB(255, 215, 0),
        DROP_RATE_BOOST = Color3.fromRGB(150, 150, 255)
    },
    ANIMATIONS = {
        POPUP = {
            TIME = 0.3,
            EASING = Enum.EasingStyle.Back,
            DIRECTION = Enum.EasingDirection.Out
        },
        SLIDE = {
            TIME = 0.2,
            EASING = Enum.EasingStyle.Quad,
            DIRECTION = Enum.EasingDirection.Out
        },
        FADE = {
            TIME = 0.5,
            EASING = Enum.EasingStyle.Linear,
            DIRECTION = Enum.EasingDirection.InOut
        }
    }
}

function NotificationUI.new(parent)
    local self = setmetatable({}, NotificationUI)
    
    -- Store references
    self.parent = parent
    self.effectsSystem = EffectsSystem.new()
    
    -- Initialize notification container
    self:createContainer()
    
    -- Initialize active notifications list
    self.activeNotifications = {}
    
    return self
end

function NotificationUI:createContainer()
    -- Create container for notifications
    self.container = Instance.new("Frame")
    self.container.Name = "NotificationContainer"
    self.container.Size = UDim2.new(1, 0, 1, 0)
    self.container.Position = UDim2.new(0, 0, 0, 0)
    self.container.BackgroundTransparency = 1
    self.container.Parent = self.parent
end

function NotificationUI:createNotificationCard(notification)
    -- Create notification frame
    local card = Instance.new("Frame")
    card.Name = "NotificationCard"
    card.Size = UI_CONFIG.NOTIFICATION_SIZE
    card.Position = UDim2.new(1, 0, 0, 0) -- Start off screen
    card.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
    card.BackgroundTransparency = 0.1
    
    -- Add icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0.2, 0, 0.8, 0)
    icon.Position = UDim2.new(0.05, 0, 0.1, 0)
    icon.BackgroundTransparency = 1
    icon.Image = notification.icon
    icon.Parent = card
    
    -- Add title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.7, 0, 0.4, 0)
    title.Position = UDim2.new(0.25, 0, 0.1, 0)
    title.BackgroundTransparency = 1
    title.Text = notification.title
    title.TextColor3 = UI_CONFIG.COLORS.TEXT
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = card
    
    -- Add message
    local message = Instance.new("TextLabel")
    message.Name = "Message"
    message.Size = UDim2.new(0.7, 0, 0.4, 0)
    message.Position = UDim2.new(0.25, 0, 0.5, 0)
    message.BackgroundTransparency = 1
    message.Text = notification.message
    message.TextColor3 = UI_CONFIG.COLORS.TEXT
    message.TextScaled = true
    message.Font = Enum.Font.GothamMedium
    message.Parent = card
    
    -- Add glow effect based on notification type
    local glow = Instance.new("UIGradient")
    glow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, UI_CONFIG.COLORS[notification.type]),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, UI_CONFIG.COLORS[notification.type])
    })
    glow.Parent = card
    
    -- Animate glow
    local rotation = 0
    game:GetService("RunService").RenderStepped:Connect(function()
        rotation = (rotation + 1) % 360
        glow.Rotation = rotation
    end)
    
    -- Add close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.1, 0, 0.2, 0)
    closeButton.Position = UDim2.new(0.85, 0, 0.1, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = UI_CONFIG.COLORS.TEXT
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = card
    
    -- Add close button handler
    closeButton.MouseButton1Click:Connect(function()
        self:removeNotification(card)
    end)
    
    return card
end

function NotificationUI:show(notification)
    -- Remove oldest notification if at max
    if #self.activeNotifications >= UI_CONFIG.MAX_NOTIFICATIONS then
        self:removeNotification(self.activeNotifications[1])
    end
    
    -- Create new notification card
    local card = self:createNotificationCard(notification)
    card.Parent = self.container
    
    -- Add to active notifications
    table.insert(self.activeNotifications, card)
    
    -- Position card
    local position = #self.activeNotifications - 1
    local targetY = position * UI_CONFIG.NOTIFICATION_SPACING
    
    -- Play entrance animation
    self:playEntranceAnimation(card, targetY)
    
    -- Play particle effects
    self:playParticleEffects(card, notification.type)
    
    -- Set up auto-removal timer
    delay(UI_CONFIG.DISPLAY_TIME, function()
        if card.Parent then
            self:removeNotification(card)
        end
    end)
end

function NotificationUI:playEntranceAnimation(card, targetY)
    -- Initial state
    card.Position = UDim2.new(1, 0, targetY, 0)
    card.Size = UDim2.new(0, 0, 0, 0)
    
    -- Slide in and expand
    local slideTween = TweenService:Create(card, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.SLIDE.TIME,
        UI_CONFIG.ANIMATIONS.SLIDE.EASING,
        UI_CONFIG.ANIMATIONS.SLIDE.DIRECTION
    ), {
        Position = UDim2.new(0.7, 0, targetY, 0)
    })
    
    local expandTween = TweenService:Create(card, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.POPUP.TIME,
        UI_CONFIG.ANIMATIONS.POPUP.EASING,
        UI_CONFIG.ANIMATIONS.POPUP.DIRECTION
    ), {
        Size = UI_CONFIG.NOTIFICATION_SIZE
    })
    
    slideTween:Play()
    expandTween:Play()
end

function NotificationUI:playParticleEffects(card, notificationType)
    -- Play particle effects based on notification type
    local color = UI_CONFIG.COLORS[notificationType]
    
    self.effectsSystem:playParticles({
        position = card.AbsolutePosition + card.AbsoluteSize/2,
        color = color,
        lifetime = NumberRange.new(0.5, 1),
        rate = 20,
        speed = NumberRange.new(10, 30)
    })
end

function NotificationUI:removeNotification(card)
    -- Find card index
    local index = table.find(self.activeNotifications, card)
    if not index then return end
    
    -- Remove from active notifications
    table.remove(self.activeNotifications, index)
    
    -- Animate remaining cards
    for i = index, #self.activeNotifications do
        local remainingCard = self.activeNotifications[i]
        local targetY = (i - 1) * UI_CONFIG.NOTIFICATION_SPACING
        
        TweenService:Create(remainingCard, TweenInfo.new(
            UI_CONFIG.ANIMATIONS.SLIDE.TIME,
            UI_CONFIG.ANIMATIONS.SLIDE.EASING,
            UI_CONFIG.ANIMATIONS.SLIDE.DIRECTION
        ), {
            Position = UDim2.new(0.7, 0, targetY, 0)
        }):Play()
    end
    
    -- Fade out and slide away
    local fadeTween = TweenService:Create(card, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.FADE.TIME,
        UI_CONFIG.ANIMATIONS.FADE.EASING,
        UI_CONFIG.ANIMATIONS.FADE.DIRECTION
    ), {
        BackgroundTransparency = 1,
        TextTransparency = 1
    })
    
    local slideTween = TweenService:Create(card, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.SLIDE.TIME,
        UI_CONFIG.ANIMATIONS.SLIDE.EASING,
        UI_CONFIG.ANIMATIONS.SLIDE.DIRECTION
    ), {
        Position = UDim2.new(1, 0, card.Position.Y.Scale, 0)
    })
    
    fadeTween:Play()
    slideTween:Play()
    
    -- Destroy card after animation
    slideTween.Completed:Connect(function()
        card:Destroy()
    end)
end

function NotificationUI:destroy()
    self.container:Destroy()
    self.effectsSystem:destroy()
end

return NotificationUI 