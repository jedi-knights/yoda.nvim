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

-- ============================================================================
-- Yoda Modules
-- ============================================================================

-- Utility function for safe module loading with error reporting
local function safe_require(module_name)
  local ok, result = pcall(require, module_name)
  if not ok then
    -- Use print for early errors before notification system is ready
    print(string.format("Yoda Init Error: Failed to load %s: %s", module_name, result))
    return nil
  end
  return result
end

-- Load colorscheme (must be after plugins to ensure plugin availability)
safe_require("yoda.colorscheme")

-- Consolidated deferred initialization (fixes race conditions)
-- All scheduled tasks run in a single, ordered block to ensure proper dependency chain
vim.schedule(function()
  -- 1. Setup foundation plugins first (highest priority)
  local yoda_setup = require("yoda-setup")
  yoda_setup.setup_yoda_plugins()
  
  -- 2. Load local configuration (may override plugin settings)
  pcall(require, "local")
  
  -- 3. Setup keymaps and autocmds (depends on plugins being ready)
  require("keymaps")
  require("autocmds")
  
  -- 4. Load non-critical commands (can be used after keymaps are set)
  safe_require("yoda.commands")
  
  -- 5. Initialize large file detection system
  local large_file = safe_require("yoda.large_file")
  if large_file then
    large_file.setup(vim.g.yoda_large_file or {})
    large_file.setup_commands()
  end
  
  -- 6. Load test utilities (development mode only)
  if vim.env.YODA_DEV then
    safe_require("yoda.plenary")
  end
  
  -- 7. Show environment notifications (last, after everything is ready)
  local environment = safe_require("yoda.environment")
  if environment then
    environment.show_notification()
    environment.show_local_dev_notification()
  end
  
  -- Load diagnostic tools (lazy load on command use)
  -- DISABLED: CmdlineEnter causing crashes in Neovim 0.11.4
  -- vim.api.nvim_create_autocmd("CmdlineEnter", {
  --   pattern = ":",
  --   once = true,
  --   callback = function()
  --     vim.schedule(function()
  --       safe_require("yoda.diagnose_flickering")
  --       safe_require("yoda.diagnose_signs")
  --     end)
  --   end,
  -- })
end)
