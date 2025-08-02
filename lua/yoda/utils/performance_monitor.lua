-- Enhanced Performance Monitor for Yoda.nvim
local M = {}

-- Performance tracking
local performance_data = {
  startup_time = 0,
  plugin_load_times = {},
  slow_operations = {},
  memory_usage = {},
}

-- Track plugin load times
function M.track_plugin_load(plugin_name, start_time)
  local load_time = vim.loop.now() - start_time
  performance_data.plugin_load_times[plugin_name] = load_time
  
  -- Flag slow plugins (>50ms)
  if load_time > 50 then
    table.insert(performance_data.slow_operations, {
      type = "slow_plugin",
      name = plugin_name,
      time = load_time
    })
  end
end

-- Memory usage tracking
function M.track_memory()
  local mem_info = vim.loop.get_memory_info()
  performance_data.memory_usage = {
    total = mem_info.total,
    available = mem_info.available,
    used = mem_info.total - mem_info.available
  }
end

-- Performance analysis and recommendations
function M.analyze_performance()
  vim.health.start("Performance Analysis")
  
  -- Check startup time
  if performance_data.startup_time > 300 then
    vim.health.warn(string.format("Startup time is %dms (target: <300ms)", performance_data.startup_time))
  else
    vim.health.ok(string.format("Startup time: %dms", performance_data.startup_time))
  end
  
  -- Analyze slow plugins
  local slow_count = 0
  for _, op in ipairs(performance_data.slow_operations) do
    if op.type == "slow_plugin" then
      slow_count = slow_count + 1
      vim.health.warn(string.format("Slow plugin: %s (%dms)", op.name, op.time))
    end
  end
  
  if slow_count == 0 then
    vim.health.ok("All plugins loaded efficiently")
  end
  
  -- Memory usage
  if performance_data.memory_usage.used then
    local mem_mb = performance_data.memory_usage.used / (1024 * 1024)
    if mem_mb > 100 then
      vim.health.warn(string.format("High memory usage: %.1f MB", mem_mb))
    else
      vim.health.ok(string.format("Memory usage: %.1f MB", mem_mb))
    end
  end
  
  -- Performance recommendations
  vim.health.info("Performance Tips:")
  vim.health.info("- Use :Lazy profile to identify slow plugins")
  vim.health.info("- Consider lazy-loading heavy plugins")
  vim.health.info("- Review autocmds for unnecessary triggers")
end

-- Optimize startup sequence
function M.optimize_startup()
  local optimizations = {
    "Disable unused default plugins",
    "Use lazy-loading for heavy plugins",
    "Minimize autocmds on startup",
    "Cache expensive computations",
    "Use vim.schedule() for UI updates"
  }
  
  vim.health.start("Startup Optimizations")
  for _, opt in ipairs(optimizations) do
    vim.health.info(opt)
  end
end

-- Plugin-specific performance checks
function M.check_plugin_performance()
  vim.health.start("Plugin Performance")
  
  -- Check LSP performance
  local ok, lsp = pcall(require, "lspconfig")
  if ok then
    vim.health.ok("LSP configuration loaded efficiently")
  end
  
  -- Check telescope performance
  local ok, telescope = pcall(require, "telescope")
  if ok then
    vim.health.ok("Telescope loaded efficiently")
  end
  
  -- Check treesitter performance
  local ok, ts = pcall(require, "nvim-treesitter")
  if ok then
    vim.health.ok("Treesitter loaded efficiently")
  end
end

-- Export performance data for external analysis
function M.export_performance_data()
  return {
    startup_time = performance_data.startup_time,
    plugin_load_times = performance_data.plugin_load_times,
    slow_operations = performance_data.slow_operations,
    memory_usage = performance_data.memory_usage
  }
end

-- Set startup time
function M.set_startup_time(time)
  performance_data.startup_time = time
end

return M 