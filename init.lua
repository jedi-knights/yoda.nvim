-- init.lua
-- Yoda.nvim - A custom Neovim distribution

-- Enable faster lua module loading (available since Neovim 0.9; min is 0.10.1)
vim.loader.enable()

-- ============================================================================
-- Early Setup
-- ============================================================================

-- Set leader key early (before plugins/keymaps)
vim.g.mapleader = " "
-- maplocalleader intentionally matches mapleader — filetype plugins that use
-- <localleader> will share the same key, which is acceptable because we have
-- no conflicting local-leader bindings. If that changes, set this to "\\".
vim.g.maplocalleader = " "

-- ============================================================================
-- Core Bootstrap
-- ============================================================================

-- Bootstrap lazy.nvim
require("lazy-bootstrap")

-- Load base configuration
require("options")
require("lazy-plugins")

-- Load local configuration if it exists.
-- Always surface errors so the user sees config mistakes immediately;
-- only suppress the expected "module not found" when no local.lua is present.
vim.schedule(function()
  local ok, err = pcall(require, "local")
  if not ok and type(err) == "string" and not err:find("module 'local' not found") then
    vim.notify("[yoda] Error in local.lua: " .. err, vim.log.levels.ERROR)
  end
end)

-- Defer keymaps and autocmds for better startup performance
vim.schedule(function()
  require("yoda.keymaps")
  require("autocmds")
end)

-- ============================================================================
-- Yoda Modules
-- ============================================================================

-- Defer loading of non-critical modules
vim.schedule(function()
  local verbose = vim.g.yoda_config and vim.g.yoda_config.verbose_startup

  local ok_cmds, err_cmds = pcall(require, "yoda.commands")
  if not ok_cmds and verbose then
    vim.notify("[yoda] Failed to load yoda.commands: " .. tostring(err_cmds), vim.log.levels.WARN)
  end

  -- Initialize large file detection
  local ok, large_file = pcall(require, "yoda.large_file")
  if ok then
    large_file.setup(vim.g.yoda_large_file or {})
    large_file.setup_commands()
  elseif verbose then
    vim.notify("[yoda] Failed to load yoda.large_file: " .. tostring(large_file), vim.log.levels.WARN)
  end

  -- Initialize memory manager
  local mem_ok, memory_manager = pcall(require, "yoda.performance.memory_manager")
  if mem_ok then
    memory_manager.setup(vim.g.yoda_memory_manager or {})
  elseif verbose then
    vim.notify("[yoda] Failed to load yoda.performance.memory_manager: " .. tostring(memory_manager), vim.log.levels.WARN)
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
  elseif vim.g.yoda_config and vim.g.yoda_config.verbose_startup then
    vim.notify("[yoda] Failed to load yoda.environment: " .. tostring(environment), vim.log.levels.WARN)
  end
end)
