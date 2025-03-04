--[[
    Config/Biomes.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Defines biome configurations for world generation
]]

return {
    Forest = {
        centerX = 0,
        centerZ = 0,
        radius = 200,
        baseHeight = 10,
        heightVariation = 20,
        terrainTexture = Enum.Material.Grass,
        terrainMaterial = Enum.Material.Grass,
        lighting = {
            ambient = Color3.fromRGB(200, 200, 200),
            outdoorAmbient = Color3.fromRGB(200, 200, 200),
            brightness = 1,
            globalShadows = true
        },
        assets = {
            trees = {"Oak", "Pine", "Birch"},
            rocks = {"Rock1", "Rock2", "Rock3"},
            structures = {
                {type = "Cabin", density = {min = 1, max = 3}},
                {type = "Watchtower", density = {min = 0, max = 1}}
            },
            decorations = {"Bush", "Flower", "Mushroom"},
            treeDensity = {min = 10, max = 20},
            rockDensity = {min = 5, max = 10},
            decorationDensity = {min = 15, max = 30}
        }
    },
    
    Desert = {
        centerX = 300,
        centerZ = 0,
        radius = 200,
        baseHeight = 15,
        heightVariation = 30,
        terrainTexture = Enum.Material.Sand,
        terrainMaterial = Enum.Material.Sand,
        lighting = {
            ambient = Color3.fromRGB(255, 200, 150),
            outdoorAmbient = Color3.fromRGB(255, 200, 150),
            brightness = 1.2,
            globalShadows = true
        },
        assets = {
            trees = {"Cactus", "Palm"},
            rocks = {"DesertRock1", "DesertRock2"},
            structures = {
                {type = "Oasis", density = {min = 0, max = 1}},
                {type = "DesertTemple", density = {min = 0, max = 1}}
            },
            decorations = {"DesertBush", "DesertFlower"},
            treeDensity = {min = 5, max = 10},
            rockDensity = {min = 8, max = 15},
            decorationDensity = {min = 10, max = 20}
        }
    },
    
    Ocean = {
        centerX = 0,
        centerZ = 300,
        radius = 200,
        baseHeight = -20,
        heightVariation = 10,
        terrainTexture = Enum.Material.Water,
        terrainMaterial = Enum.Material.Water,
        lighting = {
            ambient = Color3.fromRGB(150, 200, 255),
            outdoorAmbient = Color3.fromRGB(150, 200, 255),
            brightness = 1,
            globalShadows = true
        },
        assets = {
            trees = {"Seaweed", "Coral"},
            rocks = {"CoralRock1", "CoralRock2"},
            structures = {
                {type = "Shipwreck", density = {min = 0, max = 2}},
                {type = "UnderwaterCave", density = {min = 1, max = 3}}
            },
            decorations = {"Seaweed", "Coral", "Shell"},
            treeDensity = {min = 15, max = 25},
            rockDensity = {min = 10, max = 20},
            decorationDensity = {min = 20, max = 40}
        }
    }
} 