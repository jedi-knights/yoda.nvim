-- lua/yoda/window_utils.lua
-- Window finding and management utilities
-- Eliminates duplicate window search patterns across codebase

local M = {}

--- Find window by matching function
--- @param match_fn function Function that receives (win, buf, buf_name, filetype) and returns boolean
--- @return number|nil, number|nil Window handle and buffer handle, or nil if not found
function M.find_window(match_fn)
  -- Input validation (assertive programming)
  if type(match_fn) ~= "function" then
    vim.notify("find_window: match_fn must be a function, got " .. type(match_fn), vim.log.levels.ERROR, { title = "Window Utils Error" })
    return nil, nil
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local ft = vim.bo[buf].filetype

    if match_fn(win, buf, buf_name, ft) then
      return win, buf
    end
  end
  return nil, nil
end

--- Find all windows matching a function
--- @param match_fn function Function that receives (win, buf, buf_name, filetype) and returns boolean
--- @return table Array of {win = number, buf = number} pairs
function M.find_all_windows(match_fn)
  -- Input validation (assertive programming)
  if type(match_fn) ~= "function" then
    vim.notify("find_all_windows: match_fn must be a function, got " .. type(match_fn), vim.log.levels.ERROR, { title = "Window Utils Error" })
    return {}
  end

  local matches = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local ft = vim.bo[buf].filetype

    if match_fn(win, buf, buf_name, ft) then
      table.insert(matches, { win = win, buf = buf })
    end
  end
  return matches
end

--- Focus a window by matching function
--- @param match_fn function Function that receives (win, buf, buf_name, filetype) and returns boolean
--- @return boolean True if window was found and focused
function M.focus_window(match_fn)
  -- Input validation (assertive programming)
  if type(match_fn) ~= "function" then
    vim.notify("focus_window: match_fn must be a function, got " .. type(match_fn), vim.log.levels.ERROR, { title = "Window Utils Error" })
    return false
  end

  local win, _ = M.find_window(match_fn)
  if win then
    vim.api.nvim_set_current_win(win)
    return true
  end
  return false
end

--- Close windows matching a function
--- @param match_fn function Function that receives (win, buf, buf_name, filetype) and returns boolean
--- @param force boolean|nil Force close even if modified
--- @return number Number of windows closed
function M.close_windows(match_fn, force)
  -- Input validation (assertive programming)
  if type(match_fn) ~= "function" then
    vim.notify("close_windows: match_fn must be a function, got " .. type(match_fn), vim.log.levels.ERROR, { title = "Window Utils Error" })
    return 0
  end

  local windows = M.find_all_windows(match_fn)
  local count = 0

  for _, win_data in ipairs(windows) do
    local ok = pcall(vim.api.nvim_win_close, win_data.win, force or false)
    if ok then
      count = count + 1
    end
  end

  return count
end

-- ============================================================================
-- COMMON WINDOW MATCHERS (convenience functions)
-- ============================================================================

--- Find Snacks Explorer window
--- @return number|nil, number|nil Window handle and buffer handle
function M.find_snacks_explorer()
  return M.find_window(function(win, buf, buf_name, ft)
    return ft:match("snacks_") or ft == "snacks" or buf_name:match("snacks")
  end)
end

--- Find OpenCode window
--- @return number|nil, number|nil Window handle and buffer handle
function M.find_opencode()
  return M.find_window(function(win, buf, buf_name, ft)
    return buf_name:match("[Oo]pencode") or ft:match("opencode")
  end)
end

--- Find Trouble window
--- @return number|nil, number|nil Window handle and buffer handle
function M.find_trouble()
  return M.find_window(function(win, buf, buf_name, ft)
    return buf_name:match("Trouble") or ft:match("trouble")
  end)
end

--- Find window by buffer name pattern
--- @param pattern string Lua pattern to match against buffer name
--- @return number|nil, number|nil Window handle and buffer handle
function M.find_by_name(pattern)
  -- Input validation
  if type(pattern) ~= "string" or pattern == "" then
    vim.notify("find_by_name: pattern must be a non-empty string", vim.log.levels.ERROR, { title = "Window Utils Error" })
    return nil, nil
  end

  return M.find_window(function(win, buf, buf_name, ft)
    return buf_name:match(pattern)
  end)
end

--- Find window by filetype
--- @param filetype string Filetype to match
--- @return number|nil, number|nil Window handle and buffer handle
function M.find_by_filetype(filetype)
  -- Input validation
  if type(filetype) ~= "string" or filetype == "" then
    vim.notify("find_by_filetype: filetype must be a non-empty string", vim.log.levels.ERROR, { title = "Window Utils Error" })
    return nil, nil
  end

  return M.find_window(function(win, buf, buf_name, ft)
    return ft == filetype
  end)
end

return M
