-- lua/yoda/init.lua
-- Public API entry point for yoda.nvim: require("yoda").setup(opts).
--
-- This is the "opts" half of the config-vessel migration described in
-- ARCHITECTURE.md and lua/yoda/config.lua -- the primary path consumers on
-- the v1.0.0 plugin+starter install use, in place of vim.g.yoda_* globals.
-- Callers wire it from the starter's lazy.nvim spec:
--   { "jedi-knights/yoda.nvim", opts = {...}, config = function(_, opts)
--       require("yoda").setup(opts)
--     end }
--
-- NOTE: lua/options.lua, lua/autocmds.lua, and lua/yoda/keymaps apply their
-- effects as a side effect of require() (module caching makes a second
-- require() of an already-loaded module a no-op), so opts.defaults.
-- {options,keymaps,autocmds} remain advisory metadata only until those
-- modules are decomposed into explicit apply() functions decoupled from
-- require() -- tracked in TODO.md Step 2A. This entry point wires the
-- modules that are already require()/setup() decoupled: commands,
-- ui/large_file, ui/environment, ui/startup_mode, screencast.

local M = {}

--- Configure yoda.nvim. Safe to call more than once -- every module wired
--- below already guards its own re-registration (augroups use
--- `{ clear = true }`, user commands simply get redefined), matching the
--- idempotence contract described in ARCHITECTURE.md's Bootstrap flow.
--- @param opts table|nil User-provided options merged over yoda's defaults
--- @return table resolved config
function M.setup(opts)
  local config = require("yoda.config")
  -- config.resolve() already validates opts is a table-or-nil and raises
  -- otherwise; no need to duplicate that check here.
  local resolved = config.resolve(opts)

  require("yoda.commands")

  if resolved.large_file.enable then
    require("yoda.ui.large_file").setup(resolved.large_file)
  end

  local environment = require("yoda.ui.environment")
  environment.show_notification()
  environment.show_local_dev_notification()

  if resolved.startup_mode.enable then
    require("yoda.ui.startup_mode").setup()
  end

  require("yoda.screencast").setup()

  return resolved
end

return M
