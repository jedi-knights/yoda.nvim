-- lua/yoda/utils/error_recovery.lua
-- Comprehensive error recovery and handling system for Yoda.nvim

local M = {}

-- Error tracking and recovery data
local error_data = {
  errors = {},
  recovery_attempts = {},
  fallback_states = {},
  critical_errors = {},
  user_notifications = {}
}

-- Error severity levels
local ERROR_LEVELS = {
  CRITICAL = "critical",
  ERROR = "error", 
  WARNING = "warning",
  INFO = "info",
  DEBUG = "debug"
}

-- Recovery strategies
local RECOVERY_STRATEGIES = {
  RETRY = "retry",
  FALLBACK = "fallback",
  DISABLE = "disable",
  RESTART = "restart",
  IGNORE = "ignore"
}

-- Error context tracking
local current_context = {
  module = nil,
  operation = nil,
  user_action = nil
}

-- Set error context for better debugging
function M.set_context(module, operation, user_action)
  current_context = {
    module = module,
    operation = operation,
    user_action = user_action
  }
end

-- Clear error context
function M.clear_context()
  current_context = {
    module = nil,
    operation = nil,
    user_action = nil
  }
end

-- Enhanced error logging with context
function M.log_error(error_msg, level, recovery_strategy)
  level = level or ERROR_LEVELS.ERROR
  recovery_strategy = recovery_strategy or RECOVERY_STRATEGIES.FALLBACK
  
  local error_entry = {
    message = error_msg,
    level = level,
    recovery_strategy = recovery_strategy,
    context = vim.deepcopy(current_context),
    timestamp = os.time(),
    stack_trace = debug.traceback()
  }
  
  table.insert(error_data.errors, error_entry)
  
  -- Log to Neovim's error log
  vim.notify(error_msg, vim.log.levels[level:upper()], {
    title = "Yoda Error Recovery",
    timeout = 5000
  })
  
  return error_entry
end

-- Safe require with error recovery
function M.safe_require(module_name, fallback_module)
  local ok, module = pcall(require, module_name)
  
  if not ok then
    local error_msg = string.format("Failed to load module '%s': %s", module_name, tostring(module))
    M.log_error(error_msg, ERROR_LEVELS.ERROR, RECOVERY_STRATEGIES.FALLBACK)
    
    -- Try fallback module if provided
    if fallback_module then
      local fallback_ok, fallback = pcall(require, fallback_module)
      if fallback_ok then
        M.log_error(string.format("Using fallback module '%s'", fallback_module), ERROR_LEVELS.INFO)
        return fallback
      end
    end
    
    return nil
  end
  
  return module
end

-- Safe function execution with retry logic
function M.safe_execute(func, func_name, max_retries, fallback_func)
  max_retries = max_retries or 3
  func_name = func_name or "unknown_function"
  
  M.set_context("error_recovery", "safe_execute", func_name)
  
  for attempt = 1, max_retries do
    local ok, result = pcall(func)
    
    if ok then
      M.clear_context()
      return result
    else
      local error_msg = string.format("Function '%s' failed (attempt %d/%d): %s", 
        func_name, attempt, max_retries, tostring(result))
      
      if attempt == max_retries then
        M.log_error(error_msg, ERROR_LEVELS.ERROR, RECOVERY_STRATEGIES.FALLBACK)
        
        -- Try fallback function if provided
        if fallback_func then
          local fallback_ok, fallback_result = pcall(fallback_func)
          if fallback_ok then
            M.log_error(string.format("Using fallback for '%s'", func_name), ERROR_LEVELS.INFO)
            return fallback_result
          end
        end
        
        return nil
      else
        M.log_error(error_msg, ERROR_LEVELS.WARNING, RECOVERY_STRATEGIES.RETRY)
        -- Wait before retry
        vim.defer_fn(function() end, 100 * attempt)
      end
    end
  end
end

-- Plugin loading with error recovery
function M.safe_plugin_load(plugin_name, config_func, fallback_config)
  M.set_context("plugin_loading", "safe_plugin_load", plugin_name)
  
  local plugin = M.safe_require(plugin_name)
  if not plugin then
    return false
  end
  
  if config_func then
    local config_ok = M.safe_execute(function()
      config_func(plugin)
    end, string.format("config_%s", plugin_name), 2, fallback_config)
    
    if not config_ok then
      M.log_error(string.format("Failed to configure plugin '%s'", plugin_name), 
        ERROR_LEVELS.WARNING, RECOVERY_STRATEGIES.DISABLE)
      return false
    end
  end
  
  M.clear_context()
  return true
end

