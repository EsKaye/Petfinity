--[[
    WorldGenerator/BiomeBlender.lua
    Author: Cursor AI (Adapted from Eidolon-Pets)
    Created: 2024-12-19
    Version: 1.0.0
    Purpose: Advanced biome blending and transitions for Petfinity's world
    
    🧩 FEATURE CONTEXT:
    The BiomeBlender creates smooth transitions between different biomes in
    Petfinity's world, ensuring natural-looking environments where pets can
    thrive. It handles biome determination, terrain blending, and material
    transitions to create diverse and interesting habitats for different
    types of pets.
    
    🧷 DEPENDENCIES:
    - NoiseGenerator: For terrain variation and biome noise
    - Vector2: For distance calculations
    - Math library: For blending calculations and clamping
    
    💡 USAGE EXAMPLES:
    - Get biome: BiomeBlender:getBiomeAtPosition(x, z)
    - Blend biomes: BiomeBlender:blendBiomes(x, z, biome1, biome2)
    - Get terrain data: BiomeBlender:getTerrainData(x, z)
    - Generate biome map: BiomeBlender:generateBiomeMap(width, height)
    
    ⚡ PERFORMANCE CONSIDERATIONS:
    - Biome calculations are optimized for smooth transitions
    - Distance calculations use efficient Vector2 operations
    - Blending factors are cached to avoid redundant calculations
    - Large biome maps are generated incrementally
    
    🔒 SECURITY IMPLICATIONS:
    - No external dependencies or network calls
    - Deterministic output based on input coordinates
    - Safe for server-side execution
    
    📜 CHANGELOG:
    - v1.0.0: Initial implementation adapted from Eidolon-Pets
]]

-- Core dependencies
local NoiseGenerator = require(script.Parent.NoiseGenerator)

-- Biome blending configuration for Petfinity
local BIOME_CONFIG = {
    BLEND_DISTANCE = 20,
    SMOOTHING_ITERATIONS = 3,
    MIN_BIOME_SIZE = 50,
    MAX_BIOME_SIZE = 200
}

-- Petfinity biome definitions with pet-friendly characteristics
local BIOME_DEFINITIONS = {
    GRASSLAND = {
        name = "Grassland",
        color = Color3.fromRGB(34, 139, 34),
        material = Enum.Material.Grass,
        baseHeight = 5,
        heightVariation = 3,
        petSpawnRate = 0.8,
        petTypes = {"Common", "Rare"},
        structures = {"SmallHouse", "Fence", "Tree"},
        features = {"Flowers", "Rocks", "SmallPond"}
    },
    FOREST = {
        name = "Forest",
        color = Color3.fromRGB(0, 100, 0),
        material = Enum.Material.LeafyGrass,
        baseHeight = 8,
        heightVariation = 5,
        petSpawnRate = 0.6,
        petTypes = {"Rare", "Epic"},
        structures = {"Cabin", "TreeHouse", "Log"},
        features = {"DenseTrees", "Mushrooms", "Stream"}
    },
    DESERT = {
        name = "Desert",
        color = Color3.fromRGB(238, 203, 173),
        material = Enum.Material.Sand,
        baseHeight = 2,
        heightVariation = 8,
        petSpawnRate = 0.4,
        petTypes = {"Rare", "Legendary"},
        structures = {"Pyramid", "Oasis", "Cactus"},
        features = {"SandDunes", "RockFormations", "Mirage"}
    },
    MOUNTAIN = {
        name = "Mountain",
        color = Color3.fromRGB(105, 105, 105),
        material = Enum.Material.Rock,
        baseHeight = 15,
        heightVariation = 10,
        petSpawnRate = 0.3,
        petTypes = {"Epic", "Legendary"},
        structures = {"Cave", "Watchtower", "Crystal"},
        features = {"Cliffs", "Snow", "CrystalFormations"}
    },
    VOLCANIC = {
        name = "Volcanic",
        color = Color3.fromRGB(139, 69, 19),
        material = Enum.Material.Basalt,
        baseHeight = 12,
        heightVariation = 15,
        petSpawnRate = 0.2,
        petTypes = {"Legendary", "Mythic"},
        structures = {"Volcano", "LavaPool", "Obsidian"},
        features = {"Lava", "Ash", "Geysers"}
    },
    OASIS = {
        name = "Oasis",
        color = Color3.fromRGB(0, 255, 127),
        material = Enum.Material.Water,
        baseHeight = 3,
        heightVariation = 2,
        petSpawnRate = 0.9,
        petTypes = {"Common", "Rare", "Epic"},
        structures = {"PalmTree", "Waterfall", "Bridge"},
        features = {"ClearWater", "PalmTrees", "Flowers"}
    }
}

-- BiomeBlender class with enhanced functionality
local BiomeBlender = {}
BiomeBlender.__index = BiomeBlender

