-- lua/autocmds.lua
-- Autocommands configuration for Yoda.nvim

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local large_file = require("yoda.large_file")
local autocmd_logger = require("yoda.autocmd_logger")
local autocmd_perf = require("yoda.autocmd_performance")
local notify = require("yoda.adapters.notification")
local alpha_manager = require("yoda.ui.alpha_manager")
local gitsigns = require("yoda.integrations.gitsigns")
local buffer_state = require("yoda.buffer.state_checker")
local filetype_settings = require("yoda.filetype.settings")
local filetype_detection = require("yoda.filetype.detection")
local layout_manager = require("yoda.window.layout_manager")
local terminal_autocmds = require("yoda.terminal.autocmds")

-- ============================================================================
-- Constants
-- ============================================================================

-- Timing constants (all values in milliseconds)
-- These values are tuned for optimal balance between responsiveness and performance
local DELAYS = {
  ALPHA_STARTUP = 200, -- Delay for alpha dashboard on startup (allows plugins to load)
  ALPHA_BUFFER_CHECK = 100, -- Delay before checking alpha conditions (prevents flicker)
  YANK_HIGHLIGHT = 50, -- Duration for yank highlight (brief visual feedback)
  BUF_ENTER_DEBOUNCE = 50, -- Debounce for BufEnter expensive operations (prevents rapid firing)
  ALPHA_CLOSE = 50, -- Delay for closing alpha dashboard (allows transitions to complete)
  TELESCOPE_CLOSE = 50, -- Delay after telescope closes (allows file to open first)
}

local THRESHOLDS = {
  MAX_LINES_FOR_YANK_HIGHLIGHT = 1000, -- Skip yank highlight for large files
}

-- ============================================================================
-- Helper Functions
-- ============================================================================

--- Create an autocommand with a named group
--- @param events string|table Event(s) to trigger on
--- @param opts table Autocommand options
local function create_autocmd(events, opts)
  opts.group = opts.group or augroup("YodaAutocmd", { clear = true })
  autocmd(events, opts)
end

-- Debounce state for BufEnter handler
local buf_enter_debounce = {}

--- Change to directory if provided as argument
local function handle_directory_argument()
  if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
    vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
  end
end

--- Handle debounced operations for real buffers (OpenCode integration, git signs)
--- @param buf number Buffer number
local function handle_debounced_buffer_operations(buf)
  if buf_enter_debounce[buf] then
    pcall(vim.fn.timer_stop, buf_enter_debounce[buf])
    buf_enter_debounce[buf] = nil
  end

  buf_enter_debounce[buf] = vim.fn.timer_start(DELAYS.BUF_ENTER_DEBOUNCE, function()
    if not vim.api.nvim_buf_is_valid(buf) then
      autocmd_logger.log("Refresh_Skip", { buf = buf, reason = "invalid_buffer" })
      buf_enter_debounce[buf] = nil
      return
    end

    autocmd_logger.log("Refresh_Start", { buf = buf })
    buf_enter_debounce[buf] = nil

    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        if buffer_state.can_reload_buffer() and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
          autocmd_logger.log("Refresh_Buffer", { buf = buf })
          opencode_integration.refresh_buffer(buf)
        end
        autocmd_logger.log("Refresh_GitSigns", { buf = buf })
        opencode_integration.refresh_git_signs()
      end)
    else
      gitsigns.refresh()
    end
  end)
end

--- Handle real buffer enter (files with content)
--- @param buf number Buffer number
--- @param filetype string File type
--- @param start_time number Start time for logging
--- @param perf_start_time number Performance tracking start time
--- @return boolean true if handled
local function handle_real_buffer_enter(buf, filetype, start_time, perf_start_time)
  autocmd_logger.log("BufEnter_REAL_BUFFER", { buf = buf, filetype = filetype })

  alpha_manager.handle_alpha_close_for_real_buffer(buf, DELAYS.ALPHA_CLOSE, autocmd_logger)
  handle_debounced_buffer_operations(buf)

  autocmd_logger.log_end("BufEnter", start_time, { action = "refresh_scheduled" })
  autocmd_perf.track_autocmd("BufEnter", perf_start_time)
  return true
end

-- ============================================================================
-- Filetype Detection
-- ============================================================================

filetype_detection.setup_all(autocmd, augroup)

-- ============================================================================
-- Autocommand Definitions
-- ============================================================================

-- Large File Detection (must be first to run before other expensive operations)
create_autocmd("BufReadPre", {
  group = augroup("YodaLargeFile", { clear = true }),
  desc = "Detect and optimize for large files",
  callback = function(args)
    large_file.on_buf_read(args.buf)
  end,
})

