--[[
    PerfMonitor.lua
    Author: Cursor AI (Adapted from Eidolon-Pets)
    Created: 2024-12-19
    Version: 1.0.0
    Purpose: Centralized performance monitoring and benchmarking for Petfinity
    
    🧩 FEATURE CONTEXT:
    The PerfMonitor provides comprehensive performance tracking and benchmarking
    for Petfinity's systems, ensuring optimal performance across all game
    features. It monitors frame times, memory usage, and operation durations
    to identify performance bottlenecks and optimize system efficiency.
    
    🧷 DEPENDENCIES:
    - RunService: For frame time tracking
    - Logger: For performance logging and debugging
    - Garbage collection: For memory usage monitoring
    
    💡 USAGE EXAMPLES:
    - Initialize: PerfMonitor:init()
    - Track operation: PerfMonitor:startOperation("petUpdate")
    - End operation: PerfMonitor:endOperation("petUpdate")
    - Benchmark: PerfMonitor:benchmark("worldGeneration", generateWorld)
    - Get stats: PerfMonitor:getStats()
    
    ⚡ PERFORMANCE CONSIDERATIONS:
    - Minimal overhead for performance tracking
    - Circular buffers prevent memory bloat
    - Asynchronous memory monitoring
    - Efficient data structures for metrics
    
    🔒 SECURITY IMPLICATIONS:
    - No external dependencies or network calls
    - Performance data is stored locally
    - Safe for server-side execution
    
    📜 CHANGELOG:
    - v1.0.0: Initial implementation adapted from Eidolon-Pets
]]

-- Core Roblox services for performance monitoring
local RunService = game:GetService("RunService")

-- Performance monitoring configuration for Petfinity
local PERF_CONFIG = {
    BENCHMARK_ITERATIONS = 5,
    MAX_HISTORY_ENTRIES = 100,
    MEMORY_CHECK_INTERVAL = 5, -- seconds
    FRAME_TIME_WARNING_THRESHOLD = 0.016, -- 60 FPS threshold
    MEMORY_WARNING_THRESHOLD = 500 * 1024 * 1024, -- 500MB
    AUTO_ALERTS = true
}

-- PerfMonitor class with enhanced functionality
local PerfMonitor = {}
PerfMonitor.__index = PerfMonitor

-- Initialize a new PerfMonitor instance
function PerfMonitor.new()
    local self = setmetatable({}, PerfMonitor)
    
    -- Initialize properties
    self.modules = {}
    self.benchmarks = {}
    self.moduleHistory = {}
    self.isRunning = false
    self.currentFrame = 0
    self.totalPausedTime = 0
    self.lastPauseTime = 0
    self.memoryBaseline = 0
    
    -- Performance metrics
    self.metrics = {
        frameTimeHistory = {},
        memoryHistory = {},
        benchmarkResults = {},
        startTimeByOperation = {},
        alerts = {}
    }
    
    -- Performance tracking connections
    self.connections = {}
    
    print("📊 PerfMonitor initialized")
    return self
end

-- Initialize performance monitoring
function PerfMonitor:init()
    if self.isRunning then
        return self
    end
    
    print("🚀 Initializing performance monitoring system...")
    
    -- Get baseline memory usage
    self.memoryBaseline = gcinfo()
    
    -- Reset metrics
    self.metrics = {
        frameTimeHistory = {},
        memoryHistory = {},
        benchmarkResults = {},
        startTimeByOperation = {},
        alerts = {}
    }
    
    -- Start frame time tracking
    self:startFrameTracking()
    
    -- Start memory monitoring
    self:startMemoryMonitoring()
    
    -- Start performance alerts
    if PERF_CONFIG.AUTO_ALERTS then
        self:startPerformanceAlerts()
    end
    
    self.isRunning = true
    print("✅ Performance monitoring system initialized")
    return self
end

-- Start frame time tracking
function PerfMonitor:startFrameTracking()
    local connection = RunService.Heartbeat:Connect(function(deltaTime)
        if self.isRunning then
            self:trackFrame(deltaTime)
        end
    end)
    
    table.insert(self.connections, connection)
    print("🔄 Frame time tracking started")
end

-- Start memory monitoring
function PerfMonitor:startMemoryMonitoring()
    task.spawn(function()
        while true do
            if self.isRunning then
                self:trackMemory()
            end
            task.wait(PERF_CONFIG.MEMORY_CHECK_INTERVAL)
        end
    end)
    
    print("💾 Memory monitoring started")
end

-- Start performance alerts
function PerfMonitor:startPerformanceAlerts()
    task.spawn(function()
        while true do
            if self.isRunning then
                self:checkPerformanceAlerts()
            end
            task.wait(10) -- Check every 10 seconds
        end
    end)
    
    print("🚨 Performance alerts started")
end

-- Register a module for performance tracking
function PerfMonitor:registerModule(moduleName, moduleInstance)
    if not self.modules[moduleName] then
        print("📦 Registering module for performance tracking:", moduleName)
        self.modules[moduleName] = moduleInstance
        self.moduleHistory[moduleName] = {}
    end
    return self
