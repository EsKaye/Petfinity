--[[
    PetInteractionSystem.lua
    Handles pet interactions, animations, and mood effects
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import EffectsSystem for particles
local EffectsSystem = require(game.ReplicatedStorage.Systems.EffectsSystem)

local PetInteractionSystem = {}
PetInteractionSystem.__index = PetInteractionSystem

-- Animation configurations for different interactions
local ANIMATIONS = {
    PET = {
        BOUNCE = {
            TIME = 0.3,
            EASING = Enum.EasingStyle.Bounce,
            DIRECTION = Enum.EasingDirection.Out,
            HEIGHT = 20 -- Bounce height in pixels
        },
        GLOW = {
            TIME = 0.5,
            EASING = Enum.EasingStyle.Sine,
            DIRECTION = Enum.EasingDirection.InOut
        }
    },
    FEED = {
        CHEW = {
            TIME = 0.2,
            EASING = Enum.EasingStyle.Quad,
            DIRECTION = Enum.EasingDirection.InOut,
            SCALE = 1.1 -- Scale factor while chewing
        }
    },
    PLAY = {
        SPIN = {
            TIME = 0.8,
            EASING = Enum.EasingStyle.Cubic,
            DIRECTION = Enum.EasingDirection.InOut,
            ROTATIONS = 2 -- Number of full rotations
        },
        JUMP = {
            TIME = 0.5,
            EASING = Enum.EasingStyle.Quad,
            DIRECTION = Enum.EasingDirection.Out,
            HEIGHT = 30 -- Jump height in pixels
        }
    },
    IDLE = {
        WIGGLE = {
            TIME = 1.5,
            EASING = Enum.EasingStyle.Sine,
            DIRECTION = Enum.EasingDirection.InOut,
            ANGLE = 5 -- Wiggle angle in degrees
        },
        FLOAT = {
            TIME = 2,
            EASING = Enum.EasingStyle.Sine,
            DIRECTION = Enum.EasingDirection.InOut,
            HEIGHT = 5 -- Float height in pixels
        }
    }
}

-- Particle effects for different moods
local PARTICLES = {
    HAPPY = {
        TYPE = "Hearts",
        COLOR = Color3.fromRGB(255, 150, 200),
        RATE = 10,
        LIFETIME = NumberRange.new(0.5, 1),
        SIZE = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(0.5, 0.3),
            NumberSequenceKeypoint.new(1, 0)
        })
    },
    EXCITED = {
        TYPE = "Sparkles",
        COLOR = Color3.fromRGB(255, 255, 150),
        RATE = 15,
        LIFETIME = NumberRange.new(0.3, 0.8),
        SIZE = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(0.5, 0.4),
            NumberSequenceKeypoint.new(1, 0)
        })
    },
    SAD = {
        TYPE = "Cloud",
        COLOR = Color3.fromRGB(150, 150, 255),
        RATE = 5,
        LIFETIME = NumberRange.new(1, 1.5),
        SIZE = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(0.5, 0.5),
            NumberSequenceKeypoint.new(1, 0)
        })
    }
}

-- Sound effects for different pet types
local SOUNDS = {
    CAT = {
        HAPPY = "rbxasset://sounds/cat_purr.mp3",
        EXCITED = "rbxasset://sounds/cat_meow.mp3",
        SAD = "rbxasset://sounds/cat_sad.mp3"
    },
    DOG = {
        HAPPY = "rbxasset://sounds/dog_happy.mp3",
        EXCITED = "rbxasset://sounds/dog_bark.mp3",
        SAD = "rbxasset://sounds/dog_whimper.mp3"
    },
    MAGICAL = {
        HAPPY = "rbxasset://sounds/magic_chime.mp3",
        EXCITED = "rbxasset://sounds/magic_sparkle.mp3",
        SAD = "rbxasset://sounds/magic_low.mp3"
    }
}

function PetInteractionSystem.new(petInstance)
    local self = setmetatable({}, PetInteractionSystem)
    
    -- Store references
    self.petInstance = petInstance
    self.effectsSystem = EffectsSystem.new(petInstance)
    
    -- Initialize mood state
    self.mood = "HAPPY"
    self.happiness = 100
    
    -- Set up idle animations
    self:setupIdleAnimations()
    
    return self
end

function PetInteractionSystem:setupIdleAnimations()
    -- Create wiggle animation
    local function playWiggle()
        local wiggleTween = TweenService:Create(
            self.petInstance,
            TweenInfo.new(
                ANIMATIONS.IDLE.WIGGLE.TIME,
                ANIMATIONS.IDLE.WIGGLE.EASING,
                ANIMATIONS.IDLE.WIGGLE.DIRECTION,
                -1, -- Repeat forever
                true -- Reverse
            ),
            {Rotation = ANIMATIONS.IDLE.WIGGLE.ANGLE}
        )
        wiggleTween:Play()
    end
    
    -- Create float animation
    local function playFloat()
        local floatTween = TweenService:Create(
            self.petInstance,
            TweenInfo.new(
                ANIMATIONS.IDLE.FLOAT.TIME,
                ANIMATIONS.IDLE.FLOAT.EASING,
                ANIMATIONS.IDLE.FLOAT.DIRECTION,
                -1, -- Repeat forever
                true -- Reverse
            ),
            {Position = self.petInstance.Position + Vector3.new(0, ANIMATIONS.IDLE.FLOAT.HEIGHT, 0)}
        )
        floatTween:Play()
    end
    
    playWiggle()
    playFloat()
