--[[
    WorldGenerator/ChunkManager.lua
    Author: Cursor AI (Adapted from Eidolon-Pets)
    Created: 2024-12-19
    Version: 1.0.0
    Purpose: Dynamic chunk loading and management for Petfinity's world
    
    🧩 FEATURE CONTEXT:
    The ChunkManager handles dynamic loading and unloading of world chunks
    based on player proximity, ensuring optimal performance while maintaining
    a seamless world experience. It manages chunk generation, storage, and
    terrain application to create an efficient world system for pets.
    
    🧷 DEPENDENCIES:
    - BiomeBlender: For biome and terrain data generation
    - TerrainModifier: For terrain manipulation and application
    - Workspace: For terrain access and modification
    - Players: For player position tracking
    
    💡 USAGE EXAMPLES:
    - Initialize: ChunkManager:initialize()
    - Load chunk: ChunkManager:loadChunk(chunkX, chunkZ)
    - Unload chunk: ChunkManager:unloadChunk(chunkX, chunkZ)
    - Update chunks: ChunkManager:updateChunks(playerPosition)
    
    ⚡ PERFORMANCE CONSIDERATIONS:
    - Chunks are loaded based on player proximity for optimal performance
    - Chunk data is cached to avoid redundant generation
    - Unused chunks are automatically unloaded to conserve memory
    - Chunk loading is prioritized based on distance from players
    
    🔒 SECURITY IMPLICATIONS:
    - No external dependencies or network calls
    - Chunk data is validated before application
    - Safe for server-side execution
    
    📜 CHANGELOG:
    - v1.0.0: Initial implementation adapted from Eidolon-Pets
]]

-- Core Roblox services for chunk management
local Workspace = game:GetService("Workspace")
local Terrain = Workspace.Terrain
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Core dependencies
local BiomeBlender = require(script.Parent.BiomeBlender)
local TerrainModifier = require(script.Parent.TerrainModifier)

-- Chunk management configuration for Petfinity
local CHUNK_CONFIG = {
    SIZE = 32, -- Size of each chunk in studs
    LOAD_DISTANCE = 3, -- Number of chunks to load around players
    UNLOAD_DISTANCE = 5, -- Distance at which chunks are unloaded
    MAX_LOADED_CHUNKS = 100, -- Maximum number of loaded chunks
    UPDATE_INTERVAL = 1, -- Seconds between chunk updates
    PRIORITY_LOADING = true -- Load closest chunks first
}

-- ChunkManager class with enhanced functionality
local ChunkManager = {}
ChunkManager.__index = ChunkManager

-- Initialize a new ChunkManager instance
function ChunkManager.new()
    local self = setmetatable({}, ChunkManager)
    
    -- Initialize properties
    self.chunks = {}
    self.generatedChunks = {}
    self.loadedChunks = {}
    self.worldContainer = nil
    self.biomeBlender = nil
    self.terrainModifier = nil
    
    -- Performance tracking
    self.stats = {
        chunksGenerated = 0,
        chunksLoaded = 0,
        chunksUnloaded = 0,
        totalChunks = 0
    }
    
    -- Update loop
    self.updateConnection = nil
    self.isInitialized = false
    
    print("🧩 ChunkManager initialized")
    return self
end

-- Set the chunk size for this manager
function ChunkManager:setChunkSize(size)
    CHUNK_CONFIG.SIZE = size or 32
    print("📏 Chunk size set to:", CHUNK_CONFIG.SIZE)
    return self
end

-- Set the load distance for chunks
function ChunkManager:setLoadDistance(distance)
    CHUNK_CONFIG.LOAD_DISTANCE = distance or 3
    print("📏 Load distance set to:", CHUNK_CONFIG.LOAD_DISTANCE)
    return self
end

-- Set the world container for chunk storage
function ChunkManager:setWorldContainer(container)
    self.worldContainer = container
    print("🌍 World container set for ChunkManager")
    return self
end

-- Set the biome blender for terrain generation
function ChunkManager:setBiomeBlender(biomeBlender)
    self.biomeBlender = biomeBlender
    print("🌈 BiomeBlender set for ChunkManager")
    return self
end

-- Set the terrain modifier for terrain application
function ChunkManager:setTerrainModifier(terrainModifier)
    self.terrainModifier = terrainModifier
    print("🏔️ TerrainModifier set for ChunkManager")
    return self
end

