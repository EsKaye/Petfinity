--[[
    PetSystem.lua
    Core module for managing pet collection and interactions
    
    Author: Cursor AI
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetSystem = {}
PetSystem.__index = PetSystem

-- Pet states and attributes
local PET_STATES = {
    HAPPY = "HAPPY",
    NEUTRAL = "NEUTRAL",
    SAD = "SAD"
}

local PET_ATTRIBUTES = {
    HUNGER = "HUNGER",
    ENERGY = "ENERGY",
    HAPPINESS = "HAPPINESS"
}

-- Initialize the pet system
function PetSystem.new()
    local self = setmetatable({}, PetSystem)
    
    -- Initialize collections
    self.pets = {}
    self.activePet = nil
    
    return self
end

-- Add a new pet to the collection
function PetSystem:addPet(petData)
    -- Generate unique ID for the pet
    local petId = #self.pets + 1
    
    -- Create new pet instance
    local pet = {
        id = petId,
        name = petData.name or "Pet " .. petId,
        rarity = petData.rarity,
        level = 1,
        experience = 0,
        attributes = {
            [PET_ATTRIBUTES.HUNGER] = 100,
            [PET_ATTRIBUTES.ENERGY] = 100,
            [PET_ATTRIBUTES.HAPPINESS] = 100
        },
        state = PET_STATES.HAPPY
    }
    
    -- Add to collection
    self.pets[petId] = pet
    return pet
end

-- Get pet state based on attributes
function PetSystem:getPetState(pet)
    local avgAttribute = (
        pet.attributes[PET_ATTRIBUTES.HUNGER] +
        pet.attributes[PET_ATTRIBUTES.ENERGY] +
        pet.attributes[PET_ATTRIBUTES.HAPPINESS]
    ) / 3
    
    if avgAttribute >= 70 then
        return PET_STATES.HAPPY
    elseif avgAttribute >= 30 then
        return PET_STATES.NEUTRAL
    else
        return PET_STATES.SAD
    end
end

-- Update pet attributes (called periodically)
function PetSystem:updatePetAttributes(pet, deltaTime)
    -- Decrease attributes over time
    local decayRate = 1 * deltaTime -- 1 point per second
    
    for attribute, value in pairs(pet.attributes) do
        pet.attributes[attribute] = math.max(0, value - decayRate)
    end
    
    -- Update pet state
    pet.state = self:getPetState(pet)
end

-- Interact with pet (feed, play, etc.)
function PetSystem:interactWithPet(pet, interactionType)
    local attribute = PET_ATTRIBUTES[interactionType]
    if attribute then
        pet.attributes[attribute] = math.min(100, pet.attributes[attribute] + 25)
        pet.state = self:getPetState(pet)
        return true
    end
    return false
end

return PetSystem 