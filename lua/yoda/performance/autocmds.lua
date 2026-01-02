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
