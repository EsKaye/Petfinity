--[[
    WorldGenerator/NoiseGenerator.lua
    Author: Cursor AI (Adapted from Eidolon-Pets)
    Created: 2024-12-19
    Version: 1.0.0
    Purpose: Advanced noise generation for Petfinity's procedural world creation
    
    🧩 FEATURE CONTEXT:
    The NoiseGenerator provides sophisticated procedural noise generation for
    creating natural-looking terrain, biomes, and features in Petfinity's world.
    It uses multi-octave Perlin noise with configurable parameters to generate
    varied and interesting landscapes that pets can inhabit and explore.
    
    🧷 DEPENDENCIES:
    - Workspace: For terrain manipulation and visualization
    - Terrain: For debug visualization and terrain generation
    - Math library: For noise generation and mathematical operations
    
    💡 USAGE EXAMPLES:
    - Generate terrain: NoiseGenerator:generateTerrainNoise(x, z)
    - Generate biomes: NoiseGenerator:generateBiomeNoise(x, z)
    - Generate features: NoiseGenerator:generateFeatureNoise(x, z)
    - Clear cache: NoiseGenerator:clearCache()
    
    ⚡ PERFORMANCE CONSIDERATIONS:
    - Noise values are cached to avoid redundant calculations
    - Multi-octave noise provides natural variation efficiently
    - Debug visualization can be disabled for production
    - Cache clearing prevents memory bloat
    
    🔒 SECURITY IMPLICATIONS:
    - No external dependencies or network calls
    - Deterministic output based on input coordinates
    - Safe for server-side execution
    
    📜 CHANGELOG:
    - v1.0.0: Initial implementation adapted from Eidolon-Pets
]]

-- Core Roblox services for noise generation
local Workspace = game:GetService("Workspace")
local Terrain = Workspace.Terrain

-- Noise generation configuration for Petfinity
local NOISE_CONFIG = {
    TERRAIN = {
        scale = 0.01,
        octaves = 4,
        persistence = 0.5,
        lacunarity = 2,
        amplitude = 20
    },
    BIOME = {
        scale = 0.005,
        octaves = 3,
        persistence = 0.6,
        lacunarity = 2.5,
        amplitude = 1
    },
    FEATURE = {
        scale = 0.02,
        octaves = 2,
        persistence = 0.7,
        lacunarity = 1.8,
        amplitude = 10
    }
}

-- Debug configuration
local DEBUG_CONFIG = {
    VISUALIZATION = false, -- Set to true for terrain visualization
    HEIGHT = 50,
    MATERIAL = Enum.Material.Neon
}

-- NoiseGenerator class with enhanced functionality
local NoiseGenerator = {}
NoiseGenerator.__index = NoiseGenerator

-- Cache for noise values to improve performance
local noiseCache = {}

-- Initialize a new NoiseGenerator instance
function NoiseGenerator.new()
    local self = setmetatable({}, NoiseGenerator)
    
    -- Initialize properties
    self.seed = os.time()
    self.cacheEnabled = true
    self.debugMode = false
    
    -- Performance tracking
    self.stats = {
        cacheHits = 0,
        cacheMisses = 0,
        totalGenerations = 0
    }
    
    print("🎲 NoiseGenerator initialized with seed:", self.seed)
    return self
end

-- Set the seed for deterministic noise generation
function NoiseGenerator:setSeed(seed)
    self.seed = seed or os.time()
    print("🎲 NoiseGenerator seed set to:", self.seed)
    return self
end

-- Enable or disable debug mode
function NoiseGenerator:setDebugMode(enabled)
    self.debugMode = enabled
    DEBUG_CONFIG.VISUALIZATION = enabled
    print("🔧 Debug mode:", enabled and "enabled" or "disabled")
    return self
end

-- Enable or disable caching
function NoiseGenerator:setCacheEnabled(enabled)
    self.cacheEnabled = enabled
    if not enabled then
        self:clearCache()
    end
    print("💾 Cache:", enabled and "enabled" or "disabled")
    return self
end

-- Generate multi-octave Perlin noise with configurable parameters
function NoiseGenerator:generateNoise(x, z, config)
    config = config or NOISE_CONFIG.TERRAIN
    
    -- Create cache key for this specific generation
    local cacheKey = string.format("%d,%d,%.3f,%d,%.2f,%.2f", 
        x, z, config.scale, config.octaves, config.persistence, config.lacunarity)
    
    -- Check cache first
    if self.cacheEnabled and noiseCache[cacheKey] then
        self.stats.cacheHits = self.stats.cacheHits + 1
        return noiseCache[cacheKey]
    end
    
    self.stats.cacheMisses = self.stats.cacheMisses + 1
    self.stats.totalGenerations = self.stats.totalGenerations + 1
    
    -- Generate multi-octave noise
    local total = 0
    local frequency = 1
    local amplitude = 1
    local maxValue = 0
    
    for i = 1, config.octaves do
        -- Add seed offset for deterministic generation
        local noiseX = (x * config.scale * frequency) + self.seed
        local noiseZ = (z * config.scale * frequency) + self.seed
        
        total = total + math.noise(noiseX, noiseZ) * amplitude
        maxValue = maxValue + amplitude
        amplitude = amplitude * config.persistence
        frequency = frequency * config.lacunarity
    end
    
    local result = (total / maxValue) * config.amplitude
    
    -- Cache the result
    if self.cacheEnabled then
        noiseCache[cacheKey] = result
    end
    
    -- Debug visualization
    if self.debugMode and DEBUG_CONFIG.VISUALIZATION then
        self:createDebugVisualization(x, z, result)
    end
    
    return result
