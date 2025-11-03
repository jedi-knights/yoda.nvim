-- lua/yoda/terminal/autocmds.lua
-- Terminal and Python-related autocmds

local M = {}

-- ============================================================================
-- Terminal Configuration
-- ============================================================================

--- Configure terminal buffer settings
local function configure_terminal()
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  -- Ensure terminal buffers are modifiable for proper operation
  vim.opt_local.modifiable = true
end

-- ============================================================================
-- Python Syntax Configuration
-- ============================================================================

--- Ensure Python syntax highlighting is properly enabled
local function configure_python_syntax()
  -- Ensure treesitter is enabled for Python
  local ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
  if ok and ts_highlight then
    ts_highlight.attach(0, "python")
  end

  -- Fallback to vim syntax if treesitter fails
  if not vim.treesitter.highlighter.active[0] then
    vim.cmd("syntax enable")
    vim.bo.syntax = "python"
  end
end

-- ============================================================================
-- Setup Functions
-- ============================================================================

--- Setup terminal autocmds
--- @param autocmd function vim.api.nvim_create_autocmd
--- @param augroup function vim.api.nvim_create_augroup
function M.setup_terminal_autocmd(autocmd, augroup)
  autocmd("TermOpen", {
    group = augroup("YodaTerminal", { clear = true }),
    desc = "Configure terminal buffers",
    callback = configure_terminal,
  })
end

--- Setup Python syntax autocmd
--- @param autocmd function vim.api.nvim_create_autocmd
--- @param augroup function vim.api.nvim_create_augroup
function M.setup_python_syntax_autocmd(autocmd, augroup)
  autocmd("FileType", {
    group = augroup("YodaPythonSyntax", { clear = true }),
    desc = "Ensure Python syntax highlighting is properly enabled",
    pattern = "python",
    callback = configure_python_syntax,
  })
end

--- Setup all terminal-related autocmds
--- @param autocmd function vim.api.nvim_create_autocmd
--- @param augroup function vim.api.nvim_create_augroup
function M.setup_all(autocmd, augroup)
  M.setup_terminal_autocmd(autocmd, augroup)
  M.setup_python_syntax_autocmd(autocmd, augroup)
end

return M
