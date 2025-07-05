-- lua/yoda/plugins/spec/ui.lua
-- Consolidated UI plugins configuration

return {
  -- Snacks UI framework
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- For file icons
    },
    opts = {
      toggle = {
        which_key = true,
      },
      input = {},
      notifier = {},
      lazygit = {},
      indent = {},
      explorer = {
        enabled = true,
        replace_netrw = true,
        show_hidden = true,
        ignore = {}, -- disables all default ignore patterns
        refresh_on_git = true,
      },
      picker = {
        sources = {
          explorer = {
            layout = { preset = "sidebar", preview = false },
            hidden = true,
          },
        },
      },
      terminal = {
        win = {
          style = "terminal",
          position = "float",
          width = 0.8,
          height = 0.8,
          border = "rounded",
          relative = "editor",
        },
        persistent = true,
        autoinsert = true,
      },
      dashboard = {
        enabled = true,
        key = "g",        -- enables <g> for Snacks.dashboard
        preset = {
          header = [[
██╗   ██╗ ██████╗ ██████╗  █████╗
╚██╗ ██╔╝██╔═══██╗██╔══██╗██╔══██╗
 ╚████╔╝ ██║   ██║██║  ██║███████║
  ╚██╔╝  ██║   ██║██║  ██║██╔══██║
   ██║   ╚██████╔╝██████╔╝██║  ██║
   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═╝

                YODA.NVIM
              Do or do not.
              There is no try.
              ]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      bigfile = {
        enabled = true,
      },
      image = {
        enabled = true,
      },
      quickfile = {
        enabled = true,
      },
      scope = {
        enabled = true,
      },
      scroll = {
        enabled = true,
      },
      statuscolumn = {
        enabled = true,
      },
      statusline = {
        enabled = true,
        style = "minimal", -- Use Snacks statusline instead of mini.statusline
      },
      tabline = {
        enabled = true,
        style = "minimal", -- Use Snacks tabline instead of mini.tabline
      },
      words = {
        enabled = true,
      },
    },
    init = function()
      -- Set up autocmd to refresh Snacks Explorer on git status changes
      vim.api.nvim_create_autocmd("User", {
        pattern = "NeogitStatusRefresh",
        callback = function()
          local ok, snacks_explorer = pcall(require, "snacks.explorer")
          if ok then
            -- Find all Snacks Explorer windows and refresh them
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == "snacks-explorer" then
                if snacks_explorer.refresh then
                  snacks_explorer.refresh()
                end
              end
            end
          end
        end,
      })
    end,
    config = function()
      -- Configure UI selectors after Snacks is loaded
      vim.ui.select = require("snacks.picker").select
      vim.ui.input = require("snacks.input").input
      
      -- Register custom test picker with Snacks
      local snacks = require("snacks")
      if snacks.picker and snacks.picker.register then
        snacks.picker.register("yoda-test", {
          name = "🧪 Yoda Test Picker",
          description = "Run tests with environment and region selection",
          icon = "🧪",
          action = function()
            require("yoda.testpicker").run()
          end,
        })
      end
    end,
    keys = {
      -- Smart file search (buffers, project files)
      {
        "<leader><leader>",
        function()
          Snacks.picker.smart({
            multi = {
              "buffers",
              {
                source = "files",
                cwd = vim.fn.getcwd(),
                hidden = true,
                ignore = { "**/.jj/**" },
              },
            },
          })
        end,
        desc = "[ ] Search Files",
      },
      -- Grep (live grep)
      {
        "<leader>/",
        function()
          Snacks.picker.grep({ hidden = true })
        end,
        desc = "[/] Search by Grep",
      },

      -- Help and keymaps
      {
        "<leader>sh",
        function()
          Snacks.picker.help()
        end,
        desc = "[S]earch [H]elp",
      },
      {
        "<leader>sk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "[S]earch [K]eymaps",
      },

      -- File pickers
      {
        "<leader>sf",
        function()
          Snacks.picker.files()
        end,
        desc = "[S]earch [F]iles",
      },
      {
        "<leader>s.",
        function()
          Snacks.picker.recent()
        end,
        desc = '[S]earch Recent Files (["."] for repeat)',
      },

      -- Word + Grep
      {
        "<leader>sw",
        function()
          Snacks.picker.grep_word()
        end,
        desc = "[S]earch current [W]ord",
      },
      {
        "<leader>sg",
        function()
          Snacks.picker.grep()
        end,
        desc = "[S]earch by [G]rep",
      },

      -- LSP + diagnostics
      {
        "<leader>sd",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "[S]earch [D]iagnostics",
      },

      -- Resume last picker
      {
        "<leader>sr",
        function()
          Snacks.picker.resume()
        end,
        desc = "[S]earch [R]esume",
      },

      -- Picker picker
      {
        "<leader>ss",
        function()
          Snacks.picker()
        end,
        desc = "[S]earch [S]elect Picker",
      },
      
      -- Test picker (also available in picker picker)
      {
        "<leader>tt",
        function()
          require("yoda.testpicker").run()
        end,
        desc = "[T]est [T]est Picker",
      },

      -- open Snacks explorer (like NeoTree)
      {
        "<leader>se",
        function()
          Snacks.explorer.open()
        end,
        desc = "[E]xplorer",
      },

      -- open Snacks dashboard
      {
        "<leader>d",
        function()
          Snacks.dashboard.open()
        end,
        desc = "[D]ashboard",
      },

      {
        "<leader>n",
        function()
          Snacks.picker.notifications()
        end,
        desc = "[N]otification History",
      },
      {
        "<leader>.",
        function()
          Snacks.terminal.toggle()
        end,
        desc = "Toggle floating terminal",
      },
      -- Test picker integration
      {
        "<leader>tp",
        function()
          require("yoda.testpicker").run()
        end,
        desc = "Run tests with Yoda test picker",
      },
      {
        "<esc><esc>",
        "<C-\\><C-n>",
        mode = "t",
        desc = "Exit terminal mode",
      },
    },
  },

  -- Telescope (required for ChatGPT.nvim)
  {
    "nvim-telescope/telescope.nvim",
    version = false,
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },

  -- Mini.nvim utilities
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.comment").setup()
      require("mini.surround").setup()
      require("mini.pairs").setup()
      require("mini.indentscope").setup()
    end,
  },

  -- Noice for better UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    }
  },

  -- Removed duplicate which-key entry (keeping the one below)

  -- TokyoNight colorscheme moved to separate spec file

  -- Image paste support
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      -- add options here
    },
    keys = {
      -- suggested keymap
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
    },
  },

  -- Devicons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    priority = 1000,
    config = function()
      require("nvim-web-devicons").setup({
        -- Enable icons
        default = true,
        -- Enable strict mode (only show icons for supported filetypes)
        strict = false,
        -- Override or add specific icons
        override = {
          zsh = {
            icon = "",
            color = "#428850",
            cterm_color = "65",
            name = "Zsh"
          },
          fish = {
            icon = "",
            color = "#4d5a5e",
            cterm_color = "240",
            name = "Fish"
          },
        },
        -- Override by filename
        override_by_filename = {
          [".gitignore"] = {
            icon = "",
            color = "#f1502f",
            name = "Gitignore"
          },
          ["README.md"] = {
            icon = "",
            color = "#519aba",
            name = "Readme"
          },
          ["Makefile"] = {
            icon = "",
            color = "#427819",
            name = "Makefile"
          },
          ["KEYMAPS.md"] = {
            icon = "🗝️",
            color = "#519aba", 
            name = "Keymaps"
          },
        },
        -- Override by file extension
        override_by_extension = {
          ["log"] = {
            icon = "",
            color = "#81e043",
            name = "Log"
          },
          ["feature"] = {
            icon = "",
            color = "#44a51c",
            name = "Gherkin"
          },
        },
        -- Globally enable default icons (set to true if you don't have a Nerd Font)
        color_icons = true,
      })
    end,
  },

  -- Trouble for diagnostics
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  -- Removed dressing.nvim to avoid conflicts with which-key

  -- Which-key moved to separate spec file
} 