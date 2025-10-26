-- lua/plugins/testing/neotest.lua
-- Neotest - Testing framework

return {
  "nvim-neotest/neotest",
  lazy = true,
  cmd = { "Neotest", "NeotestRun", "NeotestSummary", "NeotestOutput" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
  },
  config = function()
    require("yoda.testing.neotest_config").setup()
  end,
}