end

-- Track frame time
function PerfMonitor:trackFrame(deltaTime)
    self.currentFrame = self.currentFrame + 1
    
    -- Store frame time in circular buffer
    table.insert(self.metrics.frameTimeHistory, deltaTime)
    if #self.metrics.frameTimeHistory > PERF_CONFIG.MAX_HISTORY_ENTRIES then
        table.remove(self.metrics.frameTimeHistory, 1)
    end
    
    -- Check for performance issues
    if deltaTime > PERF_CONFIG.FRAME_TIME_WARNING_THRESHOLD then
        self:addAlert("FRAME_TIME", "Frame time exceeded threshold: " .. deltaTime)
    end
end

-- Track memory usage
function PerfMonitor:trackMemory()
    local memoryUsage = gcinfo() - self.memoryBaseline
    
    -- Store memory usage in circular buffer
    table.insert(self.metrics.memoryHistory, {
        time = os.time(),
        usage = memoryUsage
    })
    
    if #self.metrics.memoryHistory > PERF_CONFIG.MAX_HISTORY_ENTRIES then
        table.remove(self.metrics.memoryHistory, 1)
    end
    
    -- Check for memory issues
    if memoryUsage > PERF_CONFIG.MEMORY_WARNING_THRESHOLD then
        self:addAlert("MEMORY", "Memory usage exceeded threshold: " .. memoryUsage)
    end
end

-- Start timing an operation
function PerfMonitor:startOperation(operationName, context)
    if not self.isRunning then
        return self
    end
    
    context = context or "default"
    local key = operationName .. ":" .. context
    self.metrics.startTimeByOperation[key] = os.clock()
    
    return self
end

-- End timing an operation and record result
function PerfMonitor:endOperation(operationName, context, metadata)
    if not self.isRunning then
        return 0
    end
    
    context = context or "default"
    local key = operationName .. ":" .. context
    local startTime = self.metrics.startTimeByOperation[key]
    
    if not startTime then
        warn("⚠️ Attempted to end operation that wasn't started:", key)
        return 0
    end
    
    local endTime = os.clock()
    local duration = endTime - startTime
    
    -- Record completion
    local result = {
        operation = operationName,
        context = context,
        duration = duration,
        timestamp = os.time(),
        frame = self.currentFrame,
        metadata = metadata or {}
    }
    
    -- Store in module-specific history if applicable
    if context and self.moduleHistory[context] then
        table.insert(self.moduleHistory[context], result)
        
        -- Keep history at reasonable size
        if #self.moduleHistory[context] > PERF_CONFIG.MAX_HISTORY_ENTRIES then
            table.remove(self.moduleHistory[context], 1)
        end
    end
    
    -- Clean up
    self.metrics.startTimeByOperation[key] = nil
    
    return duration
end

-- Run a benchmark of a specific function
function PerfMonitor:benchmark(name, func, params, iterations)
    if not self.isRunning then
        warn("⚠️ Performance monitoring is paused; benchmark skipped")
        return nil
    end
    
    print("🏃 Running benchmark:", name)
    iterations = iterations or PERF_CONFIG.BENCHMARK_ITERATIONS
    
    -- Prepare benchmark
    local results = {
        name = name,
        iterations = iterations,
        durations = {},
        totalDuration = 0,
        averageDuration = 0,
        minDuration = math.huge,
        maxDuration = 0,
        startMemory = gcinfo(),
        endMemory = 0,
        timestamp = os.time()
    }
    
    -- Run warmup iteration (not counted)
    if func then
        func(table.unpack(params or {}))
    end
    
    -- Run benchmark iterations
    for i = 1, iterations do
        local startTime = os.clock()
        
        -- Execute function
        if func then
            func(table.unpack(params or {}))
        end
        
        local endTime = os.clock()
        local duration = endTime - startTime
        
        -- Record results
        table.insert(results.durations, duration)
        results.totalDuration = results.totalDuration + duration
        results.minDuration = math.min(results.minDuration, duration)
        results.maxDuration = math.max(results.maxDuration, duration)
    end
    
    -- Calculate statistics
    results.averageDuration = results.totalDuration / iterations
    results.endMemory = gcinfo()
    results.memoryDelta = results.endMemory - results.startMemory
    
    -- Store benchmark results
    self.metrics.benchmarkResults[name] = results
    
    print(string.format("✅ Benchmark complete: %s (avg: %.4fs, min: %.4fs, max: %.4fs)", 
        name, results.averageDuration, results.minDuration, results.maxDuration))
    
    return results
end

-- Add a performance alert
function PerfMonitor:addAlert(type, message)
    local alert = {
        type = type,
        message = message,
        timestamp = os.time(),
        frame = self.currentFrame
    }
    
    table.insert(self.metrics.alerts, alert)
    
    -- Keep alerts at reasonable size
    if #self.metrics.alerts > PERF_CONFIG.MAX_HISTORY_ENTRIES then
        table.remove(self.metrics.alerts, 1)
    end
    
    -- Log alert
    warn("🚨 Performance Alert [" .. type .. "]:", message)
