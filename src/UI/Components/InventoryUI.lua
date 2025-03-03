--[[
    InventoryUI.lua
    UI component for displaying and managing pet collection
    
    Author: Cursor AI
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import components
local PetCard = require(script.Parent.PetCard)

local InventoryUI = {}
InventoryUI.__index = InventoryUI

-- Constants for layout
local GRID_CONFIG = {
    PADDING = 10,
    CARD_WIDTH = 120,
    CARD_HEIGHT = 150,
    COLUMNS_DESKTOP = 5,
    COLUMNS_MOBILE = 3
}

-- Sorting options
local SORT_TYPES = {
    RARITY = "RARITY",
    NEWEST = "NEWEST",
    LEVEL = "LEVEL",
    FAVORITES = "FAVORITES"
}

-- Rarity order for sorting
local RARITY_ORDER = {
    LEGENDARY = 1,
    EPIC = 2,
    RARE = 3,
    UNCOMMON = 4,
    COMMON = 5
}

function InventoryUI.new(parent)
    local self = setmetatable({}, InventoryUI)
    
    -- Create main container
    self.container = Instance.new("Frame")
    self.container.Name = "InventoryUI"
    self.container.Size = UDim2.new(1, 0, 1, 0)
    self.container.BackgroundTransparency = 0.1
    self.container.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    self.container.Parent = parent
    
    -- Create scroll frame for grid
    self.scrollFrame = Instance.new("ScrollingFrame")
    self.scrollFrame.Name = "PetGrid"
    self.scrollFrame.Size = UDim2.new(1, 0, 0.9, 0)
    self.scrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
    self.scrollFrame.BackgroundTransparency = 1
    self.scrollFrame.ScrollBarThickness = 6
    self.scrollFrame.Parent = self.container
    
    -- Create UI grid layout
    self.gridLayout = Instance.new("UIGridLayout")
    self.gridLayout.CellSize = UDim2.new(0, GRID_CONFIG.CARD_WIDTH, 0, GRID_CONFIG.CARD_HEIGHT)
    self.gridLayout.CellPadding = UDim2.new(0, GRID_CONFIG.PADDING, 0, GRID_CONFIG.PADDING)
    self.gridLayout.Parent = self.scrollFrame
    
    -- Create sort buttons container
    self.sortContainer = Instance.new("Frame")
    self.sortContainer.Name = "SortButtons"
    self.sortContainer.Size = UDim2.new(1, 0, 0.1, 0)
    self.sortContainer.BackgroundTransparency = 0.5
    self.sortContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    self.sortContainer.Parent = self.container
    
    -- Create sort buttons
    self:createSortButtons()
    
    -- Initialize state
    self.currentSort = SORT_TYPES.RARITY
    self.petCards = {}
    self.favorites = {}
    
    -- Set up responsive layout
    self:setupResponsiveLayout()
    
    return self
end

function InventoryUI:createSortButtons()
    local buttonWidth = 0.2
    local spacing = (1 - buttonWidth * 4) / 5
    local positions = {
        spacing,
        spacing * 2 + buttonWidth,
        spacing * 3 + buttonWidth * 2,
        spacing * 4 + buttonWidth * 3
    }
    
    local sortTypes = {"RARITY", "NEWEST", "LEVEL", "FAVORITES"}
    
    for i, sortType in ipairs(sortTypes) do
        local button = Instance.new("TextButton")
        button.Name = sortType .. "Button"
        button.Size = UDim2.new(buttonWidth, 0, 0.8, 0)
        button.Position = UDim2.new(positions[i], 0, 0.1, 0)
        button.Text = sortType
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        button.BackgroundTransparency = 0.2
        
        -- Add hover effect
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(80, 80, 85)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            }):Play()
        end)
        
        -- Add click handler
        button.MouseButton1Click:Connect(function()
            self:setSortType(SORT_TYPES[sortType])
        end)
        
        button.Parent = self.sortContainer
    end
end

function InventoryUI:setupResponsiveLayout()
    -- Update grid columns based on screen size
    local function updateLayout()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local isMobile = viewportSize.X < 800
        
        local columns = isMobile and GRID_CONFIG.COLUMNS_MOBILE or GRID_CONFIG.COLUMNS_DESKTOP
        local availableWidth = self.scrollFrame.AbsoluteSize.X
        local cardWidth = (availableWidth - (columns + 1) * GRID_CONFIG.PADDING) / columns
        
        self.gridLayout.CellSize = UDim2.new(0, cardWidth, 0, cardWidth * 1.25)
    end
    
    -- Connect to window resize events
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateLayout)
    updateLayout()
end

function InventoryUI:addPet(petData)
    -- Create new pet card
    local card = PetCard.new(self.scrollFrame, petData)
    self.petCards[petData.id] = card
    
    -- Sort pets after adding new one
    self:sortPets()
end

function InventoryUI:removePet(petId)
    local card = self.petCards[petId]
    if card then
        card:destroy()
        self.petCards[petId] = nil
        self:sortPets()
    end
end

function InventoryUI:setSortType(sortType)
    if self.currentSort == sortType then return end
    self.currentSort = sortType
    self:sortPets()
end

function InventoryUI:sortPets()
    local pets = {}
    for _, card in pairs(self.petCards) do
        table.insert(pets, card)
    end
    
    -- Sort based on current sort type
    if self.currentSort == SORT_TYPES.RARITY then
        table.sort(pets, function(a, b)
            return RARITY_ORDER[a.petData.rarity] < RARITY_ORDER[b.petData.rarity]
        end)
    elseif self.currentSort == SORT_TYPES.NEWEST then
        table.sort(pets, function(a, b)
            return a.petData.id > b.petData.id
        end)
    elseif self.currentSort == SORT_TYPES.LEVEL then
        table.sort(pets, function(a, b)
            return a.petData.level > b.petData.level
        end)
    elseif self.currentSort == SORT_TYPES.FAVORITES then
        table.sort(pets, function(a, b)
            local aFav = self.favorites[a.petData.id] and 1 or 0
            local bFav = self.favorites[b.petData.id] and 1 or 0
            if aFav ~= bFav then
                return aFav > bFav
            end
            return RARITY_ORDER[a.petData.rarity] < RARITY_ORDER[b.petData.rarity]
        end)
    end
    
    -- Reorder in grid
    for i, card in ipairs(pets) do
        card.container.LayoutOrder = i
    end
end

function InventoryUI:toggleFavorite(petId)
    self.favorites[petId] = not self.favorites[petId]
    if self.currentSort == SORT_TYPES.FAVORITES then
        self:sortPets()
    end
end

function InventoryUI:destroy()
    self.container:Destroy()
end

return InventoryUI 