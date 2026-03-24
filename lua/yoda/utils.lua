-- lua/yoda/utils.lua
-- Utilities: safe_require, notify, environment helpers, AI CLI helpers

local M = {}

-- ============================================================================
-- MODULE LOADING
-- ============================================================================

--- Safe require with error handling
--- @param module string Module name
--- @param opts table|nil Options {silent, notify, fallback}
--- @return boolean success
--- @return any module or fallback
function M.safe_require(module, opts)
  opts = opts or {}
  local ok, result = pcall(require, module)

  if not ok then
    if opts.notify ~= false and not opts.silent then
      M.notify(string.format("Failed to load %s", module), "error", { title = "Module Error" })
    end
    return false, opts.fallback or result
  end

  return true, result
end

-- ============================================================================
-- ENVIRONMENT (delegated to environment module for single source of truth)
-- ============================================================================

--- Check if running in work environment
--- @return boolean
function M.is_work_env()
  return require("yoda.environment").get_mode() == "work"
end

--- Check if running in home environment
--- @return boolean
function M.is_home_env()
  return require("yoda.environment").get_mode() == "home"
end

--- Get current environment
--- @return string
function M.get_env()
  return require("yoda.environment").get_mode()
end

-- ============================================================================
-- NOTIFICATION (uses adapter for DIP)
-- ============================================================================

--- Smart notify with automatic backend detection (uses adapter for DIP)
--- Supports noice, snacks, or native vim.notify
--- @param msg string Message to display
--- @param level string|number Log level ("info", "warn", "error" or vim.log.levels.*)
--- @param opts table|nil Options (title, timeout, etc.)
function M.notify(msg, level, opts)
  local ok, adapter = pcall(require, "yoda.adapters.notification")
  if not ok then
    -- Fallback to native vim.notify if adapter fails to load
    local numeric_level = type(level) == "string" and vim.log.levels.INFO or level
    vim.notify(msg, numeric_level, opts)
    return
  end

  adapter.notify(msg, level, opts)
end

--- Alias for notify (backwards compatibility)
--- @param msg string
--- @param level string|number
--- @param opts table
function M.smart_notify(msg, level, opts)
  return M.notify(msg, level, opts)
end

--- Log debug information (only in verbose mode)
--- @param msg string
function M.debug(msg)
  local config = require("yoda.config")
  if config.is_verbose_startup() then
    M.notify("[DEBUG] " .. msg, "debug")
  end
end

-- ============================================================================
-- AI CLI UTILITIES (delegated to diagnostics/ai_cli.lua for perfect SRP)
-- ============================================================================

--- Get Claude CLI path
--- @return string|nil
function M.get_claude_path()
  return require("yoda-diagnostics.ai_cli").get_claude_path()
end

--- Check if Claude CLI is available
--- @return boolean
function M.is_claude_available()
  return require("yoda-diagnostics.ai_cli").is_claude_available()
end

--- Get version of Claude CLI
--- @return string|nil, string|nil
function M.get_claude_version()
  return require("yoda-diagnostics.ai_cli").get_claude_version()
end

return M
