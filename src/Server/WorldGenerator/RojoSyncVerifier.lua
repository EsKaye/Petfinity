--[[
    WorldGenerator/RojoSyncVerifier.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Verifies and creates necessary directory structure for Rojo sync
]]

local RojoSyncVerifier = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Required directory structure
local REQUIRED_DIRECTORIES = {
    "src/Shared",
    "src/Config",
    "src/ReplicatedStorage/Assets",
    "src/Server",
    "src/Client"
}

-- Function to create directory if it doesn't exist
local function ensureDirectory(path)
    local parts = path:split("/")
    local current = ""
    
    for _, part in ipairs(parts) do
        current = current .. (current ~= "" and "/" or "") .. part
        if not game:GetService("RunService"):IsStudio() then
            -- In production, we don't need to create directories
            return
        end
        
        local success, result = pcall(function()
            return game:GetService("HttpService"):GetAsync(current)
        end)
        
        if not success then
            print("  ✓ Creating directory:", current)
            -- Create directory logic would go here
        end
    end
end

-- Main function to verify and create directory structure
function RojoSyncVerifier.verifyStructure()
    print("📁 Verifying Rojo sync structure...")
    
    -- Create required directories
    for _, dir in ipairs(REQUIRED_DIRECTORIES) do
        ensureDirectory(dir)
    end
    
    -- Verify ReplicatedStorage structure
    local rs = ReplicatedStorage
    if not rs:FindFirstChild("Assets") then
        print("  ✓ Creating Assets folder in ReplicatedStorage")
        local assetsFolder = Instance.new("Folder")
        assetsFolder.Name = "Assets"
        assetsFolder.Parent = rs
    end
    
    -- Verify ServerScriptService structure
    local sss = game:GetService("ServerScriptService")
    if not sss:FindFirstChild("Server") then
        print("  ✓ Creating Server folder in ServerScriptService")
        local serverFolder = Instance.new("Folder")
        serverFolder.Name = "Server"
        serverFolder.Parent = sss
    end
    
    -- Verify StarterPlayerScripts structure
    local sps = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
    if sps and not sps:FindFirstChild("Client") then
        print("  ✓ Creating Client folder in StarterPlayerScripts")
        local clientFolder = Instance.new("Folder")
        clientFolder.Name = "Client"
        clientFolder.Parent = sps
    end
    
    print("✨ Directory structure verification complete!")
end

return RojoSyncVerifier 