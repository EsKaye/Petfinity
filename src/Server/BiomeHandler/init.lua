--[[
    BiomeHandler/init.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Manages biome data and settings for world generation
]]

local BiomeHandler = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Lighting = game:GetService("Lighting")

-- Constants
local BIOME_CONFIG_PATH = "Config/Biomes"

-- Biome data cache
local biomeData = nil

-- Default biome settings
local DEFAULT_BIOME = {
    baseHeight = 10,
    heightVariation = 20,
    terrainTexture = Enum.Material.Grass,
    terrainMaterial = Enum.Material.Grass,
    weather = {
        type = "Clear",
        intensity = 1,
        frequency = 0.5
    },
    lighting = {
        ambient = Color3.fromRGB(200, 200, 200),
        outdoorAmbient = Color3.fromRGB(200, 200, 200),
        brightness = 1,
        globalShadows = true
    },
    assets = {
        trees = {},
        rocks = {},
        structures = {},
        decorations = {}
    },
    ambientSounds = {},
    spawnPoints = {}
}

-- Private functions
local function loadBiomeConfig()
    print("📂 Loading biome config...")
    local success, result = pcall(function()
        local config = require(ReplicatedStorage.Config.Biomes)
        print("✅ Successfully loaded biome config!")
        return config
    end)
    
    if not success then
        warn("❌ Failed to load biome config:", result)
        print("🔍 Checking ReplicatedStorage structure:")
        print("  ReplicatedStorage contents:")
        for _, child in ipairs(ReplicatedStorage:GetChildren()) do
            print("    -", child.Name)
            if child:IsA("Folder") then
                print("      Folder contents:")
                for _, subChild in ipairs(child:GetChildren()) do
                    print("        -", subChild.Name)
                end
            end
        end
        return {}
    end
    
    return result
end

local function initializeBiomeData()
    if biomeData then return biomeData end
    
    local config = loadBiomeConfig()
    biomeData = {}
    
    for biomeName, biomeConfig in pairs(config) do
        biomeData[biomeName] = {
            centerX = biomeConfig.centerX or 0,
            centerZ = biomeConfig.centerZ or 0,
            radius = biomeConfig.radius or 100,
            baseHeight = biomeConfig.baseHeight or DEFAULT_BIOME.baseHeight,
            heightVariation = biomeConfig.heightVariation or DEFAULT_BIOME.heightVariation,
            terrainTexture = biomeConfig.terrainTexture or DEFAULT_BIOME.terrainTexture,
            terrainMaterial = biomeConfig.terrainMaterial or DEFAULT_BIOME.terrainMaterial,
            weather = biomeConfig.weather or DEFAULT_BIOME.weather,
            lighting = {
                ambient = Color3.fromRGB(
                    biomeConfig.lighting and biomeConfig.lighting.ambient and biomeConfig.lighting.ambient.r or 200,
                    biomeConfig.lighting and biomeConfig.lighting.ambient and biomeConfig.lighting.ambient.g or 200,
                    biomeConfig.lighting and biomeConfig.lighting.ambient and biomeConfig.lighting.ambient.b or 200
                ),
                outdoorAmbient = Color3.fromRGB(
                    biomeConfig.lighting and biomeConfig.lighting.outdoorAmbient and biomeConfig.lighting.outdoorAmbient.r or 200,
                    biomeConfig.lighting and biomeConfig.lighting.outdoorAmbient and biomeConfig.lighting.outdoorAmbient.g or 200,
                    biomeConfig.lighting and biomeConfig.lighting.outdoorAmbient and biomeConfig.lighting.outdoorAmbient.b or 200
                ),
                brightness = biomeConfig.lighting and biomeConfig.lighting.brightness or 1,
                globalShadows = biomeConfig.lighting and biomeConfig.lighting.globalShadows or true
            },
            assets = biomeConfig.assets or DEFAULT_BIOME.assets,
            ambientSounds = biomeConfig.ambientSounds or DEFAULT_BIOME.ambientSounds,
            spawnPoints = biomeConfig.spawnPoints or DEFAULT_BIOME.spawnPoints
        }
    end
    
    return biomeData
end

-- Public functions
function BiomeHandler.getBiomeData()
    return biomeData or initializeBiomeData()
end

function BiomeHandler.getRandomBiomeName()
    local data = BiomeHandler.getBiomeData()
    local biomeNames = {}
    
    for name, _ in pairs(data) do
        table.insert(biomeNames, name)
    end
    
    return biomeNames[math.random(1, #biomeNames)]
end

function BiomeHandler.getBiomeAtPosition(x, z)
    local data = BiomeHandler.getBiomeData()
    local closestBiome = nil
    local minDistance = math.huge
    
    for biomeName, biome in pairs(data) do
        local distance = (Vector2.new(x, z) - Vector2.new(biome.centerX, biome.centerZ)).Magnitude
        if distance < minDistance and distance <= biome.radius then
            minDistance = distance
            closestBiome = biomeName
        end
    end
    
    return closestBiome
end

function BiomeHandler.getBiomeSettings(biomeName)
    local data = BiomeHandler.getBiomeData()
    return data[biomeName] or DEFAULT_BIOME
end

function BiomeHandler.applyBiomeLighting(biomeName)
    local settings = BiomeHandler.getBiomeSettings(biomeName)
    
    Lighting.Ambient = settings.lighting.ambient
    Lighting.OutdoorAmbient = settings.lighting.outdoorAmbient
    Lighting.Brightness = settings.lighting.brightness
    Lighting.GlobalShadows = settings.lighting.globalShadows
end

function BiomeHandler.applyBiomeWeather(biomeName)
    local settings = BiomeHandler.getBiomeSettings(biomeName)
    -- Weather system implementation will go here
end

function BiomeHandler.playAmbientSounds(biomeName)
    local settings = BiomeHandler.getBiomeSettings(biomeName)
    -- Sound system implementation will go here
end

function BiomeHandler.applyBiomeSettings()
    print("🌿 Applying all biome settings...")
    
    -- Get the biome at the center of the world
    local centerBiome = BiomeHandler.getBiomeAtPosition(0, 0)
    if not centerBiome then
        warn("⚠️ No biome found at center position")
        return
    end
    
    -- Apply lighting
    BiomeHandler.applyBiomeLighting(centerBiome)
    
    -- Apply weather (when implemented)
    BiomeHandler.applyBiomeWeather(centerBiome)
    
    -- Play ambient sounds (when implemented)
    BiomeHandler.playAmbientSounds(centerBiome)
    
    print("✅ Biome settings applied!")
end

return BiomeHandler 