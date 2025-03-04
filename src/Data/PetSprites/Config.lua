--[[
    PetSprites/Config.lua
    Configuration for pet sprite sheets and animations
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 1.0.0
--]]

return {
    -- Common pets
    BASIC_PET = {
        spriteSheet = "rbxassetid://YOUR_BASIC_PET_SPRITE_SHEET",
        frameSize = Vector2.new(150, 150),
        states = {
            IDLE = {row = 1},
            HAPPY = {row = 2},
            EXCITED = {row = 3},
            TIRED = {row = 4}
        },
        scale = 1.0,
        rarity = "COMMON"
    },
    
    -- Seasonal pets
    HALLOWEEN_SPECTER = {
        spriteSheet = "rbxassetid://YOUR_SPECTER_SPRITE_SHEET",
        frameSize = Vector2.new(200, 200),
        states = {
            IDLE = {row = 1, glowColor = Color3.fromRGB(88, 180, 255)},
            HAPPY = {row = 2, glowIntensity = 0.5},
            EXCITED = {row = 3, particleColor = Color3.fromRGB(140, 220, 255)},
            TIRED = {row = 4, glowPulse = true}
        },
        scale = 1.2,
        rarity = "LEGENDARY",
        effects = {
            GLOW = true,
            TRAIL = true,
            AMBIENT_PARTICLES = true
        }
    },
    
    CELESTIAL_UNICORN = {
        spriteSheet = "rbxassetid://YOUR_UNICORN_SPRITE_SHEET",
        frameSize = Vector2.new(200, 200),
        states = {
            IDLE = {row = 1, galaxyEffect = true},
            HAPPY = {row = 2, starburstRate = 2},
            EXCITED = {row = 3, rainbowTrail = true},
            TIRED = {row = 4, shimmerIntensity = 0.3}
        },
        scale = 1.2,
        rarity = "LEGENDARY",
        effects = {
            GALAXY = true,
            STARBURST = true,
            RAINBOW = true
        }
    },
    
    LAVA_WRAITH = {
        spriteSheet = "rbxassetid://YOUR_WRAITH_SPRITE_SHEET",
        frameSize = Vector2.new(200, 200),
        states = {
            IDLE = {row = 1, lavaGlow = true},
            HAPPY = {row = 2, emberRate = 3},
            EXCITED = {row = 3, flameIntensity = 0.6},
            TIRED = {row = 4, smolderEffect = true}
        },
        scale = 1.2,
        rarity = "LEGENDARY",
        effects = {
            LAVA = true,
            EMBERS = true,
            FLAMES = true
        }
    },
    
    -- Event pets
    SHADOW_KITSUNE = {
        spriteSheet = "rbxassetid://YOUR_KITSUNE_SPRITE_SHEET",
        frameSize = Vector2.new(180, 180),
        states = {
            IDLE = {row = 1, shadowTrail = true},
            HAPPY = {row = 2, spiritFlames = true},
            EXCITED = {row = 3, mysticalAura = true},
            TIRED = {row = 4, fadeEffect = true}
        },
        scale = 1.1,
        rarity = "EPIC",
        effects = {
            SHADOW = true,
            SPIRIT = true,
            MYSTIC = true
        }
    },
    
    AURORA_WYVERN = {
        spriteSheet = "rbxassetid://YOUR_WYVERN_SPRITE_SHEET",
        frameSize = Vector2.new(180, 180),
        states = {
            IDLE = {row = 1, auroraTrail = true},
            HAPPY = {row = 2, borealisEffect = true},
            EXCITED = {row = 3, lightShow = true},
            TIRED = {row = 4, gentleGlow = true}
        },
        scale = 1.1,
        rarity = "EPIC",
        effects = {
            AURORA = true,
            BOREALIS = true,
            LIGHT = true
        }
    },
    
    HOLIDAY_SERAPH = {
        spriteSheet = "rbxassetid://YOUR_SERAPH_SPRITE_SHEET",
        frameSize = Vector2.new(180, 180),
        states = {
            IDLE = {row = 1, holyGlow = true},
            HAPPY = {row = 2, blessedSparkles = true},
            EXCITED = {row = 3, divineAura = true},
            TIRED = {row = 4, peacefulGlow = true}
        },
        scale = 1.1,
        rarity = "EPIC",
        effects = {
            HOLY = true,
            BLESSED = true,
            DIVINE = true
        }
    }
} 