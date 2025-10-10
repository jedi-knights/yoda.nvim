-- lua/yoda/adapters/picker.lua
-- Picker adapter - abstracts picker backend (DIP principle)
-- Supports snacks, telescope, or native vim.ui.select

local M = {}

-- Private state (perfect encapsulation through closure)
local backend = nil
local initialized = false

-- ============================================================================
-- Backend Detection
-- ============================================================================

--- Initialize and detect picker backend (with encapsulation guard)
--- @return string Backend name ("snacks", "telescope", or "native")
local function detect_backend()
  -- Return cached backend if already detected (singleton behavior)
  if backend and initialized then
    return backend
  end
  
  -- Check user preference first
  if vim.g.yoda_picker_backend then
    backend = vim.g.yoda_picker_backend
    initialized = true
    return backend
  end
  
  -- Auto-detect: Try snacks first
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.picker then
    backend = "snacks"
    initialized = true
    return backend
  end
  
  -- Try telescope
  local ok_telescope, telescope = pcall(require, "telescope")
  if ok_telescope then
    backend = "telescope"
    initialized = true
    return backend
  end
  
  -- Fallback to native
  backend = "native"
  initialized = true
  return backend
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
  local backend_name = detect_backend()
  return backends[backend_name]
end

--- Select item from list
--- @param items table List of items
--- @param opts table Options (prompt, format_item, etc.)
--- @param callback function Callback receiving selected item
function M.select(items, opts, callback)
  -- Input validation (assertive programming)
  if type(items) ~= "table" then
    vim.notify(
      "picker.select: items must be a table, got " .. type(items),
      vim.log.levels.ERROR,
      { title = "Picker Error" }
    )
    if callback then callback(nil) end
    return
  end
  
  if type(callback) ~= "function" then
    vim.notify(
      "picker.select: callback must be a function, got " .. type(callback),
      vim.log.levels.ERROR,
      { title = "Picker Error" }
    )
    return
  end
  
  local picker = M.create()
  picker.select(items, opts, callback)
end

--- Get current backend name
--- @return string Backend name
function M.get_backend()
  return detect_backend()
end

--- Force set backend (useful for testing)
--- @param backend_name string Backend name ("snacks", "telescope", "native")
function M.set_backend(backend_name)
  if backends[backend_name] then
    backend = backend_name
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


