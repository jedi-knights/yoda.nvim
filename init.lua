-- init.lua
-- Yoda.nvim - A custom Neovim distribution
-- Bootstrap Lazy + require config (kickstart-modular style)

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

-- Define debug helper function early (available throughout init)
function _G.P(v)
  print(vim.inspect(v))
  return v
end

-- Database configuration (can be overridden in local config)
vim.g.dbs = vim.g.dbs or {}

-- ============================================================================
-- Core Bootstrap
-- ============================================================================

-- Bootstrap lazy.nvim
require("lazy-bootstrap")

-- Load base configuration
require("options")
require("keymaps")
require("autocmds")

-- Load local configuration if it exists (must be before plugins)
pcall(require, "local")

-- Load plugins (must be after base configuration)
require("lazy-plugins")

-- ============================================================================
-- Yoda Modules
-- ============================================================================

-- Utility function for safe module loading with error reporting
local function safe_require(module_name)
  local ok, result = pcall(require, module_name)
  if not ok then
    vim.notify(
      string.format("Failed to load %s: %s", module_name, result),
      vim.log.levels.ERROR,
      { title = "Yoda Init Error" }
    )
    return nil
  end
  return result
end

-- Load colorscheme (must be after plugins to ensure plugin availability)
safe_require("yoda.colorscheme")

-- Load user commands
safe_require("yoda.commands")

-- Load utility functions
safe_require("yoda.functions")

-- Load test utilities (only in development mode)
if vim.env.YODA_DEV then
  safe_require("yoda.plenary")
end

-- ============================================================================
-- Environment Setup
-- ============================================================================

-- Show environment notification if configured (deferred to ensure all modules loaded)
vim.schedule(function()
  local environment = safe_require("yoda.environment")
  if environment then
    environment.show_notification()
  end
end)
