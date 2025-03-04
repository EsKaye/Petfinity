--[[
    LaunchSequence.lua
    Orchestrates the final deployment and launch sequence for Petfinity
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 1.0.0
--]]

local LaunchSequence = {}

-- Services
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- Load required modules
local LaunchManager = require(script.Parent.LaunchManager)
local PreLaunchValidator = require(game.ReplicatedStorage.Testing.PreLaunchValidator)

-- Constants
local BETA_DURATION = 7200 -- 2 hours beta test
local MONITORING_INTERVAL = 60 -- Check every minute
local LAUNCH_METRICS = DataStoreService:GetDataStore("LaunchMetrics")

-- Launch sequence states
local SEQUENCE_STATES = {
    VALIDATION = "VALIDATION",
    BETA = "BETA",
    PRODUCTION = "PRODUCTION",
    MONITORING = "MONITORING"
}

local currentState = SEQUENCE_STATES.VALIDATION

-- Initialize launch sequence
function LaunchSequence.init()
    print("🚀 Initializing Launch Sequence...")
    
    -- Start validation phase
    return LaunchSequence.startValidation()
end

-- Start validation phase
function LaunchSequence.startValidation()
    print("📋 Starting Pre-Launch Validation...")
    currentState = SEQUENCE_STATES.VALIDATION
    
    -- Run comprehensive validation
    local validationResults = PreLaunchValidator.runAllTests()
    
    -- Process results
    if LaunchManager.validateResults(validationResults) then
        print("✅ Validation Passed - Ready for Beta!")
        LaunchSequence.logMetric("validation_success", true)
        return LaunchSequence.startBeta()
    else
        print("❌ Validation Failed - Deployment Halted")
        LaunchSequence.logMetric("validation_success", false)
        return false
    end
end

-- Start beta phase
function LaunchSequence.startBeta()
    print("🧪 Starting Beta Deployment...")
    currentState = SEQUENCE_STATES.BETA
    
    -- Deploy to beta
    if LaunchManager.deployToBeta() then
        print("✅ Beta Deployment Successful")
        
        -- Monitor beta performance
        spawn(function()
            local startTime = tick()
            
            while currentState == SEQUENCE_STATES.BETA do
                -- Monitor performance
                local stats = LaunchManager.getServerStats()
                LaunchSequence.logMetric("beta_performance", stats)
                
                -- Check if beta duration elapsed
                if tick() - startTime >= BETA_DURATION then
                    if LaunchSequence.validateBetaMetrics() then
                        print("✅ Beta Phase Successful - Proceeding to Production")
                        LaunchSequence.startProduction()
                        break
                    else
                        print("❌ Beta Metrics Below Threshold - Extending Beta")
                        startTime = tick() -- Reset timer
                    end
                end
                
                wait(MONITORING_INTERVAL)
            end
        end)
        
        return true
    else
        print("❌ Beta Deployment Failed")
        return false
    end
end

-- Validate beta metrics
function LaunchSequence.validateBetaMetrics()
    local metrics = LaunchSequence.getMetrics("beta_performance")
    
    -- Define success criteria
    local criteria = {
        minFPS = 58, -- Slightly lower than production requirement
        maxMemory = 1000, -- MB
        errorRate = 0.01, -- 1% error tolerance
        playerRetention = 0.8 -- 80% retention target
    }
    
    -- Validate metrics
    for _, data in pairs(metrics) do
        if data.fps < criteria.minFPS or
           data.memory > criteria.maxMemory or
           data.errorRate > criteria.errorRate or
           data.retention < criteria.playerRetention then
            return false
        end
    end
    
    return true
end

-- Start production launch
function LaunchSequence.startProduction()
    print("🚀 Starting Production Launch...")
    currentState = SEQUENCE_STATES.PRODUCTION
    
    -- Final validation
    local finalCheck = PreLaunchValidator.runAllTests()
    if not LaunchManager.validateResults(finalCheck) then
        print("❌ Final Validation Failed - Reverting to Beta")
        currentState = SEQUENCE_STATES.BETA
        return false
    end
    
    -- Deploy to production
    if LaunchManager.deployToProduction() then
        print("✅ Production Deployment Successful")
        LaunchSequence.startMonitoring()
        return true
    else
        print("❌ Production Deployment Failed")
        return false
    end
end

-- Start post-launch monitoring
function LaunchSequence.startMonitoring()
    print("📊 Starting Post-Launch Monitoring...")
    currentState = SEQUENCE_STATES.MONITORING
    
    -- Monitor production performance
    spawn(function()
        while currentState == SEQUENCE_STATES.MONITORING do
            -- Gather metrics
            local stats = LaunchManager.getServerStats()
            LaunchSequence.logMetric("production_performance", stats)
            
            -- Check for critical issues
            if LaunchSequence.detectCriticalIssues(stats) then
                LaunchSequence.handleCriticalIssue()
            end
            
            wait(MONITORING_INTERVAL)
        end
    end)
end

-- Detect critical issues
function LaunchSequence.detectCriticalIssues(stats)
    return stats.fps < 30 or -- Critical FPS drop
           stats.memory > 2000 or -- Memory spike
           stats.errorRate > 0.05 -- High error rate
end

-- Handle critical issues
function LaunchSequence.handleCriticalIssue()
    print("⚠️ Critical Issue Detected!")
    
    -- Apply emergency optimizations
    LaunchManager.applyEmergencyOptimizations()
    
    -- Notify monitoring systems
    LaunchSequence.logMetric("critical_issue", {
        timestamp = os.time(),
        state = currentState
    })
end

-- Log metrics
function LaunchSequence.logMetric(category, data)
    local success, err = pcall(function()
        LAUNCH_METRICS:SetAsync(category .. "_" .. os.time(), {
            timestamp = os.time(),
            category = category,
            data = data
        })
    end)
    
    if not success then
        print("⚠️ Failed to log metric:", err)
    end
end

-- Get metrics
function LaunchSequence.getMetrics(category)
    local metrics = {}
    local success, data = pcall(function()
        return LAUNCH_METRICS:GetAsync(category)
    end)
    
    if success and data then
        metrics = data
    end
    
    return metrics
end

return LaunchSequence 