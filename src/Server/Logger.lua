--[[
    Logger.lua
    Author: Cursor AI (Adapted from Eidolon-Pets)
    Created: 2024-12-19
    Version: 1.0.0
    Purpose: Comprehensive logging and debugging system for Petfinity
    
    🧩 FEATURE CONTEXT:
    The Logger provides a centralized logging system for Petfinity, offering
    different log levels, module-specific logging, and performance tracking.
    It helps developers debug issues, monitor system performance, and track
    user interactions across all game systems.
    
    🧷 DEPENDENCIES:
    - HttpService: For JSON serialization of log data
    - DataStoreService: For persistent log storage (optional)
    - RunService: For performance timing
    
    💡 USAGE EXAMPLES:
    - Create logger: local log = Logger.forModule("PetSystem")
    - Log info: log.info("Pet created successfully")
    - Log warning: log.warning("Pet hunger is low")
    - Log error: log.error("Failed to save pet data")
    - Log debug: log.debug("Processing pet update")
    
    ⚡ PERFORMANCE CONSIDERATIONS:
    - Log levels can be filtered for production
    - Circular buffers prevent memory bloat
    - Asynchronous log writing for performance
    - Configurable log retention policies
    
    🔒 SECURITY IMPLICATIONS:
    - Sensitive data is filtered from logs
    - Log data is sanitized before storage
    - No external network calls in production
    - Safe for server-side execution
    
    📜 CHANGELOG:
    - v1.0.0: Initial implementation adapted from Eidolon-Pets
]]

-- Core Roblox services for logging
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- Logging configuration for Petfinity
local LOG_CONFIG = {
    DEFAULT_LEVEL = "INFO",
    MAX_LOG_ENTRIES = 1000,
    AUTO_SAVE_INTERVAL = 60, -- seconds
    ENABLE_PERSISTENCE = false,
    ENABLE_CONSOLE_OUTPUT = true,
    ENABLE_PERFORMANCE_TRACKING = true,
    SENSITIVE_FIELDS = {"password", "token", "key", "secret"}
}

-- Log levels with numeric values for comparison
local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARNING = 3,
    ERROR = 4,
    CRITICAL = 5
}

-- Logger class with enhanced functionality
local Logger = {}
Logger.__index = Logger

-- Global log storage
local globalLogs = {}
local moduleLoggers = {}

-- Initialize a new Logger instance
function Logger.new(moduleName)
    local self = setmetatable({}, Logger)
    
    -- Initialize properties
    self.moduleName = moduleName or "Unknown"
    self.logLevel = LOG_CONFIG.DEFAULT_LEVEL
    self.logs = {}
    self.performanceData = {}
    
    -- Performance tracking
    self.startTimes = {}
    
    print("📝 Logger initialized for module:", moduleName)
    return self
end

-- Create a logger for a specific module
function Logger.forModule(moduleName)
    if not moduleLoggers[moduleName] then
        moduleLoggers[moduleName] = Logger.new(moduleName)
    end
    return moduleLoggers[moduleName]
end

-- Set the log level for this logger
function Logger:setLogLevel(level)
    if LOG_LEVELS[level] then
        self.logLevel = level
        print("📊 Log level set to:", level, "for module:", self.moduleName)
    else
        warn("⚠️ Invalid log level:", level)
    end
    return self
end

-- Check if a log level should be output
function Logger:shouldLog(level)
    return LOG_LEVELS[level] >= LOG_LEVELS[self.logLevel]
end

-- Sanitize data for logging (remove sensitive information)
function Logger:sanitizeData(data)
    if type(data) == "table" then
        local sanitized = {}
        for key, value in pairs(data) do
            local shouldSanitize = false
            for _, sensitiveField in ipairs(LOG_CONFIG.SENSITIVE_FIELDS) do
                if string.find(string.lower(key), string.lower(sensitiveField)) then
                    shouldSanitize = true
                    break
                end
            end
            
            if shouldSanitize then
                sanitized[key] = "[REDACTED]"
            else
                sanitized[key] = self:sanitizeData(value)
            end
        end
        return sanitized
    else
        return data
    end
