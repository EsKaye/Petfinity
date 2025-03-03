--[[
    SeasonalEventSystem.lua
    Manages seasonal events, exclusive pets, and limited-time rewards
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotificationService = game:GetService("NotificationService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Import required systems
local EffectsSystem = require(game.ReplicatedStorage.Systems.EffectsSystem)
local NotificationSystem = require(game.ReplicatedStorage.Systems.NotificationSystem)

local SeasonalEventSystem = {}
SeasonalEventSystem.__index = SeasonalEventSystem

-- Event configuration
local EVENT_CONFIG = {
    HALLOWEEN = {
        NAME = "Spooky Season",
        START_MONTH = 10, -- October
        DURATION_DAYS = 31,
        EGGS = {
            {
                ID = "HALLOWEEN_EGG",
                NAME = "Haunted Egg",
                DESCRIPTION = "Contains spectral and dark creatures",
                PRICE = 250, -- Robux
                PETS = {
                    {
                        ID = "HALLOWEEN_SPECTER",
                        NAME = "Halloween Specter",
                        RARITY = "LEGENDARY",
                        CHANCE = 0.05, -- 5% chance
                        EFFECTS = {
                            GLOW = {
                                COLOR = Color3.fromRGB(0, 255, 200),
                                INTENSITY = 2,
                                PULSE = true
                            },
                            TRAIL = {
                                TYPE = "WISPY",
                                COLOR = Color3.fromRGB(0, 255, 200),
                                LIFETIME = 1
                            }
                        },
                        BUFFS = {
                            XP_BOOST = 1.5,
                            RARE_FIND = 1.2
                        }
                    },
                    {
                        ID = "SHADOW_KITSUNE",
                        NAME = "Shadow Kitsune",
                        RARITY = "LEGENDARY",
                        CHANCE = 0.05,
                        EFFECTS = {
                            FLAMES = {
                                COLOR = Color3.fromRGB(0, 150, 255),
                                SIZE = 1.2,
                                INTENSITY = 1.5
                            },
                            AURA = {
                                TYPE = "MYSTICAL",
                                COLOR = Color3.fromRGB(0, 100, 255),
                                RADIUS = 3
                            }
                        },
                        BUFFS = {
                            LUCK_BOOST = 1.3,
                            COIN_BOOST = 1.4
                        }
                    }
                }
            }
        },
        ITEMS = {
            {
                ID = "GHOST_COOKIES",
                NAME = "Ghost Cookies",
                DESCRIPTION = "Spooky treats that make pets glow!",
                EFFECTS = {
                    HAPPINESS = 25,
                    DURATION = 3600, -- 1 hour
                    GLOW = true
                }
            },
            {
                ID = "PUMPKIN_BISCUITS",
                NAME = "Pumpkin Biscuits",
                DESCRIPTION = "Seasonal snacks with magical effects!",
                EFFECTS = {
                    HAPPINESS = 20,
                    DURATION = 7200, -- 2 hours
                    SPARKLE = true
                }
            }
        }
    },
    CELESTIAL = {
        NAME = "Celestial Dreams",
        START_MONTH = 3, -- March
        DURATION_DAYS = 30,
        EGGS = {
            {
                ID = "CELESTIAL_EGG",
                NAME = "Cosmic Egg",
                DESCRIPTION = "Contains mystical celestial creatures",
                PRICE = 300,
                PETS = {
                    {
                        ID = "CELESTIAL_UNICORN",
                        NAME = "Celestial Unicorn",
                        RARITY = "LEGENDARY",
                        CHANCE = 0.05,
                        EFFECTS = {
                            TEXTURE = {
                                TYPE = "GALAXY",
                                SPEED = 0.5,
                                INTENSITY = 1.2
                            },
                            PARTICLES = {
                                TYPE = "STARDUST",
                                COLOR = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 255)),
                                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 100, 255)),
                                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 255))
                                }),
                                RATE = 20
                            }
                        },
                        BUFFS = {
                            MAGIC_FIND = 1.5,
                            XP_BOOST = 1.3
                        }
                    },
                    {
                        ID = "AURORA_WYVERN",
                        NAME = "Aurora Wyvern",
                        RARITY = "LEGENDARY",
                        CHANCE = 0.05,
                        EFFECTS = {
                            WINGS = {
                                GRADIENT = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
                                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
                                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 200))
                                }),
                                GLOW = true
                            },
                            AURA = {
                                TYPE = "CELESTIAL",
                                COLOR = Color3.fromRGB(150, 150, 255),
                                RADIUS = 4
                            }
                        },
                        BUFFS = {
                            FLIGHT_SPEED = 1.5,
                            MAGIC_POWER = 1.4
                        }
                    }
                }
            }
        },
        ITEMS = {
            {
                ID = "STARDUST_TREATS",
                NAME = "Stardust Treats",
                DESCRIPTION = "Shimmering snacks that grant cosmic powers!",
                EFFECTS = {
                    HAPPINESS = 30,
                    DURATION = 3600,
                    SPARKLE = true,
                    MAGIC_BOOST = 1.2
                }
            },
            {
                ID = "MOONLIGHT_NECTAR",
                NAME = "Moonlight Nectar",
                DESCRIPTION = "Mystical drink that makes pets glow!",
                EFFECTS = {
                    HAPPINESS = 25,
                    DURATION = 7200,
                    GLOW = true,
                    ENERGY_REGEN = 1.3
                }
            }
        }
    }
}

