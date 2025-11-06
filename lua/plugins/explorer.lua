-- lua/plugins_new/explorer.lua
-- File explorer and navigation plugins

return {
  -- Snacks - Modern UI framework with explorer
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("snacks").setup({
        explorer = {
          enabled = true,
          win = {
            position = "left",
            width = 30,
            wo = {
              winfixwidth = true,
            },
          },
        },
        picker = {
          enabled = false, -- Disabled: Snacks picker causes crashes in Neovim 0.11.x - use Telescope instead
          ui_select = false, -- Disabled: Using dressing.nvim instead
        },
        terminal = {
          enabled = true,
          auto_close = true, -- Auto-close terminal buffer when process exits (no "Process Exited" message)
        },
        input = {
          enabled = true,
          win = {
            border = "rounded",
          },
        },
      })
    end,
  },

  -- Devicons - File type icons
  {
    "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
      require("nvim-web-devicons").setup({
        default = true,
        strict = false,
      })
    end,
  },
}
