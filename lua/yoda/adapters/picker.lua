-- lua/yoda/adapters/picker.lua
-- Picker adapter - abstracts picker backend (DIP principle)
-- Supports snacks, telescope, or native vim.ui.select

local backends_system = require("yoda.core.backends")
local result = require("yoda.core.result")

local M = {}

-- ============================================================================
-- Backend Detection - PERFECT DRY
-- ============================================================================

--- Get picker backend using unified backend system
--- @return string Backend name ("snacks", "telescope", or "native")
local function get_backend()
  local preferred = vim.g.yoda_picker_backend
  local backend_result = backends_system.detect_backend("picker", preferred)
  
  if result.is_success(backend_result) then
    return backend_result.value
  else
    -- Fallback to native on error
    vim.notify("Backend detection failed: " .. result.get_error_message(backend_result), vim.log.levels.WARN)
    return "native"
  end
end

-- ============================================================================
-- Backend Implementations
-- ============================================================================

local backends = {
  snacks = {
    select = function(items, opts, callback)
      local snacks = require("snacks")
      snacks.picker.select(items, opts, callback)
    end,
  },

  telescope = {
    select = function(items, opts, callback)
      -- Use vim.ui.select which telescope should override
      -- Or use telescope directly if needed
      vim.ui.select(items, opts, callback)
    end,
  },

  native = {
    select = function(items, opts, callback)
      vim.ui.select(items, opts, callback)
    end,
  },
}

-- ============================================================================
-- Public API
-- ============================================================================

--- Create picker instance with automatic backend detection
--- @return table Picker implementation with select method
function M.create()
  local backend_name = get_backend()
  return backends[backend_name]
end

--- Select item from list
--- @param items table List of items
--- @param opts table Options (prompt, format_item, etc.)
--- @param callback function Callback receiving selected item
function M.select(items, opts, callback)
  -- Input validation (assertive programming)
  if type(items) ~= "table" then
    vim.notify("picker.select: items must be a table, got " .. type(items), vim.log.levels.ERROR, { title = "Picker Error" })
    if callback then
      callback(nil)
    end
    return
  end

  if type(callback) ~= "function" then
    vim.notify("picker.select: callback must be a function, got " .. type(callback), vim.log.levels.ERROR, { title = "Picker Error" })
    return
  end

  local picker = M.create()
  picker.select(items, opts, callback)
end

--- Get current backend name
--- @return string Backend name
function M.get_backend()
  return get_backend()
end

--- Force set backend (useful for testing)
--- @param backend_name string Backend name ("snacks", "telescope", "native")
function M.set_backend(backend_name)
  local set_result = backends_system.set_backend("picker", backend_name, true) -- Force for testing
  if result.is_error(set_result) then
    error("Unknown backend: " .. backend_name)
  end
end

--- Reset backend detection (useful for testing)
function M.reset_backend()
  backends_system.reset_backend("picker")
end

return M
