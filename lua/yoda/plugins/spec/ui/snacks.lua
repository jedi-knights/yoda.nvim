
return {
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
      enabled = true,
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
    {
      "<esc><esc>",
      "<C-\\><C-n>",
      mode = "t",
      desc = "Exit terminal mode",
    },
  },
}
