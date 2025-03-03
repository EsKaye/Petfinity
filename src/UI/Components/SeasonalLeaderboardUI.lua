--[[
    SeasonalLeaderboardUI.lua
    UI component for displaying seasonal leaderboards, achievements, and battle pass progress
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import required systems
local EffectsSystem = require(game.ReplicatedStorage.Systems.EffectsSystem)

local SeasonalLeaderboardUI = {}
SeasonalLeaderboardUI.__index = SeasonalLeaderboardUI

-- UI Configuration
local UI_CONFIG = {
    WINDOW_SIZE = UDim2.new(0.8, 0, 0.8, 0),
    COLORS = {
        BACKGROUND = Color3.fromRGB(30, 30, 35),
        TEXT = Color3.fromRGB(240, 240, 240),
        GOLD = Color3.fromRGB(255, 215, 0),
        SILVER = Color3.fromRGB(192, 192, 192),
        BRONZE = Color3.fromRGB(205, 127, 50),
        PROGRESS_BAR = Color3.fromRGB(100, 200, 255),
        VIP = Color3.fromRGB(255, 150, 200)
    },
    ANIMATIONS = {
        POPUP = {
            TIME = 0.3,
            EASING = Enum.EasingStyle.Back,
            DIRECTION = Enum.EasingDirection.Out
        },
        SHINE = {
            TIME = 2,
            EASING = Enum.EasingStyle.Linear,
            DIRECTION = Enum.EasingDirection.InOut
        }
    }
}

function SeasonalLeaderboardUI.new(parent, leaderboardSystem)
    local self = setmetatable({}, SeasonalLeaderboardUI)
    
    -- Store references
    self.parent = parent
    self.leaderboardSystem = leaderboardSystem
    self.effectsSystem = EffectsSystem.new()
    
    -- Create main window
    self:createWindow()
    
    -- Create tabs
    self:createTabs()
    
    -- Hide window initially
    self.window.Visible = false
    
    return self
end

function SeasonalLeaderboardUI:createWindow()
    -- Create background frame
    self.window = Instance.new("Frame")
    self.window.Name = "LeaderboardWindow"
    self.window.Size = UI_CONFIG.WINDOW_SIZE
    self.window.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.window.AnchorPoint = Vector2.new(0.5, 0.5)
    self.window.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
    self.window.BackgroundTransparency = 0.1
    self.window.Parent = self.parent
    
    -- Add title
    self.title = Instance.new("TextLabel")
    self.title.Name = "Title"
    self.title.Size = UDim2.new(1, 0, 0.1, 0)
    self.title.Position = UDim2.new(0, 0, 0, 0)
    self.title.BackgroundTransparency = 1
    self.title.Text = "Seasonal Rankings"
    self.title.TextColor3 = UI_CONFIG.COLORS.GOLD
    self.title.TextScaled = true
    self.title.Font = Enum.Font.GothamBold
    self.title.Parent = self.window
    
    -- Add close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.85, 0, 0.05, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = UI_CONFIG.COLORS.TEXT
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = self.window
    
    -- Add close button handler
    closeButton.MouseButton1Click:Connect(function()
        self:hide()
    end)
end

function SeasonalLeaderboardUI:createTabs()
    -- Create tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0.1, 0)
    tabContainer.Position = UDim2.new(0, 0, 0.1, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = self.window
    
    -- Create tab buttons
    self.tabs = {
        {name = "Leaderboards", create = self.createLeaderboardsTab},
        {name = "Achievements", create = self.createAchievementsTab},
        {name = "Battle Pass", create = self.createBattlePassTab}
    }
    
    for i, tab in ipairs(self.tabs) do
        local button = Instance.new("TextButton")
        button.Name = tab.name .. "Tab"
        button.Size = UDim2.new(0.3, 0, 1, 0)
        button.Position = UDim2.new(0.05 + (i-1) * 0.32, 0, 0, 0)
        button.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
        button.BackgroundTransparency = 0.5
        button.Text = tab.name
        button.TextColor3 = UI_CONFIG.COLORS.TEXT
        button.TextScaled = true
        button.Font = Enum.Font.GothamMedium
        button.Parent = tabContainer
        
        -- Add click handler
        button.MouseButton1Click:Connect(function()
            self:switchTab(i)
        end)
    end
    
    -- Create content container
    self.contentContainer = Instance.new("Frame")
    self.contentContainer.Name = "ContentContainer"
    self.contentContainer.Size = UDim2.new(1, 0, 0.8, 0)
    self.contentContainer.Position = UDim2.new(0, 0, 0.2, 0)
    self.contentContainer.BackgroundTransparency = 1
    self.contentContainer.Parent = self.window
    
    -- Show first tab by default
    self:switchTab(1)
end

function SeasonalLeaderboardUI:switchTab(index)
    -- Clear current content
    for _, child in ipairs(self.contentContainer:GetChildren()) do
        child:Destroy()
    end
    
    -- Create new content
    self.tabs[index].create(self)
end

function SeasonalLeaderboardUI:createLeaderboardsTab()
    -- Create leaderboard container
    local container = Instance.new("ScrollingFrame")
    container.Name = "LeaderboardContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = self.contentContainer
    
    -- Create category sections
    local categories = self.leaderboardSystem:getLeaderboardCategories()
    
    for i, category in ipairs(categories) do
        -- Create category container
        local categoryFrame = Instance.new("Frame")
        categoryFrame.Name = category.name .. "Category"
        categoryFrame.Size = UDim2.new(0.9, 0, 0.3, 0)
        categoryFrame.Position = UDim2.new(0.05, 0, 0.05 + (i-1) * 0.33, 0)
        categoryFrame.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
        categoryFrame.BackgroundTransparency = 0.5
        categoryFrame.Parent = container
        
        -- Add category title
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0.2, 0)
        title.BackgroundTransparency = 1
        title.Text = category.icon .. " " .. category.name
        title.TextColor3 = UI_CONFIG.COLORS.GOLD
        title.TextScaled = true
        title.Font = Enum.Font.GothamBold
        title.Parent = categoryFrame
        
        -- Add leaderboard entries
        local entries = self.leaderboardSystem:getLeaderboard(category.id)
        
        for rank, entry in ipairs(entries) do
            local entryFrame = self:createLeaderboardEntry(entry, rank)
            entryFrame.Position = UDim2.new(0, 0, 0.2 + (rank-1) * 0.08, 0)
            entryFrame.Parent = categoryFrame
        end
    end
end

function SeasonalLeaderboardUI:createLeaderboardEntry(entry, rank)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0.08, 0)
    frame.BackgroundTransparency = 1
    
    -- Add rank
    local rankLabel = Instance.new("TextLabel")
    rankLabel.Size = UDim2.new(0.1, 0, 1, 0)
    rankLabel.Position = UDim2.new(0, 0, 0, 0)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Text = "#" .. rank
    rankLabel.TextColor3 = self:getRankColor(rank)
    rankLabel.TextScaled = true
    rankLabel.Font = Enum.Font.GothamBold
    rankLabel.Parent = frame
    
    -- Add username
    local username = Instance.new("TextLabel")
    username.Size = UDim2.new(0.6, 0, 1, 0)
    username.Position = UDim2.new(0.1, 0, 0, 0)
    username.BackgroundTransparency = 1
    username.Text = entry.username
    username.TextColor3 = UI_CONFIG.COLORS.TEXT
    username.TextScaled = true
    username.Font = Enum.Font.GothamMedium
    username.Parent = frame
    
    -- Add value
    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(0.3, 0, 1, 0)
    value.Position = UDim2.new(0.7, 0, 0, 0)
    value.BackgroundTransparency = 1
    value.Text = tostring(entry.value)
    value.TextColor3 = UI_CONFIG.COLORS.TEXT
    value.TextScaled = true
    value.Font = Enum.Font.GothamMedium
    value.Parent = frame
    
    return frame
