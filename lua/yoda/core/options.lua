-- lua/yoda/core/options.lua

-- Set Neovim options
local opt = vim.opt

-- General
opt.number = true                -- Show line numbers
opt.relativenumber = true         -- Show relative line numbers
opt.mouse = "a"                  -- Enable mouse support
opt.clipboard = "unnamedplus"    -- Use system clipboard
opt.swapfile = false             -- Don't use swapfile
opt.backup = false               -- Don't create backup files
opt.undofile = true              -- Enable persistent undo
opt.updatetime = 300             -- Faster completion

-- Indentation
opt.tabstop = 4                  -- Number of spaces tabs count for
opt.shiftwidth = 4               -- Size of an indent
opt.expandtab = true             -- Convert tabs to spaces
opt.smartindent = true           -- Smart autoindenting on new lines

-- UI
opt.cursorline = true            -- Highlight the current line
opt.termguicolors = true         -- True color support
opt.signcolumn = "yes"           -- Always show the sign column

-- Searching
opt.ignorecase = true            -- Ignore case in search patterns
opt.smartcase = true             -- Override ignorecase if search contains capitals
opt.incsearch = true             -- Show search matches while typing
opt.hlsearch = false             -- Don't highlight matches after search

-- Split windows
opt.splitright = true            -- Vertical splits to the right
opt.splitbelow = true            -- Horizontal splits below

-- Scrolling
opt.scrolloff = 8                -- Minimum lines to keep above and below cursor
opt.sidescrolloff = 8            -- Minimum columns to keep left and right of cursor

-- Disable some built-in providers if you want faster startup (optional early optimization)
vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
