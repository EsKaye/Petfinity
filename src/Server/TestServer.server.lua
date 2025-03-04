--[[
    TestServer.server.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Test server script to verify Rojo sync functionality
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestModule = require(ReplicatedStorage.Shared.TestModule)

-- Print test message on server start
print("🔄 Server started - Testing Rojo sync...")
print(TestModule.getTestMessage())

-- Create a test part in workspace
local testPart = Instance.new("Part")
testPart.Name = "ServerTestPart"
testPart.Size = Vector3.new(1, 1, 1)
testPart.Position = Vector3.new(0, 10, 0)
testPart.Anchored = true
testPart.BrickColor = BrickColor.new("Really red")
testPart.Material = Enum.Material.Neon
testPart.Parent = workspace

-- Test remote event
local testEvent = Instance.new("RemoteEvent")
testEvent.Name = "TestEvent"
testEvent.Parent = ReplicatedStorage

-- Handle test event
testEvent.OnServerEvent:Connect(function(player)
    print("🎉 Test event received from player:", player.Name)
    testPart.BrickColor = BrickColor.new("Really green")
    wait(1)
    testPart.BrickColor = BrickColor.new("Really red")
end) 