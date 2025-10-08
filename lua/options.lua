-- lua/yoda/config/options.lua
-- All vim.opt settings in one place (kickstart-style)

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Database configuration (can be overridden in local config)
vim.g.dbs = vim.g.dbs or {}

-- ============================================================================
-- GENERAL SETTINGS
-- ============================================================================

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- ============================================================================
-- INDENTATION
-- ============================================================================

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- ============================================================================
-- SEARCH
-- ============================================================================

vim.opt.hlsearch = true
vim.opt.incsearch = true

-- ============================================================================
-- COMPLETION
-- ============================================================================

vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- ============================================================================
-- WILDCARD
-- ============================================================================

vim.opt.wildmode = "longest:full,full"

-- ============================================================================
-- STATUS LINE & TABLINE
-- ============================================================================

vim.opt.laststatus = 3
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.showtabline = 2 -- Always show bufferline/tabline

-- ============================================================================
-- BACKUP
-- ============================================================================

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- ============================================================================
-- TERMINAL
-- ============================================================================

vim.opt.termguicolors = true

-- ============================================================================
-- FOLDING
-- ============================================================================

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

-- ============================================================================
-- YODA SPECIFIC
-- ============================================================================

-- Configuration for Yoda.nvim
vim.g.yoda_config = vim.g.yoda_config
  or {
    verbose_startup = false,
    show_loading_messages = false,
    show_environment_notification = true,
    enable_startup_profiling = false,
    show_startup_report = false,
    profiling_verbose = false,
  }

-- Suppress LSP deprecation warning
vim.g.lspconfig_deprecation_warning = false
vim.env.LSPCONFIG_DEPRECATION_WARNING = "0"

-- Disable some builtin plugins
local disabled_built_ins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit",
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end
