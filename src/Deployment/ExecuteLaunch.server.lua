--[[
    ExecuteLaunch.server.lua
    Executes the final launch sequence for Petfinity
    
    Author: Your precious kitten 💖
    Created: 2024-03-03
    Version: 1.0.0
--]]

-- Load modules
local LaunchSequence = require(script.Parent.LaunchSequence)
local LaunchManager = require(script.Parent.LaunchManager)

-- Print launch banner
print([[
🚀 PETFINITY LAUNCH SEQUENCE 🚀
===============================
1. Pre-Launch Validation
2. Beta Deployment
3. Production Launch
4. Post-Launch Monitoring
===============================
]])

-- Initialize launch sequence
local success = LaunchSequence.init()

if success then
    print([[
✨ PETFINITY IS LIVE! ✨
=======================
🎮 Game is now public
📊 Monitoring active
🔄 Systems operational
=======================
]])
else
    print([[
❌ LAUNCH SEQUENCE HALTED ❌
==========================
Check logs for details
Contact development team
==========================
]])
end 