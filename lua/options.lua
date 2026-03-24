-- lua/yoda/config/options.lua
-- All vim.opt settings in one place (kickstart-style)

-- ============================================================================
-- GENERAL SETTINGS
-- ============================================================================

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
-- Deferred to avoid startup cost — clipboard sync with the OS has non-trivial
-- latency; scheduling it lets the rest of init complete first.
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split" -- live substitution preview in a split
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.colorcolumn = "80"

-- Make colorcolumn more visible and persistent
local function set_colorcolumn_highlight()
  -- Schedule to run after other highlights are applied
  vim.schedule(function()
    vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2a2a37" })
  end)
end

-- Re-apply after every colorscheme change so the highlight survives theme switches.
-- This also fires at startup when lazy.nvim applies the initial colorscheme,
-- so a separate immediate call is not needed.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("ColorColumnPersistent", { clear = true }),
  pattern = "*",
  callback = set_colorcolumn_highlight,
})

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
-- HELP & DOCUMENTATION
-- ============================================================================

-- Set keywordprg for K (Shift+K) help lookup
vim.opt.keywordprg = ":help"

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
vim.opt.confirm = true -- ask to save unsaved changes instead of refusing to quit
vim.opt.shortmess:append("I") -- suppress the :intro splash screen on startup

-- ============================================================================
-- BACKUP & SHADA
-- ============================================================================

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- ShaDa (shared data) settings for better reliability
vim.opt.shada = {
  "!", -- Save global variables
  "'100", -- Save marks for last 100 files
  "<50", -- Save max 50 lines for each register
  "s10", -- Max item size 10KB
  "h", -- Disable hlsearch when loading
  "f1", -- Store file marks
  "r/tmp", -- Skip removable media
}

-- ============================================================================
-- TERMINAL
-- ============================================================================

vim.opt.termguicolors = true
vim.opt.synmaxcol = 240 -- don't syntax-highlight past col 240 (prevents slowdown on minified/generated files)
vim.opt.modelines = 0 -- don't scan file edges for modeline directives (unused; free per-open win)

-- ============================================================================
-- FOLDING
-- ============================================================================

vim.opt.foldmethod = "manual"
vim.opt.foldenable = false
vim.opt.foldlevel = 99

-- ============================================================================
-- YODA SPECIFIC
-- ============================================================================

-- Configuration for Yoda.nvim (only set if not already configured)
if not vim.g.yoda_config then
  vim.g.yoda_config = {
    verbose_startup = false,
    show_loading_messages = false,
    show_environment_notification = true,
    enable_startup_profiling = false,
    show_startup_report = false,
    profiling_verbose = false,
  }
end

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
