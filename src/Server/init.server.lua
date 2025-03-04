--[[
    Server/init.server.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Main server initialization script
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load required modules
local AIController = require(script.AIController)
local WorldGenerator = require(script.WorldGenerator)
local BiomeHandler = require(script.BiomeHandler)
local AssetPlacer = require(script.AssetPlacer.init)

-- Initialize AI system
local function initializeAISystem()
    print("🧠 Initializing AI system...")
    
    -- Create AI controller
    local AIController = Instance.new("Folder")
    AIController.Name = "AIController"
    AIController.Parent = ServerScriptService
    
    -- Create AI settings
    local AISettings = Instance.new("Configuration")
    AISettings.Name = "AISettings"
    AISettings.Parent = AIController
    
    -- Set AI parameters
    local worldSize = Instance.new("NumberValue")
    worldSize.Name = "WorldSize"
    worldSize.Value = 1000
    worldSize.Parent = AISettings
    
    local biomeCount = Instance.new("NumberValue")
    biomeCount.Name = "BiomeCount"
    biomeCount.Value = 5
    biomeCount.Parent = AISettings
    
    local generationQuality = Instance.new("NumberValue")
    generationQuality.Name = "GenerationQuality"
    generationQuality.Value = 1
    generationQuality.Parent = AISettings
    
    print("✨ AI system initialized!")
end

-- Generate world with AI
local function generateWorldWithAI()
    print("🌍 Starting AI-powered world generation...")
    
    -- Create AI controller
    local ai = AIController.new()
    
    -- Generate world
    ai:generateWorld()
    
    print("✨ AI world generation complete!")
end

-- Create start button
local function createStartButton()
    print("🔘 Creating start button...")
    
    local button = Instance.new("Part")
    button.Name = "StartButton"
    button.Size = Vector3.new(10, 2, 10)
    button.Position = Vector3.new(0, 5, 0)
    button.Color = Color3.fromRGB(255, 192, 203) -- Pink color
    button.Material = Enum.Material.Neon
    button.Anchored = true
    button.CanCollide = true
    
    -- Add click detection
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.Parent = button
    
    -- Handle clicks
    clickDetector.MouseClick:Connect(function(player)
        print("👆 Start button clicked by:", player.Name)
        generateWorldWithAI()
    end)
    
    button.Parent = workspace
    print("✨ Start button created!")
end

-- Initialize everything
local function initialize()
    print("🚀 Starting Petfinity initialization...")
    
    -- Initialize AI system
    initializeAISystem()
    
    -- Create start button
    createStartButton()
    
    print("✨ Petfinity initialization complete!")
end

-- Start initialization
initialize()

-- Handle player joining
game.Players.PlayerAdded:Connect(function(player)
    print("👋 Player joined:", player.Name)
end)

-- Handle player leaving
game.Players.PlayerRemoving:Connect(function(player)
    print("👋 Player left:", player.Name)
end)

-- Handle server shutdown
game:BindToClose(function()
    print("🛑 Server shutting down...")
end) 