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
-- 500ms: enough time for deliberate multi-key leader sequences without perceptible
-- lag on ambiguous operators (g, d, etc.). Was 1000ms when jk→<Esc> was active —
-- that mapping forced a long wait on every 'j'; now that it's removed, 500ms is safe.
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "nosplit" -- live substitution preview inline (split opens a window, nosplit just highlights)
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.colorcolumn = "80"
-- The ColorColumn highlight is re-applied on every ColorScheme change to
-- survive theme switches — see autocmds.lua (ColorColumnPersistent).

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
vim.opt.pumborder = "rounded" -- bordered completion popup menu (Neovim 0.12+)

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

-- Backend overrides (optional — adapters auto-detect if not set).
-- Must be set here (before lazy-plugins loads) to take effect.
-- Notify backends:  "noice" | "snacks" | "native"
-- Picker backends:  "snacks" | "telescope" | "native"
-- vim.g.yoda_notify_backend = "snacks"
-- vim.g.yoda_picker_backend = "snacks"

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

-- Disable built-in plugins via loaded guards.
--
-- WHY this approach: setting vim.g["loaded_X"] = 1 fires *synchronously*,
-- before lazy.setup() runs and resets the rtp. This guards the brief startup
-- window between Neovim launch and lazy taking control — without these guards
-- Neovim's own plugin loader could source these files first.
--
-- RELATION TO lazy-plugins.lua: several entries here also appear in that
-- file's `disabled_plugins` list. That is intentional belt-and-suspenders:
--   1. These loaded guards fire first (early guard, before rtp reset).
--   2. lazy's disabled_plugins fires after rtp reset (permanent exclusion).
-- Entries unique to THIS list are not managed by lazy because they require
-- the early guard (e.g. netrw family, zip, tar) or have a different loaded
-- guard name than lazy expects (spellfile_plugin vs spellfile).
local disabled_built_ins = {
  "netrw", -- file explorer — replaced by snacks.explorer
  "netrwPlugin", -- also in lazy-plugins.lua disabled_plugins
  "netrwSettings",
  "netrwFileHandlers",
  "gzip", -- also in lazy-plugins.lua disabled_plugins
  "zip",
  "zipPlugin", -- also in lazy-plugins.lua disabled_plugins
  "tar",
  "tarPlugin", -- also in lazy-plugins.lua disabled_plugins
  "getscript", -- also in lazy-plugins.lua disabled_plugins
  "getscriptPlugin", -- also in lazy-plugins.lua disabled_plugins
  "vimball", -- also in lazy-plugins.lua disabled_plugins
  "vimballPlugin", -- also in lazy-plugins.lua disabled_plugins
  "2html_plugin", -- also in lazy-plugins.lua disabled_plugins
  "logipat", -- also in lazy-plugins.lua disabled_plugins
  "rrhelper", -- also in lazy-plugins.lua disabled_plugins
  "spellfile_plugin", -- note: lazy uses "spellfile" (filename); guard name differs
  "matchit", -- also in lazy-plugins.lua disabled_plugins
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end
