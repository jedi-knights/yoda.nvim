-- lua/plugins/languages/javascript/neotest_jest.lua
-- Neotest Jest adapter

return {
  "nvim-neotest/neotest-jest",
  dependencies = { "nvim-neotest/neotest" },
  ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
}
