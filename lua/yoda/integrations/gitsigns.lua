-- lua/yoda/integrations/gitsigns.lua
-- GitSigns integration utilities

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

local REFRESH_DELAY = 150 -- ms - debounce delay to prevent flickering

-- ============================================================================
-- Private State
-- ============================================================================

local refresh_timer = nil

-- ============================================================================
-- Public API
-- ============================================================================

--- Check if gitsigns plugin is loaded
--- @return boolean
function M.is_available()
  return package.loaded.gitsigns ~= nil
end

--- Get the gitsigns module if available
--- @return table|nil gitsigns module or nil
function M.get_gitsigns()
  return package.loaded.gitsigns
end

--- Safely refresh git signs (simple, non-debounced)
--- This is useful for one-time refresh operations
function M.refresh()
  local gs = M.get_gitsigns()
  if not gs then
    return
  end

  vim.schedule(function()
    pcall(gs.refresh)
  end)
end

--- Refresh git signs with debouncing to prevent flickering
--- This is preferred for repeated/frequent refresh operations
function M.refresh_debounced()
  local gs = M.get_gitsigns()
  if not gs or vim.bo.buftype ~= "" then
    return
  end

  -- Cancel any pending refresh
  if refresh_timer then
    pcall(vim.fn.timer_stop, refresh_timer)
    refresh_timer = nil
  end

  -- Schedule debounced refresh
  refresh_timer = vim.fn.timer_start(REFRESH_DELAY, function()
    refresh_timer = nil
    vim.schedule(function()
      local gitsigns = M.get_gitsigns()
      if gitsigns then
        pcall(gitsigns.refresh)
      end
    end)
  end)
end

--- Reset any pending refresh timers
--- Useful for cleanup or testing
function M.reset_timers()
  if refresh_timer then
    pcall(vim.fn.timer_stop, refresh_timer)
    refresh_timer = nil
  end
end

return M
