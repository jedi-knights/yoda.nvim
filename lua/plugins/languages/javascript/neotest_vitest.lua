-- lua/plugins/languages/javascript/neotest_vitest.lua
-- Neotest Vitest adapter

return {
  "marilari88/neotest-vitest",
  dependencies = { "nvim-neotest/neotest" },
  ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
}
