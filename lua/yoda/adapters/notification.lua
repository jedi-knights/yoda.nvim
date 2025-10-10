-- lua/yoda/adapters/notification.lua
-- Notification adapter - abstracts notification backend (DIP principle)
-- Supports noice, snacks, or native vim.notify

local M = {}

-- Private state (perfect encapsulation through closure)
local backend = nil
local initialized = false

-- ============================================================================
-- Backend Detection
-- ============================================================================

--- Initialize and detect notification backend (with encapsulation guard)
--- @return string Backend name ("noice", "snacks", or "native")
local function detect_backend()
  -- Return cached backend if already detected (singleton behavior)
  if backend and initialized then
    return backend
  end
  
  -- Check user preference first
  if vim.g.yoda_notify_backend then
    backend = vim.g.yoda_notify_backend
    initialized = true
    return backend
  end
  
  -- Auto-detect: Try noice first (most feature-rich)
  local ok, noice = pcall(require, "noice")
  if ok and noice.notify then
    backend = "noice"
    initialized = true
    return backend
  end
  
  -- Try snacks (middle ground)
  local ok_snacks, snacks = pcall(require, "snacks")
  if ok_snacks and snacks.notify then
    backend = "snacks"
    initialized = true
    return backend
  end
  
  -- Fallback to native
  backend = "native"
  initialized = true
  return backend
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
    print("ERROR: notification.notify() msg must be a string, got " .. type(msg))
    return
  end
  
  opts = opts or {}
  level = level or "info"
  
  local backend_name = detect_backend()
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
  return detect_backend()
end

--- Force set backend (useful for testing)
--- @param backend_name string Backend name ("noice", "snacks", "native")
function M.set_backend(backend_name)
  if backends[backend_name] then
    backend = backend_name
    initialized = true  -- Mark as initialized to prevent re-detection
  else
    error("Unknown backend: " .. backend_name)
  end
end

--- Reset backend detection (useful for testing)
function M.reset_backend()
  backend = nil
  initialized = false
end

return M


