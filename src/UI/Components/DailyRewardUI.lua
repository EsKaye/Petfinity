--[[
    DailyRewardUI.lua
    UI component for displaying daily rewards and streak progress
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 0.1.1
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import EffectsSystem for reward animations
local EffectsSystem = require(game.ReplicatedStorage.Systems.EffectsSystem)

local DailyRewardUI = {}
DailyRewardUI.__index = DailyRewardUI

-- UI Configuration
local UI_CONFIG = {
    WINDOW_SIZE = UDim2.new(0.6, 0, 0.7, 0),
    REWARD_CARD_SIZE = UDim2.new(0.2, 0, 0.25, 0),
    CARD_SPACING = 0.05,
    COLORS = {
        BACKGROUND = Color3.fromRGB(30, 30, 35),
        CARD_BG = Color3.fromRGB(45, 45, 50),
        CARD_HIGHLIGHT = Color3.fromRGB(60, 60, 65),
        TEXT = Color3.fromRGB(240, 240, 240),
        STREAK_BAR = Color3.fromRGB(255, 150, 200),
        VIP = Color3.fromRGB(255, 215, 0),
        LEGENDARY = Color3.fromRGB(255, 100, 255),
        ERROR = Color3.fromRGB(255, 100, 100),
        SUCCESS = Color3.fromRGB(100, 255, 150)
    },
    ANIMATIONS = {
        POPUP = {
            TIME = 0.3,
            EASING = Enum.EasingStyle.Back,
            DIRECTION = Enum.EasingDirection.Out
        },
        GLOW = {
            TIME = 1,
            EASING = Enum.EasingStyle.Sine,
            DIRECTION = Enum.EasingDirection.InOut
        },
        BOUNCE = {
            TIME = 0.2,
            EASING = Enum.EasingStyle.Bounce,
            DIRECTION = Enum.EasingDirection.Out
        },
        JACKPOT = {
            TIME = 0.5,
            EASING = Enum.EasingStyle.Elastic,
            DIRECTION = Enum.EasingDirection.Out,
            SHAKE_INTENSITY = 20,
            SHAKE_DURATION = 1
        }
    }
}

function DailyRewardUI.new(parent, dailyRewardSystem)
    local self = setmetatable({}, DailyRewardUI)
    
    -- Store references
    self.parent = parent
    self.dailyRewardSystem = dailyRewardSystem
    self.effectsSystem = EffectsSystem.new()
    
    -- Create main UI container
    self:createMainWindow()
    
    -- Create reward cards
    self:createRewardCards()
    
    -- Create streak progress bar
    self:createStreakBar()
    
    -- Set up animations
    self:setupAnimations()
    
    return self
end

function DailyRewardUI:createMainWindow()
    -- Create background frame
    self.window = Instance.new("Frame")
    self.window.Name = "DailyRewardWindow"
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
    self.title.Text = "Daily Rewards"
    self.title.TextColor3 = UI_CONFIG.COLORS.TEXT
    self.title.TextScaled = true
    self.title.Font = Enum.Font.GothamBold
    self.title.Parent = self.window
    
    -- Add close button
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
    self.closeButton.Position = UDim2.new(0.9, 0, 0, 0)
    self.closeButton.BackgroundTransparency = 1
    self.closeButton.Text = "×"
    self.closeButton.TextColor3 = UI_CONFIG.COLORS.TEXT
    self.closeButton.TextScaled = true
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.Parent = self.window
    
    -- Add close button handler
    self.closeButton.MouseButton1Click:Connect(function()
        self:hide()
    end)
end

function DailyRewardUI:createRewardCards()
    -- Create container for reward cards
    self.rewardContainer = Instance.new("Frame")
    self.rewardContainer.Name = "RewardContainer"
    self.rewardContainer.Size = UDim2.new(1, 0, 0.7, 0)
    self.rewardContainer.Position = UDim2.new(0, 0, 0.15, 0)
    self.rewardContainer.BackgroundTransparency = 1
    self.rewardContainer.Parent = self.window
    
    -- Create reward cards
    self.rewardCards = {}
    local cardsPerRow = 4
    local spacing = UI_CONFIG.CARD_SPACING
    local cardWidth = (1 - (spacing * (cardsPerRow - 1))) / cardsPerRow
    
    for i = 1, 7 do
        local row = math.floor((i-1) / cardsPerRow)
        local col = (i-1) % cardsPerRow
        
        local card = self:createRewardCard(
            UDim2.new(
                cardWidth,
                0,
                0.45,
                0
            ),
            UDim2.new(
                col * (cardWidth + spacing),
                0,
                row * (0.5 + spacing),
                0
            ),
            i
        )
        
        self.rewardCards[i] = card
    end
end

function DailyRewardUI:createRewardCard(size, position, day)
    local card = Instance.new("Frame")
    card.Name = "RewardCard_" .. day
    card.Size = size
    card.Position = position
    card.BackgroundColor3 = UI_CONFIG.COLORS.CARD_BG
    card.Parent = self.rewardContainer
    
    -- Add day number
    local dayLabel = Instance.new("TextLabel")
    dayLabel.Name = "DayLabel"
    dayLabel.Size = UDim2.new(1, 0, 0.2, 0)
    dayLabel.Position = UDim2.new(0, 0, 0, 0)
    dayLabel.BackgroundTransparency = 1
    dayLabel.Text = "Day " .. day
    dayLabel.TextColor3 = UI_CONFIG.COLORS.TEXT
    dayLabel.TextScaled = true
    dayLabel.Font = Enum.Font.GothamMedium
    dayLabel.Parent = card
    
    -- Add reward icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "RewardIcon"
    icon.Size = UDim2.new(0.6, 0, 0.6, 0)
    icon.Position = UDim2.new(0.2, 0, 0.25, 0)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://reward_icon" -- Replace with actual icon
    icon.Parent = card
    
    -- Add click handler
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:handleCardClick(day)
        end
    end)
    
    return card
end

function DailyRewardUI:createStreakBar()
    -- Create streak container
    self.streakContainer = Instance.new("Frame")
    self.streakContainer.Name = "StreakContainer"
    self.streakContainer.Size = UDim2.new(0.8, 0, 0.1, 0)
    self.streakContainer.Position = UDim2.new(0.1, 0, 0.87, 0)
    self.streakContainer.BackgroundColor3 = UI_CONFIG.COLORS.CARD_BG
    self.streakContainer.Parent = self.window
    
    -- Create streak progress bar
    self.streakBar = Instance.new("Frame")
    self.streakBar.Name = "StreakBar"
    self.streakBar.Size = UDim2.new(0, 0, 1, 0)
    self.streakBar.BackgroundColor3 = UI_CONFIG.COLORS.STREAK_BAR
    self.streakBar.Parent = self.streakContainer
    
    -- Add streak text
    self.streakText = Instance.new("TextLabel")
    self.streakText.Name = "StreakText"
    self.streakText.Size = UDim2.new(1, 0, 1, 0)
    self.streakText.BackgroundTransparency = 1
    self.streakText.Text = "Current Streak: 0 days"
    self.streakText.TextColor3 = UI_CONFIG.COLORS.TEXT
    self.streakText.TextScaled = true
    self.streakText.Font = Enum.Font.GothamBold
    self.streakText.Parent = self.streakContainer
end

function DailyRewardUI:setupAnimations()
    -- Add hover effects to reward cards
    for _, card in ipairs(self.rewardCards) do
        card.MouseEnter:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.2), {
                BackgroundColor3 = UI_CONFIG.COLORS.CARD_HIGHLIGHT,
                Size = card.Size * UDim2.new(1.05, 1.05, 1.05, 1.05)
            }):Play()
        end)
        
        card.MouseLeave:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.2), {
                BackgroundColor3 = UI_CONFIG.COLORS.CARD_BG,
                Size = card.Size * UDim2.new(1/1.05, 1/1.05, 1/1.05, 1/1.05)
            }):Play()
        end)
    end
