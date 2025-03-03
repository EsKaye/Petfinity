--[[
    UISystem.lua
    Core module for managing game UI and animations
    
    Author: Cursor AI
    Created: 2024-03-03
    Version: 0.1.0
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UISystem = {}
UISystem.__index = UISystem

-- UI States
local UI_STATES = {
    MAIN_MENU = "MAIN_MENU",
    GACHA = "GACHA",
    INVENTORY = "INVENTORY",
    PET_CARE = "PET_CARE",
    SHOP = "SHOP"
}

-- Animation presets
local ANIMATIONS = {
    FADE_IN = {
        TIME = 0.3,
        EASING = Enum.EasingStyle.Quad,
        DIRECTION = Enum.EasingDirection.Out
    },
    FADE_OUT = {
        TIME = 0.2,
        EASING = Enum.EasingStyle.Quad,
        DIRECTION = Enum.EasingDirection.In
    },
    SLIDE_IN = {
        TIME = 0.4,
        EASING = Enum.EasingStyle.Back,
        DIRECTION = Enum.EasingDirection.Out
    }
}

function UISystem.new()
    local self = setmetatable({}, UISystem)
    
    -- Initialize UI state
    self.currentState = UI_STATES.MAIN_MENU
    self.screens = {}
    self.activeScreen = nil
    
    -- Create main UI container
    self.container = Instance.new("ScreenGui")
    self.container.Name = "GameUI"
    self.container.ResetOnSpawn = false
    
    return self
end

-- Register a new UI screen
function UISystem:registerScreen(screenName, screenInstance)
    self.screens[screenName] = screenInstance
    screenInstance.Visible = false
    screenInstance.Parent = self.container
end

-- Switch to a different UI screen with animation
function UISystem:switchScreen(newState)
    if self.currentState == newState then return end
    
    local oldScreen = self.screens[self.currentState]
    local newScreen = self.screens[newState]
    
    if not newScreen then
        warn("Screen not found:", newState)
        return
    end
    
    -- Fade out current screen
    if oldScreen then
        local fadeOut = TweenService:Create(
            oldScreen,
            TweenInfo.new(
                ANIMATIONS.FADE_OUT.TIME,
                ANIMATIONS.FADE_OUT.EASING,
                ANIMATIONS.FADE_OUT.DIRECTION
            ),
            {Transparency = 1}
        )
        
        fadeOut:Play()
        fadeOut.Completed:Wait()
        oldScreen.Visible = false
    end
    
    -- Show and fade in new screen
    newScreen.Transparency = 1
    newScreen.Visible = true
    
    local fadeIn = TweenService:Create(
        newScreen,
        TweenInfo.new(
            ANIMATIONS.FADE_IN.TIME,
            ANIMATIONS.FADE_IN.EASING,
            ANIMATIONS.FADE_IN.DIRECTION
        ),
        {Transparency = 0}
    )
    
    fadeIn:Play()
    self.currentState = newState
    self.activeScreen = newScreen
end

-- Create a smooth sliding animation for UI elements
function UISystem:createSlideAnimation(guiObject, properties)
    return TweenService:Create(
        guiObject,
        TweenInfo.new(
            ANIMATIONS.SLIDE_IN.TIME,
            ANIMATIONS.SLIDE_IN.EASING,
            ANIMATIONS.SLIDE_IN.DIRECTION
        ),
        properties
    )
end

-- Clean up UI system
function UISystem:destroy()
    self.container:Destroy()
    self.screens = {}
    self.activeScreen = nil
end

return UISystem 