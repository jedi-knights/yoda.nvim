-- lua/yoda/plugins/spec/ui.lua
-- Consolidated UI and telescope plugin specifications

local plugins = {
  -- Tokyo Night - Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false, -- (IMPORTANT) make sure it's not lazy-loaded after colorscheme tries to load it
    priority = 1000, -- (IMPORTANT) load it early, before other UI plugins
  },

  -- Devicons - File type icons
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
          ["docs/KEYMAPS.md"] = {
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

  -- Mini - Minimal UI replacements
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- Core replacements
      require("mini.comment").setup()
      require("mini.surround").setup()
      require("mini.pairs").setup()

      -- UI replacements
      -- require("mini.statusline").setup() -- Disabled in favor of custom statusline
      require("mini.tabline").setup()
      require("mini.indentscope").setup({
        draw = {
          delay = 100,
          animation = require("mini.indentscope").gen_animation.none()
        },
        -- Disable indentscope on dashboard and other special buffers
        options = {
          try_as_border = true,
        },
        symbol = "│",
        -- Exclude certain filetypes from showing indentation guides
        exclude = {
          "dashboard",
          "snacks-dashboard",
          "help",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      })
    end,
  },

  -- Noice - Better UI for cmdline and messages
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify", -- optional, for better messages
    },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
      },
      views = {
        cmdline_popup = {
          position = {
            row = "40%",
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
          border = {
            style = "rounded",
          },
          win_options = {
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          },
        },
      },
    },
    config = function(_, opts)
      local plugin_loader = require("yoda.utils.plugin_loader")
      plugin_loader.safe_plugin_setup("noice", opts)
    end,
  },

  -- Showkeys - Key press display
  {
    "nvzone/showkeys",
    cmd = "ShowkeysToggle",
    config = function(_, opts)
      local plugin_loader = require("yoda.utils.plugin_loader")
      plugin_loader.safe_plugin_setup("showkeys", opts)
    end,
    opts = {
      winopts = {
        focusable = false,
        relative = "editor",
        style = "minimal",
        border = "rounded",
        height = 1,
        row = 1,
        col = 0,
        zindex = 100, -- ensure it is above other floating windows
      },

      winhl = "FloatBorder:Comment,Normal:Normal",

      timeout = 8, -- in secs
      maxkeys = 6,
      show_count = true,
      excluded_modes = {}, -- example: {"i"}

      -- bottom-left, bottom-right, bottom-center, top-left, top-right, top-center
      position = "top-right",

      keyformat = {
        ["<BS>"] = "󰁮 ",
        ["<CR>"] = "󰘌",
        ["<Space>"] = "󱁐",
        ["<Up>"] = "󰁝",
        ["<Down>"] = "󰁅",
        ["<Left>"] = "󰁍",
        ["<Right>"] = "󰁔",
        ["<PageUp>"] = "Page 󰁝",
        ["<PageDown>"] = "Page 󰁅",
        ["<M>"] = "Alt",
        ["<C>"] = "Ctrl",
      },
    }
  },

  -- Snacks - Modern UI framework
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
      input = {
        width = 60, -- number of columns
        win = {
          position = "float",
          border = "rounded",
          relative = "editor",
          style = "minimal",
        },
      },
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
        layout = {
          position = "float",
          width = 0.8,
          height = 0.8,
          border = "rounded",
          relative = "editor",
        },
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
        key = nil,        -- disables <g> for Snacks.dashboard
        layout = {
          position = "center",
          width = 80,
          height = 20,
          border = "rounded",
        },
        preset = {
          header = [[
██╗   ██╗ ██████╗ ██████╗  █████╗
╚██╗ ██╔╝██╔═══██╗██╔══██╗██╔══██╗
 ╚████╔╝ ██║   ██║██║  ██║███████║
  ╚██╔╝  ██║   ██║██║  ██║██╔══██║
   ██║   ╚██████╔╝██████╔╝██║  ██║
   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═╝
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
        enabled = false, -- Disable Snacks statusline in favor of lualine
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

      -- open Snacks explorer (like NeoTree)
      {
        "<leader>se",
        function()
          Snacks.explorer.open()
        end,
        desc = "[E]xplorer",
      },
      -- Focus Snacks explorer
      {
        "<leader>ef",
        function()
          Snacks.explorer.open()
        end,
        desc = "[E]xplorer [F]ocus",
      },
      -- Toggle Snacks explorer
      {
        "<leader>et",
        function()
          Snacks.explorer.open()
        end,
        desc = "[E]xplorer [T]oggle",
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
          require("yoda.core.functions").open_floating_terminal()
        end,
        desc = "Open floating terminal (venv aware)",
      },
      {
        "<esc><esc>",
        "<C-\\><C-n>",
        mode = "t",
        desc = "Exit terminal mode",
      },
    },
  },

  -- Trouble - Quickfix and diagnostics UI
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
      {
        "<leader>xj",
        "<cmd>Trouble lsp toggle<cr>",
        desc = "LSP Definitions /references / ... (Trouble)",
      },
    },
  },

  -- Telescope - Fuzzy finder (specialized use cases only)
  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-telescope/telescope-dap.nvim" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          path_display = { "smart" },
          layout_config = {
            horizontal = { width = 0.9 },
          },
          file_ignore_patterns = {
            "^.git/",
            "node_modules",
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--no-ignore",
          },
        },
        pickers = {
          find_files = {
            theme = "ivy",
            hidden = true,
            no_ignore = true,
          },
        },
        extensions = {
          fzf = {},
        },
      })

      -- Load extensions (only essential ones)
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
      telescope.load_extension("dap")

      local opts = { noremap = true, silent = true }
      local keymap = vim.keymap
      local builtin = require("telescope.builtin")

      -- Specialized Telescope keymaps (Snacks handles general file finding)
      keymap.set("n", "<leader>uc", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config"), hidden = true, no_ignore = true })
      end, { desc = "Find User Config" })

      keymap.set("n", "<leader>up", function()
        builtin.find_files({ cwd = vim.fn.stdpath("data") .. "/lazy", hidden = true, no_ignore = true })
      end, { desc = "Find Plugin Files" })
    end,
  },

  -- Lualine for statusline with mode indicator
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    },
  },
}

return plugins 