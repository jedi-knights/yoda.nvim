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
-- opts.defaults.{options,keymaps,autocmds} are real switches: yoda.options,
-- yoda.autocmds and yoda.keymaps each expose an explicit apply() rather than
-- acting on require(), so a starter can turn any of them off without forking
-- the plugin.

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

  -- Distribution defaults first -- commands and UI wiring below assume the
  -- option values and augroups these establish.
  if resolved.defaults.options then
    require("yoda.options").apply()
  end
  if resolved.defaults.keymaps then
    require("yoda.keymaps").apply()
  end
  if resolved.defaults.autocmds then
    require("yoda.autocmds").apply()
  end

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
