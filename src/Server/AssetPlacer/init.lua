--[[
    AssetPlacer/init.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Handles dynamic placement of assets in the world
]]

local AssetPlacer = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Terrain = Workspace.Terrain

-- Dependencies
print("📂 Loading AssetPlacer dependencies...")
local success, BiomeHandler = pcall(function()
    local path = script.Parent.Parent.BiomeHandler
    print("  Loading BiomeHandler from:", path:GetFullName())
    return require(path)
end)
if not success then
    warn("⚠️ Failed to load BiomeHandler:", BiomeHandler)
    return nil
end
print("✅ BiomeHandler loaded successfully!")

-- Verify BiomeHandler is properly initialized
if not BiomeHandler or not BiomeHandler.getBiomeData then
    warn("⚠️ BiomeHandler not properly initialized")
    return nil
end

-- Constants
local MIN_SPAWN_DISTANCE = 10
local MAX_SPAWN_DISTANCE = 1000
local SPAWN_CHECK_RADIUS = 5
local MAX_SPAWN_ATTEMPTS = 10

-- Private functions
local function createPlaceholderAsset(name, type)
    local model = Instance.new("Model")
    model.Name = name
    
    local part = Instance.new("Part")
    part.Name = "Main"
    part.Size = Vector3.new(5, 5, 5)
    part.Color = type == "Tree" and Color3.fromRGB(34, 139, 34) or
                 type == "Rock" and Color3.fromRGB(128, 128, 128) or
                 type == "Structure" and Color3.fromRGB(139, 69, 19) or
                 Color3.fromRGB(255, 255, 0)
    part.Material = Enum.Material.Plastic
    part.Anchored = true
    part.CanCollide = true
    part.Parent = model
    
    return model
end

local function ensureAssetExists(name, type)
    local assetsFolder = ReplicatedStorage:FindFirstChild("Assets")
    if not assetsFolder then
        assetsFolder = Instance.new("Folder")
        assetsFolder.Name = "Assets"
        assetsFolder.Parent = ReplicatedStorage
    end
    
    local typeFolder = assetsFolder:FindFirstChild(type)
    if not typeFolder then
        typeFolder = Instance.new("Folder")
        typeFolder.Name = type
        typeFolder.Parent = assetsFolder
    end
    
    if not typeFolder:FindFirstChild(name) then
        local model = createPlaceholderAsset(name, type)
        model.Parent = typeFolder
        print("✨ Created placeholder asset:", name, "of type:", type)
    end
end

local function getRandomPositionInRadius(centerX, centerZ, radius)
    local angle = math.random() * math.pi * 2
    local distance = math.random() * radius
    return centerX + math.cos(angle) * distance, centerZ + math.sin(angle) * distance
end

local function findValidSpawnPosition(x, z, biomeName)
    local biome = BiomeHandler.getBiomeSettings(biomeName)
    local terrain = Workspace.Terrain
    
    -- Check multiple positions around the target point
    for i = 1, MAX_SPAWN_ATTEMPTS do
        local checkX = x + (math.random() - 0.5) * SPAWN_CHECK_RADIUS
        local checkZ = z + (math.random() - 0.5) * SPAWN_CHECK_RADIUS
        
        -- Get terrain height at this position
        local height = terrain:GetHeight(Vector3.new(checkX, 0, checkZ))
        
        -- Check if position is valid (not too steep, not underwater, etc.)
        local normal = terrain:GetNormal(Vector3.new(checkX, height, checkZ))
        local slope = math.acos(normal.Y)
        
        if slope < math.rad(45) then -- Less than 45-degree slope
            return Vector3.new(checkX, height, checkZ)
        end
    end
    
    return nil
end

local function placeAsset(assetType, position, rotation)
    ensureAssetExists(assetType, "Models")
    local asset = ReplicatedStorage.Assets.Models[assetType]:Clone()
    asset:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0))
    asset.Parent = Workspace
    return asset
end

local function placeStructure(structureType, position, rotation)
    ensureAssetExists(structureType, "Structures")
    local structure = ReplicatedStorage.Assets.Structures[structureType]:Clone()
    structure:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0))
    structure.Parent = Workspace
    return structure
end

