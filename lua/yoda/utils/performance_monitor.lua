-- lua/yoda/utils/performance_monitor.lua
-- Performance monitoring utilities for Yoda.nvim

local M = {}

-- Performance metrics storage
local metrics = {
  startup_time = 0,
  plugin_load_times = {},
  memory_usage = {},
  slow_plugins = {},
}

-- Start time tracking
local start_time = vim.loop.hrtime()

-- Helper function to get current time in milliseconds
local function get_time_ms()
  return (vim.loop.hrtime() - start_time) / 1000000
end

-- Track plugin loading time
function M.track_plugin_load(plugin_name, load_function)
  local plugin_start = vim.loop.hrtime()
  
  local ok, result = pcall(load_function)
  local plugin_end = vim.loop.hrtime()
  local load_time = (plugin_end - plugin_start) / 1000000
  
  metrics.plugin_load_times[plugin_name] = load_time
  
  -- Track slow plugins (>100ms)
  if load_time > 100 then
    table.insert(metrics.slow_plugins, {
      name = plugin_name,
      time = load_time
    })
  end
  
  return ok, result
end

-- Get memory usage statistics
function M.get_memory_usage()
  local memory = vim.loop.get_total_memory()
  local free_memory = vim.loop.get_free_memory()
  local used_memory = memory - free_memory
  
  return {
    total = memory,
    free = free_memory,
    used = used_memory,
    usage_percent = (used_memory / memory) * 100
  }
end

-- Record startup completion
function M.record_startup_completion()
  metrics.startup_time = get_time_ms()
  metrics.memory_usage.startup = M.get_memory_usage()
end

-- Get performance report
function M.get_performance_report()
  local report = {
    startup_time = metrics.startup_time,
    memory_usage = metrics.memory_usage,
    slow_plugins = metrics.slow_plugins,
    plugin_count = 0,
    total_plugin_time = 0,
  }
  
  for plugin_name, load_time in pairs(metrics.plugin_load_times) do
    report.plugin_count = report.plugin_count + 1
    report.total_plugin_time = report.total_plugin_time + load_time
  end
  
  return report
end

-- Print performance report
function M.print_performance_report()
  local report = M.get_performance_report()
  
  vim.notify("🚀 Yoda Performance Report", vim.log.levels.INFO, { title = "Performance" })
  
  -- Startup time
  vim.notify(string.format("Startup Time: %.2f ms", report.startup_time), vim.log.levels.INFO)
  
  -- Plugin statistics
  vim.notify(string.format("Plugins Loaded: %d", report.plugin_count), vim.log.levels.INFO)
  vim.notify(string.format("Total Plugin Time: %.2f ms", report.total_plugin_time), vim.log.levels.INFO)
  
  -- Memory usage
  if report.memory_usage.startup then
    local mem = report.memory_usage.startup
    vim.notify(string.format("Memory Usage: %.1f MB (%.1f%%)", 
      mem.used / 1024 / 1024, mem.usage_percent), vim.log.levels.INFO)
  end
  
  -- Slow plugins
  if #report.slow_plugins > 0 then
    vim.notify("Slow Plugins (>100ms):", vim.log.levels.WARN)
    for _, plugin in ipairs(report.slow_plugins) do
      vim.notify(string.format("  %s: %.2f ms", plugin.name, plugin.time), vim.log.levels.WARN)
    end
  end
end

-- Monitor plugin loading performance
function M.monitor_plugin_loading()
  local original_require = require
  
  require = function(module_name)
    local start_time = vim.loop.hrtime()
    local result = original_require(module_name)
    local end_time = vim.loop.hrtime()
    local load_time = (end_time - start_time) / 1000000
    
    -- Only track yoda modules
    if module_name:match("^yoda") then
      metrics.plugin_load_times[module_name] = load_time
      
      if load_time > 50 then
        vim.notify(string.format("Slow module load: %s (%.2f ms)", module_name, load_time), 
          vim.log.levels.WARN)
      end
    end
    
    return result
  end
end

-- Performance optimization suggestions
function M.get_optimization_suggestions()
  local suggestions = {}
  local report = M.get_performance_report()
  
  -- Startup time suggestions
  if report.startup_time > 1000 then
    table.insert(suggestions, "Startup time is slow (>1s). Consider lazy-loading more plugins.")
  end
  
  -- Memory usage suggestions
  if report.memory_usage.startup and report.memory_usage.startup.usage_percent > 80 then
    table.insert(suggestions, "High memory usage. Consider disabling unused plugins.")
  end
  
  -- Slow plugin suggestions
  if #report.slow_plugins > 5 then
    table.insert(suggestions, "Many slow plugins detected. Review plugin configurations.")
  end
  
  -- Plugin count suggestions
  if report.plugin_count > 50 then
    table.insert(suggestions, "Large number of plugins. Consider consolidating or removing unused ones.")
  end
  
  return suggestions
end

-- Auto-optimization based on performance metrics
function M.auto_optimize()
  local suggestions = M.get_optimization_suggestions()
  
  if #suggestions > 0 then
    vim.notify("Performance optimization suggestions:", vim.log.levels.INFO)
    for _, suggestion in ipairs(suggestions) do
      vim.notify("  • " .. suggestion, vim.log.levels.INFO)
    end
  else
    vim.notify("✅ Performance is optimal", vim.log.levels.INFO)
  end
end

-- Register performance monitoring commands
vim.api.nvim_create_user_command("YodaPerformanceReport", function()
  M.print_performance_report()
end, { desc = "Show Yoda performance report" })

vim.api.nvim_create_user_command("YodaPerformanceOptimize", function()
  M.auto_optimize()
end, { desc = "Get performance optimization suggestions" })

vim.api.nvim_create_user_command("YodaPerformanceMonitor", function()
  M.monitor_plugin_loading()
  vim.notify("Performance monitoring enabled", vim.log.levels.INFO)
end, { desc = "Enable performance monitoring" })

-- Record startup completion when Neovim is fully loaded
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      M.record_startup_completion()
      
      -- Show performance report if startup was slow
      if metrics.startup_time > 1000 then
        vim.notify(string.format("Slow startup detected: %.2f ms", metrics.startup_time), 
          vim.log.levels.WARN, { title = "Performance" })
      end
    end, 100)
  end,
  once = true,
})

return M 