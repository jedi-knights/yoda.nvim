-- init.lua
-- Yoda.nvim - A custom Neovim distribution

-- Enable faster lua module loading (Neovim 0.9+)
if vim.loader then
  vim.loader.enable()
end

-- ============================================================================
-- Early Setup
-- ============================================================================

-- Set leader key early (before plugins/keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- Core Bootstrap
-- ============================================================================

-- Bootstrap lazy.nvim
require("lazy-bootstrap")

-- Load base configuration
require("options")
require("lazy-plugins")

-- Setup yoda plugins after lazy.nvim loads them
vim.schedule(function()
  local ok, yoda_setup = pcall(require, "yoda-setup")
  if ok then
    yoda_setup.setup_yoda_plugins()
  end
end)

-- Load local configuration if it exists
vim.schedule(function()
  pcall(require, "local")
end)

-- Defer keymaps and autocmds for better startup performance
vim.schedule(function()
  require("keymaps")
  require("autocmds")
end)

-- ============================================================================
-- Yoda Modules
-- ============================================================================

-- Load colorscheme
vim.schedule(function()
  pcall(require, "yoda.colorscheme")
end)

-- Defer loading of non-critical modules
vim.schedule(function()
  pcall(require, "yoda.commands")

  -- Initialize large file detection
  local ok, large_file = pcall(require, "yoda.large_file")
  if ok then
    large_file.setup(vim.g.yoda_large_file or {})
    large_file.setup_commands()
  end
end)

-- ============================================================================
-- Environment Setup
-- ============================================================================

-- Show environment notification if configured
vim.schedule(function()
  local ok, environment = pcall(require, "yoda.environment")
  if ok then
    environment.show_notification()
    environment.show_local_dev_notification()
  end
end)