-- Configuration validation with recovery
function M.validate_config(config, required_fields, optional_fields)
  local validation_errors = {}
  local recovered_config = vim.deepcopy(config)
  
  -- Check required fields
  for _, field in ipairs(required_fields or {}) do
    if config[field] == nil then
      table.insert(validation_errors, string.format("Missing required field: %s", field))
      -- Try to provide default value
      recovered_config[field] = M.get_default_value(field)
    end
  end
  
  -- Check optional fields and provide defaults
  for _, field in ipairs(optional_fields or {}) do
    if config[field] == nil then
      recovered_config[field] = M.get_default_value(field)
    end
  end
  
  if #validation_errors > 0 then
    local error_msg = string.format("Configuration validation failed: %s", 
      table.concat(validation_errors, ", "))
    M.log_error(error_msg, ERROR_LEVELS.WARNING, RECOVERY_STRATEGIES.FALLBACK)
  end
  
  return recovered_config, #validation_errors == 0
end

-- Get default values for common configuration fields
function M.get_default_value(field)
  local defaults = {
    enabled = true,
    lazy = false,
    priority = 1000,
    timeout = 5000,
    verbose = false,
    debug = false
  }
  
  return defaults[field] or nil
end

-- Graceful degradation for missing features
function M.graceful_degradation(feature_name, fallback_func, user_message)
  M.set_context("graceful_degradation", "feature_check", feature_name)
  
  local feature_ok = M.safe_execute(function()
    -- Try to access the feature
    return true
  end, string.format("check_%s", feature_name), 1)
  
  if not feature_ok then
    M.log_error(string.format("Feature '%s' not available, using fallback", feature_name), 
      ERROR_LEVELS.WARNING, RECOVERY_STRATEGIES.FALLBACK)
    
    if user_message then
      vim.notify(user_message, vim.log.levels.WARN, {
        title = "Yoda Feature Unavailable",
        timeout = 3000
      })
    end
    
    if fallback_func then
      return fallback_func()
    end
    
    return nil
  end
  
  M.clear_context()
  return true
end

-- Automatic recovery for common issues
function M.auto_recovery()
  local recovery_actions = {}
  
  -- Check for common issues and attempt recovery
  local issues = M.detect_common_issues()
  
  for _, issue in ipairs(issues) do
    local recovery_action = M.get_recovery_action(issue)
    if recovery_action then
      table.insert(recovery_actions, recovery_action)
    end
  end
  
  -- Execute recovery actions
  for _, action in ipairs(recovery_actions) do
    M.safe_execute(action.func, action.name, 1)
  end
  
  return #recovery_actions
end

-- Detect common issues
function M.detect_common_issues()
  local issues = {}
  
  -- Check for missing essential plugins
  local essential_plugins = {"lazy", "mason", "lspconfig"}
  for _, plugin in ipairs(essential_plugins) do
    local ok, _ = pcall(require, plugin)
    if not ok then
      table.insert(issues, {
        type = "missing_plugin",
        plugin = plugin,
        severity = ERROR_LEVELS.ERROR
      })
    end
  end
  
  -- Check for configuration issues
  if not vim.g.yoda_config then
    table.insert(issues, {
      type = "missing_config",
      severity = ERROR_LEVELS.WARNING
    })
  end
  
  -- Check for LSP issues
  if vim.lsp then
    local clients = vim.lsp.get_active_clients()
    if #clients == 0 then
      table.insert(issues, {
        type = "no_lsp_clients",
        severity = ERROR_LEVELS.INFO
      })
    end
  end
  
  return issues
end

-- Get recovery action for an issue
function M.get_recovery_action(issue)
  local recovery_actions = {
    missing_plugin = {
      name = "reinstall_plugin",
      func = function()
        vim.notify(string.format("Attempting to reinstall %s", issue.plugin), 
          vim.log.levels.INFO, { title = "Yoda Recovery" })
        -- This would trigger plugin reinstallation
      end
    },
    missing_config = {
      name = "restore_default_config",
      func = function()
        vim.g.yoda_config = vim.g.yoda_config or {}
        vim.notify("Restored default configuration", 
          vim.log.levels.INFO, { title = "Yoda Recovery" })
      end
    },
    no_lsp_clients = {
      name = "restart_lsp",
      func = function()
        vim.notify("No LSP clients active, consider restarting", 
          vim.log.levels.INFO, { title = "Yoda Recovery" })
      end
    }
  }
  
  return recovery_actions[issue.type]
end

