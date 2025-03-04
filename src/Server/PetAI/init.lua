--[[
    PetAI.lua
    Core AI system for pet behavior, movement, and interactions
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 1.0.0
--]]

local PetAI = {}
PetAI.__index = PetAI

-- Services
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load configurations
local function loadConfig(configName)
    local success, config = pcall(function()
        local json = require(game.ReplicatedStorage.Shared.Utils.JSON)
        local content = readfile("config/" .. configName .. ".json")
        return json.decode(content)
    end)
    
    if not success then
        warn("Failed to load configuration:", configName, config)
        return {}
    end
    
    return config
end

-- Constants
local UPDATE_RATE = 0.1
local PATH_RECOMPUTE_TIME = 1
local INTERACTION_RANGE = 5

function PetAI.new(pet, owner)
    local self = setmetatable({}, PetAI)
    
    -- Store references
    self.pet = pet
    self.owner = owner
    
    -- Load configurations
    self.petConfig = loadConfig("Pets")[pet.type]
    self.behaviorConfig = loadConfig("PetBehaviors")
    
    -- Initialize state
    self.currentState = "IDLE"
    self.mood = {
        happiness = 100,
        energy = 100,
        excitement = 50
    }
    self.lastPathUpdate = 0
    self.currentPath = nil
    self.isMoving = false
    
    -- Start AI loop
    self:startAILoop()
    
    return self
end

function PetAI:startAILoop()
    spawn(function()
        while self.pet and self.pet.Parent do
            self:update()
            wait(UPDATE_RATE)
        end
    end)
end

function PetAI:update()
    -- Update mood
    self:updateMood()
    
    -- Update movement
    if self.currentState == "FOLLOWING" then
        self:updateFollowing()
    elseif self.currentState == "ROAMING" then
        self:updateRoaming()
    end
    
    -- Update animations and effects
    self:updateVisuals()
end

function PetAI:updateMood()
    local biomeModifier = self.behaviorConfig.BIOME_REACTIONS[self.pet.currentBiome or "MYSTIC_MEADOWS"]
    
    -- Apply biome effects
    self.mood.happiness = math.clamp(
        self.mood.happiness * (biomeModifier.moodModifier or 1),
        0, 100
    )
    
    -- Apply energy changes
    if biomeModifier.energyRegen then
        self.mood.energy = math.min(100, self.mood.energy + biomeModifier.energyRegen)
    elseif biomeModifier.energyDrain then
        self.mood.energy = math.max(0, self.mood.energy - biomeModifier.energyDrain)
    end
    
    -- Update excitement based on activity
    if self.isMoving then
        self.mood.excitement = math.min(100, self.mood.excitement + 1)
    else
        self.mood.excitement = math.max(0, self.mood.excitement - 0.5)
    end
end

function PetAI:updateFollowing()
    if not self.owner then return end
    
    local now = tick()
    if now - self.lastPathUpdate >= PATH_RECOMPUTE_TIME then
        self:computePath(self.owner.Character.HumanoidRootPart.Position)
        self.lastPathUpdate = now
    end
    
    if self.currentPath then
        self:followPath()
    end
end

function PetAI:computePath(targetPosition)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true
    })
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(self.pet.PrimaryPart.Position, targetPosition)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        self.currentPath = path:GetWaypoints()
    else
        self.currentPath = nil
        warn("Failed to compute path:", errorMessage)
    end
end

function PetAI:followPath()
    if not self.currentPath or #self.currentPath == 0 then return end
    
    local nextWaypoint = self.currentPath[1]
    local distance = (nextWaypoint.Position - self.pet.PrimaryPart.Position).Magnitude
    
    if distance < 1 then
        table.remove(self.currentPath, 1)
        return
    end
    
    -- Move towards waypoint
    local movement = (nextWaypoint.Position - self.pet.PrimaryPart.Position).Unit
    local speed = self.petConfig.stats.speed * self:getSpeedMultiplier()
    
    self.pet.PrimaryPart.CFrame = CFrame.new(
        self.pet.PrimaryPart.Position + movement * speed * UPDATE_RATE
    )
    
    self.isMoving = true
end

function PetAI:getSpeedMultiplier()
    local moodBehavior = self:getCurrentMoodBehavior()
    local personalityModifier = self:getPersonalityModifier()
    local terrainModifier = self:getTerrainModifier()
    
    return moodBehavior.movementSpeed * personalityModifier * terrainModifier
end

