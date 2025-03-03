--[[
    SeasonalEventUI.lua
    UI component for displaying seasonal events, exclusive pets, and limited-time rewards
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import required systems
local EffectsSystem = require(game.ReplicatedStorage.Systems.EffectsSystem)

local SeasonalEventUI = {}
SeasonalEventUI.__index = SeasonalEventUI

-- UI Configuration
local UI_CONFIG = {
    WINDOW_SIZE = UDim2.new(0.8, 0, 0.8, 0),
    CARD_SIZE = UDim2.new(0.3, 0, 0.4, 0),
    COLORS = {
        BACKGROUND = Color3.fromRGB(30, 30, 35),
        TEXT = Color3.fromRGB(240, 240, 240),
        LEGENDARY = Color3.fromRGB(255, 215, 0),
        EPIC = Color3.fromRGB(200, 100, 255),
        RARE = Color3.fromRGB(100, 150, 255),
        COMMON = Color3.fromRGB(150, 150, 150),
        VIP = Color3.fromRGB(255, 150, 200)
    },
    ANIMATIONS = {
        POPUP = {
            TIME = 0.3,
            EASING = Enum.EasingStyle.Back,
            DIRECTION = Enum.EasingDirection.Out
        },
        HOVER = {
            TIME = 0.2,
            EASING = Enum.EasingStyle.Quad,
            DIRECTION = Enum.EasingDirection.Out
        },
        SPIN = {
            TIME = 2,
            EASING = Enum.EasingStyle.Linear,
            DIRECTION = Enum.EasingDirection.InOut
        }
    }
}

function SeasonalEventUI.new(parent, seasonalEventSystem)
    local self = setmetatable({}, SeasonalEventUI)
    
    -- Store references
    self.parent = parent
    self.seasonalEventSystem = seasonalEventSystem
    self.effectsSystem = EffectsSystem.new()
    
    -- Create main window
    self:createWindow()
    
    -- Create event display
    self:createEventDisplay()
    
    -- Create egg display
    self:createEggDisplay()
    
    -- Create item shop
    self:createItemShop()
    
    -- Hide window initially
    self.window.Visible = false
    
    return self
end

function SeasonalEventUI:createWindow()
    -- Create background frame
    self.window = Instance.new("Frame")
    self.window.Name = "SeasonalEventWindow"
    self.window.Size = UI_CONFIG.WINDOW_SIZE
    self.window.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.window.AnchorPoint = Vector2.new(0.5, 0.5)
    self.window.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
    self.window.BackgroundTransparency = 0.1
    self.window.Parent = self.parent
    
    -- Add title
    self.title = Instance.new("TextLabel")
    self.title.Name = "Title"
    self.title.Size = UDim2.new(1, 0, 0.1, 0)
    self.title.Position = UDim2.new(0, 0, 0, 0)
    self.title.BackgroundTransparency = 1
    self.title.Text = "Seasonal Event"
    self.title.TextColor3 = UI_CONFIG.COLORS.TEXT
    self.title.TextScaled = true
    self.title.Font = Enum.Font.GothamBold
    self.title.Parent = self.window
    
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

function SeasonalEventUI:createEventDisplay()
    -- Create event info container
    local eventInfo = Instance.new("Frame")
    eventInfo.Name = "EventInfo"
    eventInfo.Size = UDim2.new(1, 0, 0.2, 0)
    eventInfo.Position = UDim2.new(0, 0, 0.1, 0)
    eventInfo.BackgroundTransparency = 1
    eventInfo.Parent = self.window
    
    -- Add event name
    self.eventName = Instance.new("TextLabel")
    self.eventName.Name = "EventName"
    self.eventName.Size = UDim2.new(0.7, 0, 0.4, 0)
    self.eventName.Position = UDim2.new(0.15, 0, 0.1, 0)
    self.eventName.BackgroundTransparency = 1
    self.eventName.TextColor3 = UI_CONFIG.COLORS.LEGENDARY
    self.eventName.TextScaled = true
    self.eventName.Font = Enum.Font.GothamBold
    self.eventName.Parent = eventInfo
    
    -- Add time remaining
    self.timeRemaining = Instance.new("TextLabel")
    self.timeRemaining.Name = "TimeRemaining"
    self.timeRemaining.Size = UDim2.new(0.7, 0, 0.4, 0)
    self.timeRemaining.Position = UDim2.new(0.15, 0, 0.5, 0)
    self.timeRemaining.BackgroundTransparency = 1
    self.timeRemaining.TextColor3 = UI_CONFIG.COLORS.TEXT
    self.timeRemaining.TextScaled = true
    self.timeRemaining.Font = Enum.Font.GothamMedium
    self.timeRemaining.Parent = eventInfo
    
    -- Start timer update
    game:GetService("RunService").Heartbeat:Connect(function()
        if self.window.Visible then
            self:updateTimeDisplay()
        end
    end)
end

function SeasonalEventUI:createEggDisplay()
    -- Create egg container
    local eggContainer = Instance.new("Frame")
    eggContainer.Name = "EggContainer"
    eggContainer.Size = UDim2.new(1, 0, 0.4, 0)
    eggContainer.Position = UDim2.new(0, 0, 0.3, 0)
    eggContainer.BackgroundTransparency = 1
    eggContainer.Parent = self.window
    
    -- Create egg cards
    self.eggCards = {}
    local eggs = self.seasonalEventSystem:getEventEggs()
    
    for i, eggData in ipairs(eggs) do
        local card = self:createEggCard(eggData)
        card.Position = UDim2.new(0.1 + (i-1) * 0.4, 0, 0, 0)
        card.Parent = eggContainer
        self.eggCards[eggData.ID] = card
    end
end

function SeasonalEventUI:createEggCard(eggData)
    -- Create card container
    local card = Instance.new("Frame")
    card.Name = eggData.ID .. "Card"
    card.Size = UI_CONFIG.CARD_SIZE
    card.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
    card.BackgroundTransparency = 0.5
    
    -- Add egg image
    local image = Instance.new("ImageLabel")
    image.Name = "EggImage"
    image.Size = UDim2.new(0.8, 0, 0.6, 0)
    image.Position = UDim2.new(0.1, 0, 0.1, 0)
    image.BackgroundTransparency = 1
    image.Image = "rbxassetid://" .. eggData.ID -- Replace with actual asset ID
    image.Parent = card
    
    -- Add name label
    local name = Instance.new("TextLabel")
    name.Name = "EggName"
    name.Size = UDim2.new(0.8, 0, 0.15, 0)
    name.Position = UDim2.new(0.1, 0, 0.75, 0)
    name.BackgroundTransparency = 1
    name.Text = eggData.NAME
    name.TextColor3 = UI_CONFIG.COLORS.LEGENDARY
    name.TextScaled = true
    name.Font = Enum.Font.GothamBold
    name.Parent = card
    
    -- Add price button
    local priceButton = Instance.new("TextButton")
    priceButton.Name = "PriceButton"
    priceButton.Size = UDim2.new(0.6, 0, 0.15, 0)
    priceButton.Position = UDim2.new(0.2, 0, 0.9, 0)
    priceButton.BackgroundColor3 = UI_CONFIG.COLORS.LEGENDARY
    priceButton.Text = eggData.PRICE .. " R$"
    priceButton.TextColor3 = UI_CONFIG.COLORS.TEXT
    priceButton.TextScaled = true
    priceButton.Font = Enum.Font.GothamBold
    priceButton.Parent = card
    
    -- Add hover effects
    card.MouseEnter:Connect(function()
        self:playCardHoverAnimation(card, true)
    end)
    
    card.MouseLeave:Connect(function()
        self:playCardHoverAnimation(card, false)
    end)
    
    -- Add purchase handler
    priceButton.MouseButton1Click:Connect(function()
        self:handleEggPurchase(eggData)
    end)
    
    return card
end

function SeasonalEventUI:createItemShop()
    -- Create shop container
    local shopContainer = Instance.new("Frame")
    shopContainer.Name = "ItemShop"
    shopContainer.Size = UDim2.new(1, 0, 0.3, 0)
    shopContainer.Position = UDim2.new(0, 0, 0.7, 0)
    shopContainer.BackgroundTransparency = 1
    shopContainer.Parent = self.window
    
    -- Create item cards
    self.itemCards = {}
    local items = self.seasonalEventSystem:getEventItems()
    
    for i, itemData in ipairs(items) do
        local card = self:createItemCard(itemData)
        card.Position = UDim2.new(0.1 + (i-1) * 0.3, 0, 0, 0)
        card.Parent = shopContainer
        self.itemCards[itemData.ID] = card
    end
end

function SeasonalEventUI:createItemCard(itemData)
    -- Create card container
    local card = Instance.new("Frame")
    card.Name = itemData.ID .. "Card"
    card.Size = UDim2.new(0.25, 0, 0.8, 0)
    card.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
    card.BackgroundTransparency = 0.5
    
    -- Add item image
    local image = Instance.new("ImageLabel")
    image.Name = "ItemImage"
    image.Size = UDim2.new(0.6, 0, 0.6, 0)
    image.Position = UDim2.new(0.2, 0, 0.1, 0)
    image.BackgroundTransparency = 1
    image.Image = "rbxassetid://" .. itemData.ID -- Replace with actual asset ID
    image.Parent = card
    
    -- Add name label
    local name = Instance.new("TextLabel")
    name.Name = "ItemName"
    name.Size = UDim2.new(0.8, 0, 0.2, 0)
    name.Position = UDim2.new(0.1, 0, 0.75, 0)
    name.BackgroundTransparency = 1
    name.Text = itemData.NAME
    name.TextColor3 = UI_CONFIG.COLORS.TEXT
    name.TextScaled = true
    name.Font = Enum.Font.GothamMedium
    name.Parent = card
    
    -- Add hover effects
    card.MouseEnter:Connect(function()
        self:playCardHoverAnimation(card, true)
    end)
    
    card.MouseLeave:Connect(function()
        self:playCardHoverAnimation(card, false)
    end)
    
    -- Add click handler
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:handleItemUse(itemData)
        end
    end)
    
    return card
end

function SeasonalEventUI:playCardHoverAnimation(card, isHovering)
    local targetSize = isHovering and
        card.Size * UDim2.new(1.1, 1.1, 1.1, 1.1) or
        card.Size * UDim2.new(1/1.1, 1/1.1, 1/1.1, 1/1.1)
    
    TweenService:Create(card, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.HOVER.TIME,
        UI_CONFIG.ANIMATIONS.HOVER.EASING,
        UI_CONFIG.ANIMATIONS.HOVER.DIRECTION
    ), {
        Size = targetSize
    }):Play()
