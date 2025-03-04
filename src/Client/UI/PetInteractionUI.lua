--[[
    PetInteractionUI.lua
    Handles pet interaction buttons, mood display, and special effects
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 1.0.0
--]]

local PetInteractionUI = {}
PetInteractionUI.__index = PetInteractionUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local BUTTON_SIZE = UDim2.new(0, 60, 0, 60)
local MOOD_INDICATOR_SIZE = UDim2.new(0, 100, 0, 40)
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- UI Colors
local COLORS = {
    BACKGROUND = Color3.fromRGB(45, 45, 45),
    BUTTON = Color3.fromRGB(65, 65, 65),
    BUTTON_HOVER = Color3.fromRGB(85, 85, 85),
    TEXT = Color3.fromRGB(255, 255, 255),
    MOOD = {
        HAPPY = Color3.fromRGB(76, 209, 55),
        NEUTRAL = Color3.fromRGB(251, 200, 11),
        SAD = Color3.fromRGB(255, 89, 89)
    },
    RARITY = {
        COMMON = Color3.fromRGB(255, 255, 255),
        RARE = Color3.fromRGB(147, 112, 219),
        LEGENDARY = Color3.fromRGB(255, 215, 0)
    }
}

function PetInteractionUI.new(pet)
    local self = setmetatable({}, PetInteractionUI)
    
    -- Store references
    self.pet = pet
    self.player = Players.LocalPlayer
    
    -- Create UI elements
    self:createMainContainer()
    self:createButtons()
    self:createMoodIndicator()
    
    -- Add special effects for rare pets
    if pet.rarity ~= "COMMON" then
        self:addRarityEffects()
    end
    
    -- Connect events
    self:connectEvents()
    
    return self
end

function PetInteractionUI:createMainContainer()
    -- Create the main frame
    self.container = Instance.new("Frame")
    self.container.Name = "PetInteractionUI"
    self.container.Size = UDim2.new(0, 200, 0, 300)
    self.container.Position = UDim2.new(0.5, -100, 0.5, -150)
    self.container.BackgroundTransparency = 1
    self.container.Parent = self.player.PlayerGui:WaitForChild("MainUI")
    
    -- Add UI constraints for proper scaling
    local uiAspect = Instance.new("UIAspectRatioConstraint")
    uiAspect.AspectRatio = 0.667
    uiAspect.Parent = self.container
    
    local uiScale = Instance.new("UIScale")
    uiScale.Scale = 1
    uiScale.Parent = self.container
end

function PetInteractionUI:createButtons()
    -- Create button container
    self.buttonContainer = Instance.new("Frame")
    self.buttonContainer.Name = "ButtonContainer"
    self.buttonContainer.Size = UDim2.new(1, 0, 0.5, 0)
    self.buttonContainer.Position = UDim2.new(0, 0, 0.5, 0)
    self.buttonContainer.BackgroundTransparency = 1
    self.buttonContainer.Parent = self.container
    
    -- Create interaction buttons
    local buttonConfig = {
        {name = "Pet", icon = "rbxassetid://pet_icon"},
        {name = "Feed", icon = "rbxassetid://feed_icon"},
        {name = "Play", icon = "rbxassetid://play_icon"}
    }
    
    for i, config in ipairs(buttonConfig) do
        local button = self:createButton(config.name, config.icon, i)
        button.Parent = self.buttonContainer
    end
end

function PetInteractionUI:createButton(name, icon, position)
    -- Create button frame
    local button = Instance.new("ImageButton")
    button.Name = name .. "Button"
    button.Size = BUTTON_SIZE
    button.Position = UDim2.new((position - 1) * 0.33 + 0.17, -30, 0.5, -30)
    button.BackgroundColor3 = COLORS.BUTTON
    button.Image = icon
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = button
    
    -- Add hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TWEEN_INFO, {
            BackgroundColor3 = COLORS.BUTTON_HOVER,
            Size = BUTTON_SIZE + UDim2.new(0, 4, 0, 4)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TWEEN_INFO, {
            BackgroundColor3 = COLORS.BUTTON,
            Size = BUTTON_SIZE
        }):Play()
    end)
    
    return button
end

