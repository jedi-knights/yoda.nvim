-- Initialize global keymap log for tracking
_G.yoda_keymap_log = {}

-- Track startup time
local startup_time = vim.loop.now()

-- Load core settings
require("yoda.core.options")

pcall(function()
  local telescope = require("telescope")
  telescope.extensions.test_picker = telescope.extensions.test_picker or require("yoda.testpicker")
end)

require("yoda.commands").setup()
require("yoda.core.keymaps")
require("yoda.core.functions")
require("yoda.core.autocmds")

-- Load plugins
require("yoda.plugins.lazy") -- bootstrap lazy.nvim

-- Load utilities for development with enhanced error handling
local utils_to_load = {
  "yoda.utils.plugin_validator",
  "yoda.utils.plugin_loader", 
  "yoda.utils.config_validator",
  "yoda.utils.performance_monitor",
  "yoda.utils.startup_profiler",
  "yoda.utils.optimization_helper",
  "yoda.utils.error_recovery",
  "yoda.utils.enhanced_plugin_loader",
  "yoda.utils.interactive_help",
  "yoda.utils.feature_discovery",
  "yoda.utils.distribution_testing",
  "yoda.utils.automated_testing",
  "yoda.utils.interactive_docs",
  "yoda.utils.ai_development",
  "yoda.utils.ai_code_analysis",
  "yoda.utils.keymap_utils",
  "yoda.utils.tool_indicators",
  "yoda.utils.health_checker"
}

for _, util in ipairs(utils_to_load) do
  local ok, module = pcall(require, util)
  if not ok then
    -- Log the error but don't fail startup
    vim.notify(string.format("Failed to load utility: %s", util), vim.log.levels.WARN)
  end
end

-- Load colorscheme
require("yoda.core.colorscheme")

-- Load Plenary test keymaps
require("yoda.core.plenary")

-- Set startup time for performance monitoring
local perf_ok, perf = pcall(require, "yoda.utils.performance_monitor")
if perf_ok then
  local total_time = vim.loop.now() - startup_time
  perf.set_startup_time(total_time)
end

-- Show YODA_ENV mode notification on startup (only if enabled)
if vim.g.yoda_config and vim.g.yoda_config.show_environment_notification then
  vim.schedule(function()
    local env = vim.env.YODA_ENV or ""
    local env_label = "Unknown"
    local icon = ""
    if env == "home" then
      env_label = "Home"
      icon = ""
    elseif env == "work" then
      env_label = "Work"
      icon = "󰒱"
    end
    local msg = string.format("%s  Yoda is in %s mode", icon, env_label)
    local ok, noice = pcall(require, "noice")
    if ok and noice and noice.notify then
      noice.notify(msg, "info", { title = "Yoda Environment", timeout = 2000 })
    else
      vim.notify(msg, vim.log.levels.INFO, { title = "Yoda Environment" })
    end
    
    -- Show development tool indicators after environment notification
    vim.defer_fn(function()
      local tool_indicators = require("yoda.utils.tool_indicators")
      tool_indicators.show_startup_indicators()
      tool_indicators.update_statusline()
    end, 500) -- 500ms delay after environment notification
  end)
end

-- Enhanced user commands
vim.api.nvim_create_user_command("YodaKeymapDump", function()
  require("yoda.devtools.keymaps").dump_all_keymaps()
end, {})

vim.api.nvim_create_user_command("YodaKeymapConflicts", function()
  require("yoda.devtools.keymaps").find_conflicts()
end, {})

vim.api.nvim_create_user_command("YodaLoggedKeymaps", function()
  require("yoda.utils.keymap_logger").dump()
end, {})

vim.api.nvim_create_user_command("YodaKeymapStats", function()
  require("yoda.utils.keymap_utils").print_stats()
end, {})

-- Manual update commands
vim.api.nvim_create_user_command("YodaUpdate", function()
  vim.notify("Checking for plugin updates...", vim.log.levels.INFO, { title = "Yoda.nvim" })
  require("lazy").sync()
end, { desc = "Manually check and update plugins" })

vim.api.nvim_create_user_command("YodaCheckUpdates", function()
  vim.notify("Checking for available updates...", vim.log.levels.INFO, { title = "Yoda.nvim" })
  require("lazy").check()
end, { desc = "Check for available plugin updates without installing" })

