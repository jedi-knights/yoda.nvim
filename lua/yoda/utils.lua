-- lua/yoda/utils.lua
-- Consolidated utilities with delegation to focused core modules
-- This module serves as the main entry point for utilities

local M = {}

-- ============================================================================
-- CORE MODULE IMPORTS (perfect loose coupling)
-- ============================================================================

-- Use core loader to eliminate direct coupling - PERFECT SRP
local core_loader = require("yoda.core.loader")

-- Lazy load ONLY focused modules (perfect single responsibility)
local string_utils = core_loader.load_core("string")
local table_utils = core_loader.load_core("table")
local filesystem_utils = core_loader.load_core("filesystem")
local json_utils = core_loader.load_core("json")
local temp_utils = core_loader.load_core("temp")
local platform_utils = core_loader.load_core("platform")

-- Export focused modules directly (perfect SRP compliance)
M.string = string_utils
M.table = table_utils
M.filesystem = filesystem_utils
M.json = json_utils
M.temp = temp_utils
M.platform = platform_utils

-- Backwards compatibility layer (delegates only, no business logic)
M.io = require("yoda.compat.io")

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
  return filesystem_utils.file_exists(path)
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
  if vim.g.yoda_config and vim.g.yoda_config.verbose_startup then
    M.notify("[DEBUG] " .. msg, "debug")
  end
end

-- ============================================================================
-- AI CLI UTILITIES (delegated to diagnostics/ai_cli.lua for perfect SRP)
-- ============================================================================

--- Get Claude CLI path
--- @return string|nil
function M.get_claude_path()
  return require("yoda.diagnostics.ai_cli").get_claude_path()
end

--- Check if Claude CLI is available
--- @return boolean
function M.is_claude_available()
  return require("yoda.diagnostics.ai_cli").is_claude_available()
end

--- Get version of Claude CLI
--- @return string|nil, string|nil
function M.get_claude_version()
  return require("yoda.diagnostics.ai_cli").get_claude_version()
end

-- ============================================================================
-- SHADA MAINTENANCE
-- ============================================================================

--- Safely clean up ShaDa temporary files (only removes stale files)
--- This function checks for active Neovim processes before removing temp files
--- @param force boolean|nil Force cleanup even if other instances might be running
--- @return boolean success, string message
function M.cleanup_shada_files(force)
  local shada_dir = vim.fn.stdpath("state") .. "/shada"

  if not M.file_exists(shada_dir) then
    return true, "ShaDa directory not found"
  end

  -- Get all temp files
  local temp_files = vim.fn.glob(shada_dir .. "/*.tmp.*", false, true)

  if #temp_files == 0 then
    return true, "No temporary files found"
  end

  -- Check for other running Neovim instances if not forcing
  if not force then
    local nvim_processes = vim.fn.system("pgrep -c nvim"):match("^%d+")
    local process_count = tonumber(nvim_processes) or 0

    -- If more than 1 nvim process (current one), be more careful
    if process_count > 1 then
      local old_files = {}
      local current_time = os.time()

      -- Only remove files older than 5 minutes (300 seconds)
      for _, file in ipairs(temp_files) do
        local stat = vim.loop.fs_stat(file)
        if stat and (current_time - stat.mtime.sec) > 300 then
          table.insert(old_files, file)
        end
      end

      temp_files = old_files

      if #temp_files == 0 then
        return true,
          string.format(
            "Found %d temp files but they're recent (other nvim instances may be using them)",
            #vim.fn.glob(shada_dir .. "/*.tmp.*", false, true)
          )
      end
    end
  end

  -- Remove the identified temp files
  local removed_count = 0
  for _, file in ipairs(temp_files) do
    if vim.fn.delete(file) == 0 then
      removed_count = removed_count + 1
    end
  end

  return true, string.format("Cleaned up %d temporary files", removed_count)
end

--- Check if ShaDa cleanup is needed
--- @return boolean needs_cleanup, number temp_file_count
function M.check_shada_cleanup_needed()
  local shada_dir = vim.fn.stdpath("state") .. "/shada"

  if not M.file_exists(shada_dir) then
    return false, 0
  end

  local temp_files = vim.fn.glob(shada_dir .. "/*.tmp.*", false, true)
  return #temp_files > 0, #temp_files
end

return M
