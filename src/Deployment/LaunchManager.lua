--[[
    LaunchManager.lua
    Handles the deployment and launch process for Petfinity
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 1.0.0
--]]

local LaunchManager = {}

-- Services
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- Constants
local BETA_GROUP_ID = 12345 -- Replace with actual beta group ID
local VIP_PRODUCT_ID = 67890 -- Replace with actual VIP product ID
local MIN_SERVER_FPS = 60
local MAX_PETS_PER_SERVER = 100

-- Deployment States
local STATES = {
    TESTING = "TESTING",
    BETA = "BETA",
    LIVE = "LIVE"
}

-- Current deployment state
local currentState = STATES.TESTING

-- Initialize systems
function LaunchManager.init()
    print("🚀 Initializing Launch Manager...")
    
    -- Load PreLaunchValidator
    local PreLaunchValidator = require(game.ReplicatedStorage.Testing.PreLaunchValidator)
    
    -- Run pre-launch validation
    local validationResults = PreLaunchValidator.runAllTests()
    
    -- Check if we can proceed with launch
    if LaunchManager.validateResults(validationResults) then
        print("✅ Pre-launch validation passed!")
        return true
    else
        print("❌ Pre-launch validation failed!")
        return false
    end
end

-- Validate test results
function LaunchManager.validateResults(results)
    local allPassed = true
    
    -- Check each category
    for category, summary in pairs(results.summary) do
        if summary.successRate < 0.95 then -- 95% threshold
            allPassed = false
            print("❌ " .. category .. " tests failed! Success rate: " .. summary.successRate * 100 .. "%")
        end
    end
    
    return allPassed
end

-- Deploy to beta
function LaunchManager.deployToBeta()
    print("🚀 Deploying to Beta...")
    
    -- Set deployment state
    currentState = STATES.BETA
    
    -- Enable beta features
    LaunchManager.enableBetaFeatures()
    
    -- Monitor beta performance
    LaunchManager.startPerformanceMonitoring()
    
    print("✅ Beta deployment complete!")
end

-- Enable beta features
function LaunchManager.enableBetaFeatures()
    -- Enable beta access for group members
    game.Players.PlayerAdded:Connect(function(player)
        if player:IsInGroup(BETA_GROUP_ID) then
            -- Grant beta access
            player:SetAttribute("BetaTester", true)
            
            -- Send welcome message
            LaunchManager.sendBetaWelcome(player)
        end
    end)
end

-- Send beta welcome message
function LaunchManager.sendBetaWelcome(player)
    local message = {
        title = "Welcome Beta Tester! 🎉",
        body = "Thank you for helping test Petfinity! Please report any bugs or issues you find.",
        duration = 10
    }
    
    -- Send notification
    game.ReplicatedStorage.Remotes.ShowNotification:FireClient(player, message)
end

-- Deploy to production
function LaunchManager.deployToProduction()
    print("🚀 Deploying to Production...")
    
    -- Set deployment state
    currentState = STATES.LIVE
    
    -- Enable all features
    LaunchManager.enableAllFeatures()
    
    -- Start monitoring
    LaunchManager.startPerformanceMonitoring()
    
    -- Send launch announcement
    LaunchManager.sendLaunchAnnouncement()
    
    print("✅ Production deployment complete!")
end

-- Enable all features
function LaunchManager.enableAllFeatures()
    -- Enable VIP purchases
    MarketplaceService.ProcessReceipt = function(receiptInfo)
        if receiptInfo.ProductId == VIP_PRODUCT_ID then
            local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
            if player then
                -- Grant VIP benefits
                player:SetAttribute("VIP", true)
                return true
            end
        end
        return false
    end
    
    -- Enable seasonal events
    game.ReplicatedStorage.Systems.SeasonalEventSystem.Enabled = true
    
    -- Enable leaderboards
    game.ReplicatedStorage.Systems.LeaderboardSystem.Enabled = true
end

-- Start performance monitoring
function LaunchManager.startPerformanceMonitoring()
    spawn(function()
        while true do
            -- Monitor server performance
            local stats = LaunchManager.getServerStats()
            
            -- Check thresholds
            if stats.fps < MIN_SERVER_FPS then
                LaunchManager.handlePerformanceIssue("Low FPS: " .. stats.fps)
            end
            
            if stats.activePets > MAX_PETS_PER_SERVER then
                LaunchManager.handlePerformanceIssue("Too many pets: " .. stats.activePets)
            end
            
            wait(60) -- Check every minute
        end
    end)
end

-- Get server statistics
function LaunchManager.getServerStats()
    return {
        fps = game:GetService("Stats").CurrentFPS,
        activePets = #workspace.Pets:GetChildren(),
        playerCount = #Players:GetPlayers(),
        memory = game:GetService("Stats"):GetTotalMemoryUsageMb()
    }
end

-- Handle performance issues
function LaunchManager.handlePerformanceIssue(issue)
    print("⚠️ Performance Issue Detected: " .. issue)
    
    -- Log the issue
    game.ReplicatedStorage.Remotes.LogError:FireServer({
        type = "PERFORMANCE",
        message = issue,
        timestamp = os.time()
    })
    
    -- Take action based on severity
    if currentState == STATES.BETA then
        -- In beta, we can be more aggressive with fixes
        LaunchManager.applyEmergencyOptimizations()
    else
        -- In production, be more cautious
        LaunchManager.applyGradualOptimizations()
    end
end

-- Apply emergency optimizations
function LaunchManager.applyEmergencyOptimizations()
    -- Reduce visual effects
    game.ReplicatedStorage.Systems.EffectsSystem.Quality = "Low"
    
    -- Limit pet count
    workspace.Pets.ChildAdded:Connect(function(pet)
        if #workspace.Pets:GetChildren() > MAX_PETS_PER_SERVER then
            pet:Destroy()
        end
    end)
end

-- Apply gradual optimizations
function LaunchManager.applyGradualOptimizations()
    -- Gradually reduce effects quality
    local quality = game.ReplicatedStorage.Systems.EffectsSystem.Quality
    if quality == "High" then
        quality = "Medium"
    elseif quality == "Medium" then
        quality = "Low"
    end
end

-- Send launch announcement
function LaunchManager.sendLaunchAnnouncement()
    local announcement = {
        title = "🎉 PETFINITY IS LIVE! 🎉",
        body = "Welcome to the magical world of Petfinity! Collect pets, explore biomes, and make new friends!",
        duration = 15
    }
    
    -- Send to all players
    for _, player in ipairs(Players:GetPlayers()) do
        game.ReplicatedStorage.Remotes.ShowNotification:FireClient(player, announcement)
    end
end

return LaunchManager 