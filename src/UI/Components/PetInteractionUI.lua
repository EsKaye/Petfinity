--[[
    PetInteractionUI.lua
    UI component for pet interaction controls and mood display
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetInteractionUI = {}
PetInteractionUI.__index = PetInteractionUI

-- Button configurations
local BUTTON_CONFIG = {
    SIZE = UDim2.new(0.15, 0, 0.15, 0),
    SPACING = 0.05,
    ICONS = {
        PET = "rbxassetid://heart_icon",
        FEED = "rbxassetid://food_icon",
        PLAY = "rbxassetid://play_icon"
    }
}

-- Mood indicator configurations
local MOOD_STYLES = {
    HAPPY = {
        Icon = "rbxassetid://happy_face",
        Color = Color3.fromRGB(255, 150, 200),
        Text = "Happy!"
    },
    NEUTRAL = {
        Icon = "rbxassetid://neutral_face",
        Color = Color3.fromRGB(200, 200, 200),
        Text = "Content"
    },
    SAD = {
        Icon = "rbxassetid://sad_face",
        Color = Color3.fromRGB(150, 150, 255),
        Text = "Needs Love"
    }
}

function PetInteractionUI.new(parent, petInteractionSystem)
    local self = setmetatable({}, PetInteractionUI)
    
    -- Store reference to interaction system
    self.petInteractionSystem = petInteractionSystem
    
    -- Create main container
    self.container = Instance.new("Frame")
    self.container.Name = "PetInteractionUI"
    self.container.Size = UDim2.new(1, 0, 0.2, 0)
    self.container.Position = UDim2.new(0, 0, 0.8, 0)
    self.container.BackgroundTransparency = 0.3
    self.container.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    self.container.Parent = parent
    
    -- Create interaction buttons
    self:createInteractionButtons()
    
    -- Create mood indicator
    self:createMoodIndicator()
    
    -- Set up animations
    self:setupAnimations()
    
    return self
end

function PetInteractionUI:createInteractionButtons()
    local buttonSpacing = BUTTON_CONFIG.SPACING
    local totalWidth = BUTTON_CONFIG.SIZE.X.Scale * 3 + buttonSpacing * 2
    local startX = (1 - totalWidth) / 2
    
    -- Create pet button
    self.petButton = self:createButton(
        "PetButton",
        UDim2.new(startX, 0, 0.1, 0),
        BUTTON_CONFIG.ICONS.PET,
        function() self:handlePetButton() end
    )
    
    -- Create feed button
    self.feedButton = self:createButton(
        "FeedButton",
        UDim2.new(startX + BUTTON_CONFIG.SIZE.X.Scale + buttonSpacing, 0, 0.1, 0),
        BUTTON_CONFIG.ICONS.FEED,
        function() self:handleFeedButton() end
    )
    
    -- Create play button
    self.playButton = self:createButton(
        "PlayButton",
        UDim2.new(startX + (BUTTON_CONFIG.SIZE.X.Scale + buttonSpacing) * 2, 0, 0.1, 0),
        BUTTON_CONFIG.ICONS.PLAY,
        function() self:handlePlayButton() end
    )
end

function PetInteractionUI:createButton(name, position, icon, callback)
    local button = Instance.new("ImageButton")
    button.Name = name
    button.Size = BUTTON_CONFIG.SIZE
    button.Position = position
    button.Image = icon
    button.BackgroundTransparency = 0.5
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    
    -- Add hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(80, 80, 85),
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 65),
            ImageColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
    end)
    
    -- Add click handler
    button.MouseButton1Click:Connect(callback)
    
    button.Parent = self.container
    return button
end

function PetInteractionUI:createMoodIndicator()
    -- Create mood container
    self.moodContainer = Instance.new("Frame")
    self.moodContainer.Name = "MoodIndicator"
    self.moodContainer.Size = UDim2.new(0.3, 0, 0.4, 0)
    self.moodContainer.Position = UDim2.new(0.35, 0, 0.5, 0)
    self.moodContainer.BackgroundTransparency = 0.7
    self.moodContainer.Parent = self.container
    
    -- Create mood icon
    self.moodIcon = Instance.new("ImageLabel")
    self.moodIcon.Name = "MoodIcon"
    self.moodIcon.Size = UDim2.new(0.4, 0, 0.8, 0)
    self.moodIcon.Position = UDim2.new(0.05, 0, 0.1, 0)
    self.moodIcon.BackgroundTransparency = 1
    self.moodIcon.Parent = self.moodContainer
    
    -- Create mood text
    self.moodText = Instance.new("TextLabel")
    self.moodText.Name = "MoodText"
    self.moodText.Size = UDim2.new(0.5, 0, 0.8, 0)
    self.moodText.Position = UDim2.new(0.45, 0, 0.1, 0)
    self.moodText.BackgroundTransparency = 1
    self.moodText.TextColor3 = Color3.new(1, 1, 1)
    self.moodText.TextScaled = true
    self.moodText.Parent = self.moodContainer
    
    -- Update initial mood display
    self:updateMoodDisplay("HAPPY")
end

function PetInteractionUI:updateMoodDisplay(mood)
    local style = MOOD_STYLES[mood]
    if not style then return end
    
    -- Update mood indicator
    self.moodIcon.Image = style.Icon
    self.moodText.Text = style.Text
    
    -- Animate color change
    TweenService:Create(self.moodContainer, TweenInfo.new(0.3), {
        BackgroundColor3 = style.Color
    }):Play()
end

function PetInteractionUI:setupAnimations()
    -- Add bounce effect to buttons on click
    local function addButtonBounce(button)
        button.MouseButton1Down:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = BUTTON_CONFIG.SIZE * UDim2.new(0.9, 0.9, 0.9, 0.9)
            }):Play()
        end)
        
        button.MouseButton1Up:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = BUTTON_CONFIG.SIZE
            }):Play()
        end)
    end
    
    addButtonBounce(self.petButton)
    addButtonBounce(self.feedButton)
    addButtonBounce(self.playButton)
end

function PetInteractionUI:handlePetButton()
    self.petInteractionSystem:handlePetting()
    local happiness, mood = self.petInteractionSystem:updateHappiness(10)
    self:updateMoodDisplay(mood)
end

function PetInteractionUI:handleFeedButton()
    self.petInteractionSystem:handleFeeding()
    local happiness, mood = self.petInteractionSystem:updateHappiness(15)
    self:updateMoodDisplay(mood)
end

function PetInteractionUI:handlePlayButton()
    self.petInteractionSystem:handlePlaying()
    local happiness, mood = self.petInteractionSystem:updateHappiness(20)
    self:updateMoodDisplay(mood)
end

function PetInteractionUI:destroy()
    self.container:Destroy()
end

return PetInteractionUI 