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
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    lazy = false,
    ---@module "neo-tree"
    ---@type neotree.Config?
    opts = {
      window = {
        width = 35,
        auto_expand_width = true,
        mappings = {
        }, -- (leave your custom mappings here later)
      },
      filesystem = {
        filtered_items = {
          visible = false, -- show hidden file
          show_hidden_count = true,
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_by_name = {
            "package-lock.json",
            ".changeset",
            ".prettierrc.json",
            ".DS_Store",
            "thumbs.db",
          },
          never_show = { ".git" },
        },
        follow_current_file = {
          enabled = true, -- follow the current buffer
          leave_dirs_open = false, -- optionally collapse dirs unrelated to the file
        },
        use_libuv_file_watcher = true, -- use vim.loop to watch for changes
      },
      buffers = {
        follow_current_file = {
          enabled = true, -- also follow in buffers view
        },
      },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "dracula",
          section_separators = "",
          component_separators = "",
        },
      })
    end,
  },

  -- Mini Icons
  {
    "echasnovski/mini.nvim",
    version = false,
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
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          offsets = {
            {
              filetype = "neo-tree",
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

