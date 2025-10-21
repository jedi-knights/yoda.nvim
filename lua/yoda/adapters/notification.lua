-- lua/yoda/adapters/notification.lua
-- Notification adapter - abstracts notification backend (DIP principle)
-- Supports noice, snacks, or native vim.notify

local backends_system = require("yoda.core.backends")
local result = require("yoda.core.result")

local M = {}

-- ============================================================================
-- Backend Detection - PERFECT DRY
-- ============================================================================

--- Get notification backend using unified backend system
--- @return string Backend name ("noice", "snacks", or "native")
local function get_backend()
  local preferred = vim.g.yoda_notify_backend
  local backend_result = backends_system.detect_backend("notification", preferred)
  
  if result.is_success(backend_result) then
    return backend_result.value
  else
    -- Fallback to native on error
    vim.notify("Backend detection failed: " .. result.get_error_message(backend_result), vim.log.levels.WARN)
    return "native"
  end
end

-- ============================================================================
-- Level Conversion
-- ============================================================================

--- Convert level to number if string
--- @param level string|number Level ("info", "warn", etc. or vim.log.levels)
--- @return number Numeric level
local function normalize_level_to_number(level)
  if type(level) == "number" then
    return level
  end

  local levels = {
    error = vim.log.levels.ERROR,
    warn = vim.log.levels.WARN,
    info = vim.log.levels.INFO,
    debug = vim.log.levels.DEBUG,
    trace = vim.log.levels.TRACE,
  }

  return levels[level:lower()] or vim.log.levels.INFO
end

--- Convert level to string if number
--- @param level string|number Level
--- @return string String level
local function normalize_level_to_string(level)
  if type(level) == "string" then
    return level:lower()
  end

  local levels = {
    [vim.log.levels.ERROR] = "error",
    [vim.log.levels.WARN] = "warn",
    [vim.log.levels.INFO] = "info",
    [vim.log.levels.DEBUG] = "debug",
    [vim.log.levels.TRACE] = "trace",
  }

  return levels[level] or "info"
end

-- ============================================================================
-- Backend Implementations
-- ============================================================================

local backends = {
  noice = function(msg, level, opts)
    local noice = require("noice")
    local string_level = normalize_level_to_string(level)
    noice.notify(msg, string_level, opts)
  end,

  snacks = function(msg, level, opts)
    local snacks = require("snacks")
    local string_level = normalize_level_to_string(level)
    snacks.notify(msg, string_level, opts)
  end,

  native = function(msg, level, opts)
    local numeric_level = normalize_level_to_number(level)
    vim.notify(msg, numeric_level, opts)
  end,
}

-- ============================================================================
-- Public API
-- ============================================================================

--- Smart notify with automatic backend detection
--- @param msg string Message to display
--- @param level string|number Log level ("info", "warn", "error" or vim.log.levels.*)
--- @param opts table|nil Options (title, timeout, etc.)
function M.notify(msg, level, opts)
  -- Input validation (assertive programming)
  if type(msg) ~= "string" then
    -- Use vim.notify directly here to avoid circular dependency
    vim.notify("ERROR: notification.notify() msg must be a string, got " .. type(msg), vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  level = level or "info"

  local backend_name = get_backend()
  local notify_fn = backends[backend_name]

  if notify_fn then
    local ok, err = pcall(notify_fn, msg, level, opts)
    if not ok then
      -- Fallback to native if backend fails
      backends.native(msg, level, opts)
    end
  else
    -- Unknown backend, use native
    backends.native(msg, level, opts)
  end
end

--- Get current backend name
--- @return string Backend name
function M.get_backend()
  return get_backend()
end

--- Force set backend (useful for testing)
--- @param backend_name string Backend name ("noice", "snacks", "native")
function M.set_backend(backend_name)
  local set_result = backends_system.set_backend("notification", backend_name, true) -- Force for testing
  if result.is_error(set_result) then
    error("Unknown backend: " .. backend_name)
  end
end

--- Reset backend detection (useful for testing)
function M.reset_backend()
  backends_system.reset_backend("notification")
end

return M