function PetInteractionUI:createMoodIndicator()
    -- Create mood container
    self.moodContainer = Instance.new("Frame")
    self.moodContainer.Name = "MoodContainer"
    self.moodContainer.Size = MOOD_INDICATOR_SIZE
    self.moodContainer.Position = UDim2.new(0.5, -50, 0.1, 0)
    self.moodContainer.BackgroundColor3 = COLORS.BACKGROUND
    self.moodContainer.Parent = self.container
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = self.moodContainer
    
    -- Create mood text
    self.moodText = Instance.new("TextLabel")
    self.moodText.Size = UDim2.new(1, 0, 1, 0)
    self.moodText.BackgroundTransparency = 1
    self.moodText.Font = Enum.Font.GothamBold
    self.moodText.TextColor3 = COLORS.TEXT
    self.moodText.TextSize = 18
    self.moodText.Parent = self.moodContainer
    
    -- Update initial mood
    self:updateMoodDisplay()
end

function PetInteractionUI:addRarityEffects()
    -- Add glowing border
    local glow = Instance.new("UIGradient")
    glow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.RARITY[self.pet.rarity]),
        ColorSequenceKeypoint.new(0.5, COLORS.RARITY[self.pet.rarity]:Lerp(Color3.new(1, 1, 1), 0.5)),
        ColorSequenceKeypoint.new(1, COLORS.RARITY[self.pet.rarity])
    })
    glow.Parent = self.container
    
    -- Animate glow rotation
    spawn(function()
        local rotation = 0
        while self.container.Parent do
            rotation = (rotation + 1) % 360
            glow.Rotation = rotation
            wait(0.03)
        end
    end)
    
    -- Add sparkle effects
    if self.pet.rarity == "LEGENDARY" then
        self:addSparkleEffects()
    end
end

function PetInteractionUI:addSparkleEffects()
    spawn(function()
        while self.container.Parent do
            -- Create sparkle
            local sparkle = Instance.new("Frame")
            sparkle.Size = UDim2.new(0, 4, 0, 4)
            sparkle.BackgroundColor3 = COLORS.RARITY.LEGENDARY
            sparkle.Position = UDim2.new(math.random(), 0, math.random(), 0)
            sparkle.Parent = self.container
            
            -- Add corner rounding
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = sparkle
            
            -- Animate sparkle
            local fadeOut = TweenService:Create(sparkle, TweenInfo.new(1), {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 8, 0, 8)
            })
            
            fadeOut.Completed:Connect(function()
                sparkle:Destroy()
            end)
            
            fadeOut:Play()
            wait(0.2)
        end
    end)
end

function PetInteractionUI:updateMoodDisplay()
    local mood = self.pet:getMood()
    local moodColor = COLORS.MOOD[mood.state]
    
    -- Update mood text
    self.moodText.Text = mood.state
    
    -- Animate color change
    TweenService:Create(self.moodContainer, TWEEN_INFO, {
        BackgroundColor3 = moodColor
    }):Play()
end

function PetInteractionUI:connectEvents()
    -- Connect button clicks
    self.buttonContainer.PetButton.MouseButton1Click:Connect(function()
        self:handleInteraction("PET")
    end)
    
    self.buttonContainer.FeedButton.MouseButton1Click:Connect(function()
        self:handleInteraction("FEED")
    end)
    
    self.buttonContainer.PlayButton.MouseButton1Click:Connect(function()
        self:handleInteraction("PLAY")
    end)
    
    -- Connect to pet mood changes
    self.pet.MoodChanged:Connect(function()
        self:updateMoodDisplay()
    end)
end

function PetInteractionUI:handleInteraction(interactionType)
    -- Animate button press
    local button = self.buttonContainer[interactionType .. "Button"]
    local originalSize = button.Size
    
    TweenService:Create(button, TweenInfo.new(0.1), {
        Size = originalSize - UDim2.new(0, 4, 0, 4)
    }):Play()
    
    wait(0.1)
    
    TweenService:Create(button, TweenInfo.new(0.1), {
        Size = originalSize
    }):Play()
    
    -- Send interaction to server
    ReplicatedStorage.Remotes.PetInteraction:FireServer(self.pet, interactionType)
end

function PetInteractionUI:destroy()
    -- Clean up
    if self.container then
        self.container:Destroy()
    end
end

return PetInteractionUI 