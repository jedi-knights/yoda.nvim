-- lua/autocmds.lua
-- Autocommands configuration for Yoda.nvim

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ============================================================================
-- Constants
-- ============================================================================

local DELAYS = {
  ALPHA_STARTUP = 200, -- Delay for alpha dashboard on startup
  ALPHA_BUFFER_CHECK = 100, -- Delay before checking alpha conditions
  YANK_HIGHLIGHT = 50, -- Duration for yank highlight
}

local THRESHOLDS = {
  MAX_LINES_FOR_YANK_HIGHLIGHT = 1000, -- Skip yank highlight for large files
}

local ALPHA_CONFIG = {
  HEADER_PADDING = 2,
  BUTTON_PADDING = 2,
  FOOTER_PADDING = 1,
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

--- Check if a buffer name indicates it's empty or unnamed
--- @param bufname string Buffer name to check
--- @return boolean
local function is_empty_buffer_name(bufname)
  return bufname == "" or bufname == "[No Name]"
end

--- Check if a buffer name indicates it's a scratch buffer
--- @param bufname string Buffer name to check
--- @return boolean
local function is_scratch_buffer(bufname)
  return bufname == "[Scratch]"
end

--- Check if a buffer is empty or unnamed (but not a scratch buffer)
--- @param bufnr number|nil Buffer number (default: current buffer)
--- @return boolean
local function is_buffer_empty(bufnr)
  bufnr = bufnr or 0
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  -- Don't consider scratch buffers as "empty" for alpha purposes
  if is_scratch_buffer(bufname) then
    return false
  end

  return is_empty_buffer_name(bufname)
end

-- Performance optimizations: cache expensive checks
local alpha_cache = {
  has_startup_files = nil,
  last_check_time = 0,
  check_interval = 100, -- ms
}

--- Check if alpha dashboard is already open (optimized)
--- @return boolean
local function has_alpha_buffer()
  -- Fast check: iterate only valid listed buffers
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].filetype == "alpha" then
      return true
    end
  end
  return false
end

--- Check if files were opened at startup (cached)
--- @return boolean
local function has_startup_files()
  if alpha_cache.has_startup_files == nil then
    alpha_cache.has_startup_files = vim.fn.argc() ~= 0
  end
  return alpha_cache.has_startup_files
end

--- Check if current buffer has a filetype (optimized)
--- @return boolean
local function has_filetype()
  return vim.bo.filetype ~= ""
end

--- Check if current buffer has a special buftype (optimized)
--- @return boolean
local function has_special_buftype()
  return vim.bo.buftype ~= ""
end

--- Count normal buffers (simplified and cached)
--- @return number
local function count_normal_buffers()
  local current_time = vim.loop.hrtime() / 1000000 -- convert to ms

  -- Use cached result if recent enough
  if alpha_cache.normal_count and (current_time - alpha_cache.last_check_time) < alpha_cache.check_interval then
    return alpha_cache.normal_count
  end

  local count = 0
  -- Only check listed buffers for performance
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      local buf_ft = vim.bo[buf].filetype
      if buf_ft ~= "alpha" and buf_ft ~= "" then
        count = count + 1
      end
    end
  end

  -- Cache result
  alpha_cache.normal_count = count
  alpha_cache.last_check_time = current_time
  return count
end

--- Check if we're in a state where alpha should be shown (optimized)
--- @return boolean
local function should_show_alpha()
  -- Fastest checks first (single function calls)
  if has_startup_files() then
    return false
  end

  if has_filetype() then
    return false
  end

  if has_special_buftype() then
    return false
  end

  if not is_buffer_empty() then
    return false
  end

  -- More expensive checks last
  if has_alpha_buffer() then
    return false
  end

  -- Most expensive check last with caching
  return count_normal_buffers() == 0
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
local function start_alpha_dashboard()
  local ok, alpha = pcall(require, "alpha")
  if not ok or not alpha or not alpha.start then
    return false
  end

  local dashboard_ok, dashboard = pcall(require, "alpha.themes.dashboard")
  if not dashboard_ok or not dashboard then
    return false
  end

  local alpha_config = {
    redraw_on_resize = true,
    layout = create_alpha_layout(dashboard),
  }

  local config_ok = pcall(alpha.start, alpha_config)
  return config_ok
end

--- Attempt to show alpha dashboard with error notification
local function show_alpha_dashboard()
  local success = start_alpha_dashboard()
  if not success then
    vim.notify("Alpha dashboard failed to start", vim.log.levels.WARN)
  end
end

--- Change to directory if provided as argument
local function handle_directory_argument()
  if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
    vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
  end
end

--- Check if buffer can be reloaded safely
--- @return boolean
local function can_reload_buffer()
  return vim.bo.modifiable and vim.bo.buftype == "" and not vim.bo.readonly
end

-- ============================================================================
-- Filetype-specific Settings Configuration
-- ============================================================================

