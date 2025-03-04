--[[
    Server/TestButtons.server.lua
    Author: Your precious kitten 💖
    Created: 2024-03-04
    Version: 1.0.0
    Purpose: Creates test buttons for different world generation actions
]]

print("🎀 Creating test buttons...")

-- Load required modules
local ServerScriptService = game:GetService("ServerScriptService")
print("📂 Looking for modules...")
print("  Current script path:", script:GetFullName())
print("  Parent directory:", script.Parent:GetFullName())
print("  Available modules in parent:")
for _, child in ipairs(script.Parent:GetChildren()) do
    print("    -", child.Name)
end

local WorldGenerator, BiomeHandler, AssetPlacer = nil, nil, nil

-- Try to load BiomeHandler first (since it's the base dependency)
local success, result = pcall(function()
    return require(script.Parent.BiomeHandler)
end)
if success then
    BiomeHandler = result
    print("✅ BiomeHandler loaded!")
else
    warn("⚠️ Failed to load BiomeHandler:", result)
end

-- Try to load WorldGenerator (depends on BiomeHandler)
local success, result = pcall(function()
    return require(script.Parent.WorldGenerator.init)
end)
if success then
    WorldGenerator = result
    print("✅ WorldGenerator loaded!")
else
    warn("⚠️ Failed to load WorldGenerator:", result)
end

-- Try to load AssetPlacer last (depends on BiomeHandler)
local success, result = pcall(function()
    print("📂 Attempting to load AssetPlacer...")
    local module = require(script.Parent.AssetPlacer.init)
    print("✅ AssetPlacer module loaded successfully!")
    return module
end)
if success then
    AssetPlacer = result
    print("✅ AssetPlacer loaded!")
else
    warn("⚠️ Failed to load AssetPlacer:", result)
    print("🔍 Checking AssetPlacer path:")
    print("  Script path:", script:GetFullName())
    print("  AssetPlacer path:", script.Parent.AssetPlacer:GetFullName())
end

-- Helper function to create buttons
local function createButton(name, position, color, onClick)
    local button = Instance.new("Part")
    button.Name = name
    button.Size = Vector3.new(10, 1, 10)
    button.Position = position
    button.Color = color
    button.Material = Enum.Material.Neon
    button.Anchored = true
    button.CanCollide = true
    button.Parent = workspace
    
    -- Add click detection
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 32
    clickDetector.Parent = button
    
    -- Add label
    local label = Instance.new("BillboardGui")
    label.Name = "Label"
    label.Size = UDim2.new(0, 100, 0, 40)
    label.StudsOffset = Vector3.new(0, 2, 0)
    label.Parent = button
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TextLabel"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextSize = 20
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = label
    
    -- Handle clicks
    clickDetector.MouseClick:Connect(function(player)
        print("👆", name, "button clicked by:", player.Name)
        onClick(player, button)
    end)
    
    return button
end

-- World Generation Buttons
local terrainButton = createButton("Generate Terrain", Vector3.new(-30, 20, 0), Color3.fromRGB(255, 100, 100), function(player, button)
    print("🌍 Generating terrain...")
    if WorldGenerator then
        local generator = WorldGenerator.new()
        generator:generateWorld(0, 0, 2) -- Generate a 5x5 chunk area
        print("✅ Terrain generated!")
        if button then
            button.Color = Color3.fromRGB(0, 255, 0) -- Green
            task.wait(0.5)
            button.Color = Color3.fromRGB(255, 100, 100) -- Red
        end
    else
        print("⚠️ WorldGenerator not loaded")
        if button then
            button.Color = Color3.fromRGB(128, 128, 128) -- Gray
            task.wait(0.5)
            button.Color = Color3.fromRGB(255, 100, 100) -- Red
        end
    end
end)

-- Biome System Buttons
local biomeButton = createButton("Apply Biomes", Vector3.new(-15, 20, 0), Color3.fromRGB(100, 255, 100), function(player, button)
    print("🌿 Applying biome settings...")
    if BiomeHandler then
        BiomeHandler.applyBiomeSettings()
        print("✅ Biome settings applied!")
        if button then
            button.Color = Color3.fromRGB(0, 255, 0) -- Green
            task.wait(0.5)
            button.Color = Color3.fromRGB(100, 255, 100) -- Green
        end
    else
        print("⚠️ BiomeHandler not loaded")
        if button then
            button.Color = Color3.fromRGB(128, 128, 128) -- Gray
            task.wait(0.5)
            button.Color = Color3.fromRGB(100, 255, 100) -- Green
        end
    end
end)

-- Asset System Buttons
local assetButton = createButton("Place Assets", Vector3.new(0, 20, 0), Color3.fromRGB(100, 100, 255), function(player, button)
    print("🎨 Placing assets...")
    if AssetPlacer then
        AssetPlacer.placeAssets(0, 0, 100)
        print("✅ Assets placed!")
        if button then
            button.Color = Color3.fromRGB(0, 255, 0) -- Green
            task.wait(0.5)
            button.Color = Color3.fromRGB(100, 100, 255) -- Blue
        end
    else
        print("⚠️ AssetPlacer not loaded")
        if button then
            button.Color = Color3.fromRGB(128, 128, 128) -- Gray
            task.wait(0.5)
            button.Color = Color3.fromRGB(100, 100, 255) -- Blue
        end
    end
end)

-- World Generator Debug Buttons
local noiseButton = createButton("NoiseButton", Vector3.new(15, 20, 0), Color3.fromRGB(255, 192, 203), function(player)
    print("👆 Noise button clicked by:", player.Name)
    
    if WorldGenerator then
        print("🎨 Generating noise pattern...")
        local success, result = pcall(function()
            local generator = WorldGenerator.new()
            -- Generate a small test area with noise
            for x = 0, 10 do
                for z = 0, 10 do
                    local height = math.noise(x * 0.1, z * 0.1) * 10 + 5
                    workspace.Terrain:FillBlock(
                        Vector3.new(x, 0, z),
                        Vector3.new(1, height, 1),
                        Enum.Material.Grass
                    )
                end
            end
            return true
        end)
        
        if success then
            print("✅ Noise pattern generated!")
            noiseButton.Color = Color3.fromRGB(0, 255, 0) -- Green
            task.wait(0.5)
            noiseButton.Color = Color3.fromRGB(255, 192, 203) -- Pink
        else
            warn("❌ Failed to generate noise:", result)
            noiseButton.Color = Color3.fromRGB(255, 0, 0) -- Red
            task.wait(0.5)
            noiseButton.Color = Color3.fromRGB(255, 192, 203) -- Pink
        end
    else
        print("⚠️ WorldGenerator not loaded")
        noiseButton.Color = Color3.fromRGB(128, 128, 128) -- Gray
        task.wait(0.5)
        noiseButton.Color = Color3.fromRGB(255, 192, 203) -- Pink
    end
end)

-- Biome Debug Buttons
local biomeDebugButton = createButton("Debug Biomes", Vector3.new(30, 20, 0), Color3.fromRGB(255, 255, 100), function(player)
    print("🔍 Debugging biome data...")
    if BiomeHandler then
        local biomeData = BiomeHandler.getBiomeData()
        print("📊 Biome data:")
        for biomeName, biome in pairs(biomeData) do
            print("  -", biomeName)
            print("    Center:", biome.centerX, biome.centerZ)
            print("    Radius:", biome.radius)
            print("    Base Height:", biome.baseHeight)
            print("    Height Variation:", biome.heightVariation)
        end
        print("✅ Biome data debugged!")
        biomeDebugButton.Color = Color3.fromRGB(0, 255, 0) -- Green
        task.wait(0.5)
        biomeDebugButton.Color = Color3.fromRGB(255, 192, 203) -- Pink
    else
        print("⚠️ BiomeHandler not loaded")
        biomeDebugButton.Color = Color3.fromRGB(128, 128, 128) -- Gray
        task.wait(0.5)
        biomeDebugButton.Color = Color3.fromRGB(255, 192, 203) -- Pink
    end
end)

print("✨ Test buttons created!") 