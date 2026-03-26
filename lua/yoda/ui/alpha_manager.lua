-- lua/yoda/ui/alpha_manager.lua
-- Alpha dashboard management

local M = {}

local notify = require("yoda-adapters.notification")
local win_utils = require("yoda-window.utils")

local ALPHA_CONFIG = {
  HEADER_PADDING = 2,
  BUTTON_PADDING = 2,
  FOOTER_PADDING = 1,
}

-- creation_in_progress guards against re-entrant alpha.start calls.
-- has_startup_files is set once at startup from vim.fn.argc().
local alpha_cache = {
  has_startup_files = nil,
  creation_in_progress = false,
}

--- Invalidate buffer caches (kept for API compatibility with start_alpha_dashboard)
function M.invalidate_cache()
  -- Buffer scans in has_alpha_buffer/count_normal_buffers are always fresh;
  -- no TTL cache to clear.
end

--- Check if alpha dashboard is already open
--- @return boolean
function M.has_alpha_buffer()
  if alpha_cache.creation_in_progress then
    return true
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local bo = vim.bo[buf]
      if bo.buflisted and bo.filetype == "alpha" then
        return true
      end
    end
  end
  return false
end

--- Check if files were opened at startup (cached once at startup)
--- @return boolean
function M.has_startup_files()
  if alpha_cache.has_startup_files == nil then
    alpha_cache.has_startup_files = vim.fn.argc() ~= 0
  end
  return alpha_cache.has_startup_files
end

--- Count normal (non-alpha, non-empty) listed buffers
--- @return number
function M.count_normal_buffers()
  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local bo = vim.bo[buf]
      if bo.buflisted then
        local ft = bo.filetype
        if ft ~= "alpha" and ft ~= "" then
          count = count + 1
        end
      end
    end
  end
  return count
end

--- Check if we're in a state where alpha should be shown
--- @param is_buffer_empty_fn function Function to check if current buffer is empty
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

  if not win or not buf then
    return false
  end

  local current_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(win)

  local ok, alpha = pcall(require, "alpha")
  if ok and alpha and alpha.start then
    local alpha_config = vim.b[buf].alpha_config
    local start_ok, start_err = pcall(alpha.start, false, alpha_config)
    if not start_ok then
      vim.notify("[yoda] Failed to recenter alpha dashboard: " .. tostring(start_err), vim.log.levels.WARN)
    end
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
  if alpha_cache.creation_in_progress then
    return false
  end

  alpha_cache.creation_in_progress = true

  local ok, alpha = pcall(require, "alpha")
  if not ok or not alpha or not alpha.start then
    alpha_cache.creation_in_progress = false
    return false
  end

  local dashboard_ok, dashboard = pcall(require, "alpha.themes.dashboard")
  if not dashboard_ok or not dashboard then
    alpha_cache.creation_in_progress = false
    return false
  end

  local layout_ok, alpha_config = pcall(function()
    return {
      redraw_on_resize = true,
      layout = create_alpha_layout(dashboard),
    }
  end)

  if not layout_ok then
    alpha_cache.creation_in_progress = false
    return false
  end

  local config_ok = pcall(alpha.start, alpha_config)

  vim.schedule(function()
    alpha_cache.creation_in_progress = false
    M.invalidate_cache()
  end)

  return config_ok
end

--- Attempt to show alpha dashboard with error notification
function M.show_alpha_dashboard()
  local success = M.start_alpha_dashboard()
  if not success then
    notify.notify("Alpha dashboard failed to start", "warn")
  end
end

return M