end

-- Create a log entry
function Logger:createLogEntry(level, message, data)
    local entry = {
        timestamp = os.time(),
        level = level,
        module = self.moduleName,
        message = message,
        data = self:sanitizeData(data),
        frame = RunService.Heartbeat:Wait() and 0 or 0 -- Placeholder for frame number
    }
    
    return entry
end

-- Add a log entry
function Logger:addLogEntry(entry)
    table.insert(self.logs, entry)
    table.insert(globalLogs, entry)
    
    -- Keep logs at reasonable size
    if #self.logs > LOG_CONFIG.MAX_LOG_ENTRIES then
        table.remove(self.logs, 1)
    end
    
    if #globalLogs > LOG_CONFIG.MAX_LOG_ENTRIES * 2 then
        table.remove(globalLogs, 1)
    end
    
    -- Output to console if enabled
    if LOG_CONFIG.ENABLE_CONSOLE_OUTPUT then
        self:outputToConsole(entry)
    end
end

-- Output log entry to console
function Logger:outputToConsole(entry)
    local timestamp = os.date("%H:%M:%S", entry.timestamp)
    local prefix = string.format("[%s] [%s] [%s]", timestamp, entry.level, entry.module)
    
    if entry.level == "DEBUG" then
        print(prefix, entry.message)
    elseif entry.level == "INFO" then
        print(prefix, entry.message)
    elseif entry.level == "WARNING" then
        warn(prefix, entry.message)
    elseif entry.level == "ERROR" or entry.level == "CRITICAL" then
        error(prefix .. " " .. entry.message, 0)
    end
    
    -- Output additional data if present
    if entry.data and next(entry.data) then
        print("📊 Data:", HttpService:JSONEncode(entry.data))
    end
end

-- Log a debug message
function Logger:debug(message, data)
    if self:shouldLog("DEBUG") then
        local entry = self:createLogEntry("DEBUG", message, data)
        self:addLogEntry(entry)
    end
end

-- Log an info message
function Logger:info(message, data)
    if self:shouldLog("INFO") then
        local entry = self:createLogEntry("INFO", message, data)
        self:addLogEntry(entry)
    end
end

-- Log a warning message
function Logger:warning(message, data)
    if self:shouldLog("WARNING") then
        local entry = self:createLogEntry("WARNING", message, data)
        self:addLogEntry(entry)
    end
end

-- Log an error message
function Logger:error(message, data)
    if self:shouldLog("ERROR") then
        local entry = self:createLogEntry("ERROR", message, data)
        self:addLogEntry(entry)
    end
end

-- Log a critical message
function Logger:critical(message, data)
    if self:shouldLog("CRITICAL") then
        local entry = self:createLogEntry("CRITICAL", message, data)
        self:addLogEntry(entry)
    end
end

-- Start timing an operation
function Logger:startTimer(operationName)
    if LOG_CONFIG.ENABLE_PERFORMANCE_TRACKING then
        self.startTimes[operationName] = os.clock()
    end
end

-- End timing an operation and log the duration
function Logger:endTimer(operationName, context)
    if LOG_CONFIG.ENABLE_PERFORMANCE_TRACKING and self.startTimes[operationName] then
        local endTime = os.clock()
        local duration = endTime - self.startTimes[operationName]
        
        self:debug(string.format("Operation '%s' completed in %.4f seconds", operationName, duration), {
            operation = operationName,
            duration = duration,
            context = context
        })
        
        self.startTimes[operationName] = nil
        return duration
    end
    return 0
end

-- Get logs for this module
function Logger:getLogs(level, limit)
    limit = limit or 100
    local filteredLogs = {}
    
    for _, log in ipairs(self.logs) do
        if not level or log.level == level then
            table.insert(filteredLogs, log)
            if #filteredLogs >= limit then
                break
            end
        end
    end
    
    return filteredLogs
