-- lua/yoda/plugins/lazy.lua

-- Path to install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Bootstrap lazy.nvim if it's not installed
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

-- Prepend lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- Load plugins using lazy.nvim
require("lazy").setup({
  spec = {
    import = "yoda.plugins.spec", -- Import all plugins defined under plugins/spec/
  },
  defaults = {
    lazy = true, -- Lazy-load everything by default
    version = false, -- Always use the latest commit (you can pin versions later if needed)
  },
  install = {
    colorscheme = { "tokyonight" }, -- Try to load this colorscheme after install
  },
  checker = { enabled = false }, -- Manually check for plugin updates
  change_detection = {
    enabled = true,
    notify = true, -- Get a notification when plugins are updated
  },
  dev = {
    rocks = {
      enabled = false,    -- disables luarocks support
      hererocks = false,  -- prevents auto-installing hererocks
    },
  },
  -- Disable documentation generation globally to prevent issues with local plugins
  readme = {
    enabled = false,
  },
  -- Add performance optimizations
  performance = {
    rtp = {
      reset = false, -- Reset the runtime path to Vim default
      paths = {}, -- Add any custom paths
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  -- Add better error handling
  concurrency = 20, -- Limit the number of concurrent operations
  git = {
    timeout = 120, -- Git operations timeout
  },
  -- Add logging for debugging
  log = {
    level = "warn", -- Set to "debug" for more verbose output
  },
  -- Add error handling for plugin loading
  ui = {
    border = "rounded",
    icons = {
      loaded = "●",
      not_loaded = "○",
      error = "✗",
    },
  },
})

