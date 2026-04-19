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
-- Neovim 0.12 UI2
-- ============================================================================

-- Enable the built-in ui2 module for floating cmdline and styled messages.
-- This replaces noice.nvim with native Neovim functionality.
--
-- NOTE: vim._core.ui2 is an internal Neovim API (underscore-prefixed).
-- It is available in Neovim 0.12 but is not yet a stable public API —
-- it may change or be renamed in future releases.
--
-- The msg target is conditionally disabled on Neovim 0.12.0–0.12.1 due
-- to a bug in ui2/messages.lua where nvim_buf_set_text receives an
-- out-of-range end_col when multiple messages arrive in the same
-- vim.schedule tick (e.g. yank + file-write notifications).
-- The version guard auto-enables msg on 0.12.2+.
local ok_ui2, ui2 = pcall(require, "vim._core.ui2")
if ok_ui2 then
  -- Neovim 0.12.0–0.12.1 has a bug where nvim_buf_set_text receives an
  -- out-of-range end_col when multiple messages arrive in the same tick.
  -- Disable the msg target on those versions; auto-enable on 0.12.2+.
  local buggy = vim.version.range(">=0.12.0 <0.12.2"):has(vim.version())
  local ui2_opts = buggy and {} or { msg = { targets = "msg", msg = { timeout = 2500 } } }

  local ok_enable, err_enable = pcall(ui2.enable, ui2_opts)
  if not ok_enable then
    vim.defer_fn(function()
      vim.notify("[yoda] ui2.enable failed: " .. tostring(err_enable), vim.log.levels.WARN)
    end, 0)
  else
    -- ui2 provides a floating cmdline overlay, so hide the built-in cmdline.
    vim.o.cmdheight = 0

    -- With ui2 active, set the notify backend to native (vim.notify works directly)
    if not vim.g.yoda_notify_backend then
      vim.g.yoda_notify_backend = "native"
    end
  end
end

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

  -- Show environment notifications if configured
  local ok_env, environment = pcall(require, "yoda.environment")
  if ok_env then
    environment.show_notification()
    environment.show_local_dev_notification()
  else
    vim.notify("[yoda] Failed to load yoda.environment: " .. tostring(environment), vim.log.levels.WARN)
  end

  -- Screen recording toggle (macOS only — requires ffmpeg and Screen Recording permission)
  local ok_sc, screencast = pcall(require, "yoda.screencast")
  if ok_sc then
    screencast.setup()
  else
    vim.notify("[yoda] Failed to load yoda.screencast: " .. tostring(screencast), vim.log.levels.WARN)
  end
end)
