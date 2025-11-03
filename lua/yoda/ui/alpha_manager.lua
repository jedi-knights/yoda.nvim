-- lua/yoda/ui/alpha_manager.lua
-- Alpha dashboard management - extracted from autocmds.lua for better separation of concerns

local M = {}

-- ============================================================================
-- Dependencies
-- ============================================================================

local notify = require("yoda.adapters.notification")
local win_utils = require("yoda.window_utils")

-- ============================================================================
-- Constants
-- ============================================================================

local ALPHA_CONFIG = {
  HEADER_PADDING = 2,
  BUTTON_PADDING = 2,
  FOOTER_PADDING = 1,
}

-- ============================================================================
-- Private State (Caching for Performance)
-- ============================================================================

local alpha_cache = {
  has_startup_files = nil,
  has_alpha_buffer = nil,
  normal_count = nil,
  last_check_time = 0,
  last_alpha_check_time = 0,
  check_interval = 150,
  alpha_check_interval = 100,
}

-- ============================================================================
-- Cache Management
-- ============================================================================

--- Invalidate buffer caches
function M.invalidate_cache()
  alpha_cache.has_alpha_buffer = nil
  alpha_cache.normal_count = nil
end

-- ============================================================================
-- State Checks
-- ============================================================================

--- Check if alpha dashboard is already open (optimized with caching)
--- @return boolean
function M.has_alpha_buffer()
  local current_time = vim.loop.hrtime() / 1000000

  if alpha_cache.has_alpha_buffer ~= nil and (current_time - alpha_cache.last_alpha_check_time) < alpha_cache.alpha_check_interval then
    return alpha_cache.has_alpha_buffer
  end

  local has_alpha = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].filetype == "alpha" then
      has_alpha = true
      break
    end
  end

  alpha_cache.has_alpha_buffer = has_alpha
  alpha_cache.last_alpha_check_time = current_time

  return has_alpha
end

--- Check if files were opened at startup (cached)
--- @return boolean
function M.has_startup_files()
  if alpha_cache.has_startup_files == nil then
    alpha_cache.has_startup_files = vim.fn.argc() ~= 0
  end
  return alpha_cache.has_startup_files
end

--- Count normal buffers (simplified and cached)
--- @param perf_tracker table|nil Optional performance tracker
--- @return number
function M.count_normal_buffers(perf_tracker)
  local perf_start = vim.loop.hrtime()
  local current_time = perf_start / 1000000

  if alpha_cache.normal_count and (current_time - alpha_cache.last_check_time) < alpha_cache.check_interval then
    if perf_tracker then
      perf_tracker.track_buffer_operation("count_normal_buffers_cached", perf_start)
    end
    return alpha_cache.normal_count
  end

  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      local buf_ft = vim.bo[buf].filetype
      if buf_ft ~= "alpha" and buf_ft ~= "" then
        count = count + 1
      end
    end
  end

  alpha_cache.normal_count = count
  alpha_cache.last_check_time = current_time

  if perf_tracker then
    perf_tracker.track_buffer_operation("count_normal_buffers_full", perf_start)
  end

  return count
end

--- Check if we're in a state where alpha should be shown
--- @param is_buffer_empty_fn function Function to check if buffer is empty
--- @return boolean
function M.should_show_alpha(is_buffer_empty_fn)
  if M.has_startup_files() then
    return false
  end

  if vim.bo.filetype ~= "" then
    return false
  end

  if vim.bo.buftype ~= "" then
    return false
  end

  if not is_buffer_empty_fn() then
    return false
  end

  if M.has_alpha_buffer() then
    return false
  end

  return M.count_normal_buffers() == 0
end

--- Check if filetype should skip alpha display logic
--- @param filetype string File type to check
--- @return boolean true if should skip
function M.should_skip_alpha_for_filetype(filetype)
  local skip_filetypes = {
    "gitcommit",
    "gitrebase",
    "gitconfig",
    "NeogitCommitMessage",
    "NeogitPopup",
    "NeogitStatus",
    "fugitive",
    "fugitiveblame",
    "markdown",
  }

  for _, ft in ipairs(skip_filetypes) do
    if filetype == ft then
      return true
    end
  end

  return false
end

-- ============================================================================
-- Dashboard Operations
-- ============================================================================

--- Close all alpha dashboard buffers
function M.close_all_alpha_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "alpha" then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

--- Recenter alpha dashboard if visible
--- @return boolean true if alpha was recentered
function M.recenter_alpha_dashboard()
  local win, buf = win_utils.find_by_filetype("alpha")

  if not win then
    return false
  end

  local current_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(win)

  local ok, alpha = pcall(require, "alpha")
  if ok and alpha and alpha.start then
    local alpha_config = vim.b[buf].alpha_config
    pcall(alpha.start, false, alpha_config)
  end

  if current_win ~= win and vim.api.nvim_win_is_valid(current_win) then
    vim.api.nvim_set_current_win(current_win)
  end

  return true
