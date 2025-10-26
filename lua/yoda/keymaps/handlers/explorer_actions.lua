local win_utils = require("yoda.window_utils")
local M = {}

function M.toggle_with_opencode()
  local opencode_win = win_utils.find_opencode()
  local explorer_win, _ = win_utils.find_snacks_explorer()

  if explorer_win then
    pcall(vim.api.nvim_win_close, explorer_win, true)

    if opencode_win and vim.api.nvim_win_is_valid(opencode_win) then
      vim.api.nvim_win_set_width(opencode_win, 120)
    end
  else
    local ok = pcall(function()
      require("snacks").explorer.open()
    end)

    if ok and opencode_win and vim.api.nvim_win_is_valid(opencode_win) then
      vim.api.nvim_win_set_width(opencode_win, 80)
    end
  end
end

function M.with_auto_save(operation_fn)
  return function(...)
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      opencode_integration.save_all_buffers()
    end

    operation_fn(...)
  end
end

function M.toggle_opencode_with_insert()
  local OPENCODE_STARTUP_DELAY_MS = 100
  local win, _ = win_utils.find_opencode()

  if win then
    vim.api.nvim_set_current_win(win)
    vim.schedule(function()
      vim.cmd("startinsert")
    end)
  else
    require("opencode").toggle()
    vim.defer_fn(function()
      local new_win, _ = win_utils.find_opencode()
      if new_win then
        vim.api.nvim_set_current_win(new_win)
        vim.cmd("startinsert")
      end
    end, OPENCODE_STARTUP_DELAY_MS)
  end
end

function M.return_from_opencode()
  if vim.fn.mode() == "i" then
    vim.cmd("stopinsert")
  end

  local current_win = vim.api.nvim_get_current_win()
  local windows = vim.api.nvim_list_wins()

  for _, win in ipairs(windows) do
    if win ~= current_win then
      local buf = vim.api.nvim_win_get_buf(win)
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if not buf_name:match("[Oo]pen[Cc]ode") and not buf_name:match("^$") and vim.bo[buf].buftype == "" then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end

  vim.cmd("wincmd p")
end

function M.smart_escape_opencode()
  local buf_name = vim.api.nvim_buf_get_name(0)

  if buf_name:match("[Oo]pen[Cc]ode") then
    vim.cmd("stopinsert")
    vim.schedule(function()
      local windows = vim.api.nvim_list_wins()
      for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if not name:match("[Oo]pen[Cc]ode") and vim.bo[buf].buftype == "" then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
      vim.cmd("wincmd p")
    end)
  else
    vim.cmd("stopinsert")
  end
end

return M
