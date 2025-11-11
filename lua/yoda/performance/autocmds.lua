-- lua/yoda/performance/autocmds.lua
-- Performance-related autocmds (yank highlight, cmdline)

local M = {}

-- ============================================================================
-- Configuration
-- ============================================================================

local DELAYS = {
  YANK_HIGHLIGHT = 50, -- Duration for yank highlight
}

local THRESHOLDS = {
  MAX_LINES_FOR_YANK_HIGHLIGHT = 1000, -- Skip yank highlight for large files
}

-- ============================================================================
-- Yank Highlight
-- ============================================================================

--- Highlight yanked text briefly
local function highlight_yank()
  if vim.api.nvim_buf_line_count(0) < THRESHOLDS.MAX_LINES_FOR_YANK_HIGHLIGHT then
    vim.highlight.on_yank({ timeout = DELAYS.YANK_HIGHLIGHT })
  end
end

-- ============================================================================
-- Markdown Performance
-- ============================================================================

--- Apply aggressive performance optimizations for markdown files
local function optimize_markdown_performance()
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
  vim.diagnostic.disable(0)

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
end

-- ============================================================================
-- Cmdline Performance
-- ============================================================================

--- Disable LSP features in cmdline mode for performance
local function enter_cmdline_mode()
  vim.g.cmdline_mode = true
end

--- Re-enable LSP features after leaving cmdline mode
local function leave_cmdline_mode()
  vim.g.cmdline_mode = false
end

-- ============================================================================
-- Setup Functions
-- ============================================================================

--- Setup yank highlight autocmd
--- @param autocmd function vim.api.nvim_create_autocmd
--- @param augroup function vim.api.nvim_create_augroup
function M.setup_yank_highlight(autocmd, augroup)
  autocmd("TextYankPost", {
    group = augroup("YodaHighlightYank", { clear = true }),
    desc = "Highlight yanked text briefly",
    callback = highlight_yank,
  })
end

--- Setup cmdline performance autocmds
--- @param autocmd function vim.api.nvim_create_autocmd
--- @param augroup function vim.api.nvim_create_augroup
function M.setup_cmdline_performance(autocmd, augroup)
  -- DISABLED: CmdlineEnter/CmdlineLeave causing crashes in Neovim 0.11.4
  -- local cmdline_perf_group = augroup("YodaCmdlinePerformance", { clear = true })

  -- autocmd("CmdlineEnter", {
  --   group = cmdline_perf_group,
  --   desc = "Disable LSP features in cmdline mode for performance",
  --   callback = enter_cmdline_mode,
  -- })

  -- autocmd("CmdlineLeave", {
  --   group = cmdline_perf_group,
  --   desc = "Re-enable LSP features after leaving cmdline mode",
  --   callback = leave_cmdline_mode,
  -- })
end

--- Setup all performance-related autocmds
--- @param autocmd function vim.api.nvim_create_autocmd
--- @param augroup function vim.api.nvim_create_augroup
function M.setup_all(autocmd, augroup)
  M.setup_yank_highlight(autocmd, augroup)
  M.setup_cmdline_performance(autocmd, augroup)
end

return M
