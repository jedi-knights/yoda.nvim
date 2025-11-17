-- lua/yoda/utils.lua
-- Consolidated utilities with delegation to focused core modules
-- This module serves as the main entry point for utilities

local M = {}

-- ============================================================================
-- CORE MODULE IMPORTS
-- ============================================================================

-- Import focused core modules
local string_utils = require("yoda-core.string")
local table_utils = require("yoda-core.table")
local io_utils = require("yoda-core.io")
local platform_utils = require("yoda-core.platform")

-- Export core modules for direct access
M.string = string_utils
M.table = table_utils
M.io = io_utils
M.platform = platform_utils

-- ============================================================================
-- STRING UTILITIES (delegated to core/string.lua)
-- ============================================================================

--- Trim whitespace from string
--- @param str string
--- @return string
function M.trim(str)
  return string_utils.trim(str)
end

--- Check if a string starts with a prefix
--- @param str string
--- @param prefix string
--- @return boolean
function M.starts_with(str, prefix)
  return string_utils.starts_with(str, prefix)
end

--- Check if a string ends with a suffix
--- @param str string
--- @param suffix string
--- @return boolean
function M.ends_with(str, suffix)
  return string_utils.ends_with(str, suffix)
end

--- Get the file extension from a path
--- @param path string
--- @return string
function M.get_extension(path)
  return string_utils.get_extension(path)
end

-- ============================================================================
-- FILE UTILITIES (delegated to core/io.lua)
-- ============================================================================

--- Check if a file exists
--- @param path string
--- @return boolean
function M.file_exists(path)
  return io_utils.file_exists(path)
end

-- ============================================================================
-- TABLE UTILITIES (delegated to core/table.lua)
-- ============================================================================

--- Create a table with default values
--- @param defaults table
--- @param overrides table
--- @return table
function M.merge_tables(defaults, overrides)
  return table_utils.merge(defaults, overrides)
end

--- Deep copy a table
--- @param orig table
--- @return table
function M.deep_copy(orig)
  return table_utils.deep_copy(orig)
end

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
