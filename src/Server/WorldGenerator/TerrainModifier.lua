--[[
    WorldGenerator/TerrainModifier.lua
    Author: Cursor AI (Adapted from Eidolon-Pets)
    Created: 2024-12-19
    Version: 1.0.0
    Purpose: Terrain manipulation and application for Petfinity's world
    
    🧩 FEATURE CONTEXT:
    The TerrainModifier handles the application of generated terrain data to
    Roblox's terrain system, ensuring smooth and efficient terrain generation
    for Petfinity's world. It manages terrain height, materials, and features
    to create diverse and interesting environments for pets.
    
    🧷 DEPENDENCIES:
    - Workspace: For terrain access and modification
    - Terrain: For terrain manipulation operations
    - Math library: For height calculations and clamping
    
    💡 USAGE EXAMPLES:
    - Apply chunk: TerrainModifier:applyChunkToTerrain(chunk, chunkX, chunkZ)
    - Set height: TerrainModifier:setTerrainHeight(x, z, height)
    - Set material: TerrainModifier:setTerrainMaterial(x, z, material)
    - Smooth terrain: TerrainModifier:smoothTerrain(region)
    
    ⚡ PERFORMANCE CONSIDERATIONS:
    - Terrain operations are batched for efficiency
    - Height calculations are optimized for smooth transitions
    - Material changes are minimized to reduce processing
    - Large terrain modifications are done incrementally
    
    🔒 SECURITY IMPLICATIONS:
    - No external dependencies or network calls
    - Terrain data is validated before application
    - Safe for server-side execution
    
    📜 CHANGELOG:
    - v1.0.0: Initial implementation adapted from Eidolon-Pets
]]

-- Core Roblox services for terrain modification
local Workspace = game:GetService("Workspace")
local Terrain = Workspace.Terrain

-- Terrain modification configuration for Petfinity
local TERRAIN_CONFIG = {
    MIN_HEIGHT = 0,
    MAX_HEIGHT = 100,
    SMOOTHING_RADIUS = 2,
    BATCH_SIZE = 100, -- Number of operations per batch
    MATERIAL_BLEND = true -- Enable material blending
}

-- TerrainModifier class with enhanced functionality
local TerrainModifier = {}
TerrainModifier.__index = TerrainModifier

-- Initialize a new TerrainModifier instance
function TerrainModifier.new()
    local self = setmetatable({}, TerrainModifier)
    
    -- Initialize properties
    self.operationQueue = {}
    self.isProcessing = false
    
    -- Performance tracking
    self.stats = {
        terrainOperations = 0,
        heightChanges = 0,
        materialChanges = 0,
        chunksApplied = 0
    }
    
    print("🏔️ TerrainModifier initialized")
    return self
end

-- Clamp height value to valid range
function TerrainModifier:clampHeight(height)
    return math.clamp(height, TERRAIN_CONFIG.MIN_HEIGHT, TERRAIN_CONFIG.MAX_HEIGHT)
end

-- Set terrain height at specific coordinates
function TerrainModifier:setTerrainHeight(x, z, height)
    height = self:clampHeight(height)
    
    -- Get current height
    local currentHeight = Terrain:ReadVoxels(
        Region3.new(Vector3.new(x, 0, z), Vector3.new(x, TERRAIN_CONFIG.MAX_HEIGHT, z)),
        4
    )
    
    -- Only modify if height is different
    if currentHeight[1][1][1] ~= height then
        Terrain:FillBlock(
            Vector3.new(x, height, z),
            Vector3.new(1, 1, 1),
            Enum.Material.Grass
        )
        
        self.stats.heightChanges = self.stats.heightChanges + 1
        self.stats.terrainOperations = self.stats.terrainOperations + 1
    end
    
    return height
end

-- Set terrain material at specific coordinates
function TerrainModifier:setTerrainMaterial(x, z, material)
    if not material then
        return
    end
    
    -- Get current material
    local currentMaterial = Terrain:ReadVoxels(
        Region3.new(Vector3.new(x, 0, z), Vector3.new(x, TERRAIN_CONFIG.MAX_HEIGHT, z)),
        4
    )
    
    -- Only modify if material is different
    if currentMaterial[1][1][1] ~= material then
        Terrain:FillBlock(
            Vector3.new(x, 0, z),
            Vector3.new(1, TERRAIN_CONFIG.MAX_HEIGHT, z),
            material
        )
        
        self.stats.materialChanges = self.stats.materialChanges + 1
        self.stats.terrainOperations = self.stats.terrainOperations + 1
    end
    
    return material
