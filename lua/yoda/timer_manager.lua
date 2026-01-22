-- lua/yoda/timer_manager.lua
-- Centralized timer management to prevent memory leaks

local M = {}

-- ============================================================================
-- Private State
-- ============================================================================

local active_timers = {}
local active_vim_timers = {}
local timer_id_counter = 0
local total_timers_created = 0

-- ============================================================================
-- Helper Functions
-- ============================================================================

--- Generate unique timer ID
--- @return string
local function generate_timer_id()
  timer_id_counter = timer_id_counter + 1
  return "timer_" .. timer_id_counter
end

--- Wrap callback in pcall for safety
--- @param callback function
--- @param timer_id string
--- @return function
local function wrap_callback(callback, timer_id)
  return function(...)
    local ok, err = pcall(callback, ...)
    if not ok then
      vim.notify("Timer callback error [" .. timer_id .. "]: " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

-- ============================================================================
-- Public API - vim.loop timers
-- ============================================================================

--- Create a new vim.loop timer with automatic cleanup
--- @param callback function Timer callback
--- @param timeout number Timeout in milliseconds
--- @param repeat_interval number|nil Repeat interval (0 for one-shot)
--- @param timer_id string|nil Optional timer ID for tracking
--- @return table timer Timer handle
--- @return string id Timer ID
function M.create_timer(callback, timeout, repeat_interval, timer_id)
  timer_id = timer_id or generate_timer_id()
  repeat_interval = repeat_interval or 0

  local timer = vim.loop.new_timer()
  if not timer then
    vim.notify("Failed to create timer: " .. timer_id, vim.log.levels.ERROR)
    return nil, nil
  end

  local wrapped_callback = wrap_callback(callback, timer_id)

  active_timers[timer_id] = {
    timer = timer,
    callback = callback,
    timeout = timeout,
    repeat_interval = repeat_interval,
  }

  timer:start(timeout, repeat_interval, vim.schedule_wrap(wrapped_callback))

  total_timers_created = total_timers_created + 1

  return timer, timer_id
end

--- Stop and cleanup a vim.loop timer
--- @param timer_id string Timer ID
function M.stop_timer(timer_id)
  local timer_data = active_timers[timer_id]
  if not timer_data then
    return
  end

  local timer = timer_data.timer
  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
  end

  active_timers[timer_id] = nil
end

--- Check if timer is active
--- @param timer_id string Timer ID
--- @return boolean
function M.is_timer_active(timer_id)
  return active_timers[timer_id] ~= nil
end

-- ============================================================================
-- Public API - vim.fn.timer_start timers
-- ============================================================================

--- Create a vim.fn.timer_start timer with automatic cleanup
--- @param callback function Timer callback
--- @param delay number Delay in milliseconds
--- @param timer_id string|nil Optional timer ID for tracking
--- @return number|nil timer_handle Timer handle
--- @return string|nil id Timer ID
function M.create_vim_timer(callback, delay, timer_id)
  timer_id = timer_id or generate_timer_id()

  local wrapped_callback = wrap_callback(function()
    callback()
    active_vim_timers[timer_id] = nil
  end, timer_id)

  local timer_handle = vim.fn.timer_start(delay, wrapped_callback)

  if timer_handle == -1 then
    vim.notify("Failed to create vim timer: " .. timer_id, vim.log.levels.ERROR)
    return nil, nil
  end

  active_vim_timers[timer_id] = {
    handle = timer_handle,
    callback = callback,
    delay = delay,
  }

  total_timers_created = total_timers_created + 1

  return timer_handle, timer_id
end

--- Stop a vim.fn.timer_start timer
--- @param timer_id string Timer ID
function M.stop_vim_timer(timer_id)
  local timer_data = active_vim_timers[timer_id]
  if not timer_data then
    return
  end

  pcall(vim.fn.timer_stop, timer_data.handle)
  active_vim_timers[timer_id] = nil
end

--- Check if vim timer is active
--- @param timer_id string Timer ID
--- @return boolean
function M.is_vim_timer_active(timer_id)
  return active_vim_timers[timer_id] ~= nil
end

-- ============================================================================
-- Cleanup Functions
-- ============================================================================

--- Stop all active timers
function M.stop_all_timers()
  for timer_id, _ in pairs(active_timers) do
    M.stop_timer(timer_id)
  end

  for timer_id, _ in pairs(active_vim_timers) do
    M.stop_vim_timer(timer_id)
  end
end

--- Get count of active timers
--- @return number loop_timers Number of vim.loop timers
--- @return number vim_timers Number of vim.fn timers
function M.get_timer_count()
  local loop_count = 0
  local vim_count = 0

  for _, _ in pairs(active_timers) do
    loop_count = loop_count + 1
  end

  for _, _ in pairs(active_vim_timers) do
    vim_count = vim_count + 1
  end

  return loop_count, vim_count
end

--- Get timer statistics for debugging
--- @return table stats Timer statistics
function M.get_stats()
  return {
    loop_timers = vim.tbl_keys(active_timers),
    vim_timers = vim.tbl_keys(active_vim_timers),
    total_created = total_timers_created,
  }
end

--- Reset timer manager state (for testing)
function M.reset()
  M.stop_all_timers()
  timer_id_counter = 0
  total_timers_created = 0
end

-- ============================================================================
-- Autocmd Setup
-- ============================================================================

--- Setup automatic timer cleanup on Neovim exit
function M.setup_cleanup()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("YodaTimerCleanup", { clear = true }),
    desc = "Cleanup all active timers before Neovim exits",
    callback = function()
      M.stop_all_timers()
    end,
  })
end

return M
