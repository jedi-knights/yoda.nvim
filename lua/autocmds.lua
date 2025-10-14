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

--- Check if alpha dashboard is already open
--- @return boolean
local function has_alpha_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "alpha" then
      return true
    end
  end
  return false
end

--- Check if files were opened at startup
--- @return boolean
local function has_startup_files()
  return vim.fn.argc() ~= 0
end

--- Check if current buffer has a filetype
--- @return boolean
local function has_filetype()
  return vim.bo.filetype ~= ""
end

--- Check if current buffer has a special buftype
--- @return boolean
local function has_special_buftype()
  return vim.bo.buftype ~= ""
end

--- Count normal (non-alpha, non-empty) buffers
--- @return number
local function count_normal_buffers()
  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      local buf_ft = vim.bo[buf].filetype
      if buf_ft ~= "alpha" and buf_ft ~= "" then
        count = count + 1
      end
    end
  end
  return count
end

--- Check if we're in a state where alpha should be shown
--- @return boolean
local function should_show_alpha()
  -- Early returns for clear negative cases
  if has_startup_files() then
    return false
  end

  if has_alpha_buffer() then
    return false
  end

  if not is_buffer_empty() then
    return false
  end

  if has_filetype() then
    return false
  end

  if has_special_buftype() then
    return false
  end

  -- Only show alpha if we have no other normal buffers
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
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
    -- Performance optimizations for markdown
    vim.opt_local.foldmethod = "manual" -- Disable treesitter folding for performance
    vim.opt_local.updatetime = 1000 -- Reduce event frequency (less aggressive than 250ms)
    vim.opt_local.spelllang = "en_us" -- Limit spell checking to English for performance
  end,

  -- Git commit messages: optimize for fast typing
  gitcommit = function()
    vim.opt_local.foldmethod = "manual" -- Disable treesitter folding for performance
    vim.opt_local.spell = true -- Enable spell check for commits
    vim.opt_local.wrap = true -- Wrap long lines
    vim.opt_local.textwidth = 72 -- Standard git commit line length
    vim.opt_local.updatetime = 1000 -- Reduce event frequency (less aggressive than 250ms)
  end,

  -- Neogit buffers: optimize for performance
  NeogitCommitMessage = function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 72
    vim.opt_local.updatetime = 1000
  end,

  NeogitStatus = function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.updatetime = 1000
  end,

  NeogitPopup = function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.updatetime = 1000
  end,

  ["snacks-explorer"] = function()
    vim.cmd("stopinsert")
    vim.schedule(function()
      if vim.fn.mode() ~= "n" then
        vim.cmd("stopinsert")
      end
    end)
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
  desc = "Reload files changed outside of Neovim",
  callback = function()
    if can_reload_buffer() then
      pcall(vim.cmd, "checktime")
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