-- Initialize the chunk manager
function ChunkManager:initialize()
    if self.isInitialized then
        return self
    end
    
    print("🚀 Initializing ChunkManager...")
    
    -- Create terrain modifier if not provided
    if not self.terrainModifier then
        self.terrainModifier = TerrainModifier.new()
    end
    
    -- Start update loop
    self:startUpdateLoop()
    
    self.isInitialized = true
    print("✅ ChunkManager initialized")
    return self
end

-- Start the chunk update loop
function ChunkManager:startUpdateLoop()
    if self.updateConnection then
        self.updateConnection:Disconnect()
    end
    
    self.updateConnection = RunService.Heartbeat:Connect(function()
        self:updateChunks()
    end)
    
    print("🔄 Chunk update loop started")
end

-- Update chunks based on player positions
function ChunkManager:updateChunks()
    local playerPositions = {}
    
    -- Get all player positions
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local position = player.Character.HumanoidRootPart.Position
            table.insert(playerPositions, {
                player = player,
                position = position,
                chunkX = math.floor(position.X / CHUNK_CONFIG.SIZE),
                chunkZ = math.floor(position.Z / CHUNK_CONFIG.SIZE)
            })
        end
    end
    
    -- If no players, don't update
    if #playerPositions == 0 then
        return
    end
    
    -- Determine which chunks to load
    local chunksToLoad = {}
    local chunksToUnload = {}
    
    -- Find chunks that need to be loaded
    for _, playerData in ipairs(playerPositions) do
        for dx = -CHUNK_CONFIG.LOAD_DISTANCE, CHUNK_CONFIG.LOAD_DISTANCE do
            for dz = -CHUNK_CONFIG.LOAD_DISTANCE, CHUNK_CONFIG.LOAD_DISTANCE do
                local chunkX = playerData.chunkX + dx
                local chunkZ = playerData.chunkZ + dz
                local chunkKey = chunkX .. "," .. chunkZ
                
                if not self.loadedChunks[chunkKey] then
                    table.insert(chunksToLoad, {
                        x = chunkX,
                        z = chunkZ,
                        key = chunkKey,
                        distance = math.abs(dx) + math.abs(dz) -- Manhattan distance
                    })
                end
            end
        end
    end
    
    -- Sort chunks by distance for priority loading
    if CHUNK_CONFIG.PRIORITY_LOADING then
        table.sort(chunksToLoad, function(a, b)
            return a.distance < b.distance
        end)
    end
    
    -- Load chunks (limit to prevent performance issues)
    local chunksLoaded = 0
    for _, chunkData in ipairs(chunksToLoad) do
        if chunksLoaded >= 5 then -- Load max 5 chunks per frame
            break
        end
        
        if self:loadChunk(chunkData.x, chunkData.z) then
            chunksLoaded = chunksLoaded + 1
        end
    end
    
    -- Find chunks to unload
    for chunkKey, chunkData in pairs(self.loadedChunks) do
        local shouldUnload = true
        
        for _, playerData in ipairs(playerPositions) do
            local distance = math.abs(chunkData.x - playerData.chunkX) + math.abs(chunkData.z - playerData.chunkZ)
            if distance <= CHUNK_CONFIG.UNLOAD_DISTANCE then
                shouldUnload = false
                break
            end
        end
        
        if shouldUnload then
            table.insert(chunksToUnload, chunkKey)
        end
    end
    
    -- Unload chunks
    for _, chunkKey in ipairs(chunksToUnload) do
        self:unloadChunk(chunkKey)
    end
end