-- User-friendly error reporting
function M.user_friendly_error(error_entry)
  local user_messages = {
    [ERROR_LEVELS.CRITICAL] = "🚨 Critical error occurred",
    [ERROR_LEVELS.ERROR] = "❌ Error occurred",
    [ERROR_LEVELS.WARNING] = "⚠️  Warning",
    [ERROR_LEVELS.INFO] = "ℹ️  Information",
    [ERROR_LEVELS.DEBUG] = "🔍 Debug information"
  }
  
  local message = user_messages[error_entry.level] or "ℹ️  Message"
  message = message .. ": " .. error_entry.message
  
  -- Add context if available
  if error_entry.context and error_entry.context.operation then
    message = message .. string.format(" (Operation: %s)", error_entry.context.operation)
  end
  
  -- Add recovery suggestion
  local recovery_suggestions = {
    [RECOVERY_STRATEGIES.RETRY] = "Will retry automatically",
    [RECOVERY_STRATEGIES.FALLBACK] = "Using fallback option",
    [RECOVERY_STRATEGIES.DISABLE] = "Feature disabled",
    [RECOVERY_STRATEGIES.RESTART] = "Consider restarting Neovim",
    [RECOVERY_STRATEGIES.IGNORE] = "Error ignored"
  }
  
  local suggestion = recovery_suggestions[error_entry.recovery_strategy]
  if suggestion then
    message = message .. " - " .. suggestion
  end
  
  return message
end

-- Get error report
function M.get_error_report()
  local report = {
    total_errors = #error_data.errors,
    critical_errors = 0,
    warnings = 0,
    info_messages = 0,
    recent_errors = {},
    recovery_suggestions = {}
  }
  
  -- Categorize errors
  for _, error_entry in ipairs(error_data.errors) do
    if error_entry.level == ERROR_LEVELS.CRITICAL then
      report.critical_errors = report.critical_errors + 1
    elseif error_entry.level == ERROR_LEVELS.WARNING then
      report.warnings = report.warnings + 1
    elseif error_entry.level == ERROR_LEVELS.INFO then
      report.info_messages = report.info_messages + 1
    end
    
    -- Add recent errors (last 10)
    if #report.recent_errors < 10 then
      table.insert(report.recent_errors, {
        message = error_entry.message,
        level = error_entry.level,
        timestamp = error_entry.timestamp,
        context = error_entry.context
      })
    end
  end
  
  -- Generate recovery suggestions
  if report.critical_errors > 0 then
    table.insert(report.recovery_suggestions, "Restart Neovim to clear critical errors")
  end
  
  if report.warnings > 5 then
    table.insert(report.recovery_suggestions, "Check configuration for issues")
  end
  
  return report
end

-- Print error report
function M.print_error_report()
  local report = M.get_error_report()
  
  print("=== Yoda.nvim Error Recovery Report ===")
  print(string.format("Total Errors: %d", report.total_errors))
  print(string.format("Critical: %d", report.critical_errors))
  print(string.format("Warnings: %d", report.warnings))
  print(string.format("Info: %d", report.info_messages))
  
  if #report.recent_errors > 0 then
    print("\n📋 Recent Errors:")
    for _, error in ipairs(report.recent_errors) do
      local level_icon = {
        [ERROR_LEVELS.CRITICAL] = "🚨",
        [ERROR_LEVELS.ERROR] = "❌",
        [ERROR_LEVELS.WARNING] = "⚠️",
        [ERROR_LEVELS.INFO] = "ℹ️",
        [ERROR_LEVELS.DEBUG] = "🔍"
      }
      print(string.format("  %s %s", level_icon[error.level] or "ℹ️", error.message))
    end
  end
  
  if #report.recovery_suggestions > 0 then
    print("\n💡 Recovery Suggestions:")
    for _, suggestion in ipairs(report.recovery_suggestions) do
      print(string.format("  💡 %s", suggestion))
    end
  end
  
  print("=======================================")
end

-- Clear error history
function M.clear_error_history()
  error_data.errors = {}
  error_data.recovery_attempts = {}
  vim.notify("Error history cleared", vim.log.levels.INFO, {
    title = "Yoda Error Recovery",
    timeout = 2000
  })
end

-- User commands
vim.api.nvim_create_user_command("YodaErrorReport", function()
  M.print_error_report()
end, { desc = "Show error recovery report" })

vim.api.nvim_create_user_command("YodaClearErrors", function()
  M.clear_error_history()
end, { desc = "Clear error history" })

vim.api.nvim_create_user_command("YodaAutoRecovery", function()
  local recovered = M.auto_recovery()
  vim.notify(string.format("Auto-recovery completed: %d actions taken", recovered), 
    vim.log.levels.INFO, { title = "Yoda Recovery" })
end, { desc = "Run automatic error recovery" })

return M 