function PetAI:getCurrentMoodBehavior()
    if self.mood.happiness >= 70 then
        return self.behaviorConfig.MOOD_BEHAVIORS.HAPPY
    elseif self.mood.happiness <= 30 then
        return self.behaviorConfig.MOOD_BEHAVIORS.SAD
    else
        return self.behaviorConfig.MOOD_BEHAVIORS.NEUTRAL
    end
end

function PetAI:getPersonalityModifier()
    local personality = self.petConfig.personality
    local modifier = 1
    
    if personality.playfulness > 0.7 then
        modifier = modifier * self.behaviorConfig.PERSONALITY_MODIFIERS.PLAYFUL.movementSpeed
    end
    if personality.energy > 0.7 then
        modifier = modifier * self.behaviorConfig.PERSONALITY_MODIFIERS.ENERGETIC.movementSpeed
    end
    
    return modifier
end

function PetAI:getTerrainModifier()
    local terrain = self:getCurrentTerrain()
    local adaptation = self.behaviorConfig.MOVEMENT.TERRAIN_ADAPTATION[terrain]
    
    return adaptation and adaptation.speedMultiplier or 1
end

function PetAI:getCurrentTerrain()
    -- TODO: Implement terrain detection
    return "normal"
end

function PetAI:updateRoaming()
    if not self.roamTarget or (self.pet.PrimaryPart.Position - self.roamTarget).Magnitude < 1 then
        self:selectNewRoamTarget()
    else
        local direction = (self.roamTarget - self.pet.PrimaryPart.Position).Unit
        local speed = self.petConfig.stats.speed * self:getSpeedMultiplier() * 0.5
        
        self.pet.PrimaryPart.CFrame = CFrame.new(
            self.pet.PrimaryPart.Position + direction * speed * UPDATE_RATE
        )
        
        self.isMoving = true
    end
end

function PetAI:selectNewRoamTarget()
    local center = self.owner and self.owner.Character.PrimaryPart.Position or self.pet.PrimaryPart.Position
    local angle = math.random() * math.pi * 2
    local radius = math.random() * self.behaviorConfig.MOVEMENT.ROAM.radius
    
    self.roamTarget = center + Vector3.new(
        math.cos(angle) * radius,
        0,
        math.sin(angle) * radius
    )
end

function PetAI:updateVisuals()
    local currentMood = self:getCurrentMoodBehavior()
    
    -- Update animations
    if self.isMoving then
        self:playAnimation(currentMood.animations[1])
    else
        self:playAnimation("idle")
    end
    
    -- Update effects
    if currentMood.effectsEnabled then
        self:updateEffects()
    end
    
    -- Play sounds
    if math.random() < currentMood.soundFrequency * UPDATE_RATE then
        self:playRandomSound()
    end
end

function PetAI:playAnimation(animationName)
    -- TODO: Implement animation playing
end

function PetAI:updateEffects()
    -- TODO: Implement visual effects
end

function PetAI:playRandomSound()
    -- TODO: Implement sound playing
end

function PetAI:handleInteraction(interactionType, source)
    local interaction = self.behaviorConfig.INTERACTIONS[interactionType]
    if not interaction then return end
    
    -- Apply mood changes
    self.mood.happiness = math.min(100, self.mood.happiness + interaction.moodIncrease)
    if interaction.energyIncrease then
        self.mood.energy = math.min(100, self.mood.energy + interaction.energyIncrease)
    end
    if interaction.energyDecrease then
        self.mood.energy = math.max(0, self.mood.energy - interaction.energyDecrease)
    end
    
    -- Play effects
    for _, effect in ipairs(interaction.effects) do
        -- TODO: Implement effect playing
    end
    
    -- Play sounds
    for _, sound in ipairs(interaction.sounds) do
        -- TODO: Implement sound playing
    end
    
    -- Play animations
    for _, animation in ipairs(interaction.animations) do
        self:playAnimation(animation)
    end
end

function PetAI:setState(newState)
    if self.currentState == newState then return end
    
    -- Clean up current state
    if self.currentState == "FOLLOWING" then
        self.currentPath = nil
    elseif self.currentState == "ROAMING" then
        self.roamTarget = nil
    end
    
    -- Set new state
    self.currentState = newState
    
    -- Initialize new state
    if newState == "FOLLOWING" then
        self.lastPathUpdate = 0
    elseif newState == "ROAMING" then
        self:selectNewRoamTarget()
    end
end

function PetAI:destroy()
    -- Clean up any running processes
    self.pet = nil
    self.owner = nil
    self.currentPath = nil
end

return PetAI 