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
opt.colorcolumn = "80"           -- Set color column at 80 characters

-- Indentation
opt.tabstop = 4                  -- Number of spaces tabs count for
opt.shiftwidth = 4               -- Size of an indent
opt.expandtab = true             -- Convert tabs to spaces
opt.smartindent = true           -- Smart autoindenting on new lines
opt.softtabstop = 4              -- Number of spaces tabs count for when editing
opt.smarttab = true              -- Insert spaces when pressing tab in insert mode
opt.encoding = "utf-8"            -- Set encoding to UTF-8
opt.visualbell = true            -- Visual bell instead of audible bell

-- UI
opt.cursorline = true            -- Highlight the current line
opt.termguicolors = true         -- Enable 24-bit RGB colors in the terminal
opt.signcolumn = "yes"           -- Always show the sign column

-- Searching
opt.ignorecase = true            -- Ignore case in search patterns
opt.smartcase = true             -- Override ignorecase if search contains capitals
opt.incsearch = true             -- Show search matches while typing
opt.hlsearch = false             -- Don't Highlight matches after search

-- Split windows
opt.splitright = true            -- Vertical splits to the right
opt.splitbelow = true            -- Horizontal splits below

-- Scrolling
opt.scrolloff = 5                -- Minimum lines to keep above and below cursor
opt.sidescrolloff = 8            -- Minimum columns to keep left and right of cursor

opt.fillchars = {
    eob = " ",                   -- Empty lines at the end of a buffer
    fold = " ",                 -- Folds
    diff = "╱",                 -- Diff characters
    msgsep = "─",               -- Message separator
    vert = "│",                 -- Vertical line
    horiz = "─",                -- Horizontal line
}


-- Disable some built-in providers if you want faster startup jk(optional early optimization)
vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Set explicit Python path for better performance
vim.g.python3_host_prog = "/opt/homebrew/opt/python@3.13/bin/python3"


opt.list = true                -- Show whitespace characters
opt.listchars = {
    tab = ">-",
    trail = "·",
    extends = "»",
    precedes = "«",
    nbsp = "␣",
    eol = "↲",
}