-- Startup message control commands
vim.api.nvim_create_user_command("YodaVerboseOn", function()
  vim.g.yoda_config.verbose_startup = true
  vim.g.yoda_config.show_loading_messages = true
  vim.notify("Verbose startup messages enabled", vim.log.levels.INFO, { title = "Yoda.nvim" })
end, { desc = "Enable verbose startup messages" })

vim.api.nvim_create_user_command("YodaVerboseOff", function()
  vim.g.yoda_config.verbose_startup = false
  vim.g.yoda_config.show_loading_messages = false
  vim.notify("Verbose startup messages disabled", vim.log.levels.INFO, { title = "Yoda.nvim" })
end, { desc = "Disable verbose startup messages" })

vim.api.nvim_create_user_command("YodaShowConfig", function()
  local config = vim.g.yoda_config or {}
  local msg = string.format([[
Yoda Configuration:
- Verbose Startup: %s
- Show Loading Messages: %s
- Show Environment Notification: %s
- Enable Startup Profiling: %s
- Show Startup Report: %s
- Profiling Verbose: %s
]], 
    tostring(config.verbose_startup or false),
    tostring(config.show_loading_messages or false),
    tostring(config.show_environment_notification or true),
    tostring(config.enable_startup_profiling or false),
    tostring(config.show_startup_report or false),
    tostring(config.profiling_verbose or false)
  )
  vim.notify(msg, vim.log.levels.INFO, { title = "Yoda.nvim Config" })
end, { desc = "Show current Yoda configuration" })

-- Startup profiling commands
vim.api.nvim_create_user_command("YodaProfilingOn", function()
  vim.g.yoda_config.enable_startup_profiling = true
  vim.g.yoda_config.show_startup_report = true
  vim.notify("Startup profiling enabled", vim.log.levels.INFO, { title = "Yoda.nvim" })
end, { desc = "Enable startup profiling" })

vim.api.nvim_create_user_command("YodaProfilingOff", function()
  vim.g.yoda_config.enable_startup_profiling = false
  vim.g.yoda_config.show_startup_report = false
  vim.notify("Startup profiling disabled", vim.log.levels.INFO, { title = "Yoda.nvim" })
end, { desc = "Disable startup profiling" })

-- Enhanced health and validation commands
vim.api.nvim_create_user_command("YodaHealth", function()
  local health_ok, health = pcall(require, "yoda.utils.health_checker")
  if health_ok then
    health.run_all_checks()
  else
    vim.notify("Health checker not available", vim.log.levels.ERROR)
  end
end, { desc = "Run comprehensive Yoda.nvim health checks" })

vim.api.nvim_create_user_command("YodaPerformance", function()
  local perf_ok, perf = pcall(require, "yoda.utils.performance_monitor")
  if perf_ok then
    perf.analyze_performance()
    perf.optimize_startup()
    perf.check_plugin_performance()
  else
    vim.notify("Performance monitor not available", vim.log.levels.ERROR)
  end
end, { desc = "Analyze Yoda.nvim performance" })

vim.api.nvim_create_user_command("YodaValidatePlugins", function()
  local validator_ok, validator = pcall(require, "yoda.utils.plugin_validator")
  if validator_ok then
    validator.generate_report()
  else
    vim.notify("Plugin validator not available", vim.log.levels.ERROR)
  end
end, { desc = "Validate all Yoda.nvim plugins" })

-- Error recovery commands
vim.api.nvim_create_user_command("YodaErrorReport", function()
  local error_ok, error_utils = pcall(require, "yoda.utils.error_recovery")
  if error_ok then
    local report = error_utils.get_error_report()
    print(string.format("Total errors: %d", report.total_errors))
    for i, error in ipairs(report.recent_errors) do
      print(string.format("[%d] %s: %s", i, error.severity, error.message))
    end
  else
    vim.notify("Error recovery not available", vim.log.levels.ERROR)
  end
end, { desc = "Show Yoda.nvim error report" })

vim.api.nvim_create_user_command("YodaClearErrors", function()
  local error_ok, error_utils = pcall(require, "yoda.utils.error_recovery")
  if error_ok then
    error_utils.clear_error_log()
    vim.notify("Error log cleared", vim.log.levels.INFO)
  else
    vim.notify("Error recovery not available", vim.log.levels.ERROR)
  end
end, { desc = "Clear Yoda.nvim error log" })

