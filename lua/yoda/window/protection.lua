-- lua/yoda/window/protection.lua
-- Window protection utilities to prevent unwanted buffer overwrites

local M = {}

local win_utils = require("yoda.window_utils")
local notify = require("yoda.adapters.notification")

-- Cache for protected windows
local protected_windows = {}

--- Check if window is protected (explorer, opencode, etc.)
--- @param win number Window handle
--- @return boolean is_protected
local function is_protected_window(win)
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.bo[buf].filetype
  local buf_name = vim.api.nvim_buf_get_name(buf)

  -- Check for protected filetypes
  local protected_filetypes = {
    "snacks-explorer",
    "opencode",
    "alpha",
    "trouble",
    "aerial",
  }

  for _, protected_ft in ipairs(protected_filetypes) do
    if ft == protected_ft or ft:match(protected_ft) then
      return true
    end
  end

  -- Check for protected buffer names
  if buf_name:match("[Oo]pencode") or buf_name:match("snacks") or buf_name:match("Trouble") then
    return true
  end

  return false
end

--- Find the best main editing window for a buffer
--- @param exclude_win number|nil Window to exclude from search
--- @return number|nil main_win Window handle for main editing area
local function find_main_editing_window(exclude_win)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= exclude_win and vim.api.nvim_win_is_valid(win) then
      -- Skip floating windows
      local config = vim.api.nvim_win_get_config(win)
      if config.relative == "" then
        -- Skip protected windows
        if not is_protected_window(win) then
          return win
        end
      end
    end
  end
  return nil
end

--- Create a new main editing window
--- @return number new_win New window handle
local function create_main_editing_window()
  -- Try to split from explorer window if available
  local explorer_win = win_utils.find_snacks_explorer()
  if explorer_win then
    vim.api.nvim_set_current_win(explorer_win)
    vim.cmd("rightbelow vsplit")
    return vim.api.nvim_get_current_win()
  end

  -- Fallback to creating a split from current window
  vim.cmd("vsplit")
  return vim.api.nvim_get_current_win()
end

--- Redirect buffer from protected window to appropriate editing window
--- @param buf number Buffer handle
--- @param protected_win number Protected window that buffer shouldn't enter
--- @return boolean success Whether redirection was successful
function M.redirect_buffer_from_protected_window(buf, protected_win)
  -- Input validation
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(protected_win) then
    return false
  end

  -- Don't redirect if buffer belongs in protected window
  local ft = vim.bo[buf].filetype
  local bt = vim.bo[buf].buftype
  if ft == "snacks-explorer" or ft == "opencode" or ft == "alpha" or bt ~= "" then
    return true -- Allow it to stay
  end

  -- Find or create main editing window
  local main_win = find_main_editing_window(protected_win)
  if not main_win then
    main_win = create_main_editing_window()
  end

  -- Redirect buffer to main window
  local ok = pcall(vim.api.nvim_win_set_buf, main_win, buf)
  if ok then
    vim.api.nvim_set_current_win(main_win)
    return true
  end

  return false
end

--- Protect window from buffer overwrites
--- @param win number Window handle to protect
--- @param protection_type string Type of protection ("explorer", "opencode", etc.)
function M.protect_window(win, protection_type)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  protected_windows[win] = {
    type = protection_type,
    created_at = vim.loop.hrtime(),
  }

  -- Set window options for protection
  local ok, _ = pcall(function()
    vim.api.nvim_win_set_option(win, "winfixwidth", true)
    vim.api.nvim_win_set_option(win, "winfixheight", true)
  end)

  if not ok then
    protected_windows[win] = nil
  end
end

--- Remove protection from window
--- @param win number Window handle
function M.unprotect_window(win)
  protected_windows[win] = nil
end

--- Check if buffer switch should be allowed
--- @param target_win number Target window for buffer
--- @param buf number Buffer to switch to
--- @return boolean allowed Whether switch should be allowed
function M.is_buffer_switch_allowed(target_win, buf)
  if not vim.api.nvim_win_is_valid(target_win) or not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  -- Always allow if window is not protected
  if not is_protected_window(target_win) then
    return true
  end

  -- Check if buffer is appropriate for protected window
  local ft = vim.bo[buf].filetype
  local bt = vim.bo[buf].buftype
  local target_buf = vim.api.nvim_win_get_buf(target_win)
  local target_ft = vim.bo[target_buf].filetype

  -- Allow same filetype switches
  if ft == target_ft then
    return true
  end

  -- Allow special buffer types in their respective windows
  if (target_ft == "snacks-explorer" and ft == "snacks-explorer") or (target_ft == "opencode" and ft == "opencode") then
    return true
  end

  return false
end

--- Setup window protection autocmds
--- @param autocmd function vim.api.nvim_create_autocmd
--- @param augroup function vim.api.nvim_create_augroup
function M.setup_autocmds(autocmd, augroup)
  -- Protect against unwanted buffer switches
  autocmd("BufWinEnter", {
    group = augroup("YodaWindowProtection", { clear = true }),
    desc = "Protect special windows from buffer overwrites",
    callback = function(args)
      local buf = args.buf
      local win = vim.api.nvim_get_current_win()

      -- Skip if not a regular file buffer
      local ft = vim.bo[buf].filetype
      local bt = vim.bo[buf].buftype
      if bt ~= "" or ft == "" or ft == "alpha" then
        return
      end

      -- Check if current window is protected
      if is_protected_window(win) then
        -- Redirect buffer to appropriate window
        if not M.is_buffer_switch_allowed(win, buf) then
          vim.schedule(function()
            M.redirect_buffer_from_protected_window(buf, win)
          end)
        end
      end
    end,
  })

  -- Clean up protection cache when windows are closed
  autocmd("WinClosed", {
    group = augroup("YodaWindowProtectionCleanup", { clear = true }),
    desc = "Clean up window protection cache",
    callback = function(args)
      local win = tonumber(args.match)
      if win then
        M.unprotect_window(win)
      end
    end,
  })
end

return M
