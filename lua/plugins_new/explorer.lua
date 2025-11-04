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
  },

  -- nvim-tree - File explorer
  {
    "nvim-tree/nvim-tree.lua",
    lazy = true,
    cmd = { "NvimTreeToggle", "NvimTreeOpen" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
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