-- VIP bonuses
local VIP_BONUSES = {
    DROP_RATE_MULTIPLIER = 1.5, -- 50% better chance for rare pets
    DURATION_MULTIPLIER = 1.5, -- 50% longer buff duration
    EXCLUSIVE_PETS = true -- Access to VIP-only pets
}

function SeasonalEventSystem.new(player)
    local self = setmetatable({}, SeasonalEventSystem)
    
    -- Store references
    self.player = player
    self.effectsSystem = EffectsSystem.new()
    self.notificationSystem = NotificationSystem.new(player)
    
    -- Initialize current event
    self:updateCurrentEvent()
    
    -- Start event timer
    self:startEventTimer()
    
    return self
end

function SeasonalEventSystem:updateCurrentEvent()
    local currentMonth = tonumber(os.date("%m"))
    
    -- Find active event for current month
    for eventName, eventData in pairs(EVENT_CONFIG) do
        if currentMonth == eventData.START_MONTH then
            self.currentEvent = eventName
            self.eventData = eventData
            self.eventStartTime = os.time()
            self.eventEndTime = self.eventStartTime + (eventData.DURATION_DAYS * 24 * 3600)
            break
        end
    end
    
    -- Notify if new event started
    if self.currentEvent then
        self:notifyEventStart()
    end
end

function SeasonalEventSystem:startEventTimer()
    -- Check event status every minute
    game:GetService("RunService").Heartbeat:Connect(function()
        if self.currentEvent then
            local timeLeft = self.eventEndTime - os.time()
            
            -- Event ended
            if timeLeft <= 0 then
                self:endCurrentEvent()
            -- Event ending soon (24 hours)
            elseif timeLeft <= 86400 then
                self:notifyEventEnding(timeLeft)
            end
        else
            -- Check for new event
            self:updateCurrentEvent()
        end
    end)
end

function SeasonalEventSystem:notifyEventStart()
    -- Send event start notification
    self.notificationSystem:queueNotification(
        "EVENT_ALERT",
        string.format("%s has begun! Collect limited-time pets now!", self.eventData.NAME),
        {eventName = self.currentEvent}
    )
end

function SeasonalEventSystem:notifyEventEnding(timeLeft)
    -- Format time remaining
    local hours = math.floor(timeLeft / 3600)
    local minutes = math.floor((timeLeft % 3600) / 60)
    
    -- Send event ending notification
    self.notificationSystem:queueNotification(
        "EVENT_ALERT",
        string.format("%s ends in %d hours and %d minutes! Don't miss out!", 
            self.eventData.NAME, hours, minutes),
        {eventName = self.currentEvent, timeLeft = timeLeft}
    )
