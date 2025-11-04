-- lua/yoda/window/layout_manager.lua
-- Window layout management for multi-pane setups (Explorer + Editor + OpenCode)

local M = {}

local win_utils = require("yoda.window_utils")

-- ============================================================================
-- Private Functions
-- ============================================================================

--- Check if buffer should skip layout management
--- @param buf number Buffer handle
--- @param filetype string Buffer filetype
--- @param bufname string Buffer name
--- @return boolean
local function should_skip_buffer(buf, filetype, bufname)
  -- Skip special buffers
  if filetype == "snacks-explorer" or filetype == "opencode" or filetype == "alpha" or bufname == "" then
    return true
  end

  -- Skip if this is not a real file buffer
  if vim.bo[buf].buftype ~= "" then
    return true
  end

  return false
end

--- Get list of regular (non-floating) windows
--- @return table List of window handles
local function get_regular_windows()
  local regular_wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      table.insert(regular_wins, win)
    end
  end
  return regular_wins
end

--- Find or create main edit window between explorer and OpenCode
--- @param explorer_win number Explorer window handle
--- @param opencode_win number OpenCode window handle
--- @param regular_wins table List of regular window handles
--- @return number|nil Main window handle
local function find_or_create_main_window(explorer_win, opencode_win, regular_wins)
  -- Try to find existing main window
  for _, win in ipairs(regular_wins) do
    if win ~= explorer_win and win ~= opencode_win then
      return win
    end
  end

  -- Create new window between explorer and OpenCode
  vim.api.nvim_set_current_win(explorer_win)
  vim.cmd("rightbelow vsplit")
  return vim.api.nvim_get_current_win()
end

-- ============================================================================
-- Public API
-- ============================================================================

--- Handle window layout when opening a file with Explorer and OpenCode
--- Ensures files open in the middle pane, not in OpenCode window
--- @param buf number Buffer handle
function M.handle_buf_win_enter(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local bufname = vim.api.nvim_buf_get_name(buf)
  local filetype = vim.bo[buf].filetype

  if should_skip_buffer(buf, filetype, bufname) then
    return
  end

  -- Don't manage layout - let Snacks explorer handle it naturally
  -- This module is DISABLED to prevent duplicate window creation
  return
end

--- Setup window layout management autocmds
--- @param autocmd function vim.api.nvim_create_autocmd
--- @param augroup function vim.api.nvim_create_augroup
function M.setup_autocmds(autocmd, augroup)
  autocmd("BufWinEnter", {
    group = augroup("YodaWindowLayout", { clear = true }),
    desc = "Ensure proper window placement with Snacks explorer and OpenCode",
    callback = function(args)
      M.handle_buf_win_enter(args.buf)
    end,
  })
end

return M
