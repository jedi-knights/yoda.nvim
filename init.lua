-- init.lua
-- yoda.nvim -- config entry point.
--
-- TRANSITIONAL: in the v1.0.0 plugin+starter shape this file belongs to
-- jedi-knights/yoda-starter, not to the plugin (TODO.md Step 3). It is kept
-- deliberately thin and starter-shaped so that move is a copy rather than a
-- rewrite, and so everything below it is exercised through the same
-- require("yoda").setup(opts) path a real consumer will use.

vim.loader.enable()

-- Leader must be set before any keymap is defined.
vim.g.mapleader = " "
-- maplocalleader intentionally matches mapleader -- filetype plugins that use
-- <localleader> share the same key, which is acceptable because we have no
-- conflicting local-leader bindings. If that changes, set this to "\\".
vim.g.maplocalleader = " "

require("lazy-bootstrap")

-- Options must precede lazy.setup(): the vim.g.loaded_* built-in guards only
-- take effect if they are set before the plugins they disable are sourced.
-- apply() is idempotent, so setup() re-applying them below is a no-op.
require("yoda.options").apply()

require("lazy-plugins")

-- Registered before the scheduled block: this installs a VimEnter autocmd,
-- and VimEnter fires before the first vim.schedule callback runs. Snacks is
-- already loaded (lazy = false) and the :ClaudeCode cmd trigger is registered
-- by this point.
require("yoda.ui.startup_mode").setup()

vim.schedule(function()
  -- Optional machine-local overrides. pcall is deliberate here and is not the
  -- silent-degradation pattern ARCHITECTURE.md rules out: local.lua is
  -- user-authored and absent from the repo, so a typo in it must not brick
  -- startup for the distribution around it.
  local local_path = vim.fn.stdpath("config") .. "/lua/local.lua"
  if vim.uv.fs_stat(local_path) then
    local ok, err = pcall(require, "local")
    if not ok then
      vim.notify(
        "[yoda] Error in local.lua: " .. tostring(err),
        vim.log.levels.ERROR
      )
    end
  end

  -- Legacy dual-read, removed in TODO.md Step 2C: honour
  -- vim.g.yoda_large_file for anyone still setting it from local.lua.
  -- nil merges to the defaults, so the unset case is unaffected.
  require("yoda").setup({ large_file = vim.g.yoda_large_file })
end)
