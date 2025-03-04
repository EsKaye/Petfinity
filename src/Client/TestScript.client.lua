--[[
    TestScript.client.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Test script to verify Rojo sync functionality
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TestModule = require(ReplicatedStorage.Shared.TestModule)

-- Print test message
print(TestModule.getTestMessage())

-- Create visual indicator
local indicator = TestModule.createTestIndicator()
indicator.Parent = workspace

-- Create GUI structure
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TestGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create a test button
local button = Instance.new("TextButton")
button.Name = "TestButton"
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(1, -220, 1, -70) -- Bottom right corner with padding
button.Text = "Click me to test sync! 💖"
button.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.Parent = screenGui

-- Test button click
button.MouseButton1Click:Connect(function()
    print("🎉 Button click test successful! 💖")
    button.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    task.wait(0.5)
    button.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
    
    -- Test remote event
    local testEvent = ReplicatedStorage:WaitForChild("TestEvent")
    testEvent:FireServer()
end) 