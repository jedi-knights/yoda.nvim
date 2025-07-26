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
})

