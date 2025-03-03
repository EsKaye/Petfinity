--[[
    DailyRewardSystem.lua
    Handles daily login rewards, streaks, and reward distribution
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 0.1.1
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Import EffectsSystem for reward animations
local EffectsSystem = require(game.ReplicatedStorage.Systems.EffectsSystem)

local DailyRewardSystem = {}
DailyRewardSystem.__index = DailyRewardSystem

-- Constants for streak management
local STREAK_CONFIG = {
    MAX_STREAK = 30, -- Maximum tracked streak days
    GRACE_PERIOD = 24, -- Hours allowed to claim reward before streak reset
    VIP_MULTIPLIER = 2, -- Reward multiplier for VIP players
    RESTORE_COST = 25 -- Robux cost to restore streak
}

-- Define reward tiers based on streak length
local REWARD_TIERS = {
    -- Days 1-3: Basic rewards
    {
        MIN_STREAK = 1,
        MAX_STREAK = 3,
        REWARDS = {
            {type = "COINS", amount = 100},
            {type = "FOOD", amount = 1, rarity = "COMMON"},
            {type = "XP_BOOST", amount = 1.1, duration = 3600} -- 1 hour
        }
    },
    -- Days 4-6: Better rewards
    {
        MIN_STREAK = 4,
        MAX_STREAK = 6,
        REWARDS = {
            {type = "COINS", amount = 250},
            {type = "FOOD", amount = 2, rarity = "RARE"},
            {type = "XP_BOOST", amount = 1.25, duration = 7200}, -- 2 hours
            {type = "GACHA_ROLL", amount = 1}
        }
    },
    -- Days 7+: Premium rewards
    {
        MIN_STREAK = 7,
        MAX_STREAK = STREAK_CONFIG.MAX_STREAK,
        REWARDS = {
            {type = "COINS", amount = 500},
            {type = "FOOD", amount = 3, rarity = "EPIC"},
            {type = "XP_BOOST", amount = 1.5, duration = 14400}, -- 4 hours
            {type = "GACHA_ROLL", amount = 2},
            {type = "EXCLUSIVE_EGG", chance = 0.1} -- 10% chance for exclusive egg
        }
    }
}

-- Special event rewards with expanded seasonal pets
local EVENT_REWARDS = {
    SPRING = {
        {type = "EXCLUSIVE_EGG", id = "SPRING_BUNNY", chance = 0.15, vipExclusive = false},
        {type = "EXCLUSIVE_EGG", id = "FLOWER_FAIRY", chance = 0.1, vipExclusive = true},
        {type = "SPECIAL_FOOD", id = "CARROT_CAKE", amount = 3},
        {type = "SPECIAL_FOOD", id = "HONEY_NECTAR", amount = 2}
    },
    SUMMER = {
        {type = "EXCLUSIVE_EGG", id = "BEACH_DRAGON", chance = 0.15, vipExclusive = false},
        {type = "EXCLUSIVE_EGG", id = "CORAL_MERMAID", chance = 0.1, vipExclusive = true},
        {type = "SPECIAL_FOOD", id = "TROPICAL_SMOOTHIE", amount = 3},
        {type = "SPECIAL_FOOD", id = "COCONUT_MILK", amount = 2}
    },
    FALL = {
        {type = "EXCLUSIVE_EGG", id = "MAPLE_PHOENIX", chance = 0.15, vipExclusive = false},
        {type = "EXCLUSIVE_EGG", id = "HARVEST_SPIRIT", chance = 0.1, vipExclusive = true},
        {type = "SPECIAL_FOOD", id = "PUMPKIN_SPICE", amount = 3},
        {type = "SPECIAL_FOOD", id = "APPLE_CIDER", amount = 2}
    },
    WINTER = {
        {type = "EXCLUSIVE_EGG", id = "FROST_DRAGON", chance = 0.15, vipExclusive = false},
        {type = "EXCLUSIVE_EGG", id = "AURORA_SPIRIT", chance = 0.1, vipExclusive = true},
        {type = "SPECIAL_FOOD", id = "HOT_CHOCOLATE", amount = 3},
        {type = "SPECIAL_FOOD", id = "CANDY_CANE", amount = 2}
    }
}

function DailyRewardSystem.new(player)
    local self = setmetatable({}, DailyRewardSystem)
    
    -- Initialize player data
    self.player = player
    self.dataStore = DataStoreService:GetDataStore("DailyRewards_" .. player.UserId)
    self.effectsSystem = EffectsSystem.new()
    
    -- Load player streak data
    self:loadStreakData()
    
    return self
end

function DailyRewardSystem:loadStreakData()
    local success, data = pcall(function()
        return self.dataStore:GetAsync("streak_data")
    end)
    
    if success and data then
        self.streakData = data
    else
        -- Initialize new streak data
        self.streakData = {
            currentStreak = 0,
            lastClaimTime = 0,
            totalLogins = 0
        }
    end
end

function DailyRewardSystem:saveStreakData()
    local success, err = pcall(function()
        self.dataStore:SetAsync("streak_data", self.streakData)
    end)
    
    return success
end

function DailyRewardSystem:canClaimReward()
    local currentTime = os.time()
    local timeSinceLastClaim = currentTime - self.streakData.lastClaimTime
    
    -- Check if enough time has passed (24 hours - grace period)
    if timeSinceLastClaim < (24 - STREAK_CONFIG.GRACE_PERIOD) * 3600 then
        return false, "Too soon to claim"
    end
    
    -- Check if streak should be reset (missed day + grace period)
    if timeSinceLastClaim > (24 + STREAK_CONFIG.GRACE_PERIOD) * 3600 then
        self.streakData.currentStreak = 0
    end
    
    return true, nil
end

function DailyRewardSystem:getRewardsForStreak()
    local streak = self.streakData.currentStreak
    local rewards = {}
    
    -- Find appropriate reward tier
    for _, tier in ipairs(REWARD_TIERS) do
        if streak >= tier.MIN_STREAK and streak <= tier.MAX_STREAK then
            rewards = table.clone(tier.REWARDS)
            break
        end
    end
    
    -- Apply VIP multiplier if applicable
    if self:isVIPPlayer() then
        for _, reward in ipairs(rewards) do
            if reward.amount then
                reward.amount = reward.amount * STREAK_CONFIG.VIP_MULTIPLIER
            end
        end
    end
    
    -- Add random bonus rewards
    self:addBonusRewards(rewards)
    
    return rewards
end

function DailyRewardSystem:canRestoreStreak()
    -- Check if streak is broken
    local currentTime = os.time()
    local timeSinceLastClaim = currentTime - self.streakData.lastClaimTime
    
    return timeSinceLastClaim > (24 + STREAK_CONFIG.GRACE_PERIOD) * 3600
end

function DailyRewardSystem:restoreStreak()
    local MarketplaceService = game:GetService("MarketplaceService")
    
    -- Verify streak is broken
    if not self:canRestoreStreak() then
        return false, "Streak is not broken"
    end
    
    -- Prompt Robux purchase
    local success = pcall(function()
        MarketplaceService:PromptProductPurchase(
            self.player,
            STREAK_CONFIG.RESTORE_COST
        )
    end)
    
    if success then
        -- Restore streak data
        local previousStreak = self.streakData.currentStreak
        self.streakData.lastClaimTime = os.time() - 24 * 3600 -- Set to yesterday
        self:saveStreakData()
        
        -- Trigger notification
        self:notifyPlayer("Streak Restored!", "Your " .. previousStreak .. " day streak has been restored!")
        
        return true, "Streak restored successfully"
    end
    
    return false, "Failed to process purchase"
end

function DailyRewardSystem:addBonusRewards(rewards)
    -- 10% chance for bonus reward
    if math.random() < 0.1 then
        table.insert(rewards, {
            type = "BONUS",
            reward = {
                type = "GACHA_ROLL",
                amount = 1
            }
        })
    end
    
    -- Add event rewards if active
    local currentEvent = self:getCurrentEvent()
    if currentEvent and EVENT_REWARDS[currentEvent] then
        local isVIP = self:isVIPPlayer()
        
        for _, eventReward in ipairs(EVENT_REWARDS[currentEvent]) do
            -- Skip VIP exclusive rewards for non-VIP players
            if eventReward.vipExclusive and not isVIP then
                continue
            end
            
            if math.random() < (eventReward.chance or 1) then
                -- Increase chance for VIP players
                if isVIP and eventReward.chance then
                    eventReward.chance = eventReward.chance * 1.5
                end
                
                table.insert(rewards, eventReward)
            end
        end
    end
end

function DailyRewardSystem:claimDailyReward()
    local canClaim, error = self:canClaimReward()
    if not canClaim then
        return false, error
    end
    
    -- Get rewards for current streak
    local rewards = self:getRewardsForStreak()
    
    -- Update streak data
    self.streakData.currentStreak = self.streakData.currentStreak + 1
    self.streakData.lastClaimTime = os.time()
    self.streakData.totalLogins = self.streakData.totalLogins + 1
    
    -- Save updated streak data
    self:saveStreakData()
    
    -- Distribute rewards
    self:distributeRewards(rewards)
    
    return true, rewards
end

function DailyRewardSystem:distributeRewards(rewards)
    for _, reward in ipairs(rewards) do
        -- Handle different reward types
        if reward.type == "COINS" then
            -- Add coins to player balance
            self:addCoins(reward.amount)
        elseif reward.type == "FOOD" then
            -- Add food items to inventory
            self:addFood(reward.amount, reward.rarity)
        elseif reward.type == "XP_BOOST" then
            -- Apply XP boost
            self:applyXPBoost(reward.amount, reward.duration)
        elseif reward.type == "GACHA_ROLL" then
            -- Add gacha rolls
            self:addGachaRolls(reward.amount)
        elseif reward.type == "EXCLUSIVE_EGG" then
            -- Add exclusive egg to inventory
            self:addExclusiveEgg(reward.id)
        end
    end
end

function DailyRewardSystem:isVIPPlayer()
    -- Check if player has VIP game pass
    local MarketplaceService = game:GetService("MarketplaceService")
    return MarketplaceService:UserOwnsGamePassAsync(self.player.UserId, GAMEPASS_IDS.VIP)
end

function DailyRewardSystem:getCurrentEvent()
    -- Determine current seasonal event
    local month = os.date("*t").month
    
    if month >= 3 and month <= 5 then
        return "SPRING"
    elseif month >= 6 and month <= 8 then
        return "SUMMER"
    elseif month >= 9 and month <= 11 then
        return "FALL"
    else
        return "WINTER"
    end
end

-- Helper functions for reward distribution
function DailyRewardSystem:addCoins(amount)
    -- Implementation depends on economy system
end

function DailyRewardSystem:addFood(amount, rarity)
    -- Implementation depends on inventory system
end

function DailyRewardSystem:applyXPBoost(multiplier, duration)
    -- Implementation depends on progression system
end

function DailyRewardSystem:addGachaRolls(amount)
    -- Implementation depends on gacha system
end

function DailyRewardSystem:addExclusiveEgg(eggId)
    -- Implementation depends on pet system
end

function DailyRewardSystem:notifyPlayer(title, message)
    -- Implementation depends on notification system
    if self.notificationSystem then
        self.notificationSystem:show(title, message)
    end
end

function DailyRewardSystem:checkMissedStreak()
    if self:canRestoreStreak() then
        -- Show streak restoration prompt
        if self.dailyRewardUI then
            self.dailyRewardUI:showRestorePrompt(self.streakData.currentStreak)
        end
    end
end

function DailyRewardSystem:destroy()
    self.effectsSystem:destroy()
end

return DailyRewardSystem 