end

function DailyRewardUI:handleCardClick(day)
    -- Check if reward can be claimed
    local canClaim, error = self.dailyRewardSystem:canClaimReward()
    if not canClaim then
        self:showError(error)
        return
    end
    
    -- Claim reward
    local success, rewards = self.dailyRewardSystem:claimDailyReward()
    if success then
        self:playRewardAnimation(day, rewards)
        self:updateStreakDisplay()
    end
end

function DailyRewardUI:showRestorePrompt(streak)
    -- Create prompt container
    local promptContainer = Instance.new("Frame")
    promptContainer.Name = "RestorePrompt"
    promptContainer.Size = UDim2.new(0.8, 0, 0.4, 0)
    promptContainer.Position = UDim2.new(0.1, 0, 0.3, 0)
    promptContainer.BackgroundColor3 = UI_CONFIG.COLORS.CARD_BG
    promptContainer.Parent = self.window
    
    -- Add glow effect
    local glowEffect = Instance.new("UIGradient")
    glowEffect.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
    })
    glowEffect.Parent = promptContainer
    
    -- Animate glow
    local rotation = 0
    game:GetService("RunService").RenderStepped:Connect(function()
        rotation = (rotation + 1) % 360
        glowEffect.Rotation = rotation
    end)
    
    -- Add message
    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(0.8, 0, 0.4, 0)
    message.Position = UDim2.new(0.1, 0, 0.1, 0)
    message.BackgroundTransparency = 1
    message.Text = "Oh no! You missed a day!\nRestore your " .. streak .. " day streak for 25 Robux?"
    message.TextColor3 = UI_CONFIG.COLORS.TEXT
    message.TextScaled = true
    message.Font = Enum.Font.GothamBold
    message.Parent = promptContainer
    
    -- Add buttons
    local restoreButton = Instance.new("TextButton")
    restoreButton.Size = UDim2.new(0.4, 0, 0.2, 0)
    restoreButton.Position = UDim2.new(0.1, 0, 0.7, 0)
    restoreButton.BackgroundColor3 = UI_CONFIG.COLORS.SUCCESS
    restoreButton.Text = "Restore (25 R$)"
    restoreButton.TextColor3 = UI_CONFIG.COLORS.TEXT
    restoreButton.TextScaled = true
    restoreButton.Font = Enum.Font.GothamBold
    restoreButton.Parent = promptContainer
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Size = UDim2.new(0.3, 0, 0.2, 0)
    cancelButton.Position = UDim2.new(0.6, 0, 0.7, 0)
    cancelButton.BackgroundColor3 = UI_CONFIG.COLORS.ERROR
    cancelButton.Text = "Reset"
    cancelButton.TextColor3 = UI_CONFIG.COLORS.TEXT
    cancelButton.TextScaled = true
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Parent = promptContainer
    
    -- Add button handlers
    restoreButton.MouseButton1Click:Connect(function()
        local success = self.dailyRewardSystem:restoreStreak()
        if success then
            self:playRestoreAnimation()
        end
        promptContainer:Destroy()
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        promptContainer:Destroy()
    end)
    
    -- Animate prompt appearance
    promptContainer.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(promptContainer, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.POPUP.TIME,
        UI_CONFIG.ANIMATIONS.POPUP.EASING,
        UI_CONFIG.ANIMATIONS.POPUP.DIRECTION
    ), {
        Size = UDim2.new(0.8, 0, 0.4, 0)
    }):Play()
