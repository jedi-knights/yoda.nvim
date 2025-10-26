-- lua/plugins/testing/pytest_atlas.lua
-- Pytest Atlas - Pytest runner with environment/marker selection

return {
  "ocrosby/pytest-atlas.nvim",
  lazy = false,
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    require("pytest-atlas").setup({
      keymap = "<leader>tt",
      enable_keymap = true,
      picker = "snacks",
      debug = false,
    })
  end,
}
