-- lua/yoda/core/notify.lua
-- Unified notification system - PERFECT DRY
-- Single source of truth for all vim.notify patterns - eliminates 97+ instances of duplication

local M = {}

-- ============================================================================
-- Notification Levels (Centralized)
-- ============================================================================

M.LEVELS = {
  ERROR = vim.log.levels.ERROR,
  WARN = vim.log.levels.WARN,
  INFO = vim.log.levels.INFO,
  DEBUG = vim.log.levels.DEBUG,
  TRACE = vim.log.levels.TRACE,
}

-- ============================================================================
-- Core Notification Functions
-- ============================================================================

--- Unified notification with consistent formatting
--- @param message string Message to display
--- @param level number|string Log level (vim.log.levels.* or string)
--- @param title string|nil Optional title (defaults to "Yoda")
--- @param opts table|nil Additional options for vim.notify
function M.notify(message, level, title, opts)
  level = level or M.LEVELS.INFO
  opts = opts or {}
  
  -- Convert string levels to numbers if needed
  if type(level) == "string" then
    level = M.LEVELS[level:upper()] or M.LEVELS.INFO
  end
  
  -- Set default title
  if title then
    opts.title = title
  elseif not opts.title then
    opts.title = "Yoda"
  end
  
  vim.notify(message, level, opts)
end

--- Error notification with consistent formatting
--- @param message string Error message
--- @param title string|nil Optional title (defaults to "Yoda Error")
--- @param opts table|nil Additional options
function M.error(message, title, opts)
  M.notify(message, M.LEVELS.ERROR, title or "Yoda Error", opts)
end

--- Warning notification with consistent formatting
--- @param message string Warning message
--- @param title string|nil Optional title (defaults to "Yoda Warning")
--- @param opts table|nil Additional options
function M.warn(message, title, opts)
  M.notify(message, M.LEVELS.WARN, title or "Yoda Warning", opts)
end

--- Info notification with consistent formatting
--- @param message string Info message
--- @param title string|nil Optional title (defaults to "Yoda")
--- @param opts table|nil Additional options
function M.info(message, title, opts)
  M.notify(message, M.LEVELS.INFO, title, opts)
end

--- Debug notification with consistent formatting
--- @param message string Debug message
--- @param title string|nil Optional title (defaults to "Yoda Debug")
--- @param opts table|nil Additional options
function M.debug(message, title, opts)
  M.notify(message, M.LEVELS.DEBUG, title or "Yoda Debug", opts)
end

-- ============================================================================
-- Specialized Notification Functions
-- ============================================================================

--- Module-specific error notification
--- @param module_name string Name of the module
--- @param function_name string Name of the function
--- @param param_name string Name of the parameter that failed
--- @param expected string What was expected
--- @param actual string What was received
function M.validation_error(module_name, function_name, param_name, expected, actual)
  local message = string.format(
    "%s.%s(): %s must be %s, got %s",
    module_name, function_name, param_name, expected, actual
  )
  M.error(message, module_name .. " Error")
end

--- Success notification with checkmark
--- @param message string Success message
--- @param title string|nil Optional title
--- @param opts table|nil Additional options
function M.success(message, title, opts)
  M.info("✅ " .. message, title, opts)
end

--- Failure notification with X mark
--- @param message string Failure message  
--- @param title string|nil Optional title
--- @param opts table|nil Additional options
function M.failure(message, title, opts)
  M.error("❌ " .. message, title, opts)
end

--- Progress notification with info icon
--- @param message string Progress message
--- @param title string|nil Optional title
--- @param opts table|nil Additional options
function M.progress(message, title, opts)
  M.info("ℹ️ " .. message, title, opts)
end

--- Warning with warning icon
--- @param message string Warning message
--- @param title string|nil Optional title  
--- @param opts table|nil Additional options
function M.warning_icon(message, title, opts)
  M.warn("⚠️ " .. message, title, opts)
end

-- ============================================================================
-- Module-Specific Notification Helpers
-- ============================================================================

--- Create module-specific notification function
--- @param module_name string Name of the module
--- @return table module_notifier Module-specific notification functions
function M.for_module(module_name)
  return {
    error = function(message, opts)
      M.error(message, module_name .. " Error", opts)
    end,
    warn = function(message, opts)
      M.warn(message, module_name .. " Warning", opts)  
    end,
    info = function(message, opts)
      M.info(message, module_name, opts)
    end,
    success = function(message, opts)
      M.success(message, module_name, opts)
    end,
    failure = function(message, opts)
      M.failure(message, module_name, opts)
    end,
    validation_error = function(function_name, param_name, expected, actual)
      M.validation_error(module_name, function_name, param_name, expected, actual)
    end,
  }
end

-- ============================================================================
-- Common Notification Patterns
-- ============================================================================

--- Notification for missing dependencies
--- @param dependency_name string Name of missing dependency
--- @param suggestion string|nil Optional suggestion for installation
function M.missing_dependency(dependency_name, suggestion)
  local message = dependency_name .. " not available"
  if suggestion then
    message = message .. ". " .. suggestion
  end
  M.failure(message, "Missing Dependency")
end

--- Notification for CLI tool availability
--- @param tool_name string Name of the CLI tool
--- @param version string|nil Version information
--- @param available boolean Whether the tool is available
function M.cli_status(tool_name, available, version)
  if available then
    local message = tool_name .. " available"
    if version then
      message = message .. " (" .. version .. ")"
    end
    M.success(message, "CLI Tools")
  else
    M.failure(tool_name .. " not available", "CLI Tools")
  end
end

--- Notification for LSP status  
--- @param client_names table List of active LSP client names
function M.lsp_status(client_names)
  if #client_names == 0 then
    M.failure("No LSP clients are currently active", "LSP Status")
  else
    M.success("Active LSP clients:", "LSP Status")
    for _, name in ipairs(client_names) do
      M.info("  - " .. name, "LSP Status")
    end
  end
end

--- Notification for file operations
--- @param operation string Operation name (e.g., "save", "load")
--- @param filename string Name of the file
--- @param success boolean Whether the operation succeeded
--- @param error_msg string|nil Error message if operation failed
function M.file_operation(operation, filename, success, error_msg)
  if success then
    M.success(string.format("%s %s", operation, filename), "File Operation")
  else
    local message = string.format("Failed to %s %s", operation, filename)
    if error_msg then
      message = message .. ": " .. error_msg
    end
    M.failure(message, "File Operation")
  end
end

return M