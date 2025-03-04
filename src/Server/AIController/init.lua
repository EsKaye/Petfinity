--[[
    AIController/init.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Controls AI-powered world generation
]]

print("🎀 Initializing AIController module...")

local AIController = {}
AIController.__index = AIController

-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
print("📂 Loading dependencies...")
local WorldGenerator, BiomeHandler, AssetPlacer = nil, nil, nil

local success, result = pcall(function()
    return require(ServerScriptService.Server.WorldGenerator.init)
end)
if success then
    WorldGenerator = result
    print("✅ WorldGenerator loaded!")
else
    warn("⚠️ Failed to load WorldGenerator:", result)
end

local success, result = pcall(function()
    return require(ServerScriptService.Server.BiomeHandler)
end)
if success then
    BiomeHandler = result
    print("✅ BiomeHandler loaded!")
else
    warn("⚠️ Failed to load BiomeHandler:", result)
end

local success, result = pcall(function()
    return require(ServerScriptService.Server.AssetPlacer.init)
end)
if success then
    AssetPlacer = result
    print("✅ AssetPlacer loaded!")
else
    warn("⚠️ Failed to load AssetPlacer:", result)
end

print("✨ Dependencies loaded!")

-- Constants
local CHUNK_SIZE = 100
local MAX_WORLD_SIZE = 2000
local MIN_WORLD_SIZE = 500
local BIOME_BLEND_DISTANCE = 50

-- Private functions
local function generateBiomeLayout(worldSize)
    if not BiomeHandler then
        warn("⚠️ BiomeHandler not loaded - using default biome layout")
        return {
            Default = {
                centerX = 0,
                centerZ = 0,
                radius = worldSize/2
            }
        }
    end
    
    local biomes = {}
    local biomeCount = math.random(3, 6)
    
    for i = 1, biomeCount do
        local biomeName = BiomeHandler.getRandomBiomeName()
        local centerX = math.random(-worldSize/2, worldSize/2)
        local centerZ = math.random(-worldSize/2, worldSize/2)
        local radius = math.random(worldSize/4, worldSize/3)
        
        biomes[biomeName] = {
            centerX = centerX,
            centerZ = centerZ,
            radius = radius
        }
    end
    
    return biomes
end

local function optimizeAssetPlacement(biomeLayout, worldSize)
    if not BiomeHandler then
        warn("⚠️ BiomeHandler not loaded - using default asset layout")
        return {
            Default = {
                trees = 10,
                rocks = 5,
                decorations = 20
            }
        }
    end
    
    local assetLayout = {}
    
    for biomeName, biomeData in pairs(biomeLayout) do
        local biomeSettings = BiomeHandler.getBiomeSettings(biomeName)
        local assetDensity = biomeSettings.assets
        
        -- Calculate optimal asset counts based on biome size
        local area = math.pi * biomeData.radius * biomeData.radius
        local treeCount = math.floor(area * assetDensity.treeDensity.max / 1000)
        local rockCount = math.floor(area * assetDensity.rockDensity.max / 1000)
        local decorationCount = math.floor(area * assetDensity.decorationDensity.max / 1000)
        
        assetLayout[biomeName] = {
            trees = treeCount,
            rocks = rockCount,
            decorations = decorationCount
        }
    end
    
    return assetLayout
end

-- Public functions
function AIController.new()
    local self = setmetatable({}, AIController)
    self.worldSize = math.random(MIN_WORLD_SIZE, MAX_WORLD_SIZE)
    self.biomeLayout = generateBiomeLayout(self.worldSize)
    self.assetLayout = optimizeAssetPlacement(self.biomeLayout, self.worldSize)
    return self
end

function AIController:generateWorld()
    print("🧠 AI is generating world...")
    
    if not WorldGenerator then
        warn("⚠️ WorldGenerator not loaded - world generation disabled")
        return false
    end
    
    -- Initialize world generator
    local generator = WorldGenerator.new()
    
    -- Generate terrain
    local chunkCount = math.ceil(self.worldSize / CHUNK_SIZE)
    generator:generateWorld(0, 0, chunkCount)
    
    -- Apply biome settings
    if BiomeHandler then
        for biomeName, biomeData in pairs(self.biomeLayout) do
            BiomeHandler.applyBiomeLighting(biomeName)
            BiomeHandler.applyBiomeWeather(biomeName)
        end
    end
    
    -- Place assets
    if AssetPlacer then
        AssetPlacer.placeAssets(0, 0, self.worldSize)
        AssetPlacer.placeGachaMachines(0, 0, self.worldSize)
        AssetPlacer.placeEventAreas(0, 0, self.worldSize)
    end
    
    print("✨ AI world generation complete!")
    return true
end

function AIController:getBiomeLayout()
    return self.biomeLayout
end

function AIController:getAssetLayout()
    return self.assetLayout
end

print("🎀 AIController module initialized!")
return AIController 