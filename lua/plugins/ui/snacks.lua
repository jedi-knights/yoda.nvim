-- lua/plugins/ui/snacks.lua
-- Snacks - Modern UI framework

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("snacks").setup({
      explorer = {
        enabled = true,
        show_hidden = true,
        win = {
          position = "left",
          width = 30,
          wo = {
            winfixwidth = true,
          },
        },
      },
      picker = {
        enabled = true,
      },
      terminal = {
        enabled = true,
      },
      input = {
        enabled = true,
        win = {
          border = "rounded",
        },
      },
    })
  end,
}
