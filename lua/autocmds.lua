local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ============================================================================
-- Editor Behavior
-- ============================================================================

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
-- CursorHoldI intentionally excluded: with updatetime=250 it fired every 250ms
-- in insert mode, running checktime (file stat I/O) continuously while typing.
-- FocusGained is intentionally excluded here: git_refresh.lua owns that event
-- and already calls checktime before refreshing git signs, avoiding double I/O.
autocmd({ "BufEnter", "CursorHold" }, {
  group = augroup("YodaChecktime", { clear = true }),
  desc = "Reload files changed outside Neovim",
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd.checktime()
    end
  end,
})

-- Briefly highlight yanked text. Skipped for large buffers (>1000 lines)
-- where the highlight scan would be perceptible.
autocmd("TextYankPost", {
  group = augroup("YodaHighlightYank", { clear = true }),
  desc = "Highlight yanked text briefly",
  callback = function()
    if vim.api.nvim_buf_line_count(0) < 1000 then
      vim.hl.on_yank({ timeout = 50 })
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
    if not vim.bo.modifiable then
      return
    end
    local ok, conform = pcall(require, "conform")
    if ok and #conform.list_formatters(0) > 0 then
      return
    end
    vim.cmd([[%s/\s\+$//e]])
  end,
})

-- Re-apply the ColorColumn highlight after every colorscheme change so it
-- survives theme switches. Scheduling defers until after other highlights
-- settle. The ColorScheme event also fires at startup when lazy.nvim applies
-- the initial theme, so no separate immediate call is needed.
autocmd("ColorScheme", {
  group = augroup("ColorColumnPersistent", { clear = true }),
  pattern = "*",
  desc = "Keep ColorColumn highlight visible after theme changes",
  callback = function()
    vim.schedule(function()
      vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2a2a37" })
    end)
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

-- ============================================================================
-- Module Delegations
-- ============================================================================

-- Modules that register their own autocmds via a setup call. Kept here so
-- all autocmd registration is visible in one place.
-- Loaded individually so one failure doesn't cascade to the rest.
local ok_fd, filetype_detection = pcall(require, "yoda.filetype.detection")
if not ok_fd then
  vim.notify("[yoda] Failed to load yoda.filetype.detection: " .. tostring(filetype_detection), vim.log.levels.WARN)
end

local ok_gr, git_refresh = pcall(require, "yoda.git_refresh")
if not ok_gr then
  vim.notify("[yoda] Failed to load yoda.git_refresh: " .. tostring(git_refresh), vim.log.levels.WARN)
end

-- Register VimLeavePre cleanup for all tracked timers.
-- Lives here because setup_cleanup() is just registering an autocmd.
local ok_timer, timer_manager = pcall(require, "yoda.timer_manager")
if ok_timer then
  if timer_manager.setup_cleanup then
    timer_manager.setup_cleanup()
  end
else
  vim.notify("[yoda] Failed to load yoda.timer_manager: " .. tostring(timer_manager), vim.log.levels.WARN)
end

-- Register VimLeavePre ShaDa write to prevent "file already exists" warnings.
local ok_session, session = pcall(require, "yoda.session")
if ok_session then
  session.setup()
else
  vim.notify("[yoda] Failed to load yoda.session: " .. tostring(session), vim.log.levels.WARN)
end

if ok_fd then
  filetype_detection.setup_all(autocmd, augroup)
end
if ok_gr then
  git_refresh.setup_autocmds(autocmd, augroup)
end

-- ============================================================================
-- Buffer
-- ============================================================================

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

-- ============================================================================
-- Window
-- ============================================================================

local RESIZE_DEBOUNCE_DELAY = 300

autocmd("VimResized", {
  group = augroup("YodaResizeSplits", { clear = true }),
  desc = "Resize splits equally when Vim is resized",
  callback = function()
    local ok, timer_mgr = pcall(require, "yoda.timer_manager")
    if not ok then
      return
    end
    local timer_id = "vim_resized"
    if timer_mgr.is_vim_timer_active(timer_id) then
      timer_mgr.stop_vim_timer(timer_id)
    end

    timer_mgr.create_vim_timer(function()
      pcall(vim.cmd, "wincmd =")
    end, RESIZE_DEBOUNCE_DELAY, timer_id)
  end,
})

-- ============================================================================
-- Filetype
-- ============================================================================

autocmd("FileType", {
  group = augroup("YodaFileTypes", { clear = true }),
  desc = "Apply filetype-specific settings",
  callback = function()
    local ok, settings = pcall(require, "yoda.filetype.settings")
    if not ok then
      vim.notify("[yoda] Failed to load yoda.filetype.settings: " .. tostring(settings), vim.log.levels.WARN)
      return
    end
    settings.apply(vim.bo.filetype)
  end,
})