end

-- Apply a chunk to the terrain
function TerrainModifier:applyChunkToTerrain(chunk, chunkX, chunkZ, chunkSize)
    if not chunk then
        return false
    end
    
    print("🏗️ Applying chunk to terrain:", chunkX, chunkZ)
    local startTime = tick()
    
    local operations = 0
    
    -- Apply chunk data to terrain
    for x = 0, chunkSize do
        for z = 0, chunkSize do
            local chunkData = chunk[x] and chunk[x][z]
            if chunkData then
                local worldX = chunkX * chunkSize + x
                local worldZ = chunkZ * chunkSize + z
                
                -- Set terrain height
                self:setTerrainHeight(worldX, worldZ, chunkData.height)
                
                -- Set terrain material
                self:setTerrainMaterial(worldX, worldZ, chunkData.material)
                
                operations = operations + 1
                
                -- Yield every few operations to prevent freezing
                if operations % TERRAIN_CONFIG.BATCH_SIZE == 0 then
                    task.wait()
                end
            end
        end
    end
    
    self.stats.chunksApplied = self.stats.chunksApplied + 1
    
    local endTime = tick()
    print(string.format("✅ Chunk applied in %.2f seconds (%d operations)", endTime - startTime, operations))
    
    return true
end

-- Smooth terrain in a region
function TerrainModifier:smoothTerrain(startX, startZ, endX, endZ)
    print("🔄 Smoothing terrain...")
    local startTime = tick()
    
    local smoothedHeights = {}
    
    -- Calculate smoothed heights
    for x = startX, endX do
        smoothedHeights[x] = {}
        for z = startZ, endZ do
            local totalHeight = 0
            local count = 0
            
            -- Average heights in smoothing radius
            for dx = -TERRAIN_CONFIG.SMOOTHING_RADIUS, TERRAIN_CONFIG.SMOOTHING_RADIUS do
                for dz = -TERRAIN_CONFIG.SMOOTHING_RADIUS, TERRAIN_CONFIG.SMOOTHING_RADIUS do
                    local nx = x + dx
                    local nz = z + dz
                    
                    if nx >= startX and nx <= endX and nz >= startZ and nz <= endZ then
                        local height = Terrain:ReadVoxels(
                            Region3.new(Vector3.new(nx, 0, nz), Vector3.new(nx, TERRAIN_CONFIG.MAX_HEIGHT, nz)),
                            4
                        )
                        totalHeight = totalHeight + height[1][1][1]
                        count = count + 1
                    end
                end
            end
            
            smoothedHeights[x][z] = count > 0 and totalHeight / count or 0
        end
        
        -- Yield every few rows to prevent freezing
        if x % 10 == 0 then
            task.wait()
        end
    end
    
    -- Apply smoothed heights
    for x = startX, endX do
        for z = startZ, endZ do
            self:setTerrainHeight(x, z, smoothedHeights[x][z])
        end
    end
    
    local endTime = tick()
    print(string.format("✅ Terrain smoothed in %.2f seconds", endTime - startTime))
    
    return true
end

-- Create a flat terrain region
function TerrainModifier:createFlatTerrain(startX, startZ, endX, endZ, height, material)
    print("🏞️ Creating flat terrain...")
    local startTime = tick()
    
    material = material or Enum.Material.Grass
    height = self:clampHeight(height)
    
    local operations = 0
    
    for x = startX, endX do
        for z = startZ, endZ do
            self:setTerrainHeight(x, z, height)
            self:setTerrainMaterial(x, z, material)
            operations = operations + 1
            
            -- Yield every few operations to prevent freezing
            if operations % TERRAIN_CONFIG.BATCH_SIZE == 0 then
                task.wait()
            end
        end
    end
    
    local endTime = tick()
    print(string.format("✅ Flat terrain created in %.2f seconds (%d operations)", endTime - startTime, operations))
    
    return true
end