end

function SeasonalEventUI:handleEggPurchase(eggData)
    -- TODO: Implement purchase logic
    print("Purchasing egg:", eggData.NAME)
end

function SeasonalEventUI:handleItemUse(itemData)
    -- TODO: Implement item use logic
    print("Using item:", itemData.NAME)
end

function SeasonalEventUI:updateTimeDisplay()
    local timeLeft = self.seasonalEventSystem:getTimeUntilNextEvent()
    
    if timeLeft > 0 then
        local days = math.floor(timeLeft / 86400)
        local hours = math.floor((timeLeft % 86400) / 3600)
        local minutes = math.floor((timeLeft % 3600) / 60)
        
        self.timeRemaining.Text = string.format(
            "Time Remaining: %d days, %d hours, %d minutes",
            days, hours, minutes
        )
    else
        self.timeRemaining.Text = "Event Ended"
    end
end

function SeasonalEventUI:show()
    -- Update event info
    local currentEvent = self.seasonalEventSystem.currentEvent
    if currentEvent then
        self.eventName.Text = self.seasonalEventSystem.eventData.NAME
        self:updateTimeDisplay()
    end
    
    -- Show window
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

function SeasonalEventUI:hide()
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

function SeasonalEventUI:destroy()
    self.window:Destroy()
    self.effectsSystem:destroy()
end

return SeasonalEventUI 