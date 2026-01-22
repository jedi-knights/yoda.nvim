-- lua/yoda/integrations/gitsigns.lua
-- GitSigns integration utilities

local M = {}

local timer_manager = require("yoda.timer_manager")

-- ============================================================================
-- Constants
-- ============================================================================

local REFRESH_DELAY = 150 -- ms - debounce delay to prevent flickering
local BATCH_WINDOW = 200 -- ms - batching window for multiple refresh requests
local TIMER_ID = "gitsigns_refresh"
local BATCH_TIMER_ID = "gitsigns_batch"

-- ============================================================================
-- Private State
-- ============================================================================

local refresh_timer = nil
local batch_state = {
  timer = nil,
  requests = {},
  window_start = 0,
  request_count = 0,
  batch_count = 0,
}

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
  if timer_manager.is_vim_timer_active(TIMER_ID) then
    timer_manager.stop_vim_timer(TIMER_ID)
    refresh_timer = nil
  end

  -- Schedule debounced refresh
  refresh_timer = timer_manager.create_vim_timer(function()
    refresh_timer = nil
    vim.schedule(function()
      local gitsigns = M.get_gitsigns()
      if gitsigns then
        pcall(gitsigns.refresh)
      end
    end)
  end, REFRESH_DELAY, TIMER_ID)
end

--- Refresh git signs with batching - collects multiple requests in 200ms window
--- This is the most efficient approach for multiple refresh sources
function M.refresh_batched()
  local gs = M.get_gitsigns()
  if not gs then
    return
  end

  local current_time = vim.loop.hrtime() / 1000000

  -- Track the request
  local buf = vim.api.nvim_get_current_buf()
  batch_state.requests[buf] = true
  batch_state.request_count = batch_state.request_count + 1

  -- Start batch window if not already started
  if not batch_state.timer then
    batch_state.window_start = current_time
    batch_state.batch_count = batch_state.batch_count + 1

    batch_state.timer = timer_manager.create_vim_timer(function()
      batch_state.timer = nil

      -- Collect all buffers that requested refresh
      local buffers = {}
      for b, _ in pairs(batch_state.requests) do
        if vim.api.nvim_buf_is_valid(b) then
          table.insert(buffers, b)
        end
      end

      -- Clear batch state
      local request_count = batch_state.request_count
      batch_state.requests = {}
      batch_state.request_count = 0

      -- Execute batched refresh
      vim.schedule(function()
        local gitsigns = M.get_gitsigns()
        if gitsigns then
          for _, b in ipairs(buffers) do
            if vim.api.nvim_buf_is_valid(b) then
              pcall(gitsigns.refresh, b)
            end
          end
        end
      end)
    end, BATCH_WINDOW, BATCH_TIMER_ID)
  end
end

--- Reset any pending refresh timers
--- Useful for cleanup or testing
function M.reset_timers()
  if timer_manager.is_vim_timer_active(TIMER_ID) then
    timer_manager.stop_vim_timer(TIMER_ID)
    refresh_timer = nil
  end

  if timer_manager.is_vim_timer_active(BATCH_TIMER_ID) then
    timer_manager.stop_vim_timer(BATCH_TIMER_ID)
    batch_state.timer = nil
    batch_state.requests = {}
    batch_state.request_count = 0
  end
end

--- Get batch statistics (for testing/debugging)
--- @return table stats Batch statistics
function M.get_batch_stats()
  return {
    active = batch_state.timer ~= nil,
    pending_requests = batch_state.request_count,
    total_batches = batch_state.batch_count,
    window_ms = BATCH_WINDOW,
  }
end

--- Reset batch statistics (for testing)
function M.reset_batch_stats()
  batch_state.batch_count = 0
  batch_state.request_count = 0
  batch_state.requests = {}
end

return M
