--[[
    GameConfig.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Main game configuration file
]]

return {
    -- Game Settings
    GAME_NAME = "Petfinity",
    GAME_VERSION = "1.0.0",
    MAX_PLAYERS = 30,
    MAX_PETS_PER_SERVER = 100,
    
    -- Performance Settings
    TARGET_FPS = 60,
    MEMORY_LIMIT = 1024, -- MB
    
    -- Pet Settings
    PET_RARITIES = {
        COMMON = "Common",
        UNCOMMON = "Uncommon",
        RARE = "Rare",
        EPIC = "Epic",
        LEGENDARY = "Legendary"
    },
    
    -- Biome Settings
    BIOMES = {
        FOREST = "Forest",
        DESERT = "Desert",
        OCEAN = "Ocean",
        MOUNTAIN = "Mountain",
        ARCTIC = "Arctic"
    },
    
    -- UI Settings
    UI_SCALE = {
        MOBILE = 0.8,
        DESKTOP = 1.0
    },
    
    -- Animation Settings
    ANIMATION_SPEED = {
        NORMAL = 1.0,
        FAST = 1.5,
        SLOW = 0.5
    },
    
    -- Sound Settings
    SOUND_VOLUME = {
        MASTER = 1.0,
        MUSIC = 0.7,
        SFX = 0.8,
        AMBIENT = 0.5
    }
} 