-- Smart Buffer Delete Command
vim.api.nvim_create_user_command("Bd", function(opts)
  local buf = vim.api.nvim_get_current_buf()
  local autocmd_logger = require("yoda.autocmd_logger")

  autocmd_logger.log("Bd_Start", { buf = buf, bang = opts.bang })

  -- Skip special buffers
  if vim.bo[buf].buftype ~= "" then
    autocmd_logger.log("Bd_Special", { buf = buf, buftype = vim.bo[buf].buftype })
    vim.cmd("bdelete" .. (opts.bang and "!" or ""))
    return
  end

  -- Find which window(s) are displaying this buffer
  local windows_with_buf = vim.fn.win_findbuf(buf)
  autocmd_logger.log("Bd_Windows", { buf = buf, window_count = #windows_with_buf })

  -- Get list of normal buffers (excluding current)
  local normal_buffers = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and b ~= buf and vim.bo[b].buflisted and vim.bo[b].buftype == "" then
      table.insert(normal_buffers, b)
    end
  end

  autocmd_logger.log("Bd_Alternates", { buf = buf, alternate_count = #normal_buffers })

  -- If there are other normal buffers, switch windows before deleting
  if #normal_buffers > 0 then
    -- Determine which buffer to switch to
    local alt = vim.fn.bufnr("#")
    local target_buf

    if alt ~= -1 and alt ~= buf and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buftype == "" then
      target_buf = alt -- Use alternate buffer
      autocmd_logger.log("Bd_UseAlternate", { buf = buf, target = alt })
    else
      target_buf = normal_buffers[1] -- Use first available buffer
      autocmd_logger.log("Bd_UseFirst", { buf = buf, target = normal_buffers[1] })
    end

    -- Switch each window to the target buffer BEFORE deletion
    for _, win in ipairs(windows_with_buf) do
      if vim.api.nvim_win_is_valid(win) then
        local ok = pcall(vim.api.nvim_win_set_buf, win, target_buf)
        autocmd_logger.log("Bd_SwitchWindow", { win = win, target = target_buf, success = ok })
      end
    end
  else
    autocmd_logger.log("Bd_NoAlternates", { buf = buf })
  end

  -- Now delete the buffer
  local delete_cmd = "bdelete" .. (opts.bang and "!" or "") .. " " .. buf
  autocmd_logger.log("Bd_Delete", { buf = buf, cmd = delete_cmd })

  local ok, err = pcall(vim.cmd, delete_cmd)
  if not ok then
    autocmd_logger.log("Bd_DeleteFailed", { buf = buf, error = tostring(err) })
    notify.notify("Buffer delete failed: " .. tostring(err), "error")
  else
    autocmd_logger.log("Bd_DeleteSuccess", { buf = buf })
  end
end, { bang = true, desc = "Smart buffer delete that preserves window layout" })

-- Create alias for standard :bd command
vim.api.nvim_create_user_command("BD", function(opts)
  vim.cmd("Bd" .. (opts.bang and "!" or ""))
end, { bang = true, desc = "Alias for Bd" })

-- Buffer Cache Invalidation: Clear caches when buffer state changes
create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = augroup("YodaBufferCacheInvalidation", { clear = true }),
  desc = "Invalidate buffer caches when buffers are removed",
  callback = function(args)
    -- Only invalidate if it's a real buffer being deleted
    local buf = args.buf
    if vim.api.nvim_buf_is_valid(buf) then
      local buftype = vim.bo[buf].buftype
      local filetype = vim.bo[buf].filetype
      -- Only invalidate for real buffers or alpha dashboard
      if buftype == "" or filetype == "alpha" then
        alpha_manager.invalidate_cache()
      end
    end
  end,
})

-- Terminal and Python autocmds
terminal_autocmds.setup_all(autocmd, augroup)

-- Startup: Handle directory argument and show dashboard
create_autocmd("VimEnter", {
  group = augroup("YodaStartup", { clear = true }),
  desc = "Initialize on startup",
  callback = function()
    handle_directory_argument()

    if alpha_manager.should_show_alpha(buffer_state.is_buffer_empty) then
      vim.defer_fn(function()
        if alpha_manager.should_show_alpha(buffer_state.is_buffer_empty) then
          alpha_manager.show_alpha_dashboard()
        end
      end, DELAYS.ALPHA_STARTUP)
    end
  end,
})

create_autocmd("BufEnter", {
  group = augroup("YodaConsolidatedBufEnter", { clear = true }),
  desc = "Consolidated buffer enter handler for alpha, refresh, and git signs",
  callback = function(args)
    local perf_start_time = vim.loop.hrtime()
    local start_time = autocmd_logger.log_start("BufEnter", { buf = args.buf })
    local buf = args.buf

    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:match("snacks_") or bufname:match("^%[.-%]$") then
      autocmd_logger.log("BufEnter_SKIP", { buf = buf, reason = "snacks_buffer" })
      autocmd_logger.log_end("BufEnter", start_time, { action = "skipped_snacks" })
      return
    end

    local buftype = vim.bo[buf].buftype
    local filetype = vim.bo[buf].filetype
    local buflisted = vim.bo[buf].buflisted

    if buftype ~= "" and buftype ~= "help" then
      autocmd_logger.log("BufEnter_SKIP", { buf = buf, reason = "special_buftype", buftype = buftype })
      autocmd_logger.log_end("BufEnter", start_time, { action = "skipped_special" })
      return
    end

    local is_real_buffer = buftype == "" and filetype ~= "" and filetype ~= "alpha" and bufname ~= ""

    if is_real_buffer then
      handle_real_buffer_enter(buf, filetype, start_time, perf_start_time)
      return
    end

    alpha_manager.handle_alpha_dashboard_display({
      buf = buf,
      buftype = buftype,
      filetype = filetype,
      buflisted = buflisted,
      start_time = start_time,
      perf_start_time = perf_start_time,
      logger = autocmd_logger,
      perf_tracker = autocmd_perf,
      is_buffer_empty_fn = buffer_state.is_buffer_empty,
      delay = DELAYS.ALPHA_BUFFER_CHECK,
    })
  end,
})

-- Additional Alpha closing for file pickers and external commands
create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = augroup("AlphaCloseOnFile", { clear = true }),
  desc = "Close alpha dashboard when reading/creating files",
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype
    local bufname = vim.api.nvim_buf_get_name(args.buf)

    -- Skip alpha and special buffers
    if filetype == "alpha" or filetype == "" or bufname == "" then
      return
    end

    vim.schedule(function()
      alpha_manager.close_all_alpha_buffers()
    end)
  end,
})

