--[[
    WorldGenerator/AssetVerifier.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Verifies that all required assets are present in the correct folders
]]

local AssetVerifier = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Required asset lists
local REQUIRED_ASSETS = {
    Trees = {
        "OakTree",
        "PineTree",
        "MapleTree",
        "Cactus1",
        "Cactus2",
        "PalmTree",
        "Coral1",
        "Coral2",
        "Seaweed1"
    },
    Rocks = {
        "Rock1",
        "Rock2",
        "Rock3",
        "DesertRock1",
        "DesertRock2",
        "UnderwaterRock1",
        "UnderwaterRock2"
    },
    Structures = {
        "WoodenCabin",
        "DesertTemple",
        "UnderwaterRuins",
        "GachaMachine",
        "UnderwaterGacha",
        "EventArea",
        "UnderwaterEvent"
    },
    Decorations = {
        "Flower1",
        "Flower2",
        "Bush1",
        "Bush2",
        "DesertPlant1",
        "DesertPlant2",
        "Seaweed2",
        "Seaweed3",
        "Shell1",
        "Shell2"
    }
}

-- Function to check if a folder exists
local function folderExists(parent, folderName)
    return parent:FindFirstChild(folderName) ~= nil
end

-- Function to check if an asset exists
local function assetExists(parent, assetName)
    return parent:FindFirstChild(assetName) ~= nil
end

-- Function to verify assets in a category
local function verifyCategory(parent, category, assets)
    local missingAssets = {}
    
    for _, assetName in ipairs(assets) do
        if not assetExists(parent, assetName) then
            table.insert(missingAssets, assetName)
        end
    end
    
    return missingAssets
end

-- Main verification function
function AssetVerifier.verifyAssets()
    local assetsFolder = ReplicatedStorage:FindFirstChild("Assets")
    if not assetsFolder then
        warn("❌ Assets folder not found in ReplicatedStorage!")
        return false
    end
    
    local missingAssets = {}
    local allPresent = true
    
    -- Check each category
    for category, assets in pairs(REQUIRED_ASSETS) do
        local categoryFolder = assetsFolder:FindFirstChild(category)
        if not categoryFolder then
            warn("❌ Category folder missing:", category)
            missingAssets[category] = assets
            allPresent = false
        else
            local missing = verifyCategory(categoryFolder, category, assets)
            if #missing > 0 then
                missingAssets[category] = missing
                allPresent = false
            end
        end
    end
    
    -- Print results
    if allPresent then
        print("✅ All required assets are present!")
    else
        print("❌ Missing assets found:")
        for category, assets in pairs(missingAssets) do
            print("  " .. category .. ":")
            for _, asset in ipairs(assets) do
                print("    - " .. asset)
            end
        end
    end
    
    return allPresent
end

return AssetVerifier 