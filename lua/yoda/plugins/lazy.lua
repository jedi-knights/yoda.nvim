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
    { import = "yoda.plugins.spec.ai" },
    { import = "yoda.plugins.spec.completion" },
    { import = "yoda.plugins.spec.core" },
    { import = "yoda.plugins.spec.dap" },
    { import = "yoda.plugins.spec.development" },
    { import = "yoda.plugins.spec.git" },
    { import = "yoda.plugins.spec.lsp" },
    { import = "yoda.plugins.spec.markdown" },
    { import = "yoda.plugins.spec.navigation" },
    { import = "yoda.plugins.spec.syntax" },
    { import = "yoda.plugins.spec.tokyonight" },
    { import = "yoda.plugins.spec.ui" },
    -- Which-key temporarily disabled due to persistent errors
  },
  defaults = {
    lazy = true, -- Lazy-load everything by default
    version = false, -- Always use the latest commit (you can pin versions later if needed)
  },
  install = {
    -- Colorscheme is set in tokyonight.lua after plugin setup
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
  -- Ensure tokyonight is loaded immediately
  performance = {
    rtp = {
      reset = false,
      paths = {},
      disabled_plugins = {},
    },
  },
})

