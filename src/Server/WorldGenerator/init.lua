--[[
    WorldGenerator/init.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Handles procedural terrain generation and asset placement
]]

local WorldGenerator = {}
WorldGenerator.__index = WorldGenerator

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local Terrain = Workspace.Terrain

-- Constants
local CHUNK_SIZE = 100
local MAX_HEIGHT = 100
local MIN_HEIGHT = 0
local NOISE_SCALE = 0.01
local BIOME_BLEND_DISTANCE = 20

-- Dependencies
print("📂 Loading WorldGenerator dependencies...")
local success, BiomeHandler = pcall(function()
    return require(script.Parent.Parent.BiomeHandler)
end)
if not success then
    warn("⚠️ Failed to load BiomeHandler:", BiomeHandler)
    return nil
end
print("✅ BiomeHandler loaded!")

-- Private functions
local function generateNoise(x, z, scale, octaves, persistence, lacunarity)
    local total = 0
    local frequency = 1
    local amplitude = 1
    local maxValue = 0
    
    for i = 1, octaves do
        total = total + math.noise(x * scale * frequency, z * scale * frequency) * amplitude
        maxValue = maxValue + amplitude
        amplitude = amplitude * persistence
        frequency = frequency * lacunarity
    end
    
    return total / maxValue
end

local function getBiomeAtPosition(x, z)
    local biomeData = BiomeHandler.getBiomeData()
    local closestBiome = nil
    local minDistance = math.huge
    
    for biomeName, biome in pairs(biomeData) do
        local distance = (Vector2.new(x, z) - Vector2.new(biome.centerX, biome.centerZ)).Magnitude
        if distance < minDistance then
            minDistance = distance
            closestBiome = biomeName
        end
    end
    
    return closestBiome
end

local function blendBiomes(x, z, biome1, biome2, distance)
    local blendFactor = math.clamp(distance / BIOME_BLEND_DISTANCE, 0, 1)
    local biome1Data = BiomeHandler.getBiomeData()[biome1]
    local biome2Data = BiomeHandler.getBiomeData()[biome2]
    
    return {
        height = biome1Data.baseHeight * (1 - blendFactor) + biome2Data.baseHeight * blendFactor,
        texture = blendFactor < 0.5 and biome1Data.terrainTexture or biome2Data.terrainTexture,
        material = blendFactor < 0.5 and biome1Data.terrainMaterial or biome2Data.terrainMaterial
    }
end

-- Public functions
function WorldGenerator.new()
    local self = setmetatable({}, WorldGenerator)
    self.chunks = {}
    self.generatedChunks = {}
    return self
end

function WorldGenerator:generateChunk(chunkX, chunkZ)
    if self.generatedChunks[chunkX .. "," .. chunkZ] then
        return
    end
    
    local biomeData = BiomeHandler.getBiomeData()
    local chunk = {}
    
    for x = 0, CHUNK_SIZE do
        chunk[x] = {}
        for z = 0, CHUNK_SIZE do
            local worldX = chunkX * CHUNK_SIZE + x
            local worldZ = chunkZ * CHUNK_SIZE + z
            
            local biome1 = getBiomeAtPosition(worldX, worldZ)
            local biome2 = getBiomeAtPosition(worldX + 1, worldZ + 1)
            
            local height, texture, material
            if biome1 == biome2 then
                local biome = biomeData[biome1]
                height = biome.baseHeight + generateNoise(worldX, worldZ, NOISE_SCALE, 4, 0.5, 2) * biome.heightVariation
                texture = biome.terrainTexture
                material = biome.terrainMaterial
            else
                local blended = blendBiomes(worldX, worldZ, biome1, biome2, 
                    (Vector2.new(worldX, worldZ) - Vector2.new(biomeData[biome1].centerX, biomeData[biome1].centerZ)).Magnitude)
                height = blended.height
                texture = blended.texture
                material = blended.material
            end
            
            chunk[x][z] = {
                height = math.clamp(height, MIN_HEIGHT, MAX_HEIGHT),
                texture = texture,
                material = material
            }
        end
    end
    
    self.chunks[chunkX .. "," .. chunkZ] = chunk
    self.generatedChunks[chunkX .. "," .. chunkZ] = true
    
    return chunk
end

function WorldGenerator:applyChunkToTerrain(chunkX, chunkZ)
    local chunk = self.chunks[chunkX .. "," .. chunkZ]
    if not chunk then return end
    
    for x = 0, CHUNK_SIZE do
        for z = 0, CHUNK_SIZE do
            local worldX = chunkX * CHUNK_SIZE + x
            local worldZ = chunkZ * CHUNK_SIZE + z
            local data = chunk[x][z]
            
            -- Create base terrain
            Terrain:FillBlock(
                CFrame.new(worldX, data.height/2, worldZ),
                Vector3.new(1, math.max(1, data.height), 1),
                data.material
            )
            
            -- Create top layer
            Terrain:FillBlock(
                CFrame.new(worldX, data.height, worldZ),
                Vector3.new(1, 1, 1),
                data.texture
            )
        end
    end
end

function WorldGenerator:generateWorld(centerX, centerZ, radius)
    for chunkX = -radius, radius do
        for chunkZ = -radius, radius do
            self:generateChunk(chunkX, chunkZ)
            self:applyChunkToTerrain(chunkX, chunkZ)
        end
    end
end

return WorldGenerator 