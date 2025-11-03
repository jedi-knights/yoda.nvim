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
-- Uses unified logging system (lazy-loaded to avoid startup impact)
function _G.P(v)
  -- Lazy-load logger only when actually called
  local ok, logger = pcall(require, "yoda.logging.logger")
  if ok then
    logger.set_strategy("console")
    logger.debug(vim.inspect(v))
  else
    -- Fallback to print if logger not available
    print(vim.inspect(v))
  end
  return v
end

-- Database configuration (can be overridden in local config)
vim.g.dbs = vim.g.dbs or {}

-- ============================================================================
-- Core Bootstrap
-- ============================================================================

-- Bootstrap lazy.nvim
require("lazy-bootstrap")

-- Load base configuration in optimal order
require("options") -- Fastest - just vim option settings
require("lazy-plugins") -- Load plugins early to allow lazy loading to work

-- Load local configuration if it exists (deferred)
vim.schedule(function()
  pcall(require, "local")
end)

-- Defer keymaps and autocmds for better startup performance
vim.schedule(function()
  require("keymaps")   -- Contains some expensive setup logic
  require("autocmds")  -- Contains complex autocommands
end)

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

-- Defer loading of non-critical modules (performance optimization)
-- These modules provide commands and utilities that aren't needed immediately at startup
vim.schedule(function()
  -- Load user commands (deferred - only needed when user invokes them)
  safe_require("yoda.commands")

  -- Initialize large file detection system
  local large_file = safe_require("yoda.large_file")
  if large_file then
    -- Setup with default config (can be overridden in local.lua)
    large_file.setup(vim.g.yoda_large_file or {})
    large_file.setup_commands()
  end

  -- Load test utilities (only in development mode)
  if vim.env.YODA_DEV then
    safe_require("yoda.plenary")
  end

  -- Load diagnostic tools (lazy load on command use)
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    pattern = ":",
    once = true,
    callback = function()
      vim.schedule(function()
        safe_require("yoda.diagnose_flickering")
        safe_require("yoda.diagnose_signs")
      end)
    end,
  })
end)

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