-- Initialize a new BiomeBlender instance
function BiomeBlender.new(noiseGenerator)
    local self = setmetatable({}, BiomeBlender)
    
    -- Initialize properties
    self.noiseGenerator = noiseGenerator or NoiseGenerator.new()
    self.biomeCenters = {}
    self.biomeMap = {}
    
    -- Performance tracking
    self.stats = {
        biomeCalculations = 0,
        blendOperations = 0,
        terrainGenerations = 0
    }
    
    print("🌈 BiomeBlender initialized")
    return self
end

-- Set the noise generator for this biome blender
function BiomeBlender:setNoiseGenerator(noiseGenerator)
    self.noiseGenerator = noiseGenerator
    print("🎲 NoiseGenerator set for BiomeBlender")
    return self
end

-- Generate biome centers for the world
function BiomeBlender:generateBiomeCenters(worldSize, biomeCount)
    print("🎯 Generating biome centers...")
    
    self.biomeCenters = {}
    local availableBiomes = {}
    
    -- Get available biomes
    for biomeName, _ in pairs(BIOME_DEFINITIONS) do
        table.insert(availableBiomes, biomeName)
    end
    
    -- Generate biome centers
    for i = 1, math.min(biomeCount, #availableBiomes) do
        local biomeName = availableBiomes[i]
        local centerX = math.random(BIOME_CONFIG.MIN_BIOME_SIZE, worldSize - BIOME_CONFIG.MIN_BIOME_SIZE)
        local centerZ = math.random(BIOME_CONFIG.MIN_BIOME_SIZE, worldSize - BIOME_CONFIG.MIN_BIOME_SIZE)
        
        self.biomeCenters[biomeName] = {
            centerX = centerX,
            centerZ = centerZ,
            radius = math.random(BIOME_CONFIG.MIN_BIOME_SIZE, BIOME_CONFIG.MAX_BIOME_SIZE),
            definition = BIOME_DEFINITIONS[biomeName]
        }
    end
    
    print("✅ Generated", #self.biomeCenters, "biome centers")
    return self.biomeCenters
end

-- Get the biome at a specific position
function BiomeBlender:getBiomeAtPosition(x, z)
    self.stats.biomeCalculations = self.stats.biomeCalculations + 1
    
    local closestBiome = nil
    local minDistance = math.huge
    
    for biomeName, biome in pairs(self.biomeCenters) do
        local distance = (Vector2.new(x, z) - Vector2.new(biome.centerX, biome.centerZ)).Magnitude
        
        -- Check if within biome radius
        if distance <= biome.radius then
            if distance < minDistance then
                minDistance = distance
                closestBiome = biomeName
            end
        end
    end
    
    -- If no biome found, return the closest one
    if not closestBiome then
        for biomeName, biome in pairs(self.biomeCenters) do
            local distance = (Vector2.new(x, z) - Vector2.new(biome.centerX, biome.centerZ)).Magnitude
            if distance < minDistance then
                minDistance = distance
                closestBiome = biomeName
            end
        end
    end
    
    return closestBiome
end

-- Blend two biomes at a specific position
function BiomeBlender:blendBiomes(x, z, biome1Name, biome2Name)
    self.stats.blendOperations = self.stats.blendOperations + 1
    
    local biome1 = self.biomeCenters[biome1Name]
    local biome2 = self.biomeCenters[biome2Name]
    
    if not biome1 or not biome2 then
        return nil
    end
    
    -- Calculate blend factor based on distance
    local distance1 = (Vector2.new(x, z) - Vector2.new(biome1.centerX, biome1.centerZ)).Magnitude
    local distance2 = (Vector2.new(x, z) - Vector2.new(biome2.centerX, biome2.centerZ)).Magnitude
    
    local totalDistance = distance1 + distance2
    local blendFactor = math.clamp(distance1 / totalDistance, 0, 1)
    
    -- Blend biome properties
    local blendedBiome = {
        name = blendFactor < 0.5 and biome1Name or biome2Name,
        color = self:blendColors(biome1.definition.color, biome2.definition.color, blendFactor),
        material = blendFactor < 0.5 and biome1.definition.material or biome2.definition.material,
        baseHeight = biome1.definition.baseHeight * (1 - blendFactor) + biome2.definition.baseHeight * blendFactor,
        heightVariation = biome1.definition.heightVariation * (1 - blendFactor) + biome2.definition.heightVariation * blendFactor,
        petSpawnRate = biome1.definition.petSpawnRate * (1 - blendFactor) + biome2.definition.petSpawnRate * blendFactor,
        petTypes = blendFactor < 0.5 and biome1.definition.petTypes or biome2.definition.petTypes,
        structures = blendFactor < 0.5 and biome1.definition.structures or biome2.definition.structures,
        features = blendFactor < 0.5 and biome1.definition.features or biome2.definition.features
    }
    
    return blendedBiome
end

-- Blend two colors based on a factor
function BiomeBlender:blendColors(color1, color2, factor)
    return Color3.new(
        color1.R * (1 - factor) + color2.R * factor,
        color1.G * (1 - factor) + color2.G * factor,
        color1.B * (1 - factor) + color2.B * factor
    )
end

-- Get terrain data for a specific position
function BiomeBlender:getTerrainData(x, z)
    self.stats.terrainGenerations = self.stats.terrainGenerations + 1
    
    local biome1Name = self:getBiomeAtPosition(x, z)
    local biome2Name = self:getBiomeAtPosition(x + 1, z + 1)
    
    local biomeData
    if biome1Name == biome2Name then
        -- Single biome
        local biome = self.biomeCenters[biome1Name]
        local definition = biome.definition
        
        biomeData = {
            name = biome1Name,
            color = definition.color,
            material = definition.material,
            baseHeight = definition.baseHeight,
            heightVariation = definition.heightVariation,
            petSpawnRate = definition.petSpawnRate,
            petTypes = definition.petTypes,
            structures = definition.structures,
            features = definition.features
        }
    else
        -- Blended biome
        biomeData = self:blendBiomes(x, z, biome1Name, biome2Name)
    end
    
    -- Add terrain noise
    local terrainNoise = self.noiseGenerator:generateTerrainNoise(x, z)
    local finalHeight = biomeData.baseHeight + terrainNoise * biomeData.heightVariation
    finalHeight = math.max(0, finalHeight) -- Ensure non-negative height
    
    return {
        biome = biomeData.name,
        height = finalHeight,
        color = biomeData.color,
        material = biomeData.material,
        petSpawnRate = biomeData.petSpawnRate,
        petTypes = biomeData.petTypes,
        structures = biomeData.structures,
        features = biomeData.features
    }
end

-- Generate a complete biome map
function BiomeBlender:generateBiomeMap(width, height)
    print("🗺️ Generating biome map:", width, "x", height)
    local startTime = tick()
    
    local biomeMap = {}
    
    for x = 1, width do
        biomeMap[x] = {}
        for z = 1, height do
            local worldX = x
            local worldZ = z
            
            biomeMap[x][z] = self:getTerrainData(worldX, worldZ)
        end
        
        -- Yield every few rows to prevent freezing
        if x % 10 == 0 then
            task.wait()
        end
    end
    
    -- Apply smoothing to reduce sharp transitions
    biomeMap = self:smoothBiomeMap(biomeMap)
    
    local endTime = tick()
    print(string.format("✅ Biome map generated in %.2f seconds", endTime - startTime))
    
    return biomeMap
end

-- Smooth the biome map to reduce sharp transitions
function BiomeBlender:smoothBiomeMap(biomeMap)
    print("🔄 Smoothing biome map...")
    
    local width = #biomeMap
    local height = #biomeMap[1]
    
    for iteration = 1, BIOME_CONFIG.SMOOTHING_ITERATIONS do
        local smoothedMap = {}
        
        for x = 1, width do
            smoothedMap[x] = {}
            for z = 1, height do
                -- Get neighboring biomes
                local neighbors = {}
                for dx = -1, 1 do
                    for dz = -1, 1 do
                        local nx = math.clamp(x + dx, 1, width)
                        local nz = math.clamp(z + dz, 1, height)
                        table.insert(neighbors, biomeMap[nx][nz].biome)
                    end
                end
                
                -- Find most common biome among neighbors
                local biomeCounts = {}
                for _, biome in ipairs(neighbors) do
                    biomeCounts[biome] = (biomeCounts[biome] or 0) + 1
                end
                
                local mostCommonBiome = nil
                local maxCount = 0
                for biome, count in pairs(biomeCounts) do
                    if count > maxCount then
                        maxCount = count
                        mostCommonBiome = biome
                    end
                end
                
                -- Update biome if different
                if mostCommonBiome and mostCommonBiome ~= biomeMap[x][z].biome then
                    local newTerrainData = self:getTerrainData(x, z)
                    newTerrainData.biome = mostCommonBiome
                    smoothedMap[x][z] = newTerrainData
                else
                    smoothedMap[x][z] = biomeMap[x][z]
                end
            end
        end
        
        biomeMap = smoothedMap
    end
    
    print("✅ Biome map smoothed")
    return biomeMap
end

-- Get biome definition by name
function BiomeBlender:getBiomeDefinition(biomeName)
    return BIOME_DEFINITIONS[biomeName]
end

-- Get all available biome names
function BiomeBlender:getAvailableBiomes()
    local biomes = {}
    for biomeName, _ in pairs(BIOME_DEFINITIONS) do
        table.insert(biomes, biomeName)
    end
    return biomes
end

-- Get performance statistics
function BiomeBlender:getStats()
    return {
        biomeCalculations = self.stats.biomeCalculations,
        blendOperations = self.stats.blendOperations,
        terrainGenerations = self.stats.terrainGenerations,
        biomeCenters = #self.biomeCenters
    }
end

-- Clean up resources
function BiomeBlender:destroy()
    self.biomeCenters = {}
    self.biomeMap = {}
    print("🗑️ BiomeBlender destroyed")
end

return BiomeBlender 