end

-- Generate terrain noise for heightmap creation
function NoiseGenerator:generateTerrainNoise(x, z)
    return self:generateNoise(x, z, NOISE_CONFIG.TERRAIN)
end

-- Generate biome noise for biome determination
function NoiseGenerator:generateBiomeNoise(x, z)
    return self:generateNoise(x, z, NOISE_CONFIG.BIOME)
end

-- Generate feature noise for structure placement
function NoiseGenerator:generateFeatureNoise(x, z)
    return self:generateNoise(x, z, NOISE_CONFIG.FEATURE)
end

-- Generate humidity noise for biome variation
function NoiseGenerator:generateHumidityNoise(x, z)
    local config = {
        scale = 0.02,
        octaves = 2,
        persistence = 0.6,
        lacunarity = 2,
        amplitude = 1
    }
    return self:generateNoise(x, z, config)
end

-- Generate temperature noise for biome variation
function NoiseGenerator:generateTemperatureNoise(x, z)
    local config = {
        scale = 0.01,
        octaves = 3,
        persistence = 0.5,
        lacunarity = 2.2,
        amplitude = 1
    }
    -- Add offset to temperature noise for variation
    return self:generateNoise(x + 100, z + 100, config)
end

-- Create debug visualization for noise values
function NoiseGenerator:createDebugVisualization(x, z, height)
    local height = math.floor(height * 2) -- Scale for visibility
    height = math.clamp(height, 1, 20) -- Limit height range
    
    Terrain:FillBlock(
        Vector3.new(x, DEBUG_CONFIG.HEIGHT, z),
        Vector3.new(1, height, 1),
        DEBUG_CONFIG.MATERIAL
    )
end

-- Generate a complete heightmap for a region
function NoiseGenerator:generateHeightmap(startX, startZ, width, height)
    print("🗺️ Generating heightmap:", width, "x", height)
    local startTime = tick()
    
    local heightmap = {}
    
    for x = 1, width do
        heightmap[x] = {}
        for z = 1, height do
            local worldX = startX + x - 1
            local worldZ = startZ + z - 1
            
            -- Generate base terrain
            local baseHeight = self:generateTerrainNoise(worldX, worldZ)
            
            -- Add medium-scale variation
            local mediumVariation = self:generateNoise(worldX, worldZ, {
                scale = 0.05,
                octaves = 2,
                persistence = 0.6,
                lacunarity = 2,
                amplitude = 10
            })
            
            -- Add small-scale variation
            local smallVariation = self:generateNoise(worldX, worldZ, {
                scale = 0.1,
                octaves = 1,
                persistence = 0.8,
                lacunarity = 1.5,
                amplitude = 5
            })
            
            -- Combine all variations
            local finalHeight = baseHeight + mediumVariation + smallVariation
            finalHeight = math.max(0, finalHeight) -- Ensure non-negative height
            
            heightmap[x][z] = finalHeight
        end
        
        -- Yield every few rows to prevent freezing
        if x % 10 == 0 then
            task.wait()
        end
    end
    
    local endTime = tick()
    print(string.format("✅ Heightmap generated in %.2f seconds", endTime - startTime))
    
    return heightmap
end

-- Clear the noise cache to free memory
function NoiseGenerator:clearCache()
    noiseCache = {}
    print("🧹 Noise cache cleared")
    return self
end

-- Get performance statistics
function NoiseGenerator:getStats()
    local cacheHitRate = self.stats.totalGenerations > 0 and 
        (self.stats.cacheHits / self.stats.totalGenerations) * 100 or 0
    
    return {
        cacheHits = self.stats.cacheHits,
        cacheMisses = self.stats.cacheMisses,
        totalGenerations = self.stats.totalGenerations,
        cacheHitRate = cacheHitRate,
        cacheSize = self:getCacheSize()
    }
end

-- Get the current cache size
function NoiseGenerator:getCacheSize()
    local count = 0
    for _ in pairs(noiseCache) do
        count = count + 1
    end
    return count
end

-- Generate debug visualization for a region
function NoiseGenerator:generateDebugVisualization(centerX, centerZ, radius)
    if not self.debugMode then
        print("⚠️ Debug mode is disabled. Enable with setDebugMode(true)")
        return
    end
    
    print("🎨 Generating noise visualization...")
    local startTime = tick()
    
    for x = centerX - radius, centerX + radius do
        for z = centerZ - radius, centerZ + radius do
            self:generateTerrainNoise(x, z)
        end
    end
    
    local endTime = tick()
    print(string.format("✅ Noise visualization complete! Time taken: %.2f seconds", endTime - startTime))
end

-- Clean up resources
function NoiseGenerator:destroy()
    self:clearCache()
    print("🗑️ NoiseGenerator destroyed")
end

return NoiseGenerator 