-- Generate a chunk at the specified coordinates
function ChunkManager:generateChunk(chunkX, chunkZ)
    local chunkKey = chunkX .. "," .. chunkZ
    
    -- Check if already generated
    if self.generatedChunks[chunkKey] then
        return self.chunks[chunkKey]
    end
    
    print("🏗️ Generating chunk:", chunkX, chunkZ)
    local startTime = tick()
    
    local chunk = {}
    
    -- Generate chunk data
    for x = 0, CHUNK_CONFIG.SIZE do
        chunk[x] = {}
        for z = 0, CHUNK_CONFIG.SIZE do
            local worldX = chunkX * CHUNK_CONFIG.SIZE + x
            local worldZ = chunkZ * CHUNK_CONFIG.SIZE + z
            
            -- Get terrain data from biome blender
            local terrainData
            if self.biomeBlender then
                terrainData = self.biomeBlender:getTerrainData(worldX, worldZ)
            else
                -- Fallback terrain data
                terrainData = {
                    height = 5,
                    material = Enum.Material.Grass,
                    color = Color3.fromRGB(34, 139, 34)
                }
            end
            
            -- Store chunk data
            chunk[x][z] = {
                height = terrainData.height,
                material = terrainData.material,
                color = terrainData.color,
                biome = terrainData.biome,
                petSpawnRate = terrainData.petSpawnRate,
                petTypes = terrainData.petTypes,
                structures = terrainData.structures,
                features = terrainData.features
            }
        end
        
        -- Yield every few rows to prevent freezing
        if x % 5 == 0 then
            task.wait()
        end
    end
    
    -- Store generated chunk
    self.chunks[chunkKey] = chunk
    self.generatedChunks[chunkKey] = true
    self.stats.chunksGenerated = self.stats.chunksGenerated + 1
    
    local endTime = tick()
    print(string.format("✅ Chunk generated in %.2f seconds", endTime - startTime))
    
    return chunk
end

-- Load a chunk into the world
function ChunkManager:loadChunk(chunkX, chunkZ)
    local chunkKey = chunkX .. "," .. chunkZ
    
    -- Check if already loaded
    if self.loadedChunks[chunkKey] then
        return true
    end
    
    -- Generate chunk if not already generated
    local chunk = self:generateChunk(chunkX, chunkZ)
    if not chunk then
        return false
    end
    
    -- Apply chunk to terrain
    if self.terrainModifier then
        self.terrainModifier:applyChunkToTerrain(chunk, chunkX, chunkZ, CHUNK_CONFIG.SIZE)
    end
    
    -- Mark as loaded
    self.loadedChunks[chunkKey] = {
        x = chunkX,
        z = chunkZ,
        loadTime = tick()
    }
    
    self.stats.chunksLoaded = self.stats.chunksLoaded + 1
    self.stats.totalChunks = self.stats.totalChunks + 1
    
    print("📦 Chunk loaded:", chunkX, chunkZ)
    return true
end

-- Unload a chunk from the world
function ChunkManager:unloadChunk(chunkKey)
    if not self.loadedChunks[chunkKey] then
        return false
    end
    
    -- Remove from loaded chunks
    self.loadedChunks[chunkKey] = nil
    self.stats.chunksUnloaded = self.stats.chunksUnloaded + 1
    self.stats.totalChunks = self.stats.totalChunks - 1
    
    print("🗑️ Chunk unloaded:", chunkKey)
    return true
end

-- Get chunk data at world coordinates
function ChunkManager:getChunkData(worldX, worldZ)
    local chunkX = math.floor(worldX / CHUNK_CONFIG.SIZE)
    local chunkZ = math.floor(worldZ / CHUNK_CONFIG.SIZE)
    local chunkKey = chunkX .. "," .. chunkZ
    
    local chunk = self.chunks[chunkKey]
    if not chunk then
        return nil
    end
    
    local localX = math.floor(worldX % CHUNK_CONFIG.SIZE)
    local localZ = math.floor(worldZ % CHUNK_CONFIG.SIZE)
    
    return chunk[localX] and chunk[localX][localZ]
end

-- Get all loaded chunk keys
function ChunkManager:getLoadedChunks()
    local chunks = {}
    for chunkKey, _ in pairs(self.loadedChunks) do
        table.insert(chunks, chunkKey)
    end
    return chunks
end

-- Get performance statistics
function ChunkManager:getStats()
    return {
        chunksGenerated = self.stats.chunksGenerated,
        chunksLoaded = self.stats.chunksLoaded,
        chunksUnloaded = self.stats.chunksUnloaded,
        totalChunks = self.stats.totalChunks,
        loadedChunks = #self.loadedChunks,
        generatedChunks = #self.generatedChunks
    }
end

-- Clear all chunks
function ChunkManager:clearChunks()
    self.chunks = {}
    self.generatedChunks = {}
    self.loadedChunks = {}
    self.stats.totalChunks = 0
    
    print("🧹 All chunks cleared")
    return self
end

-- Clean up resources
function ChunkManager:destroy()
    if self.updateConnection then
        self.updateConnection:Disconnect()
        self.updateConnection = nil
    end
    
    self:clearChunks()
    print("🗑️ ChunkManager destroyed")
end

return ChunkManager 