end

function PetInteractionSystem:handlePetting()
    -- Play bounce animation
    local startPos = self.petInstance.Position
    local bounceTween = TweenService:Create(
        self.petInstance,
        TweenInfo.new(
            ANIMATIONS.PET.BOUNCE.TIME,
            ANIMATIONS.PET.BOUNCE.EASING,
            ANIMATIONS.PET.BOUNCE.DIRECTION
        ),
        {
            Position = startPos + Vector3.new(0, ANIMATIONS.PET.BOUNCE.HEIGHT, 0),
            Size = self.petInstance.Size * 1.1
        }
    )
    
    local returnTween = TweenService:Create(
        self.petInstance,
        TweenInfo.new(
            ANIMATIONS.PET.BOUNCE.TIME,
            ANIMATIONS.PET.BOUNCE.EASING,
            ANIMATIONS.PET.BOUNCE.DIRECTION
        ),
        {
            Position = startPos,
            Size = self.petInstance.Size
        }
    )
    
    bounceTween:Play()
    bounceTween.Completed:Connect(function()
        returnTween:Play()
    end)
    
    -- Play happy particles
    self.effectsSystem:playParticles(PARTICLES.HAPPY)
    
    -- Increase happiness
    self:updateHappiness(10)
end

function PetInteractionSystem:handleFeeding()
    -- Play chewing animation
    local chewTween = TweenService:Create(
        self.petInstance,
        TweenInfo.new(
            ANIMATIONS.FEED.CHEW.TIME,
            ANIMATIONS.FEED.CHEW.EASING,
            ANIMATIONS.FEED.CHEW.DIRECTION,
            3, -- Chew 3 times
            true -- Reverse
        ),
        {
            Size = self.petInstance.Size * ANIMATIONS.FEED.CHEW.SCALE
        }
    )
    
    chewTween:Play()
    
    -- Play excited particles
    self.effectsSystem:playParticles(PARTICLES.EXCITED)
    
    -- Increase happiness
    self:updateHappiness(15)
end

function PetInteractionSystem:handlePlaying()
    -- Play spin and jump animation
    local startRot = self.petInstance.Rotation
    local startPos = self.petInstance.Position
    
    local spinTween = TweenService:Create(
        self.petInstance,
        TweenInfo.new(
            ANIMATIONS.PLAY.SPIN.TIME,
            ANIMATIONS.PLAY.SPIN.EASING,
            ANIMATIONS.PLAY.SPIN.DIRECTION
        ),
        {Rotation = startRot + (360 * ANIMATIONS.PLAY.SPIN.ROTATIONS)}
    )
    
    local jumpTween = TweenService:Create(
        self.petInstance,
        TweenInfo.new(
            ANIMATIONS.PLAY.JUMP.TIME,
            ANIMATIONS.PLAY.JUMP.EASING,
            ANIMATIONS.PLAY.JUMP.DIRECTION
        ),
        {Position = startPos + Vector3.new(0, ANIMATIONS.PLAY.JUMP.HEIGHT, 0)}
    )
    
    local returnTween = TweenService:Create(
        self.petInstance,
        TweenInfo.new(
            ANIMATIONS.PLAY.JUMP.TIME,
            ANIMATIONS.PLAY.JUMP.EASING,
            ANIMATIONS.PLAY.JUMP.DIRECTION
        ),
        {Position = startPos}
    )
    
    spinTween:Play()
    jumpTween:Play()
    jumpTween.Completed:Connect(function()
        returnTween:Play()
    end)
    
    -- Play excited particles
    self.effectsSystem:playParticles(PARTICLES.EXCITED)
    
    -- Increase happiness
    self:updateHappiness(20)
end

function PetInteractionSystem:updateHappiness(delta)
    self.happiness = math.clamp(self.happiness + delta, 0, 100)
    
    -- Update mood based on happiness
    local oldMood = self.mood
    if self.happiness >= 70 then
        self.mood = "HAPPY"
    elseif self.happiness >= 30 then
        self.mood = "NEUTRAL"
    else
        self.mood = "SAD"
    end
    
    -- Play mood change effects if mood changed
    if oldMood ~= self.mood then
        if self.mood == "SAD" then
            self.effectsSystem:playParticles(PARTICLES.SAD)
        elseif self.mood == "HAPPY" then
            self.effectsSystem:playParticles(PARTICLES.HAPPY)
        end
    end
    
    -- Return current happiness and mood
    return self.happiness, self.mood
end

function PetInteractionSystem:getHappinessBonus()
    -- Calculate gameplay bonuses based on happiness
    local rollBonus = self.happiness / 100 -- 0-100% bonus to roll chances
    local xpBonus = 1 + (self.happiness / 100) -- 1x-2x XP multiplier
    
    return {
        rollBonus = rollBonus,
        xpBonus = xpBonus
    }
end

function PetInteractionSystem:destroy()
    self.effectsSystem:destroy()
end

return PetInteractionSystem 