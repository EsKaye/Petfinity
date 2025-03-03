--[[
    PetDefinitions.lua
    Defines all available pets and their properties
    
    Author: Cursor AI
    Created: 2024-03-03
    Version: 0.1.0
--]]

local PetDefinitions = {
    -- Common Pets
    {
        id = "CAT_BASIC",
        name = "Basic Cat",
        rarity = "COMMON",
        baseStats = {
            happiness = 10,
            energy = 8,
            hunger = 12
        },
        description = "A friendly basic cat companion"
    },
    {
        id = "DOG_BASIC",
        name = "Basic Dog",
        rarity = "COMMON",
        baseStats = {
            happiness = 12,
            energy = 10,
            hunger = 8
        },
        description = "A loyal basic dog companion"
    },
    
    -- Uncommon Pets
    {
        id = "RABBIT_MYSTIC",
        name = "Mystic Rabbit",
        rarity = "UNCOMMON",
        baseStats = {
            happiness = 15,
            energy = 12,
            hunger = 10
        },
        description = "A magical rabbit with glowing fur"
    },
    {
        id = "HAMSTER_CYBER",
        name = "Cyber Hamster",
        rarity = "UNCOMMON",
        baseStats = {
            happiness = 14,
            energy = 15,
            hunger = 11
        },
        description = "A technologically enhanced hamster"
    },
    
    -- Rare Pets
    {
        id = "DRAGON_BABY",
        name = "Baby Dragon",
        rarity = "RARE",
        baseStats = {
            happiness = 18,
            energy = 20,
            hunger = 15
        },
        description = "A cute baby dragon that breathes tiny flames"
    },
    {
        id = "UNICORN_STAR",
        name = "Star Unicorn",
        rarity = "RARE",
        baseStats = {
            happiness = 20,
            energy = 18,
            hunger = 16
        },
        description = "A magical unicorn that leaves stardust trails"
    },
    
    -- Epic Pets
    {
        id = "PHOENIX_EMBER",
        name = "Ember Phoenix",
        rarity = "EPIC",
        baseStats = {
            happiness = 25,
            energy = 23,
            hunger = 20
        },
        description = "A majestic phoenix with burning feathers"
    },
    {
        id = "GRIFFIN_STORM",
        name = "Storm Griffin",
        rarity = "EPIC",
        baseStats = {
            happiness = 23,
            energy = 25,
            hunger = 22
        },
        description = "A powerful griffin that commands the storms"
    },
    
    -- Legendary Pets
    {
        id = "DRAGON_CELESTIAL",
        name = "Celestial Dragon",
        rarity = "LEGENDARY",
        baseStats = {
            happiness = 30,
            energy = 30,
            hunger = 25
        },
        description = "A legendary dragon with cosmic powers"
    },
    {
        id = "KITSUNE_DIVINE",
        name = "Divine Kitsune",
        rarity = "LEGENDARY",
        baseStats = {
            happiness = 28,
            energy = 28,
            hunger = 28
        },
        description = "A mystical nine-tailed fox with divine powers"
    }
}

return PetDefinitions 