-- Close alpha when window layout changes (e.g., from Telescope)
create_autocmd("WinEnter", {
  group = augroup("AlphaCloseOnWinEnter", { clear = true }),
  desc = "Close alpha dashboard when entering non-alpha windows",
  callback = function()
    local current_filetype = vim.bo.filetype

    if current_filetype ~= "alpha" and current_filetype ~= "" and vim.api.nvim_buf_get_name(0) ~= "" then
      vim.schedule(function()
        alpha_manager.close_all_alpha_buffers()
      end)
    end
  end,
})

-- Force close alpha when Telescope or other pickers close
create_autocmd("BufHidden", {
  group = augroup("AlphaCloseOnPickerExit", { clear = true }),
  desc = "Close alpha when file pickers close",
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype

    -- If a telescope or picker buffer is being hidden, likely a file was selected
    if filetype == "TelescopePrompt" or filetype:match("^telescope") then
      vim.defer_fn(function()
        -- Check if any real files are now open
        local has_real_files = false
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
            local buf_filetype = vim.bo[buf].filetype
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if buf_filetype ~= "alpha" and buf_filetype ~= "" and buf_name ~= "" and vim.bo[buf].buftype == "" then
              has_real_files = true
              break
            end
          end
        end

        if has_real_files then
          alpha_manager.close_all_alpha_buffers()
        end
      end, DELAYS.TELESCOPE_CLOSE)
    end
  end,
})

-- Highlight on yank
create_autocmd("TextYankPost", {
  group = augroup("YodaHighlightYank", { clear = true }),
  desc = "Highlight yanked text briefly",
  callback = function()
    if vim.api.nvim_buf_line_count(0) < THRESHOLDS.MAX_LINES_FOR_YANK_HIGHLIGHT then
      vim.highlight.on_yank({ timeout = DELAYS.YANK_HIGHLIGHT })
    end
  end,
})

-- Auto reload changed files on focus
create_autocmd("FocusGained", {
  group = augroup("YodaAutoRead", { clear = true }),
  desc = "Reload files changed outside of Neovim and refresh git signs",
  callback = function()
    if buffer_state.can_reload_buffer() then
      pcall(vim.cmd, "checktime")
      gitsigns.refresh()
    end
  end,
})

