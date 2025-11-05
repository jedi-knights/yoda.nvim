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
          enabled = true,
          ui_select = false, -- Disabled: Using dressing.nvim instead (Snacks picker causes crashes)
          sources = {
            explorer = {
              hidden = true, -- Show hidden files/folders by default
            },
          },
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
