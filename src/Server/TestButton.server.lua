--[[
    Server/TestButton.server.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Creates a test button to verify server scripts are running
]]

print("🎀 Creating test button...")

-- Load required modules
local ServerScriptService = game:GetService("ServerScriptService")
print("📂 Looking for AIController module...")

local AIController
local success, result = pcall(function()
    return require(ServerScriptService.Server.AIController)
end)

if not success then
    warn("❌ Failed to load AIController:", result)
    print("🔍 Checking ServerScriptService structure:")
    print("  ServerScriptService contents:")
    for _, child in ipairs(ServerScriptService:GetChildren()) do
        print("    -", child.Name)
        if child:IsA("Folder") then
            print("      Folder contents:")
            for _, subChild in ipairs(child:GetChildren()) do
                print("        -", subChild.Name)
            end
        end
    end
else
    AIController = result
    print("✅ Successfully loaded AIController!")
    print("🔍 AIController type:", typeof(AIController))
    print("🔍 AIController methods:", table.concat(table.keys(AIController), ", "))
end

-- Create button
local button = Instance.new("Part")
button.Name = "TestButton"
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
    print("👆 Test button clicked by:", player.Name)
    
    print("🔍 Current AIController state:", AIController and "Loaded" or "Not loaded")
    if AIController then
        print("🔍 AIController type:", typeof(AIController))
        print("🔍 AIController methods:", table.concat(table.keys(AIController), ", "))
    end
    
    if AIController then
        -- Create AI controller and generate world
        print("🤖 Creating AI controller...")
        local success, ai = pcall(function()
            return AIController.new()
        end)
        
        if not success then
            warn("❌ Failed to create AI controller:", ai)
            -- Visual feedback for error
            button.Color = Color3.fromRGB(255, 0, 0) -- Flash red
            task.wait(0.5)
            button.Color = Color3.fromRGB(255, 192, 203) -- Back to pink
            return
        end
        
        print("✅ AI controller created successfully!")
        print("🌍 Starting world generation...")
        
        local success, result = pcall(function()
            return ai:generateWorld()
        end)
        
        if not success then
            warn("❌ Failed to generate world:", result)
            -- Visual feedback for error
            button.Color = Color3.fromRGB(255, 0, 0) -- Flash red
            task.wait(0.5)
            button.Color = Color3.fromRGB(255, 192, 203) -- Back to pink
            return
        end
        
        if result then
            print("✨ World generation complete!")
            -- Visual feedback for success
            button.Color = Color3.fromRGB(0, 255, 0) -- Flash green
            task.wait(0.5)
            button.Color = Color3.fromRGB(255, 192, 203) -- Back to pink
        else
            print("⚠️ World generation failed")
            -- Visual feedback for failure
            button.Color = Color3.fromRGB(255, 0, 0) -- Flash red
            task.wait(0.5)
            button.Color = Color3.fromRGB(255, 192, 203) -- Back to pink
        end
    else
        print("⚠️ AIController not loaded - world generation disabled")
        -- Visual feedback for disabled
        button.Color = Color3.fromRGB(128, 128, 128) -- Flash gray
        task.wait(0.5)
        button.Color = Color3.fromRGB(255, 192, 203) -- Back to pink
    end
end)

-- Add to workspace
button.Parent = workspace

print("✨ Test button created!") 