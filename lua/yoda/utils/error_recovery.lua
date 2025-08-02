-- Enhanced Error Recovery for Yoda.nvim
local M = {}

-- Error tracking
local error_log = {}
local recovery_attempts = {}

-- Error severity levels
local SEVERITY = {
  LOW = 1,
  MEDIUM = 2,
  HIGH = 3,
  CRITICAL = 4
}

-- Log error with context
function M.log_error(error_msg, severity, context)
  local error_entry = {
    message = error_msg,
    severity = severity or SEVERITY.MEDIUM,
    context = context or {},
    timestamp = os.time(),
    stack_trace = debug.traceback()
  }
  
  table.insert(error_log, error_entry)
  
  -- Notify user based on severity
  local level = vim.log.levels.INFO
  if severity == SEVERITY.HIGH then
    level = vim.log.levels.WARN
  elseif severity == SEVERITY.CRITICAL then
    level = vim.log.levels.ERROR
  end
  
  vim.notify(error_msg, level, { title = "Yoda.nvim Error" })
end

-- Safe require with error recovery
function M.safe_require(module_name, fallback_fn)
  local ok, module = pcall(require, module_name)
  if ok then
    return module
  else
    M.log_error(string.format("Failed to load module: %s", module_name), SEVERITY.MEDIUM, {
      module = module_name,
      error = module
    })
    
    if fallback_fn then
      return fallback_fn()
    end
    return nil
  end
end

-- Safe function execution with retry
function M.safe_execute(fn, max_retries, context)
  max_retries = max_retries or 3
  context = context or {}
  
  for attempt = 1, max_retries do
    local ok, result = pcall(fn)
    if ok then
      return result
    else
      M.log_error(string.format("Function execution failed (attempt %d/%d): %s", 
        attempt, max_retries, result), SEVERITY.MEDIUM, context)
      
      if attempt < max_retries then
        -- Wait before retry
        vim.defer_fn(function() end, 100 * attempt)
      end
    end
  end
  
  return nil
end

-- Plugin-specific error recovery
function M.recover_plugin_error(plugin_name, error_msg)
  local recovery_strategies = {
    ["lazy.nvim"] = function()
      -- Try to reload lazy.nvim
      vim.cmd("Lazy sync")
    end,
    ["telescope"] = function()
      -- Reset telescope if it's causing issues
      local ok, telescope = pcall(require, "telescope")
      if ok then
        telescope.reset()
      end
    end,
    ["lsp"] = function()
      -- Restart LSP if needed
      vim.cmd("LspRestart")
    end,
    ["treesitter"] = function()
      -- Reload treesitter
      vim.cmd("TSUpdate")
    end
  }
  
  local strategy = recovery_strategies[plugin_name]
  if strategy then
    M.safe_execute(strategy, 1, { plugin = plugin_name })
    M.log_error(string.format("Applied recovery strategy for %s", plugin_name), SEVERITY.LOW)
  end
end

-- Configuration validation
function M.validate_config()
  local issues = {}
  
  -- Check required global variables
  if not vim.g.mapleader then
    table.insert(issues, "mapleader not set")
  end
  
  -- Check core modules
  local core_modules = {
    "yoda.core.options",
    "yoda.core.keymaps"
  }
  
  for _, module in ipairs(core_modules) do
    local ok, _ = pcall(require, module)
    if not ok then
      table.insert(issues, string.format("Core module failed: %s", module))
    end
  end
  
  -- Check plugin manager
  local lazy_ok, _ = pcall(require, "lazy")
  if not lazy_ok then
    table.insert(issues, "lazy.nvim not available")
  end
  
  return issues
end

-- Auto-recovery for common issues
function M.auto_recovery()
  local issues = M.validate_config()
  
  if #issues > 0 then
    M.log_error(string.format("Configuration issues detected: %s", table.concat(issues, ", ")), SEVERITY.HIGH)
    
    -- Attempt automatic fixes
    for _, issue in ipairs(issues) do
      if issue == "mapleader not set" then
        vim.g.mapleader = " "
        M.log_error("Fixed: Set mapleader to space", SEVERITY.LOW)
      end
    end
  end
end

-- Performance error recovery
function M.recover_performance_issues()
  local perf_ok, perf = pcall(require, "yoda.utils.performance_monitor")
  if perf_ok then
    local data = perf.export_performance_data()
    
    -- Check for memory issues
    if data.memory_usage and data.memory_usage.used then
      local mem_mb = data.memory_usage.used / (1024 * 1024)
      if mem_mb > 200 then
        M.log_error(string.format("High memory usage detected: %.1f MB", mem_mb), SEVERITY.HIGH)
        -- Suggest garbage collection
        collectgarbage("collect")
      end
    end
    
    -- Check for slow startup
    if data.startup_time and data.startup_time > 500 then
      M.log_error(string.format("Slow startup detected: %dms", data.startup_time), SEVERITY.MEDIUM)
    end
  end
end

-- Error reporting
function M.get_error_report()
  return {
    total_errors = #error_log,
    recent_errors = vim.list_slice(error_log, math.max(1, #error_log - 10)),
    recovery_attempts = recovery_attempts
  }
end

-- Clear error log
function M.clear_error_log()
  error_log = {}
  recovery_attempts = {}
end

-- Register error recovery commands
vim.api.nvim_create_user_command("YodaErrorReport", function()
  local report = M.get_error_report()
  print(string.format("Total errors: %d", report.total_errors))
  for i, error in ipairs(report.recent_errors) do
    print(string.format("[%d] %s: %s", i, error.severity, error.message))
  end
end, { desc = "Show Yoda.nvim error report" })

vim.api.nvim_create_user_command("YodaClearErrors", function()
  M.clear_error_log()
  vim.notify("Error log cleared", vim.log.levels.INFO)
end, { desc = "Clear Yoda.nvim error log" })

-- Auto-recovery on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      M.auto_recovery()
      M.recover_performance_issues()
    end, 1000)
  end,
  once = true
})

return M 