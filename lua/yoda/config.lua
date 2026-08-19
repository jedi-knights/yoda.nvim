-- lua/yoda/config.lua
-- Public config surface for yoda. Owns the defaults schema, the merge, and
-- the resolved-state holder consulted by every module that needs a knob.
--
-- Precedence (during the v1.0.0 transition):
--   1. opts passed to require("yoda").setup(opts)   -- new
--   2. vim.g.yoda_* globals                          -- legacy, dual-read
--   3. defaults() below
--
-- Phase 2 of the v1.0.0 restructure adds require("yoda").setup(opts) as the
-- primary entry point and drops the vim.g fallback. Until then, get()
-- returns nil unless resolve() has been called — callers explicitly handle
-- both cases so nothing breaks for users on the legacy path.

local M = {}

local DEFAULTS = {
  -- Advisory metadata — actual extras loading is via LazyVim-style
  -- `{ import = "yoda.extras.lang.rust" }` in the starter (see
  -- ARCHITECTURE.md §5).
  extras = {},

  ui = {
    verbose_startup = false,
    show_loading_messages = false,
    show_environment_notification = true,
    show_startup_report = false,
  },

  profiling = {
    enable = false,
    verbose = false,
  },

  -- Backend selection. nil = auto-detect via yoda-adapters.
  adapters = {
    notification = nil,
    picker = nil,
  },

  large_file = {
    enable = true,
    size_threshold = 100 * 1024, -- 100 KiB
    show_notification = true,
    disable = {
      editorconfig = true,
      treesitter = true,
      lsp = true,
      gitsigns = true,
      autosave = true,
      diagnostics = true,
      syntax = false,
      swap = true,
      undo = true,
      backup = true,
    },
  },

  yaml = {
    known_environments = { fastly = true, qa = true, prod = true },
    env_indent = 2,
    region_indent = 6,
  },

  -- Freeform override table forwarded to yoda.testing.defaults.get_config().
  -- Kept opaque here because the underlying schema (environments, markers,
  -- marker_defaults) is owned by that module.
  testing = {},

  startup_mode = {
    enable = true,
    triggers = { "claude", "c" },
  },

  -- Escape hatches for the starter — set false to opt out of yoda-owned
  -- defaults for options / keymaps / autocmds without forking the plugin.
  defaults = {
    options = true,
    keymaps = true,
    autocmds = true,
  },
}

M._resolved = nil

--- Return a fresh copy of the defaults schema. Never returns the module-local
--- DEFAULTS reference directly — mutation would leak across callers.
--- @return table
function M.defaults()
  return vim.deepcopy(DEFAULTS)
end

--- Merge user opts on top of defaults and store the result.
--- Called by yoda's setup(opts) in Phase 2 of the v1.0.0 restructure.
--- @param opts table|nil User-provided options
--- @return table Resolved config
function M.resolve(opts)
  vim.validate({ opts = { opts, "table", true } })
  M._resolved = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})
  return M._resolved
end

--- Return the resolved config, or nil if resolve() hasn't been called yet.
--- Callers on the legacy vim.g.yoda_* path handle the nil case by falling
--- back to their existing global reads.
--- @return table|nil
function M.get()
  return M._resolved
end

--- Test-only helper: clear the resolved state so specs start from a clean
--- slate.
function M._reset()
  M._resolved = nil
end

return M