end

function DailyRewardUI:playRestoreAnimation()
    -- Create restoration effect
    local effect = Instance.new("Frame")
    effect.Size = UDim2.new(1, 0, 1, 0)
    effect.BackgroundColor3 = UI_CONFIG.COLORS.VIP
    effect.BackgroundTransparency = 0.5
    effect.Parent = self.window
    
    -- Play golden wave effect
    TweenService:Create(effect, TweenInfo.new(1), {
        BackgroundTransparency = 1
    }):Play()
    
    -- Play particle effects
    self.effectsSystem:playParticles({
        position = self.window.AbsolutePosition + self.window.AbsoluteSize/2,
        color = UI_CONFIG.COLORS.VIP,
        lifetime = NumberRange.new(1, 2),
        rate = 50,
        speed = NumberRange.new(50, 100)
    })
    
    wait(1)
    effect:Destroy()
end

function DailyRewardUI:playRewardAnimation(day, rewards)
    local card = self.rewardCards[day]
    if not card then return end
    
    -- Determine if this is a legendary reward
    local isLegendary = false
    for _, reward in ipairs(rewards) do
        if reward.type == "EXCLUSIVE_EGG" then
            isLegendary = true
            break
        end
    end
    
    -- Play appropriate animation
    if isLegendary then
        self:playJackpotAnimation(card)
    else
        self:playNormalRewardAnimation(card)
    end
end

