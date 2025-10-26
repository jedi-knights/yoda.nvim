-- lua/plugins/core/which_key.lua
-- Which-Key - Keymap helper

return {
  "folke/which-key.nvim",
  lazy = true,
  event = "VeryLazy",
  config = function()
    require("which-key").setup()
  end,
}
