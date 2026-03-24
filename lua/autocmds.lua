local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Relative line numbers: show absolute numbers when a window loses focus or
-- the cursor enters the command line — relative numbers are only meaningful
-- when navigating in the current buffer.
local line_numbers_group = augroup("YodaToggleLineNumbers", { clear = true })
autocmd({ "BufEnter", "FocusGained", "CmdlineLeave", "WinEnter" }, {
  group = line_numbers_group,
  desc = "Enable relative line numbers",
  callback = function()
    if vim.wo.nu and not vim.startswith(vim.api.nvim_get_mode().mode, "i") then
      vim.wo.relativenumber = true
    end
  end,
})
autocmd({ "BufLeave", "FocusLost", "CmdlineEnter", "WinLeave" }, {
  group = line_numbers_group,
  desc = "Disable relative line numbers",
  callback = function(args)
    if vim.wo.nu then
      vim.wo.relativenumber = false
    end
    if args.event == "CmdlineEnter" then
      if not vim.tbl_contains({ "@", "-" }, vim.v.event.cmdtype) then
        vim.cmd.redraw()
      end
    end
  end,
})

-- Auto-reload files changed outside Neovim. The getcmdwintype guard prevents
-- checktime from firing inside the command-line window where it is a no-op
-- and can produce spurious errors.
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = augroup("YodaChecktime", { clear = true }),
  desc = "Reload files changed outside Neovim",
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd.checktime()
    end
  end,
})

-- Remove trailing whitespace on save, but only for buffers without a conform
-- formatter — those formatters already handle whitespace and run after this
-- autocmd would fire, making the regex redundant.
autocmd("BufWritePre", {
  group = augroup("YodaTrimWhitespace", { clear = true }),
  pattern = "*",
  desc = "Remove trailing whitespace before saving (skipped when conform formatter present)",
  callback = function()
    local ok, conform = pcall(require, "conform")
    if ok and #conform.list_formatters(0) > 0 then
      return
    end
    vim.cmd([[%s/\s\+$//e]])
  end,
})

-- Close ephemeral buffer types with just `q` instead of `:quit`.
autocmd("FileType", {
  group = augroup("YodaCloseWithQ", { clear = true }),
  desc = "Close ephemeral buffers with <q>",
  pattern = { "help", "man", "qf", "scratch", "git" },
  callback = function(args)
    -- For help buffers only bind q when the buffer is not modifiable
    -- (i.e. it is a rendered help page, not an editable scratch buffer)
    if args.match ~= "help" or not vim.bo[args.buf].modifiable then
      vim.keymap.set("n", "q", "<cmd>quit<cr>", { buffer = args.buf, desc = "Close window" })
    end
  end,
})

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
