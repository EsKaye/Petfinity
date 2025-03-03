--[[
    NotificationSettingsUI.lua
    UI component for customizing notification preferences
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotificationSettingsUI = {}
NotificationSettingsUI.__index = NotificationSettingsUI

-- UI Configuration
local UI_CONFIG = {
    WINDOW_SIZE = UDim2.new(0.4, 0, 0.6, 0),
    TOGGLE_SIZE = UDim2.new(0.05, 0, 0.05, 0),
    COLORS = {
        BACKGROUND = Color3.fromRGB(30, 30, 35),
        TEXT = Color3.fromRGB(240, 240, 240),
        TOGGLE_ON = Color3.fromRGB(100, 255, 150),
        TOGGLE_OFF = Color3.fromRGB(150, 150, 150),
        SECTION = Color3.fromRGB(45, 45, 50)
    },
    ANIMATIONS = {
        POPUP = {
            TIME = 0.3,
            EASING = Enum.EasingStyle.Back,
            DIRECTION = Enum.EasingDirection.Out
        },
        TOGGLE = {
            TIME = 0.2,
            EASING = Enum.EasingStyle.Quad,
            DIRECTION = Enum.EasingDirection.Out
        }
    }
}

function NotificationSettingsUI.new(parent, notificationSystem)
    local self = setmetatable({}, NotificationSettingsUI)
    
    -- Store references
    self.parent = parent
    self.notificationSystem = notificationSystem
    
    -- Create main window
    self:createWindow()
    
    -- Create settings sections
    self:createGeneralSettings()
    self:createNotificationTypes()
    self:createQuietHours()
    
    -- Hide window initially
    self.window.Visible = false
    
    return self
end

function NotificationSettingsUI:createWindow()
    -- Create background frame
    self.window = Instance.new("Frame")
    self.window.Name = "NotificationSettings"
    self.window.Size = UI_CONFIG.WINDOW_SIZE
    self.window.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.window.AnchorPoint = Vector2.new(0.5, 0.5)
    self.window.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
    self.window.BackgroundTransparency = 0.1
    self.window.Parent = self.parent
    
    -- Add title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Notification Settings"
    title.TextColor3 = UI_CONFIG.COLORS.TEXT
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = self.window
    
    -- Add close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.85, 0, 0.05, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = UI_CONFIG.COLORS.TEXT
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = self.window
    
    -- Add close button handler
    closeButton.MouseButton1Click:Connect(function()
        self:hide()
    end)
end

function NotificationSettingsUI:createGeneralSettings()
    -- Create general settings section
    local section = self:createSection("General Settings", 0.15)
    
    -- Add master toggle
    self:createToggle(
        section,
        "Enable Notifications",
        "ENABLED",
        0
    )
    
    -- Add sound toggle
    self:createToggle(
        section,
        "Enable Sounds",
        "SOUND_ENABLED",
        0.1
    )
end

function NotificationSettingsUI:createNotificationTypes()
    -- Create notification types section
    local section = self:createSection("Notification Types", 0.35)
    
    -- Add type toggles
    local types = {
        {name = "Streak Warnings", key = "STREAK_WARNING"},
        {name = "Event Alerts", key = "EVENT_ALERT"},
        {name = "VIP Bonuses", key = "VIP_BONUS"},
        {name = "Drop Rate Boosts", key = "DROP_RATE_BOOST"}
    }
    
    for i, typeInfo in ipairs(types) do
        self:createToggle(
            section,
            typeInfo.name,
            "TYPES." .. typeInfo.key,
            (i - 1) * 0.1
        )
    end
end

function NotificationSettingsUI:createQuietHours()
    -- Create quiet hours section
    local section = self:createSection("Quiet Hours", 0.65)
    
    -- Add start time slider
    self:createTimeSlider(
        section,
        "Start Time",
        "QUIET_HOURS.START",
        0
    )
    
    -- Add end time slider
    self:createTimeSlider(
        section,
        "End Time",
        "QUIET_HOURS.END",
        0.15
    )
end

function NotificationSettingsUI:createSection(title, yPosition)
    -- Create section container
    local section = Instance.new("Frame")
    section.Name = title:gsub(" ", "") .. "Section"
    section.Size = UDim2.new(0.9, 0, 0.2, 0)
    section.Position = UDim2.new(0.05, 0, yPosition, 0)
    section.BackgroundColor3 = UI_CONFIG.COLORS.SECTION
    section.BackgroundTransparency = 0.5
    section.Parent = self.window
    
    -- Add section title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = UI_CONFIG.COLORS.TEXT
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = section
    
    return section
end

function NotificationSettingsUI:createToggle(parent, label, settingPath, yOffset)
    -- Create toggle container
    local container = Instance.new("Frame")
    container.Name = label:gsub(" ", "") .. "Toggle"
    container.Size = UDim2.new(0.9, 0, 0.2, 0)
    container.Position = UDim2.new(0.05, 0, 0.3 + yOffset, 0)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    -- Add label
    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = UI_CONFIG.COLORS.TEXT
    labelText.TextScaled = true
    labelText.Font = Enum.Font.GothamMedium
    labelText.Parent = container
    
    -- Add toggle button
    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = UI_CONFIG.TOGGLE_SIZE
    toggle.Position = UDim2.new(0.8, 0, 0.5, 0)
    toggle.AnchorPoint = Vector2.new(0, 0.5)
    toggle.BackgroundColor3 = UI_CONFIG.COLORS.TOGGLE_OFF
    toggle.Text = ""
    toggle.Parent = container
    
    -- Get initial state
    local value = self:getSettingValue(settingPath)
    if value then
        toggle.BackgroundColor3 = UI_CONFIG.COLORS.TOGGLE_ON
    end
    
    -- Add toggle handler
    toggle.MouseButton1Click:Connect(function()
        local newValue = not self:getSettingValue(settingPath)
        self:setSettingValue(settingPath, newValue)
        
        -- Animate toggle
        TweenService:Create(toggle, TweenInfo.new(
            UI_CONFIG.ANIMATIONS.TOGGLE.TIME,
            UI_CONFIG.ANIMATIONS.TOGGLE.EASING,
            UI_CONFIG.ANIMATIONS.TOGGLE.DIRECTION
        ), {
            BackgroundColor3 = newValue and UI_CONFIG.COLORS.TOGGLE_ON or UI_CONFIG.COLORS.TOGGLE_OFF
        }):Play()
    end)
end

function NotificationSettingsUI:createTimeSlider(parent, label, settingPath, yOffset)
    -- Create slider container
    local container = Instance.new("Frame")
    container.Name = label:gsub(" ", "") .. "Slider"
    container.Size = UDim2.new(0.9, 0, 0.2, 0)
    container.Position = UDim2.new(0.05, 0, 0.3 + yOffset, 0)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    -- Add label
    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Size = UDim2.new(0.4, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = UI_CONFIG.COLORS.TEXT
    labelText.TextScaled = true
    labelText.Font = Enum.Font.GothamMedium
    labelText.Parent = container
    
    -- Add time display
    local timeDisplay = Instance.new("TextLabel")
    timeDisplay.Name = "TimeDisplay"
    timeDisplay.Size = UDim2.new(0.2, 0, 1, 0)
    timeDisplay.Position = UDim2.new(0.75, 0, 0, 0)
    timeDisplay.BackgroundTransparency = 1
    timeDisplay.TextColor3 = UI_CONFIG.COLORS.TEXT
    timeDisplay.TextScaled = true
    timeDisplay.Font = Enum.Font.GothamMedium
    timeDisplay.Parent = container
    
    -- Add slider
    local slider = Instance.new("TextButton")
    slider.Name = "Slider"
    slider.Size = UDim2.new(0.3, 0, 0.3, 0)
    slider.Position = UDim2.new(0.4, 0, 0.5, 0)
    slider.AnchorPoint = Vector2.new(0, 0.5)
    slider.BackgroundColor3 = UI_CONFIG.COLORS.SECTION
    slider.Text = ""
    slider.Parent = container
    
    -- Get initial value
    local value = self:getSettingValue(settingPath)
    self:updateTimeDisplay(timeDisplay, value)
    
    -- Add slider handler
    local dragging = false
    
    slider.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    slider.MouseMoved:Connect(function(x)
        if dragging then
            local relativeX = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local hour = math.floor(relativeX * 24)
            
            self:setSettingValue(settingPath, hour)
            self:updateTimeDisplay(timeDisplay, hour)
        end
    end)
end

function NotificationSettingsUI:updateTimeDisplay(display, hour)
    local period = hour < 12 and "AM" or "PM"
    local displayHour = hour % 12
    if displayHour == 0 then displayHour = 12 end
    
    display.Text = string.format("%d %s", displayHour, period)
end

function NotificationSettingsUI:getSettingValue(path)
    local value = self.notificationSystem.settings
    for key in path:gmatch("[^%.]+") do
        if type(value) ~= "table" then return nil end
        value = value[key]
    end
    return value
end

function NotificationSettingsUI:setSettingValue(path, newValue)
    local current = self.notificationSystem.settings
    local keys = {}
    
    -- Split path into keys
    for key in path:gmatch("[^%.]+") do
        table.insert(keys, key)
    end
    
    -- Navigate to the parent table
    for i = 1, #keys - 1 do
        if type(current[keys[i]]) ~= "table" then
            current[keys[i]] = {}
        end
        current = current[keys[i]]
    end
    
    -- Set the value
    current[keys[#keys]] = newValue
    
    -- Save settings
    self.notificationSystem:saveSettings()
end

function NotificationSettingsUI:show()
    self.window.Visible = true
    
    -- Animate window opening
    self.window.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(self.window, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.POPUP.TIME,
        UI_CONFIG.ANIMATIONS.POPUP.EASING,
        UI_CONFIG.ANIMATIONS.POPUP.DIRECTION
    ), {
        Size = UI_CONFIG.WINDOW_SIZE
    }):Play()
end

function NotificationSettingsUI:hide()
    -- Animate window closing
    local closeTween = TweenService:Create(self.window, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.POPUP.TIME,
        UI_CONFIG.ANIMATIONS.POPUP.EASING,
        UI_CONFIG.ANIMATIONS.POPUP.DIRECTION
    ), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    
    closeTween:Play()
    
    -- Hide window after animation
    closeTween.Completed:Connect(function()
        self.window.Visible = false
    end)
end

function NotificationSettingsUI:destroy()
    self.window:Destroy()
end

return NotificationSettingsUI 