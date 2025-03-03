--[[
    PetCard.lua
    UI component for displaying individual pets in the inventory
    
    Author: Cursor AI
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetCard = {}
PetCard.__index = PetCard

-- Animation configurations
local ANIMATIONS = {
    POP_IN = {
        TIME = 0.3,
        EASING = Enum.EasingStyle.Back,
        DIRECTION = Enum.EasingDirection.Out
    },
    HOVER = {
        TIME = 0.2,
        EASING = Enum.EasingStyle.Quad,
        DIRECTION = Enum.EasingDirection.Out
    },
    SELECT = {
        TIME = 0.15,
        EASING = Enum.EasingStyle.Bounce,
        DIRECTION = Enum.EasingDirection.Out
    }
}

-- Rarity-based visual configurations
local RARITY_STYLES = {
    COMMON = {
        BorderColor = Color3.fromRGB(200, 200, 200),
        GlowIntensity = 0,
        GlowColor = Color3.fromRGB(255, 255, 255)
    },
    UNCOMMON = {
        BorderColor = Color3.fromRGB(100, 255, 100),
        GlowIntensity = 0.2,
        GlowColor = Color3.fromRGB(150, 255, 150)
    },
    RARE = {
        BorderColor = Color3.fromRGB(100, 100, 255),
        GlowIntensity = 0.4,
        GlowColor = Color3.fromRGB(150, 150, 255)
    },
    EPIC = {
        BorderColor = Color3.fromRGB(200, 100, 255),
        GlowIntensity = 0.6,
        GlowColor = Color3.fromRGB(220, 150, 255)
    },
    LEGENDARY = {
        BorderColor = Color3.fromRGB(255, 215, 0),
        GlowIntensity = 0.8,
        GlowColor = Color3.fromRGB(255, 235, 100)
    }
}

function PetCard.new(parent, petData)
    local self = setmetatable({}, PetCard)
    
    -- Store pet data
    self.petData = petData
    
    -- Create main container
    self.container = Instance.new("Frame")
    self.container.Name = "PetCard_" .. petData.id
    self.container.Size = UDim2.new(0, 120, 0, 150)
    self.container.BackgroundTransparency = 0.1
    self.container.BorderSizePixel = 2
    
    -- Apply rarity-based styling
    local style = RARITY_STYLES[petData.rarity]
    self.container.BorderColor3 = style.BorderColor
    
    -- Create glow effect
    self.glowEffect = Instance.new("UIGradient")
    self.glowEffect.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, style.GlowColor),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    })
    self.glowEffect.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1 - style.GlowIntensity),
        NumberSequenceKeypoint.new(1, 1)
    })
    self.glowEffect.Parent = self.container
    
    -- Create pet image
    self.petImage = Instance.new("ImageLabel")
    self.petImage.Name = "PetImage"
    self.petImage.Size = UDim2.new(0.8, 0, 0.6, 0)
    self.petImage.Position = UDim2.new(0.1, 0, 0.1, 0)
    self.petImage.BackgroundTransparency = 1
    self.petImage.Image = petData.imageId or ""
    self.petImage.Parent = self.container
    
    -- Create name label
    self.nameLabel = Instance.new("TextLabel")
    self.nameLabel.Name = "NameLabel"
    self.nameLabel.Size = UDim2.new(0.9, 0, 0.15, 0)
    self.nameLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
    self.nameLabel.BackgroundTransparency = 1
    self.nameLabel.Text = petData.name
    self.nameLabel.TextColor3 = style.BorderColor
    self.nameLabel.TextScaled = true
    self.nameLabel.Parent = self.container
    
    -- Create level label
    self.levelLabel = Instance.new("TextLabel")
    self.levelLabel.Name = "LevelLabel"
    self.levelLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
    self.levelLabel.Position = UDim2.new(0.05, 0, 0.9, 0)
    self.levelLabel.BackgroundTransparency = 1
    self.levelLabel.Text = "Level " .. petData.level
    self.levelLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    self.levelLabel.TextScaled = true
    self.levelLabel.Parent = self.container
    
    -- Set up interactions
    self:setupInteractions()
    
    -- Parent the card
    self.container.Parent = parent
    
    -- Play pop-in animation
    self:playPopInAnimation()
    
    return self
end

function PetCard:setupInteractions()
    -- Mouse hover effects
    self.container.MouseEnter:Connect(function()
        self:playHoverAnimation(true)
    end)
    
    self.container.MouseLeave:Connect(function()
        self:playHoverAnimation(false)
    end)
    
    -- Touch support
    self.container.TouchTap:Connect(function()
        self:handleSelection()
    end)
    
    -- Mouse click
    self.container.MouseButton1Click:Connect(function()
        self:handleSelection()
    end)
end

function PetCard:playPopInAnimation()
    self.container.Size = UDim2.new(0, 0, 0, 0)
    self.container.Position = self.container.Position + UDim2.new(0.5, 0, 0.5, 0)
    
    local popInTween = TweenService:Create(
        self.container,
        TweenInfo.new(
            ANIMATIONS.POP_IN.TIME,
            ANIMATIONS.POP_IN.EASING,
            ANIMATIONS.POP_IN.DIRECTION
        ),
        {
            Size = UDim2.new(0, 120, 0, 150),
            Position = self.container.Position - UDim2.new(0.5, 0, 0.5, 0)
        }
    )
    
    popInTween:Play()
end

function PetCard:playHoverAnimation(isHovering)
    local scale = isHovering and 1.1 or 1
    local transparency = isHovering and 0 or 0.1
    
    local hoverTween = TweenService:Create(
        self.container,
        TweenInfo.new(
            ANIMATIONS.HOVER.TIME,
            ANIMATIONS.HOVER.EASING,
            ANIMATIONS.HOVER.DIRECTION
        ),
        {
            Size = UDim2.new(0, 120 * scale, 0, 150 * scale),
            BackgroundTransparency = transparency
        }
    )
    
    hoverTween:Play()
end

function PetCard:handleSelection()
    -- Play selection animation
    local selectTween = TweenService:Create(
        self.container,
        TweenInfo.new(
            ANIMATIONS.SELECT.TIME,
            ANIMATIONS.SELECT.EASING,
            ANIMATIONS.SELECT.DIRECTION
        ),
        {
            Size = UDim2.new(0, 126, 0, 157),
            Position = self.container.Position - UDim2.new(0, 3, 0, 3)
        }
    )
    
    local deselectTween = TweenService:Create(
        self.container,
        TweenInfo.new(
            ANIMATIONS.SELECT.TIME,
            ANIMATIONS.SELECT.EASING,
            ANIMATIONS.SELECT.DIRECTION
        ),
        {
            Size = UDim2.new(0, 120, 0, 150),
            Position = self.container.Position + UDim2.new(0, 3, 0, 3)
        }
    )
    
    selectTween:Play()
    selectTween.Completed:Connect(function()
        deselectTween:Play()
    end)
    
    -- TODO: Trigger selection callback when implemented
end

function PetCard:destroy()
    self.container:Destroy()
end

return PetCard 