-- Restore last cursor position
create_autocmd("BufReadPost", {
  group = augroup("YodaRestoreCursor", { clear = true }),
  desc = "Restore cursor to last known position",
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

-- Auto resize splits on window resize (with alpha dashboard support)
create_autocmd("VimResized", {
  group = augroup("YodaResizeSplits", { clear = true }),
  desc = "Automatically resize splits on window resize and recenter alpha dashboard",
  callback = function()
    -- Equalize all windows
    vim.cmd("tabdo wincmd =")

    -- Check if alpha dashboard is visible and recenter it
    vim.schedule(function()
      alpha_manager.recenter_alpha_dashboard()
    end)
  end,
})

-- Filetype-specific settings
create_autocmd("FileType", {
  group = augroup("YodaFileTypes", { clear = true }),
  desc = "Apply filetype-specific settings",
  callback = function()
    filetype_settings.apply(vim.bo.filetype)
  end,
})

-- MARKDOWN PERFORMANCE: Balanced performance and functionality
create_autocmd("FileType", {
  group = augroup("YodaMarkdownPerformance", { clear = true }),
  desc = "Balanced performance optimizations for markdown",
  pattern = "markdown",
  callback = function()
    -- Keep basic syntax highlighting but disable expensive inline parsing
    vim.cmd("silent! TSDisable markdown_inline")

    -- Disable ALL autocmds that might trigger on typing events
    vim.cmd("autocmd! TextChanged,TextChangedI,TextChangedP <buffer>")
    vim.cmd("autocmd! InsertEnter,InsertLeave <buffer>")
    vim.cmd("autocmd! CursorMoved,CursorMovedI <buffer>")
    vim.cmd("autocmd! BufEnter,BufWritePost <buffer>")
    vim.cmd("autocmd! LspAttach <buffer>")

    -- Disable all completion
    vim.opt_local.complete = ""
    vim.opt_local.completeopt = ""

    -- Disable all diagnostics
    vim.diagnostic.disable()

    -- Disable all statusline updates
    vim.opt_local.statusline = ""

    -- Disable all cursor movements that might trigger events
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false

    -- Disable copilot and other AI assistants (only if available)
    local ok, copilot = pcall(require, "copilot")
    if ok and copilot then
      vim.cmd("silent! Copilot disable")
    end

    -- Disable linting
    vim.cmd("silent! LintDisable")

    -- Maximum performance settings
    vim.opt_local.updatetime = 4000
    vim.opt_local.timeoutlen = 1000
    vim.opt_local.ttimeoutlen = 0
    vim.opt_local.lazyredraw = true
    vim.opt_local.synmaxcol = 200
    vim.opt_local.maxmempattern = 1000 -- Limit regex memory usage

    -- Disable all plugin loading
    vim.opt_local.eventignore = "all"

    print("🚀 AGGRESSIVE MARKDOWN PERFORMANCE MODE ENABLED")
    print("📝 ALL autocmds, plugins, and features disabled")
  end,
})

-- ============================================================================
-- OpenCode Integration - Enhanced Buffer Management
-- ============================================================================

-- Auto-save all modified buffers when OpenCode launches
create_autocmd("User", {
  group = augroup("YodaOpenCodeAutoSave", { clear = true }),
  pattern = "OpencodeStart",
  desc = "Auto-save all buffers when OpenCode starts",
  callback = function()
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      vim.schedule(function()
        pcall(opencode_integration.save_all_buffers)
      end)
    end
  end,
})

-- Enhanced buffer refresh when focus is gained (OpenCode integration)
create_autocmd("FocusGained", {
  group = augroup("YodaOpenCodeFocusRefresh", { clear = true }),
  desc = "Refresh buffers and git signs when focus is gained",
  callback = function()
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      vim.schedule(function()
        -- Force check for external changes
        pcall(vim.cmd, "checktime")

        -- Refresh current buffer if needed
        if buffer_state.can_reload_buffer() and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
          local current_buf = vim.api.nvim_get_current_buf()
          opencode_integration.refresh_buffer(current_buf)
        end

        -- Refresh git signs
        opencode_integration.refresh_git_signs()
      end)
    else
      if buffer_state.can_reload_buffer() then
        pcall(vim.cmd, "checktime")
        gitsigns.refresh()
      end
    end
  end,
})

-- Refresh git signs when buffer is written (covers OpenCode auto-reload)
create_autocmd("BufWritePost", {
  group = augroup("YodaGitSignsWriteRefresh", { clear = true }),
  desc = "Refresh git signs after buffer is written",
  callback = function()
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      opencode_integration.refresh_git_signs()
    else
      if vim.bo.buftype == "" then
        gitsigns.refresh()
      end
    end
  end,
})

-- Enhanced file change detection with complete refresh cycle
create_autocmd("FileChangedShell", {
  group = augroup("YodaOpenCodeFileChange", { clear = true }),
  desc = "Handle files changed by external tools like OpenCode with complete refresh",
  callback = function(args)
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      vim.schedule(function()
        -- Refresh the specific changed buffer first
        if args.buf and vim.api.nvim_buf_is_valid(args.buf) then
          opencode_integration.refresh_buffer(args.buf)
        end

        -- Complete refresh cycle
        opencode_integration.complete_refresh()
      end)
    else
      -- Fallback behavior
      vim.schedule(function()
        pcall(vim.cmd, "checktime")
        gitsigns.refresh()
      end)
    end
  end,
})

-- Post-process file changes for UI consistency
create_autocmd("FileChangedShellPost", {
  group = augroup("YodaOpenCodeFileChangePost", { clear = true }),
  desc = "Post-process file changes from external tools",
  callback = function()
    vim.schedule(function()
      -- Ensure UI is properly updated
      vim.cmd("redraw!")

      -- Final git signs refresh for consistency
      local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
      if ok then
        opencode_integration.refresh_git_signs()
      else
        local gs = package.loaded.gitsigns
        if gs and vim.bo.buftype == "" then
          gs.refresh()
        end
      end
    end)
  end,
})

-- ============================================================================
-- PERFORMANCE OPTIMIZATION: Disable expensive text change events for commit buffers
-- ============================================================================

-- Disable expensive text change autocmds for git commit buffers to prevent lag
create_autocmd("FileType", {
  group = augroup("YodaGitCommitPerformance", { clear = true }),
  desc = "Disable expensive autocmds for git commit buffers to prevent typing lag",
  pattern = { "gitcommit", "NeogitCommitMessage" },
  callback = function()
    -- Disable text change events that might cause lag
    vim.cmd("autocmd! TextChanged,TextChangedI,TextChangedP <buffer>")
    vim.cmd("autocmd! CursorMoved,CursorMovedI <buffer>")
    vim.cmd("autocmd! InsertEnter,InsertLeave <buffer>")
    vim.cmd("autocmd! BufWritePost <buffer>")

    -- Disable completion-related events
    vim.cmd("autocmd! CompleteChanged,CompleteDone <buffer>")

    -- Note: LSP is already disabled for git commit buffers via filetype exclusion

    notify.notify("🔥 Disabled expensive autocmds for git commit buffer", "debug")
  end,
})

-- ============================================================================
-- OpenCode Integration Autocmds
-- ============================================================================

local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
if ok then
  opencode_integration.setup_autocmds(autocmd, augroup)
end

-- ============================================================================
-- WINDOW LAYOUT MANAGEMENT: Snacks Explorer + OpenCode
-- ============================================================================

layout_manager.setup_autocmds(autocmd, augroup)

-- ============================================================================
-- CMDLINE PERFORMANCE: Disable LSP in cmdline mode
-- ============================================================================

local cmdline_perf_group = augroup("YodaCmdlinePerformance", { clear = true })

create_autocmd("CmdlineEnter", {
  group = cmdline_perf_group,
  desc = "Disable LSP features in cmdline mode for performance",
  callback = function()
    vim.g.cmdline_mode = true
  end,
})

create_autocmd("CmdlineLeave", {
  group = cmdline_perf_group,
  desc = "Re-enable LSP features after leaving cmdline mode",
  callback = function()
    vim.g.cmdline_mode = false
  end,
})

-- ============================================================================
-- Autocmd Logging Commands (for debugging)
-- ============================================================================

vim.api.nvim_create_user_command("YodaAutocmdLogEnable", function()
  autocmd_logger.enable()
end, { desc = "Enable detailed autocmd logging for debugging" })

vim.api.nvim_create_user_command("YodaAutocmdLogDisable", function()
  autocmd_logger.disable()
end, { desc = "Disable autocmd logging" })

vim.api.nvim_create_user_command("YodaAutocmdLogToggle", function()
  autocmd_logger.toggle()
end, { desc = "Toggle autocmd logging" })

vim.api.nvim_create_user_command("YodaAutocmdLogView", function()
  autocmd_logger.view_log()
end, { desc = "View autocmd log file" })

vim.api.nvim_create_user_command("YodaAutocmdLogClear", function()
  autocmd_logger.clear_log()
end, { desc = "Clear autocmd log file" })

-- Setup autocmd performance tracking commands
autocmd_perf.setup_commands()

-- ============================================================================
-- Command Aliases for Better Buffer Management
-- ============================================================================

-- Make :bd use our smart buffer delete
vim.cmd([[
  cnoreabbrev <expr> bd getcmdtype() == ':' && getcmdline() == 'bd' ? 'Bd' : 'bd'
  cnoreabbrev <expr> bdelete getcmdtype() == ':' && getcmdline() == 'bdelete' ? 'Bd' : 'bdelete'
]])
