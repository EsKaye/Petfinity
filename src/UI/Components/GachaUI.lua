--[[
    GachaUI.lua
    UI component for gacha system interface
    
    Author: Cursor AI
    Created: 2024-03-03
    Version: 0.1.1
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import EffectsSystem
local EffectsSystem = require(game.ReplicatedStorage.Systems.EffectsSystem)

local GachaUI = {}
GachaUI.__index = GachaUI

-- Animation configurations
local ANIMATIONS = {
    ROLL = {
        TIME = 1.5,
        EASING = Enum.EasingStyle.Cubic,
        DIRECTION = Enum.EasingDirection.Out
    },
    REVEAL = {
        TIME = 0.5,
        EASING = Enum.EasingStyle.Back,
        DIRECTION = Enum.EasingDirection.Out
    }
}

-- Rarity colors for visual feedback
local RARITY_COLORS = {
    COMMON = Color3.fromRGB(200, 200, 200),
    UNCOMMON = Color3.fromRGB(100, 255, 100),
    RARE = Color3.fromRGB(100, 100, 255),
    EPIC = Color3.fromRGB(200, 100, 255),
    LEGENDARY = Color3.fromRGB(255, 215, 0)
}

function GachaUI.new(parent)
    local self = setmetatable({}, GachaUI)
    
    -- Create main UI container
    self.container = Instance.new("Frame")
    self.container.Name = "GachaUI"
    self.container.Size = UDim2.new(1, 0, 1, 0)
    self.container.BackgroundTransparency = 1
    self.container.Parent = parent
    
    -- Create roll button
    self.rollButton = Instance.new("TextButton")
    self.rollButton.Name = "RollButton"
    self.rollButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    self.rollButton.Position = UDim2.new(0.4, 0, 0.8, 0)
    self.rollButton.Text = "Roll!"
    self.rollButton.Parent = self.container
    
    -- Create result display
    self.resultDisplay = Instance.new("Frame")
    self.resultDisplay.Name = "ResultDisplay"
    self.resultDisplay.Size = UDim2.new(0.8, 0, 0.6, 0)
    self.resultDisplay.Position = UDim2.new(0.1, 0, 0.1, 0)
    self.resultDisplay.BackgroundTransparency = 0.1
    self.resultDisplay.Visible = false
    self.resultDisplay.Parent = self.container
    
    -- Initialize effects system
    self.effectsSystem = EffectsSystem.new(self.container)
    
    -- Add anticipation sound
    self.anticipationSound = Instance.new("Sound")
    self.anticipationSound.SoundId = "rbxasset://sounds/swoosh.mp3"
    self.anticipationSound.Volume = 0.5
    self.anticipationSound.Parent = self.container
    
    return self
end

-- Start roll animation sequence
function GachaUI:playRollAnimation()
    self.resultDisplay.Visible = true
    
    -- Play anticipation sound
    self.anticipationSound:Play()
    
    -- Create spinning animation
    local spinTween = TweenService:Create(
        self.resultDisplay,
        TweenInfo.new(
            ANIMATIONS.ROLL.TIME,
            ANIMATIONS.ROLL.EASING,
            ANIMATIONS.ROLL.DIRECTION
        ),
        {Rotation = 360 * 3} -- Spin 3 times
    )
    
    spinTween:Play()
    return spinTween.Completed
end

-- Display roll result with appropriate visual effects
function GachaUI:displayResult(result)
    -- Create reveal animation
    local revealTween = TweenService:Create(
        self.resultDisplay,
        TweenInfo.new(
            ANIMATIONS.REVEAL.TIME,
            ANIMATIONS.REVEAL.EASING,
            ANIMATIONS.REVEAL.DIRECTION
        ),
        {
            BackgroundColor3 = RARITY_COLORS[result.rarity],
            Size = UDim2.new(0.9, 0, 0.7, 0),
            Position = UDim2.new(0.05, 0, 0.15, 0)
        }
    )
    
    revealTween:Play()
    
    -- Play rarity-specific effects
    self.effectsSystem:playEffects(
        result.rarity,
        self.resultDisplay.AbsolutePosition + self.resultDisplay.AbsoluteSize/2
    )
    
    -- Add pop effect for the result display
    local popScale = TweenService:Create(
        self.resultDisplay,
        TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(1.1, 0, 0.8, 0),
            Position = UDim2.new(-0.05, 0, 0.1, 0)
        }
    )
    
    local returnScale = TweenService:Create(
        self.resultDisplay,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0.9, 0, 0.7, 0),
            Position = UDim2.new(0.05, 0, 0.15, 0)
        }
    )
    
    popScale:Play()
    popScale.Completed:Connect(function()
        returnScale:Play()
    end)
end

-- Clean up UI elements
function GachaUI:destroy()
    self.effectsSystem:destroy()
    self.container:Destroy()
end

return GachaUI 