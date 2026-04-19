-- lua/plugins/mini.lua
-- Consolidated mini.nvim modules. Each entry keeps its own load strategy —
-- icons must be eager (devicons shim), pairs on InsertEnter, the rest VeryLazy.

return {
  -- File type icons. Loaded eagerly so icons are available at startup.
  {
    "echasnovski/mini.icons",
    lazy = false,
    config = function()
      require("mini.icons").setup()
    end,
  },

  -- Auto-close brackets, quotes, and other paired characters.
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Extended text objects using treesitter. n_lines=50 looks up to 50 lines
  -- away for object boundaries, handling long functions without missing closing braces.
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = { n_lines = 50 },
  },

  -- Add/change/delete surrounding characters.
  -- gz prefix chosen to avoid conflict with leap.nvim's s/S bindings.
  -- gza{motion}{char} — add, gzd{char} — delete, gzr{old}{new} — replace.
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "gza",
        delete = "gzd",
        replace = "gzr",
        find = "gzf",
        find_left = "gzF",
        highlight = "gzh",
        update_n_lines = "gzn",
      },
    },
  },

  -- Extra pickers (oldfiles, keymaps, diagnostics, LSP, git, etc.)
  -- Loaded as a dependency of mini.pick — no standalone lazy trigger needed.
  {
    "echasnovski/mini.extra",
    lazy = true,
  },

  -- Fuzzy finder replacing fzf-lua. Keybindings match Jesalx/nixos-config style.
  {
    "echasnovski/mini.pick",
    dependencies = { "echasnovski/mini.extra" },
    keys = {
      {
        "<leader><leader>",
        function()
          require("mini.pick").builtin.files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>/",
        function()
          require("mini.pick").builtin.grep_live()
        end,
        desc = "Live Grep",
      },
      {
        "<leader>sh",
        function()
          require("mini.pick").builtin.help()
        end,
        desc = "Search Help",
      },
      {
        "<leader>sk",
        function()
          require("mini.extra").pickers.keymaps()
        end,
        desc = "Search Keymaps",
      },
      {
        "<leader>s.",
        function()
          require("mini.extra").pickers.oldfiles()
        end,
        desc = "Search Recent Files",
      },
      {
        "<leader>sd",
        function()
          require("mini.extra").pickers.diagnostic()
        end,
        desc = "Search Diagnostics",
      },
      {
        "<leader>sb",
        function()
          require("mini.pick").builtin.buffers()
        end,
        desc = "Search Buffers",
      },
      {
        "<leader>sc",
        function()
          local items = {}
          -- Git changed files (staged + unstaged + untracked)
          local diff = vim.fn.systemlist("git diff --name-only")
          local untracked = vim.fn.systemlist("git ls-files --others --exclude-standard")
          for _, f in ipairs(diff) do
            table.insert(items, f)
          end
          for _, f in ipairs(untracked) do
            table.insert(items, f)
          end
          require("mini.pick").start({
            source = {
              name = "Git Changed",
              items = items,
              choose = function(item)
                vim.cmd("edit " .. vim.fn.fnameescape(item))
              end,
            },
          })
        end,
        desc = "Search Git Changed Files",
      },
    },
    config = function()
      require("mini.pick").setup({
        mappings = {
          move_down = "<C-j>",
          move_up = "<C-k>",
        },
        window = {
          config = {
            border = "rounded",
          },
        },
      })
    end,
  },
}
