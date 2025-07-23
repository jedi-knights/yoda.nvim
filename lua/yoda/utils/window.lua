-- lua/yoda/utils/window.lua
-- Window and buffer management utilities

local M = {}

-- Find window by filetype
function M.find_window_by_filetype(filetype)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == filetype then
      return win, buf
    end
  end
  return nil, nil
end

-- Find window by buffer name pattern
function M.find_window_by_buffer_name(pattern)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:match(pattern) then
      return win, buf
    end
  end
  return nil, nil
end

-- Close window by filetype
function M.close_window_by_filetype(filetype)
  local win = M.find_window_by_filetype(filetype)
  if win then
    vim.api.nvim_win_close(win, true)
    return true
  end
  return false
end

-- Focus window by filetype
function M.focus_window_by_filetype(filetype)
  local win = M.find_window_by_filetype(filetype)
  if win then
    vim.api.nvim_set_current_win(win)
    return true
  end
  return false
end

-- Toggle window by filetype
function M.toggle_window_by_filetype(filetype, open_fn)
  local win = M.find_window_by_filetype(filetype)
  if win then
    vim.api.nvim_win_close(win, true)
    return false
  else
    if open_fn then
      open_fn()
    end
    return true
  end
end

-- Get current buffer info
function M.get_current_buffer_info()
  local buf = vim.api.nvim_get_current_buf()
  return {
    buf = buf,
    name = vim.api.nvim_buf_get_name(buf),
    filetype = vim.bo[buf].filetype,
    modified = vim.bo[buf].modified,
  }
end

-- Get window info
function M.get_window_info(win)
  win = win or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  return {
    win = win,
    buf = buf,
    name = vim.api.nvim_buf_get_name(buf),
    filetype = vim.bo[buf].filetype,
    modified = vim.bo[buf].modified,
  }
end

-- Create floating window
function M.create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or 80
  local height = opts.height or 20
  local row = opts.row or math.floor((vim.o.lines - height) / 2)
  local col = opts.col or math.floor((vim.o.columns - width) / 2)
  
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = opts.border or "rounded",
    title = opts.title,
    title_pos = opts.title_pos or "center",
  })
  
  return win, buf
end

-- Standard floating window options
function M.floating_window_opts(opts)
  opts = opts or {}
  return {
    relative = "editor",
    width = opts.width or 0.8,
    height = opts.height or 0.8,
    row = opts.row or 0.1,
    col = opts.col or 0.1,
    style = "minimal",
    border = opts.border or "rounded",
    title = opts.title,
    title_pos = opts.title_pos or "center",
  }
end

return M 