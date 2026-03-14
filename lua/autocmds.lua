local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Modules needed immediately at load time to register their own autocmds
local filetype_detection = require("yoda.filetype.detection")
local performance_autocmds = require("yoda.performance.autocmds")
local git_refresh = require("yoda.git_refresh")

local RESIZE_DEBOUNCE_DELAY = 300
local ALPHA_STARTUP_DELAY = 200

filetype_detection.setup_all(autocmd, augroup)

autocmd("BufReadPre", {
  group = augroup("YodaLargeFile", { clear = true }),
  desc = "Detect and optimize for large files",
  callback = function(args)
    require("yoda.large_file").on_buf_read(args.buf)
  end,
})

performance_autocmds.setup_all(autocmd, augroup)

-- Setup centralized git refresh autocmds
git_refresh.setup_autocmds(autocmd, augroup)

autocmd("BufEnter", {
  group = augroup("YodaAlphaClose", { clear = true }),
  desc = "Close alpha dashboard when opening real files",
  callback = function(args)
    local alpha_manager = require("yoda.ui.alpha_manager")
    if not alpha_manager.has_alpha_buffer() then
      return
    end

    local buf = args.buf
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    -- Close alpha if this is a real file buffer, then self-disable this autocmd —
    -- once alpha is gone it can never re-appear, so the BufEnter check is moot.
    if require("yoda.buffer.type_cache").is_real_file_buffer(buf) then
      vim.schedule(function()
        alpha_manager.close_all_alpha_buffers()
        pcall(vim.api.nvim_del_augroup_by_name, "YodaAlphaClose")
      end)
    end
  end,
})

autocmd("VimEnter", {
  group = augroup("YodaStartup", { clear = true }),
  desc = "Show alpha dashboard on startup if no files",
  callback = function()
    if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
    end

    vim.defer_fn(function()
      local alpha_manager = require("yoda.ui.alpha_manager")
      if alpha_manager.should_show_alpha(require("yoda.buffer.state_checker").is_buffer_empty) then
        alpha_manager.show_alpha_dashboard()
      end
    end, ALPHA_STARTUP_DELAY)
  end,
})

autocmd("User", {
  pattern = "VeryLazy",
  group = augroup("YodaExplorerStartup", { clear = true }),
  desc = "Open Snacks explorer on startup",
  callback = function()
    vim.defer_fn(function()
      local ok, snacks = pcall(require, "snacks")
      if ok and snacks.explorer and snacks.explorer.open then
        pcall(snacks.explorer.open)
      end
    end, 100)
  end,
})

autocmd("BufReadPost", {
  group = augroup("YodaRestoreCursor", { clear = true }),
  desc = "Restore cursor to last position",
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)

    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("VimResized", {
  group = augroup("YodaResizeSplits", { clear = true }),
  desc = "Resize splits equally when Vim is resized",
  callback = function()
    local timer_manager = require("yoda.timer_manager")
    local timer_id = "vim_resized"
    if timer_manager.is_vim_timer_active(timer_id) then
      timer_manager.stop_vim_timer(timer_id)
    end

    timer_manager.create_vim_timer(function()
      pcall(vim.cmd, "wincmd =")
    end, RESIZE_DEBOUNCE_DELAY, timer_id)
  end,
})

autocmd("FileType", {
  group = augroup("YodaFileTypes", { clear = true }),
  desc = "Apply filetype-specific settings",
  callback = function()
    require("yoda.filetype.settings").apply(vim.bo.filetype)
  end,
})

vim.api.nvim_create_user_command("Bd", function(opts)
  local buf = vim.api.nvim_get_current_buf()
  local window_protection = require("yoda-window.protection")

  if vim.bo[buf].buftype ~= "" then
    vim.cmd("bdelete" .. (opts.bang and "!" or ""))
    return
  end

  local windows_with_buf = vim.fn.win_findbuf(buf)

  local normal_buffers = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and b ~= buf and vim.bo[b].buflisted and vim.bo[b].buftype == "" then
      table.insert(normal_buffers, b)
    end
  end

  if #normal_buffers > 0 then
    local alt = vim.fn.bufnr("#")
    local target_buf

    if alt ~= -1 and alt ~= buf and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buftype == "" then
      target_buf = alt
    else
      target_buf = normal_buffers[1]
    end

    for _, win in ipairs(windows_with_buf) do
      if vim.api.nvim_win_is_valid(win) then
        if window_protection.is_buffer_switch_allowed(win, target_buf) then
          pcall(vim.api.nvim_win_set_buf, win, target_buf)
        end
      end
    end
  end

  local delete_cmd = "bdelete" .. (opts.bang and "!" or "") .. " " .. buf

  local ok_delete, err = pcall(vim.cmd, delete_cmd)
  if not ok_delete then
    require("yoda-adapters.notification").notify("Buffer delete failed: " .. tostring(err), "error")
  end
end, { bang = true, desc = "Smart buffer delete that preserves window layout" })

vim.api.nvim_create_user_command("BD", function(opts)
  vim.cmd("Bd" .. (opts.bang and "!" or ""))
end, { bang = true, desc = "Alias for Bd" })

vim.cmd([[
  cnoreabbrev <expr> bd getcmdtype() == ':' && getcmdline() == 'bd' ? 'Bd' : 'bd'
  cnoreabbrev <expr> bdelete getcmdtype() == ':' && getcmdline() == 'bdelete' ? 'Bd' : 'bdelete'
]])
