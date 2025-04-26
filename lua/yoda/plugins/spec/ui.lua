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
    lazy = false, -- load immediately at startup
    priority = 50, -- load before Lualine, Bufferline, etc...
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

      local function open_nvim_tree(data)
        -- data.file is empty if no file passed
        local no_name = data.file == "" and vim.bo[data.buf].buftype == ""
        local directory = vim.fn.isdirectory(data.file) == 1

        -- open nvim-tree ONLY if no name file
        if no_name or directory then
           require("nvim-tree.api").tree.open()
        end
      end

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = open_nvim_tree
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
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "center",
              separator = true,
            },
          },
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

