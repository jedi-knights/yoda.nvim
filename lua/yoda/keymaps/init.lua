-- lua/yoda/keymaps/init.lua
-- Aggregates the per-domain keymap modules.
--
-- Applying is an explicit call, not a require() side effect, so a starter can
-- opt out via opts.defaults.keymaps without forking the plugin.
--
-- Debug keymaps are not here -- they live in lua/yoda/plugins/dap-core.lua as
-- lazy `keys`, so nvim-dap loads on first keypress rather than at startup.

local M = {}

-- Loaded individually so one broken module does not cascade to the rest.
M.modules = {
  "yoda.keymaps.help",
  "yoda.keymaps.explorer",
  "yoda.keymaps.window",
  "yoda.keymaps.lsp",
  "yoda.keymaps.git",
  "yoda.keymaps.testing",
  "yoda.keymaps.coverage",
  "yoda.keymaps.rust",
  "yoda.keymaps.python",
  "yoda.keymaps.javascript",
  "yoda.keymaps.go",
  "yoda.keymaps.terminal",
  "yoda.keymaps.utilities",
  "yoda.keymaps.modes",
  "yoda.keymaps.devtools",
}

--- Load every keymap module. Safe to call more than once: the modules set
--- their maps via vim.keymap.set, which overwrites rather than stacking.
--- @return string[] failed Module names that raised, empty on full success
function M.apply()
  local failed = {}
  for _, mod in ipairs(M.modules) do
    local ok, err = pcall(require, mod)
    if not ok then
      table.insert(failed, mod)
      vim.notify(
        "[yoda] Failed to load " .. mod .. ": " .. tostring(err),
        vim.log.levels.WARN
      )
    end
  end
  return failed
end

return M
