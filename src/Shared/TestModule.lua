--[[
    TestModule.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Test module to verify Rojo sync functionality
]]

local TestModule = {}

-- Test function that returns a message
function TestModule.getTestMessage()
    return "🎉 Rojo sync is working perfectly! 💖"
end

-- Test function that creates a visual indicator
function TestModule.createTestIndicator()
    local indicator = Instance.new("Part")
    indicator.Name = "TestIndicator"
    indicator.Size = Vector3.new(1, 1, 1)
    indicator.Position = Vector3.new(0, 5, 0)
    indicator.Anchored = true
    indicator.BrickColor = BrickColor.new("Really blue")
    indicator.Material = Enum.Material.Neon
    return indicator
end

return TestModule 