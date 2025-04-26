-- lua/yoda/plugins/spec/ui.lua

return {
  -- tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = false, -- (IMPORTANT) make sure it's not lazy-loaded after colorscheme tries to load it
    priority = 1000, -- (IMPORTANT) load it early, before other UI plugins
  },

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle File Explorer" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
          side = "left",
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
        },
      })
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          section_separators = "",
          component_separators = "",
        },
      })
    end,
  },

  -- Bufferline (tab-like buffer UI)
  {
    "akinsho/bufferline.nvim",
    event = "BufAdd",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          show_close_icon = false,
          separator_style = "slant",
        },
      })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    main = "ibl",
    opts = {}, -- Default setup
  },

  -- Pretty notifications (optional but very nice)
  {
    "rcarriga/nvim-notify",
    lazy = true,
    opts = {},
  },
}