function DailyRewardUI:playJackpotAnimation(card)
    -- Play screen shake
    local originalPosition = self.window.Position
    local shake = UI_CONFIG.ANIMATIONS.JACKPOT.SHAKE_INTENSITY
    
    for i = 1, UI_CONFIG.ANIMATIONS.JACKPOT.SHAKE_DURATION * 60 do
        self.window.Position = originalPosition + UDim2.new(
            math.random(-shake, shake)/1000,
            0,
            math.random(-shake, shake)/1000,
            0
        )
        wait(1/60)
        shake = shake * 0.9
    end
    
    self.window.Position = originalPosition
    
    -- Play legendary effects
    local glow = Instance.new("UIGradient")
    glow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, UI_CONFIG.COLORS.LEGENDARY),
        ColorSequenceKeypoint.new(0.5, UI_CONFIG.COLORS.VIP),
        ColorSequenceKeypoint.new(1, UI_CONFIG.COLORS.LEGENDARY)
    })
    glow.Parent = card
    
    -- Rotate glow
    local rotation = 0
    game:GetService("RunService").RenderStepped:Connect(function()
        rotation = (rotation + 2) % 360
        glow.Rotation = rotation
    end)
    
    -- Play particle burst
    self.effectsSystem:playParticles({
        position = card.AbsolutePosition + card.AbsoluteSize/2,
        color = UI_CONFIG.COLORS.LEGENDARY,
        lifetime = NumberRange.new(1, 2),
        rate = 100,
        speed = NumberRange.new(100, 200)
    })
    
    -- Scale card up and down
    TweenService:Create(card, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.JACKPOT.TIME,
        UI_CONFIG.ANIMATIONS.JACKPOT.EASING,
        UI_CONFIG.ANIMATIONS.JACKPOT.DIRECTION
    ), {
        Size = card.Size * UDim2.new(1.5, 1.5, 1.5, 1.5)
    }):Play()
    
    wait(UI_CONFIG.ANIMATIONS.JACKPOT.TIME)
    
    TweenService:Create(card, TweenInfo.new(0.5), {
        Size = card.Size * UDim2.new(1/1.5, 1/1.5, 1/1.5, 1/1.5)
    }):Play()
end

function DailyRewardUI:playNormalRewardAnimation(card)
    -- Play pop animation
    local originalSize = card.Size
    
    TweenService:Create(card, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.POPUP.TIME,
        UI_CONFIG.ANIMATIONS.POPUP.EASING,
        UI_CONFIG.ANIMATIONS.POPUP.DIRECTION
    ), {
        Size = originalSize * UDim2.new(1.2, 1.2, 1.2, 1.2),
        BackgroundColor3 = UI_CONFIG.COLORS.VIP
    }):Play()
    
    -- Play particle effects
    self.effectsSystem:playParticles({
        position = card.AbsolutePosition + card.AbsoluteSize/2,
        color = UI_CONFIG.COLORS.VIP,
        lifetime = NumberRange.new(0.5, 1),
        rate = 20
    })
    
    -- Return to original state
    wait(UI_CONFIG.ANIMATIONS.POPUP.TIME)
    TweenService:Create(card, TweenInfo.new(0.2), {
        Size = originalSize,
        BackgroundColor3 = UI_CONFIG.COLORS.CARD_BG
    }):Play()
end

function DailyRewardUI:updateStreakDisplay()
    local streak = self.dailyRewardSystem.streakData.currentStreak
    
    -- Update streak text
    self.streakText.Text = "Current Streak: " .. streak .. " days"
    
    -- Animate streak bar
    local progress = math.min(streak / 7, 1)
    TweenService:Create(self.streakBar, TweenInfo.new(0.5), {
        Size = UDim2.new(progress, 0, 1, 0)
    }):Play()
end

function DailyRewardUI:showError(message)
    -- Create error message
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Name = "ErrorMessage"
    errorLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
    errorLabel.Position = UDim2.new(0.1, 0, 0.45, 0)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = message
    errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    errorLabel.TextScaled = true
    errorLabel.Font = Enum.Font.GothamBold
    errorLabel.Parent = self.window
    
    -- Fade out after 2 seconds
    wait(2)
    TweenService:Create(errorLabel, TweenInfo.new(0.5), {
        TextTransparency = 1
    }):Play()
    wait(0.5)
    errorLabel:Destroy()
end

function DailyRewardUI:show()
    -- Reset window properties
    self.window.Size = UDim2.new(0, 0, 0, 0)
    self.window.Visible = true
    
    -- Animate window opening
    TweenService:Create(self.window, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.POPUP.TIME,
        UI_CONFIG.ANIMATIONS.POPUP.EASING,
        UI_CONFIG.ANIMATIONS.POPUP.DIRECTION
    ), {
        Size = UI_CONFIG.WINDOW_SIZE
    }):Play()
    
    -- Update streak display
    self:updateStreakDisplay()
end

function DailyRewardUI:hide()
    -- Animate window closing
    local closeTween = TweenService:Create(self.window, TweenInfo.new(
        UI_CONFIG.ANIMATIONS.POPUP.TIME,
        UI_CONFIG.ANIMATIONS.POPUP.EASING,
        UI_CONFIG.ANIMATIONS.POPUP.DIRECTION
    ), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    
    closeTween:Play()
    closeTween.Completed:Connect(function()
        self.window.Visible = false
    end)
end

function DailyRewardUI:destroy()
    self.window:Destroy()
    self.effectsSystem:destroy()
end

return DailyRewardUI 