end

--- Create alpha dashboard layout configuration
--- @param dashboard table Dashboard theme module
--- @return table Layout configuration
local function create_alpha_layout(dashboard)
  return {
    { type = "padding", val = ALPHA_CONFIG.HEADER_PADDING },
    dashboard.section.header,
    { type = "padding", val = ALPHA_CONFIG.BUTTON_PADDING },
    dashboard.section.buttons,
    { type = "padding", val = ALPHA_CONFIG.FOOTER_PADDING },
    dashboard.section.footer,
  }
end

--- Start the alpha dashboard with proper configuration
--- @return boolean success Whether alpha started successfully
function M.start_alpha_dashboard()
  local ok, alpha = pcall(require, "alpha")
  if not ok or not alpha or not alpha.start then
    return false
  end

  local dashboard_ok, dashboard = pcall(require, "alpha.themes.dashboard")
  if not dashboard_ok or not dashboard then
    return false
  end

  local alpha_config = {
    redraw_on_resize = true,
    layout = create_alpha_layout(dashboard),
  }

  local config_ok = pcall(alpha.start, alpha_config)
  return config_ok
end

--- Attempt to show alpha dashboard with error notification
function M.show_alpha_dashboard()
  local success = M.start_alpha_dashboard()
  if not success then
    notify.notify("Alpha dashboard failed to start", "warn")
  end
end

-- ============================================================================
-- Handler Functions (for autocmds)
-- ============================================================================

--- Handle closing alpha dashboard for real file buffers
--- @param buf number Buffer number
--- @param delay number Delay in milliseconds
--- @param logger table|nil Optional logger
function M.handle_alpha_close_for_real_buffer(buf, delay, logger)
  vim.defer_fn(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      if logger then
        logger.log("Alpha_Close_Skip", { buf = buf, reason = "invalid_buffer" })
      end
      return
    end

    if logger then
      logger.log("Alpha_Close_Check", { buf = buf, delay = delay })
    end

    if not M.has_alpha_buffer() then
      if logger then
        logger.log("Alpha_Close_Skip", { buf = buf, reason = "no_alpha_buffer" })
      end
      return
    end

    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(b) and b ~= buf then
        local ok, ft = pcall(function()
          return vim.bo[b].filetype
        end)

        if ok and ft == "alpha" then
          local is_listed = vim.bo[b].buflisted
          if is_listed then
            if logger then
              logger.log("Alpha_Close_Delete", { buf = b })
            end
            pcall(vim.api.nvim_buf_delete, b, { force = true })
          end
        end
      end
    end
  end, delay)
end

--- Handle alpha dashboard display logic
--- @param buf number Buffer number
--- @param buftype string Buffer type
--- @param filetype string File type
--- @param buflisted boolean Whether buffer is listed
--- @param start_time number Start time for logging
--- @param perf_start_time number Performance tracking start time
--- @param logger table|nil Optional logger
--- @param perf_tracker table|nil Optional performance tracker
--- @param is_buffer_empty_fn function Function to check if buffer is empty
--- @param delay number Delay for showing alpha
function M.handle_alpha_dashboard_display(
  buf,
  buftype,
  filetype,
  buflisted,
  start_time,
  perf_start_time,
  logger,
  perf_tracker,
  is_buffer_empty_fn,
  delay
)
  if filetype == "alpha" then
    if logger then
      logger.log_end("BufEnter", start_time, { action = "alpha_skip" })
    end
    if perf_tracker then
      perf_tracker.track_autocmd("BufEnter", perf_start_time)
    end
    return
  end

  if not buflisted then
    if logger then
      logger.log_end("BufEnter", start_time, { action = "not_listed" })
    end
    if perf_tracker then
      perf_tracker.track_autocmd("BufEnter", perf_start_time)
    end
    return
  end

  if buftype ~= "" then
    if perf_tracker then
      perf_tracker.track_autocmd("BufEnter", perf_start_time)
    end
    return
  end

  if M.should_skip_alpha_for_filetype(filetype) then
    if perf_tracker then
      perf_tracker.track_autocmd("BufEnter", perf_start_time)
    end
    return
  end

  if not M.should_show_alpha(is_buffer_empty_fn) then
    if perf_tracker then
      perf_tracker.track_autocmd("BufEnter", perf_start_time)
    end
    return
  end

  vim.defer_fn(function()
    if M.should_show_alpha(is_buffer_empty_fn) then
      M.show_alpha_dashboard()
    end
  end, delay)

  if perf_tracker then
    perf_tracker.track_autocmd("BufEnter", perf_start_time)
  end
end

return M
