-- Load keymap modules individually so one failure doesn't cascade to the rest.
-- debug keymaps are in lua/plugins/debugging.lua (lazy keys — loads dap on first keypress)
local keymap_modules = {
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

for _, mod in ipairs(keymap_modules) do
  local ok, err = pcall(require, mod)
  if not ok then
    vim.notify("[yoda] Failed to load " .. mod .. ": " .. tostring(err), vim.log.levels.WARN)
  end
end