end

function SeasonalEventSystem:endCurrentEvent()
    -- Archive event data
    if self.currentEvent then
        -- TODO: Archive event statistics
        
        -- Notify event end
        self.notificationSystem:queueNotification(
            "EVENT_ALERT",
            string.format("%s has ended! Thank you for participating!", self.eventData.NAME),
            {eventName = self.currentEvent}
        )
        
        -- Clear current event
        self.currentEvent = nil
        self.eventData = nil
        self.eventStartTime = nil
        self.eventEndTime = nil
    end
end

function SeasonalEventSystem:getEventEggs()
    if not self.currentEvent then return {} end
    return self.eventData.EGGS
end

function SeasonalEventSystem:getEventItems()
    if not self.currentEvent then return {} end
    return self.eventData.ITEMS
end

function SeasonalEventSystem:rollEventEgg(eggId)
    if not self.currentEvent then return nil, "No active event" end
    
    -- Find egg data
    local eggData
    for _, egg in ipairs(self.eventData.EGGS) do
        if egg.ID == eggId then
            eggData = egg
            break
        end
    end
    
    if not eggData then return nil, "Invalid egg type" end
    
    -- Check if player has purchased the egg
    -- TODO: Implement purchase verification
    
    -- Roll for pet with VIP bonus if applicable
    local isVIP = self:isVIPPlayer()
    local roll = math.random()
    
    -- Apply VIP bonus to roll chance
    if isVIP then
        roll = roll / VIP_BONUSES.DROP_RATE_MULTIPLIER
    end
    
    -- Select pet based on roll
    for _, pet in ipairs(eggData.PETS) do
        if roll <= pet.CHANCE then
            return pet
        end
        roll = roll - pet.CHANCE
    end
    
    -- Return common pet if no rare ones were selected
    return eggData.PETS[#eggData.PETS]
end

function SeasonalEventSystem:useEventItem(itemId, petId)
    if not self.currentEvent then return false, "No active event" end
    
    -- Find item data
    local itemData
    for _, item in ipairs(self.eventData.ITEMS) do
        if item.ID == itemId then
            itemData = item
            break
        end
    end
    
    if not itemData then return false, "Invalid item" end
    
    -- Apply item effects
    -- TODO: Implement pet stat modification
    
    -- Apply VIP bonus to duration if applicable
    if self:isVIPPlayer() then
        itemData.EFFECTS.DURATION = itemData.EFFECTS.DURATION * VIP_BONUSES.DURATION_MULTIPLIER
    end
    
    return true, itemData.EFFECTS
end

function SeasonalEventSystem:isVIPPlayer()
    -- Check if player has VIP game pass
    return MarketplaceService:UserOwnsGamePassAsync(self.player.UserId, GAMEPASS_IDS.VIP)
end

function SeasonalEventSystem:getTimeUntilNextEvent()
    if self.currentEvent then
        return self.eventEndTime - os.time()
    else
        -- Calculate time until next event
        local currentMonth = tonumber(os.date("%m"))
        local nextEventMonth = 12
        
        for _, eventData in pairs(EVENT_CONFIG) do
            if eventData.START_MONTH > currentMonth and eventData.START_MONTH < nextEventMonth then
                nextEventMonth = eventData.START_MONTH
            end
        end
        
        -- Calculate seconds until next event
        local currentYear = tonumber(os.date("%Y"))
        if nextEventMonth < currentMonth then
            currentYear = currentYear + 1
        end
        
        local nextEventTime = os.time({
            year = currentYear,
            month = nextEventMonth,
            day = 1,
            hour = 0,
            min = 0,
            sec = 0
        })
        
        return nextEventTime - os.time()
    end
end

function SeasonalEventSystem:destroy()
    self.effectsSystem:destroy()
    self.notificationSystem:destroy()
end

return SeasonalEventSystem 