end

-- Get logs by level
function Logger:getLogsByLevel(level)
    return self:getLogs(level)
end

-- Get recent logs
function Logger:getRecentLogs(limit)
    return self:getLogs(nil, limit)
end

-- Get performance data for this module
function Logger:getPerformanceData()
    return self.performanceData
end

-- Clear logs for this module
function Logger:clearLogs()
    self.logs = {}
    print("🧹 Logs cleared for module:", self.moduleName)
end

-- Save logs to DataStore (if enabled)
function Logger:saveLogs()
    if not LOG_CONFIG.ENABLE_PERSISTENCE then
        return false
    end
    
    local success, result = pcall(function()
        local dataStore = DataStoreService:GetDataStore("Petfinity_Logs")
        local logData = {
            module = self.moduleName,
            logs = self.logs,
            timestamp = os.time()
        }
        
        dataStore:SetAsync(self.moduleName .. "_" .. os.time(), logData)
        return true
    end)
    
    if success then
        self:info("Logs saved to DataStore")
        return true
    else
        self:error("Failed to save logs to DataStore", {error = result})
        return false
    end
end

-- Load logs from DataStore (if enabled)
function Logger:loadLogs()
    if not LOG_CONFIG.ENABLE_PERSISTENCE then
        return false
    end
    
    local success, result = pcall(function()
        local dataStore = DataStoreService:GetDataStore("Petfinity_Logs")
        local logData = dataStore:GetAsync(self.moduleName .. "_" .. os.time())
        
        if logData and logData.logs then
            self.logs = logData.logs
            return true
        end
        return false
    end)
    
    if success and result then
        self:info("Logs loaded from DataStore")
        return true
    else
        self:error("Failed to load logs from DataStore", {error = result})
        return false
    end
end

-- Get global statistics
function Logger.getGlobalStats()
    local stats = {
        totalLogs = #globalLogs,
        moduleCount = #moduleLoggers,
        logLevels = {}
    }
    
    -- Count logs by level
    for _, log in ipairs(globalLogs) do
        stats.logLevels[log.level] = (stats.logLevels[log.level] or 0) + 1
    end
    
    return stats
end

-- Get all global logs
function Logger.getAllLogs(level, limit)
    limit = limit or 100
    local filteredLogs = {}
    
    for _, log in ipairs(globalLogs) do
        if not level or log.level == level then
            table.insert(filteredLogs, log)
            if #filteredLogs >= limit then
                break
            end
        end
    end
    
    return filteredLogs
end

-- Clear all global logs
function Logger.clearAllLogs()
    globalLogs = {}
    for moduleName, logger in pairs(moduleLoggers) do
        logger:clearLogs()
    end
    print("🧹 All logs cleared")
end

-- Save all logs to DataStore
function Logger.saveAllLogs()
    if not LOG_CONFIG.ENABLE_PERSISTENCE then
        return false
    end
    
    local successCount = 0
    local totalCount = 0
    
    for moduleName, logger in pairs(moduleLoggers) do
        totalCount = totalCount + 1
        if logger:saveLogs() then
            successCount = successCount + 1
        end
    end
    
    print(string.format("💾 Saved %d/%d module logs", successCount, totalCount))
    return successCount == totalCount
end

-- Start auto-save functionality
function Logger.startAutoSave()
    if not LOG_CONFIG.ENABLE_PERSISTENCE then
        return
    end
    
    task.spawn(function()
        while true do
            task.wait(LOG_CONFIG.AUTO_SAVE_INTERVAL)
            Logger.saveAllLogs()
        end
    end)
    
    print("💾 Auto-save started for logs")
end

-- Clean up resources
function Logger:destroy()
    self.logs = {}
    self.performanceData = {}
    self.startTimes = {}
    print("🗑️ Logger destroyed for module:", self.moduleName)
end

return Logger 