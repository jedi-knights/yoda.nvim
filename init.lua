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

-- ============================================================================
-- Yoda Modules + Environment Setup
-- ============================================================================

-- Defer until the event loop starts, after lazy.nvim plugin initialization
-- is complete. local.lua loads first so any globals it sets (e.g.
-- vim.g.yoda_large_file) are visible to the setup() calls that follow.
vim.schedule(function()
  -- Load local configuration if it exists. Use fs_stat to detect presence so
  -- we never need to pattern-match against Neovim's module-not-found message.
  local local_path = vim.fn.stdpath("config") .. "/lua/local.lua"
  if vim.uv.fs_stat(local_path) then
    local ok, err = pcall(require, "local")
    if not ok then
      vim.notify("[yoda] Error in local.lua: " .. tostring(err), vim.log.levels.ERROR)
    end
  end

  -- Keymaps and autocmds are core — Neovim is largely unusable without them.
  local ok_km, err_km = pcall(require, "yoda.keymaps")
  if not ok_km then
    vim.notify("[yoda] Failed to load yoda.keymaps: " .. tostring(err_km), vim.log.levels.ERROR)
  end

  local ok_ac, err_ac = pcall(require, "autocmds")
  if not ok_ac then
    vim.notify("[yoda] Failed to load autocmds: " .. tostring(err_ac), vim.log.levels.ERROR)
  end

  -- The following modules are non-fatal: Neovim remains usable without them.
  local ok_cmds, err_cmds = pcall(require, "yoda.commands")
  if not ok_cmds then
    vim.notify("[yoda] Failed to load yoda.commands: " .. tostring(err_cmds), vim.log.levels.WARN)
  end

  -- Initialize large file detection (setup() also registers user commands)
  local ok_lf, large_file = pcall(require, "yoda.large_file")
  if ok_lf then
    large_file.setup(vim.g.yoda_large_file or {})
  else
    vim.notify("[yoda] Failed to load yoda.large_file: " .. tostring(large_file), vim.log.levels.WARN)
  end

  -- Initialize memory manager
  local ok_mm, memory_manager = pcall(require, "yoda.performance.memory_manager")
  if ok_mm then
    memory_manager.setup(vim.g.yoda_memory_manager or {})
  else
    vim.notify("[yoda] Failed to load yoda.performance.memory_manager: " .. tostring(memory_manager), vim.log.levels.WARN)
  end

  -- Show environment notifications if configured
  local ok_env, environment = pcall(require, "yoda.environment")
  if ok_env then
    environment.show_notification()
    environment.show_local_dev_notification()
  else
    vim.notify("[yoda] Failed to load yoda.environment: " .. tostring(environment), vim.log.levels.WARN)
  end
end)