local FILETYPE_SETTINGS = {
  markdown = function()
    vim.opt_local.wrap = true
    -- AGGRESSIVE PERFORMANCE OPTIMIZATIONS - NO DELAY ALLOWED
    vim.opt_local.spell = false -- DISABLE spell checking (major performance impact)
    vim.opt_local.conceallevel = 0 -- DISABLE conceal processing (major performance impact)
    vim.opt_local.foldmethod = "manual" -- Disable treesitter folding
    vim.opt_local.updatetime = 4000 -- Maximum delay between events (4 seconds)
    vim.opt_local.timeoutlen = 1000 -- Increase timeout for key sequences
    vim.opt_local.ttimeoutlen = 0 -- No timeout for terminal key codes
    vim.opt_local.lazyredraw = true -- Disable redrawing during macros/scripts
    vim.opt_local.synmaxcol = 200 -- Limit syntax highlighting to 200 columns
    -- Disable all expensive features
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
    vim.opt_local.colorcolumn = ""
  end,

  -- Git commit messages: AGGRESSIVE performance optimization for fast typing
  gitcommit = function()
    -- Core performance settings
    vim.opt_local.foldmethod = "manual" -- Disable treesitter folding for performance
    vim.opt_local.updatetime = 2000 -- Increased from 1000ms for even less frequent events
    vim.opt_local.lazyredraw = true -- Don't redraw during macros/complex operations
    vim.opt_local.synmaxcol = 200 -- Limit syntax highlighting to 200 columns
    vim.opt_local.timeoutlen = 1000 -- Increase timeout for key sequences

    -- Disable expensive cursor features
    vim.opt_local.cursorline = false -- Disable cursor line highlighting
    vim.opt_local.cursorcolumn = false -- Disable cursor column
    vim.opt_local.relativenumber = false -- Disable relative numbers

    -- Git commit specific settings
    vim.opt_local.spell = true -- Enable spell check for commits
    vim.opt_local.wrap = true -- Wrap long lines
    vim.opt_local.textwidth = 72 -- Standard git commit line length

    -- Disable completion and diagnostics (LSP is already disabled)
    vim.opt_local.complete = "" -- Disable all completion
    vim.opt_local.completeopt = "" -- Clear completion options

    -- Notification for debugging (only in DEBUG mode)
    vim.notify("🚀 Git commit performance mode enabled", vim.log.levels.DEBUG)
  end,

  -- Neogit buffers: AGGRESSIVE performance optimization
  NeogitCommitMessage = function()
    -- Core performance settings
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.updatetime = 2000 -- Increased from 1000ms
    vim.opt_local.lazyredraw = true
    vim.opt_local.synmaxcol = 200
    vim.opt_local.timeoutlen = 1000

    -- Disable expensive cursor features
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
    vim.opt_local.relativenumber = false

    -- Commit message specific settings
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 72

    -- Disable completion and diagnostics
    vim.opt_local.complete = ""
    vim.opt_local.completeopt = ""

    -- Notification for debugging (only in DEBUG mode)
    vim.notify("🚀 Neogit commit performance mode enabled", vim.log.levels.DEBUG)
  end,

  NeogitStatus = function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.updatetime = 2000 -- Increased for better performance
    vim.opt_local.lazyredraw = true
    vim.opt_local.cursorline = false -- Disable for performance
    vim.opt_local.synmaxcol = 200
  end,

  NeogitPopup = function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.updatetime = 2000 -- Increased for better performance
    vim.opt_local.lazyredraw = true
    vim.opt_local.cursorline = false -- Disable for performance
    vim.opt_local.synmaxcol = 200
  end,

  ["snacks-explorer"] = function()
    vim.cmd("stopinsert")
    vim.schedule(function()
      if vim.fn.mode() ~= "n" then
        vim.cmd("stopinsert")
      end
    end)
  end,

  -- Helm template files: use YAML syntax with helm-specific settings
  helm = function()
    vim.opt_local.commentstring = "# %s"
    vim.opt_local.syntax = "yaml" -- Use YAML syntax highlighting as base
    vim.opt_local.wrap = false
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,

  -- Regular YAML files
  yaml = function()
    vim.opt_local.commentstring = "# %s"
    vim.opt_local.wrap = false
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
}

--- Apply filetype-specific settings
--- @param filetype string The filetype to configure
local function apply_filetype_settings(filetype)
  local settings_fn = FILETYPE_SETTINGS[filetype]
  if settings_fn then
    settings_fn()
  end
end

-- ============================================================================
-- Autocommand Definitions
-- ============================================================================

-- Terminal: Hide line numbers and ensure modifiable
create_autocmd("TermOpen", {
  group = augroup("YodaTerminal", { clear = true }),
  desc = "Configure terminal buffers",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    -- Ensure terminal buffers are modifiable for proper operation
    vim.opt_local.modifiable = true
  end,
})

