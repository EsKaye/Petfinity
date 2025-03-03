--[[
    GachaSystem.lua
    Core module for handling gacha mechanics and pet rolls
    
    Author: Cursor AI
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GachaSystem = {}
GachaSystem.__index = GachaSystem

-- Constants for rarity weights and probabilities
local RARITY_WEIGHTS = {
    COMMON = 60,
    UNCOMMON = 25,
    RARE = 10,
    EPIC = 4,
    LEGENDARY = 1
}

-- Initialize the gacha system
function GachaSystem.new()
    local self = setmetatable({}, GachaSystem)
    
    -- Initialize internal state
    self.rollsPerformed = 0
    self.pityCounter = 0
    
    return self
end

-- Perform a gacha roll
function GachaSystem:performRoll()
    self.rollsPerformed = self.rollsPerformed + 1
    self.pityCounter = self.pityCounter + 1
    
    -- Calculate roll result based on weights and pity system
    local result = self:calculateRollResult()
    
    -- Reset pity counter if legendary obtained
    if result.rarity == "LEGENDARY" then
        self.pityCounter = 0
    end
    
    return result
end

-- Calculate the result of a roll using weighted probabilities
function GachaSystem:calculateRollResult()
    -- Implement weighted random selection
    local totalWeight = 0
    for _, weight in pairs(RARITY_WEIGHTS) do
        totalWeight = totalWeight + weight
    end
    
    local roll = math.random(1, totalWeight)
    local currentWeight = 0
    
    -- Apply pity system (increased legendary chance after many rolls)
    if self.pityCounter >= 90 then
        return {
            rarity = "LEGENDARY",
            -- Additional pet data will be added here
        }
    end
    
    -- Normal roll calculation
    for rarity, weight in pairs(RARITY_WEIGHTS) do
        currentWeight = currentWeight + weight
        if roll <= currentWeight then
            return {
                rarity = rarity,
                -- Additional pet data will be added here
            }
        end
    end
end

return GachaSystem 