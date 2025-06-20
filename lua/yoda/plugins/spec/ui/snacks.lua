
return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    toggle = {
      which_key = true,
    },
    input = {},
    notifier = {},
    lazygit = {},
    indent = {},
    explorer = {
      replace_netrw = true,
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
      -- your terminal configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section in the documentation
      win = {
        style = "terminal"
      },
    },
    dashboard = {
      enabled = true,
      key = nil,        -- disables <g> for Snacks.dashboard
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
    words = {
      enabled = true,
    },
  },
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

    {
      "<leader>jj",
      function()
        Snacks.terminal.toggle("jjui", {
          win = {
            relative = "editor",
            position = "float",
            width = 0.85,
            height = 0.85,
            border = "rounded",
            title = " jjui ",
            title_pos = "center",
          },
        })
      end,
      desc = "Open jjui",
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
        require("yoda.terminals").open_sourced_terminal()
        --Snacks.terminal.toggle()
      end,
      desc = "Toggle floating terminal",
    },
    {
      "<esc><esc>",
      "<C-\\><C-n>",
      mode = "t",
      desc = "Exit terminal mode",
    },
  },
}