-- Public functions
function AssetPlacer.placeAssets(centerX, centerZ, radius)
    print("🎨 Starting asset placement...")
    local biomeData = BiomeHandler.getBiomeData()
    
    -- Create placeholder assets for each biome
    for biomeName, biome in pairs(biomeData) do
        print("🌿 Creating assets for biome:", biomeName)
        
        -- Create tree assets
        for _, treeType in ipairs(biome.assets.trees) do
            ensureAssetExists(treeType, "Models")
        end
        
        -- Create rock assets
        for _, rockType in ipairs(biome.assets.rocks) do
            ensureAssetExists(rockType, "Models")
        end
        
        -- Create structure assets
        for _, structure in ipairs(biome.assets.structures) do
            ensureAssetExists(structure.type, "Structures")
        end
        
        -- Create decoration assets
        for _, decoration in ipairs(biome.assets.decorations) do
            ensureAssetExists(decoration, "Models")
        end
    end
    
    -- Place assets in the world
    for biomeName, biome in pairs(biomeData) do
        print("🌿 Placing assets for biome:", biomeName)
        
        -- Place trees
        for _, treeType in ipairs(biome.assets.trees) do
            local count = math.random(biome.assets.treeDensity.min, biome.assets.treeDensity.max)
            for i = 1, count do
                local x, z = getRandomPositionInRadius(centerX, centerZ, radius)
                local biomeAtPos = BiomeHandler.getBiomeAtPosition(x, z)
                if biomeAtPos == biomeName then
                    local position = findValidSpawnPosition(x, z, biomeName)
                    if position then
                        placeAsset(treeType, position, math.random(0, 360))
                    end
                end
            end
        end
        
        -- Place rocks
        for _, rockType in ipairs(biome.assets.rocks) do
            local count = math.random(biome.assets.rockDensity.min, biome.assets.rockDensity.max)
            for i = 1, count do
                local x, z = getRandomPositionInRadius(centerX, centerZ, radius)
                local biomeAtPos = BiomeHandler.getBiomeAtPosition(x, z)
                if biomeAtPos == biomeName then
                    local position = findValidSpawnPosition(x, z, biomeName)
                    if position then
                        placeAsset(rockType, position, math.random(0, 360))
                    end
                end
            end
        end
        
        -- Place structures
        for _, structure in ipairs(biome.assets.structures) do
            local x, z = getRandomPositionInRadius(centerX, centerZ, radius)
            local biomeAtPos = BiomeHandler.getBiomeAtPosition(x, z)
            if biomeAtPos == biomeName then
                local position = findValidSpawnPosition(x, z, biomeName)
                if position then
                    placeStructure(structure.type, position, math.random(0, 360))
                end
            end
        end
        
        -- Place decorations
        for _, decoration in ipairs(biome.assets.decorations) do
            local count = math.random(biome.assets.decorationDensity.min, biome.assets.decorationDensity.max)
            for i = 1, count do
                local x, z = getRandomPositionInRadius(centerX, centerZ, radius)
                local biomeAtPos = BiomeHandler.getBiomeAtPosition(x, z)
                if biomeAtPos == biomeName then
                    local position = findValidSpawnPosition(x, z, biomeName)
                    if position then
                        placeAsset(decoration, position, math.random(0, 360))
                    end
                end
            end
        end
    end
    
    print("✅ Asset placement complete!")
end

function AssetPlacer.placeGachaMachines(centerX, centerZ, radius)
    local biomeData = BiomeHandler.getBiomeData()
    
    for biomeName, biome in pairs(biomeData) do
        for _, gachaPoint in ipairs(biome.spawnPoints.gacha) do
            local x, z = getRandomPositionInRadius(centerX, centerZ, radius)
            local biomeAtPos = BiomeHandler.getBiomeAtPosition(x, z)
            if biomeAtPos == biomeName then
                local position = findValidSpawnPosition(x, z, biomeName)
                if position then
                    placeStructure("GachaMachine", position, math.random(0, 360))
                end
            end
        end
    end
end

function AssetPlacer.placeEventAreas(centerX, centerZ, radius)
    local biomeData = BiomeHandler.getBiomeData()
    
    for biomeName, biome in pairs(biomeData) do
        for _, eventPoint in ipairs(biome.spawnPoints.events) do
            local x, z = getRandomPositionInRadius(centerX, centerZ, radius)
            local biomeAtPos = BiomeHandler.getBiomeAtPosition(x, z)
            if biomeAtPos == biomeName then
                local position = findValidSpawnPosition(x, z, biomeName)
                if position then
                    placeStructure("EventArea", position, math.random(0, 360))
                end
            end
        end
    end
end

return AssetPlacer 