end

-- Check for performance alerts
function PerfMonitor:checkPerformanceAlerts()
    -- Check frame time
    if #self.metrics.frameTimeHistory > 0 then
        local recentFrames = {}
        for i = math.max(1, #self.metrics.frameTimeHistory - 10), #self.metrics.frameTimeHistory do
            table.insert(recentFrames, self.metrics.frameTimeHistory[i])
        end
        
        local avgFrameTime = 0
        for _, frameTime in ipairs(recentFrames) do
            avgFrameTime = avgFrameTime + frameTime
        end
        avgFrameTime = avgFrameTime / #recentFrames
        
        if avgFrameTime > PERF_CONFIG.FRAME_TIME_WARNING_THRESHOLD then
            self:addAlert("FRAME_TIME_AVG", "Average frame time is high: " .. avgFrameTime)
        end
    end
    
    -- Check memory usage
    if #self.metrics.memoryHistory > 0 then
        local recentMemory = self.metrics.memoryHistory[#self.metrics.memoryHistory]
        if recentMemory.usage > PERF_CONFIG.MEMORY_WARNING_THRESHOLD then
            self:addAlert("MEMORY_HIGH", "Memory usage is high: " .. recentMemory.usage)
        end
    end
end

-- Get current performance statistics
function PerfMonitor:getStats()
    local stats = {
        isRunning = self.isRunning,
        currentFrame = self.currentFrame,
        totalPausedTime = self.totalPausedTime,
        memoryBaseline = self.memoryBaseline,
        currentMemory = gcinfo(),
        registeredModules = #self.modules,
        activeOperations = #self.metrics.startTimeByOperation,
        recentAlerts = #self.metrics.alerts
    }
    
    -- Calculate frame time statistics
    if #self.metrics.frameTimeHistory > 0 then
        local totalFrameTime = 0
        local minFrameTime = math.huge
        local maxFrameTime = 0
        
        for _, frameTime in ipairs(self.metrics.frameTimeHistory) do
            totalFrameTime = totalFrameTime + frameTime
            minFrameTime = math.min(minFrameTime, frameTime)
            maxFrameTime = math.max(maxFrameTime, frameTime)
        end
        
        stats.frameTime = {
            average = totalFrameTime / #self.metrics.frameTimeHistory,
            min = minFrameTime,
            max = maxFrameTime,
            count = #self.metrics.frameTimeHistory
        }
    end
    
    -- Calculate memory statistics
    if #self.metrics.memoryHistory > 0 then
        local recentMemory = self.metrics.memoryHistory[#self.metrics.memoryHistory]
        stats.currentMemoryUsage = recentMemory.usage
    end
    
    return stats
end

-- Get module-specific performance data
function PerfMonitor:getModuleStats(moduleName)
    if not self.moduleHistory[moduleName] then
        return nil
    end
    
    local history = self.moduleHistory[moduleName]
    local stats = {
        moduleName = moduleName,
        operationCount = #history,
        totalDuration = 0,
        averageDuration = 0,
        minDuration = math.huge,
        maxDuration = 0
    }
    
    for _, operation in ipairs(history) do
        stats.totalDuration = stats.totalDuration + operation.duration
        stats.minDuration = math.min(stats.minDuration, operation.duration)
        stats.maxDuration = math.max(stats.maxDuration, operation.duration)
    end
    
    if stats.operationCount > 0 then
        stats.averageDuration = stats.totalDuration / stats.operationCount
    end
    
    return stats
end

-- Get recent alerts
function PerfMonitor:getAlerts(limit)
    limit = limit or 10
    local alerts = {}
    
    for i = math.max(1, #self.metrics.alerts - limit + 1), #self.metrics.alerts do
        table.insert(alerts, self.metrics.alerts[i])
    end
    
    return alerts
end

-- Pause performance monitoring
function PerfMonitor:pause()
    if not self.isRunning then
        return self
    end
    
    self.isRunning = false
    self.lastPauseTime = os.time()
    print("⏸️ Performance monitoring paused")
    return self
end

-- Resume performance monitoring
function PerfMonitor:resume()
    if self.isRunning then
        return self
    end
    
    self.isRunning = true
    if self.lastPauseTime > 0 then
        self.totalPausedTime = self.totalPausedTime + (os.time() - self.lastPauseTime)
    end
    print("▶️ Performance monitoring resumed")
    return self
end

-- Clear all performance data
function PerfMonitor:clearData()
    self.metrics = {
        frameTimeHistory = {},
        memoryHistory = {},
        benchmarkResults = {},
        startTimeByOperation = {},
        alerts = {}
    }
    
    for moduleName, _ in pairs(self.moduleHistory) do
        self.moduleHistory[moduleName] = {}
    end
    
    print("🧹 Performance data cleared")
    return self
end

-- Clean up resources
function PerfMonitor:destroy()
    -- Disconnect all connections
    for _, connection in ipairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    self.connections = {}
    self.isRunning = false
    
    print("🗑️ PerfMonitor destroyed")
end

return PerfMonitor 