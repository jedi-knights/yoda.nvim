-- lua/yoda/core/options.lua

-- Set leader key early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Yoda configuration options
vim.g.yoda_config = vim.g.yoda_config or {}

-- Startup message configuration
vim.g.yoda_config.verbose_startup = vim.g.yoda_config.verbose_startup or false
vim.g.yoda_config.show_loading_messages = vim.g.yoda_config.show_loading_messages or false
vim.g.yoda_config.show_environment_notification = vim.g.yoda_config.show_environment_notification or true

-- General options
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Performance
opt.updatetime = 300             -- Faster completion
opt.timeoutlen = 300             -- Faster key sequence completion

-- UI
opt.termguicolors = true         -- Enable true color support
opt.background = "dark"          -- Dark background
opt.signcolumn = "yes"           -- Always show sign column
opt.cursorline = true            -- Highlight current line
opt.cursorcolumn = false         -- Don't highlight current column
opt.scrolloff = 8                -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8            -- Keep 8 columns left/right of cursor

-- Folding
opt.foldmethod = "indent"
opt.foldlevel = 99
opt.foldnestmax = 10

-- Backup
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Clipboard
opt.clipboard = "unnamedplus"

-- Split
opt.splitbelow = true
opt.splitright = true

-- Search
opt.hlsearch = false
opt.incsearch = true

-- Other
opt.mouse = "a"
opt.showmode = false
opt.showcmd = true
opt.ruler = true
opt.laststatus = 2
opt.hidden = true
opt.wildmenu = true
opt.wildmode = "list:longest"
opt.completeopt = "menuone,noselect"
opt.inccommand = "nosplit"
opt.ttyfast = true
opt.virtualedit = "block"
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"
opt.spelllang = "en_us"
opt.spell = false
opt.spellcapcheck = ""
opt.spellsuggest = "best,9"
opt.spelloptions = "camel"
opt.spellfile = vim.fn.stdpath("data") .. "/spell/en.utf-8.add"

-- Filetype
opt.fileencoding = "utf-8"
opt.fileformat = "unix"
opt.fileformats = "unix,dos,mac"

-- Session
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Diff
opt.diffopt = "filler,iwhite,algorithm:patience"

-- Grep
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"

-- Tags
opt.tags = "./tags;,tags"

-- Match
opt.matchtime = 2
opt.matchpairs = "(:),{:},[:],<:>"

-- Format
opt.formatoptions = "jcroqlnt"
opt.textwidth = 80
opt.colorcolumn = "80"

-- List
opt.list = false
opt.listchars = "tab:> ,trail:-,extends:>,precedes:<,nbsp:+"

-- Fill
opt.fillchars = "vert:│,fold: ,eob: ,diff: "

-- Window
opt.winminwidth = 5
opt.winminheight = 1

-- Pum
opt.pumheight = 10
opt.pumwidth = 10

-- Preview
opt.previewheight = 12

-- Command
opt.cmdheight = 1
opt.cmdwinheight = 5

-- Help
opt.helpheight = 12

-- History
opt.history = 1000
opt.shada = "!,'300,<50,@100,s10,h"

-- Buffer
opt.bufhidden = "hide"
opt.buflisted = true

-- Window
opt.winblend = 0
opt.pumblend = 0

-- Terminal
opt.termguicolors = true

-- Neovim specific
opt.inccommand = "nosplit"
opt.completeopt = "menuone,noselect"
opt.wildoptions = "pum"
opt.pumblend = 0
opt.winblend = 0

-- Statusline with paths relative to current working directory
opt.statusline = "%{fnamemodify(expand('%'), ':p:.')} %m%r%y %l:%c %p%%"

-- Disable built-in plugins
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
  "logiPat",
  "rrhelper",
  "spellfile_plugin",
  "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end