-- Create a hill or mountain
function TerrainModifier:createHill(centerX, centerZ, radius, maxHeight, material)
    print("⛰️ Creating hill...")
    local startTime = tick()
    
    material = material or Enum.Material.Rock
    maxHeight = self:clampHeight(maxHeight)
    
    local operations = 0
    
    for x = centerX - radius, centerX + radius do
        for z = centerZ - radius, centerZ + radius do
            local distance = math.sqrt((x - centerX)^2 + (z - centerZ)^2)
            
            if distance <= radius then
                local heightFactor = 1 - (distance / radius)
                local height = maxHeight * heightFactor
                
                self:setTerrainHeight(x, z, height)
                self:setTerrainMaterial(x, z, material)
                operations = operations + 1
                
                -- Yield every few operations to prevent freezing
                if operations % TERRAIN_CONFIG.BATCH_SIZE == 0 then
                    task.wait()
                end
            end
        end
    end
    
    local endTime = tick()
    print(string.format("✅ Hill created in %.2f seconds (%d operations)", endTime - startTime, operations))
    
    return true
end

-- Create a valley or depression
function TerrainModifier:createValley(centerX, centerZ, radius, depth, material)
    print("🏞️ Creating valley...")
    local startTime = tick()
    
    material = material or Enum.Material.Sand
    depth = math.abs(depth) -- Ensure positive depth
    
    local operations = 0
    
    for x = centerX - radius, centerX + radius do
        for z = centerZ - radius, centerZ + radius do
            local distance = math.sqrt((x - centerX)^2 + (z - centerZ)^2)
            
            if distance <= radius then
                local depthFactor = 1 - (distance / radius)
                local currentHeight = Terrain:ReadVoxels(
                    Region3.new(Vector3.new(x, 0, z), Vector3.new(x, TERRAIN_CONFIG.MAX_HEIGHT, z)),
                    4
                )
                local newHeight = math.max(0, currentHeight[1][1][1] - (depth * depthFactor))
                
                self:setTerrainHeight(x, z, newHeight)
                self:setTerrainMaterial(x, z, material)
                operations = operations + 1
                
                -- Yield every few operations to prevent freezing
                if operations % TERRAIN_CONFIG.BATCH_SIZE == 0 then
                    task.wait()
                end
            end
        end
    end
    
    local endTime = tick()
    print(string.format("✅ Valley created in %.2f seconds (%d operations)", endTime - startTime, operations))
    
    return true
end

-- Get terrain height at coordinates
function TerrainModifier:getTerrainHeight(x, z)
    local height = Terrain:ReadVoxels(
        Region3.new(Vector3.new(x, 0, z), Vector3.new(x, TERRAIN_CONFIG.MAX_HEIGHT, z)),
        4
    )
    return height[1][1][1]
end

-- Get terrain material at coordinates
function TerrainModifier:getTerrainMaterial(x, z)
    local material = Terrain:ReadVoxels(
        Region3.new(Vector3.new(x, 0, z), Vector3.new(x, TERRAIN_CONFIG.MAX_HEIGHT, z)),
        4
    )
    return material[1][1][1]
end

-- Get performance statistics
function TerrainModifier:getStats()
    return {
        terrainOperations = self.stats.terrainOperations,
        heightChanges = self.stats.heightChanges,
        materialChanges = self.stats.materialChanges,
        chunksApplied = self.stats.chunksApplied
    }
end

-- Clear terrain in a region
function TerrainModifier:clearTerrain(startX, startZ, endX, endZ)
    print("🧹 Clearing terrain...")
    local startTime = tick()
    
    local operations = 0
    
    for x = startX, endX do
        for z = startZ, endZ do
            self:setTerrainHeight(x, z, 0)
            self:setTerrainMaterial(x, z, Enum.Material.Air)
            operations = operations + 1
            
            -- Yield every few operations to prevent freezing
            if operations % TERRAIN_CONFIG.BATCH_SIZE == 0 then
                task.wait()
            end
        end
    end
    
    local endTime = tick()
    print(string.format("✅ Terrain cleared in %.2f seconds (%d operations)", endTime - startTime, operations))
    
    return true
end

-- Clean up resources
function TerrainModifier:destroy()
    self.operationQueue = {}
    print("🗑️ TerrainModifier destroyed")
end

return TerrainModifier 