-- Startup: Handle directory argument and show dashboard
create_autocmd("VimEnter", {
  group = augroup("YodaStartup", { clear = true }),
  desc = "Initialize on startup",
  callback = function()
    handle_directory_argument()

    if should_show_alpha() then
      vim.defer_fn(function()
        if should_show_alpha() then
          show_alpha_dashboard()
        end
      end, DELAYS.ALPHA_STARTUP)
    end
  end,
})

-- Buffer Enter: Show alpha dashboard for empty buffers
create_autocmd("BufEnter", {
  group = augroup("AlphaBuffer", { clear = true }),
  desc = "Show alpha dashboard for empty buffers",
  callback = function(args)
    -- Early bailout: Skip for unlisted buffers (performance optimization)
    if not vim.bo[args.buf].buflisted then
      return
    end

    -- Early bailout: Skip for git-related and text buffers (performance optimization)
    -- These buffers never need the alpha dashboard and the checks are expensive
    local filetype = vim.bo[args.buf].filetype
    local skip_filetypes = {
      "gitcommit",
      "gitrebase",
      "gitconfig",
      "NeogitCommitMessage",
      "NeogitPopup",
      "NeogitStatus",
      "fugitive",
      "fugitiveblame",
      "markdown", -- Skip expensive alpha checks for markdown files
    }

    for _, ft in ipairs(skip_filetypes) do
      if filetype == ft then
        return
      end
    end

    -- Skip if entering a terminal or special buffer
    local buftype = vim.bo[args.buf].buftype
    if buftype ~= "" then
      return
    end

    -- Quick initial check (includes scratch buffer check)
    if not should_show_alpha() then
      return
    end

    -- Double-check after a short delay to ensure state is stable
    vim.defer_fn(function()
      if should_show_alpha() then
        show_alpha_dashboard()
      end
    end, DELAYS.ALPHA_BUFFER_CHECK)
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
    if can_reload_buffer() then
      pcall(vim.cmd, "checktime")

      -- Refresh git signs after checking time
      local gs = package.loaded.gitsigns
      if gs then
        vim.schedule(function()
          gs.refresh()
        end)
      end
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

-- Auto resize splits on window resize
create_autocmd("VimResized", {
  group = augroup("YodaResizeSplits", { clear = true }),
  desc = "Automatically resize splits on window resize",
  command = "tabdo wincmd =",
})

-- Filetype-specific settings
create_autocmd("FileType", {
  group = augroup("YodaFileTypes", { clear = true }),
  desc = "Apply filetype-specific settings",
  callback = function()
    apply_filetype_settings(vim.bo.filetype)
  end,
})

-- AGGRESSIVE MARKDOWN PERFORMANCE: Disable ALL expensive features
create_autocmd("FileType", {
  group = augroup("YodaMarkdownPerformance", { clear = true }),
  desc = "Aggressive performance optimizations for markdown",
  pattern = "markdown",
  callback = function()
    -- Disable ALL plugins that might cause lag
    vim.cmd("silent! TSDisable markdown")
    vim.cmd("silent! TSDisableAll")

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

    -- Disable copilot and other AI assistants
    vim.cmd("silent! Copilot disable")

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
        opencode_integration.save_all_buffers()
      end)
    end
  end,
})

-- Enhanced buffer refresh when files are changed externally (e.g., by OpenCode)
create_autocmd({ "BufEnter", "FocusGained" }, {
  group = augroup("YodaOpenCodeBufferRefresh", { clear = true }),
  desc = "Refresh buffers and git signs when files change externally",
  callback = function()
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      vim.schedule(function()
        -- Force check for external changes
        pcall(vim.cmd, "checktime")

        -- Refresh current buffer if needed
        if can_reload_buffer() and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
          local current_buf = vim.api.nvim_get_current_buf()
          opencode_integration.refresh_buffer(current_buf)
        end

        -- Refresh git signs
        opencode_integration.refresh_git_signs()
      end)
    else
      -- Fallback to original behavior if module not available
      if can_reload_buffer() then
        pcall(vim.cmd, "checktime")
        local gs = package.loaded.gitsigns
        if gs then
          vim.schedule(function()
            gs.refresh()
          end)
        end
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
      -- Fallback
      local gs = package.loaded.gitsigns
      if gs and vim.bo.buftype == "" then
        vim.schedule(function()
          gs.refresh()
        end)
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
        local gs = package.loaded.gitsigns
        if gs then
          gs.refresh()
        end
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

    vim.notify("🔥 Disabled expensive autocmds for git commit buffer", vim.log.levels.DEBUG)
  end,
})

-- ============================================================================
-- SESSION MANAGEMENT
-- ============================================================================

-- Enhanced OpenCode integration
create_autocmd("User", {
  group = augroup("YodaOpenCodeIntegration", { clear = true }),
  pattern = "OpencodeExit",
  desc = "Handle OpenCode exit",
  callback = function()
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      opencode_integration.on_opencode_exit()
    end
  end,
})
