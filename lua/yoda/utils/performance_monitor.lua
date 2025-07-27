-- lua/yoda/utils/performance_monitor.lua
-- Performance monitoring and optimization utilities

local M = {}

-- Performance tracking data
local performance_data = {
  startup_time = 0,
  plugin_load_times = {},
  memory_usage = {},
  slow_plugins = {}
}

-- Track startup time
local startup_time = vim.loop.hrtime()

-- Monitor plugin loading performance
function M.monitor_plugin_loading()
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then
    return
  end

  -- Check if lazy.get_plugins is available
  if not lazy.get_plugins then
    return
  end

  local plugins_ok, plugins = pcall(lazy.get_plugins)
  if not plugins_ok or not plugins then
    return
  end

  for _, plugin in ipairs(plugins) do
    if plugin._.loaded then
      local load_time = plugin._.load_time or 0
      if load_time > 100 then -- 100ms threshold
        table.insert(performance_data.slow_plugins, {
          name = plugin.name,
          load_time = load_time
        })
      end
      performance_data.plugin_load_times[plugin.name] = load_time
    end
  end
end

-- Get performance report
function M.get_performance_report()
  local end_time = vim.loop.hrtime()
  performance_data.startup_time = (end_time - startup_time) / 1000000 -- Convert to milliseconds

  local report = {
    startup_time = performance_data.startup_time,
    slow_plugins = performance_data.slow_plugins,
    total_plugins = #vim.tbl_keys(performance_data.plugin_load_times)
  }

  return report
end

-- Print performance report
function M.print_performance_report()
  local report = M.get_performance_report()
  
  print("=== Yoda.nvim Performance Report ===")
  print(string.format("Startup Time: %.2f ms", report.startup_time))
  print(string.format("Total Plugins: %d", report.total_plugins))
  
  if #report.slow_plugins > 0 then
    print("\nSlow Plugins (>100ms):")
    for _, plugin in ipairs(report.slow_plugins) do
      print(string.format("  %s: %.2f ms", plugin.name, plugin.load_time))
    end
  end
  
  print("===================================")
end

-- Register performance monitoring commands
vim.api.nvim_create_user_command("YodaPerformance", function()
  M.print_performance_report()
end, { desc = "Show Yoda.nvim performance report" })

-- Auto-monitor on startup with proper timing
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      -- Wait a bit longer to ensure Lazy.nvim is fully initialized
      vim.defer_fn(function()
        M.monitor_plugin_loading()
      end, 2000) -- 2 second delay to ensure plugins are loaded
    end, 1000) -- 1 second initial delay
  end,
  once = true
})

return M 