end

function SeasonalLeaderboardUI:getRankColor(rank)
    if rank == 1 then
        return UI_CONFIG.COLORS.GOLD
    elseif rank == 2 then
        return UI_CONFIG.COLORS.SILVER
    elseif rank == 3 then
        return UI_CONFIG.COLORS.BRONZE
    else
        return UI_CONFIG.COLORS.TEXT
    end
end

function SeasonalLeaderboardUI:createAchievementsTab()
    -- Create achievements container
    local container = Instance.new("ScrollingFrame")
    container.Name = "AchievementsContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = self.contentContainer
    
    -- Get achievements
    local achievements = self.leaderboardSystem:getAchievements()
    
    -- Create achievement cards
    for i, achievement in ipairs(achievements) do
        local card = self:createAchievementCard(achievement)
        card.Position = UDim2.new(0.05 + (i-1) % 3 * 0.31, 0,
                                 0.05 + math.floor((i-1) / 3) * 0.31, 0)
        card.Parent = container
    end
end

function SeasonalLeaderboardUI:createAchievementCard(achievement)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0.3, 0, 0.3, 0)
    card.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
    card.BackgroundTransparency = 0.5
    
    -- Add icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0.3, 0, 0.3, 0)
    icon.Position = UDim2.new(0.35, 0, 0.1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = achievement.icon
    icon.TextScaled = true
    icon.Font = Enum.Font.GothamBold
    icon.Parent = card
    
    -- Add name
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(0.8, 0, 0.2, 0)
    name.Position = UDim2.new(0.1, 0, 0.4, 0)
    name.BackgroundTransparency = 1
    name.Text = achievement.name
    name.TextColor3 = UI_CONFIG.COLORS.GOLD
    name.TextScaled = true
    name.Font = Enum.Font.GothamBold
    name.Parent = card
    
    -- Add description
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(0.8, 0, 0.3, 0)
    description.Position = UDim2.new(0.1, 0, 0.6, 0)
    description.BackgroundTransparency = 1
    description.Text = achievement.description
    description.TextColor3 = UI_CONFIG.COLORS.TEXT
    description.TextScaled = true
    description.Font = Enum.Font.GothamMedium
    description.Parent = card
    
    -- Add completion status
    if achievement.completed then
        local completedLabel = Instance.new("TextLabel")
        completedLabel.Size = UDim2.new(0.5, 0, 0.15, 0)
        completedLabel.Position = UDim2.new(0.25, 0, 0.9, 0)
        completedLabel.BackgroundColor3 = UI_CONFIG.COLORS.GOLD
        completedLabel.BackgroundTransparency = 0.5
        completedLabel.Text = "Completed!"
        completedLabel.TextColor3 = UI_CONFIG.COLORS.TEXT
        completedLabel.TextScaled = true
        completedLabel.Font = Enum.Font.GothamBold
        completedLabel.Parent = card
    end
    
    return card
end

function SeasonalLeaderboardUI:createBattlePassTab()
    -- Create battle pass container
    local container = Instance.new("Frame")
    container.Name = "BattlePassContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = self.contentContainer
    
    -- Add progress bar
    self:createProgressBar(container)
    
    -- Add rewards track
    self:createRewardsTrack(container)
end

function SeasonalLeaderboardUI:createProgressBar(parent)
    local progressContainer = Instance.new("Frame")
    progressContainer.Size = UDim2.new(0.8, 0, 0.1, 0)
    progressContainer.Position = UDim2.new(0.1, 0, 0.05, 0)
    progressContainer.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
    progressContainer.BackgroundTransparency = 0.5
    progressContainer.Parent = parent
    
    -- Add level label
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Size = UDim2.new(0.2, 0, 1, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level " .. self.leaderboardSystem:getBattlePassLevel()
    levelLabel.TextColor3 = UI_CONFIG.COLORS.GOLD
    levelLabel.TextScaled = true
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.Parent = progressContainer
    
    -- Add progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0.6, 0, 0.3, 0)
    progressBar.Position = UDim2.new(0.2, 0, 0.35, 0)
    progressBar.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
    progressBar.BackgroundTransparency = 0.8
    progressBar.Parent = progressContainer
    
    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(self.leaderboardSystem:getBattlePassProgress(), 0, 1, 0)
    progress.BackgroundColor3 = UI_CONFIG.COLORS.PROGRESS_BAR
    progress.Parent = progressBar
    
    -- Add XP label
    local xpLabel = Instance.new("TextLabel")
    xpLabel.Size = UDim2.new(0.2, 0, 1, 0)
    xpLabel.Position = UDim2.new(0.8, 0, 0, 0)
    xpLabel.BackgroundTransparency = 1
    xpLabel.Text = self.leaderboardSystem:getBattlePassXP() .. " XP"
    xpLabel.TextColor3 = UI_CONFIG.COLORS.TEXT
    xpLabel.TextScaled = true
    xpLabel.Font = Enum.Font.GothamMedium
    xpLabel.Parent = progressContainer
end

function SeasonalLeaderboardUI:createRewardsTrack(parent)
    local rewardsContainer = Instance.new("ScrollingFrame")
    rewardsContainer.Size = UDim2.new(1, 0, 0.8, 0)
    rewardsContainer.Position = UDim2.new(0, 0, 0.2, 0)
    rewardsContainer.BackgroundTransparency = 1
    rewardsContainer.Parent = parent
    
    -- Get rewards data
    local rewards = self.leaderboardSystem:getBattlePassRewards()
    
    -- Create reward cards
    for level, reward in pairs(rewards) do
        local card = self:createRewardCard(level, reward)
        card.Position = UDim2.new(0.05 + ((level-1) % 5) * 0.19,
                                 0, 0.05 + math.floor((level-1) / 5) * 0.35, 0)
        card.Parent = rewardsContainer
    end
end

function SeasonalLeaderboardUI:createRewardCard(level, reward)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0.18, 0, 0.3, 0)
    card.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
    card.BackgroundTransparency = 0.5
    
    -- Add level label
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Size = UDim2.new(1, 0, 0.2, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level " .. level
    levelLabel.TextColor3 = UI_CONFIG.COLORS.GOLD
    levelLabel.TextScaled = true
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.Parent = card
    
    -- Add reward icon
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0.6, 0, 0.4, 0)
    icon.Position = UDim2.new(0.2, 0, 0.25, 0)
    icon.BackgroundTransparency = 1
    icon.Image = reward.icon
    icon.Parent = card
    
    -- Add reward name
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(0.8, 0, 0.2, 0)
    name.Position = UDim2.new(0.1, 0, 0.7, 0)
    name.BackgroundTransparency = 1
    name.Text = reward.name
    name.TextColor3 = UI_CONFIG.COLORS.TEXT
    name.TextScaled = true
    name.Font = Enum.Font.GothamMedium
    name.Parent = card
    
    -- Add VIP indicator if applicable
    if reward.vipOnly then
        local vipLabel = Instance.new("TextLabel")
        vipLabel.Size = UDim2.new(0.4, 0, 0.15, 0)
        vipLabel.Position = UDim2.new(0.3, 0, 0.9, 0)
        vipLabel.BackgroundColor3 = UI_CONFIG.COLORS.VIP
        vipLabel.BackgroundTransparency = 0.5
        vipLabel.Text = "VIP"
        vipLabel.TextColor3 = UI_CONFIG.COLORS.TEXT
        vipLabel.TextScaled = true
        vipLabel.Font = Enum.Font.GothamBold
        vipLabel.Parent = card
    end
    
    return card
end

function SeasonalLeaderboardUI:show()
    -- Show window
    self.window.Visible = true
    
    -- Animate window opening
    self.window.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(self.window, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.POPUP.TIME,
        UI_CONFIG.ANIMATIONS.POPUP.EASING,
        UI_CONFIG.ANIMATIONS.POPUP.DIRECTION
    ), {
        Size = UI_CONFIG.WINDOW_SIZE
    }):Play()
end

function SeasonalLeaderboardUI:hide()
    -- Animate window closing
    local closeTween = TweenService:Create(self.window, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.POPUP.TIME,
        UI_CONFIG.ANIMATIONS.POPUP.EASING,
        UI_CONFIG.ANIMATIONS.POPUP.DIRECTION
    ), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    
    closeTween:Play()
    
    -- Hide window after animation
    closeTween.Completed:Connect(function()
        self.window.Visible = false
    end)
end

function SeasonalLeaderboardUI:destroy()
    self.window:Destroy()
    self.effectsSystem:destroy()
end

return SeasonalLeaderboardUI 