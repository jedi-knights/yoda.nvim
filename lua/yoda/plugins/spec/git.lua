-- lua/yoda/plugins/spec/git.lua
-- Consolidated git plugin specifications

local plugins = {
  -- Git Blame - Inline git blame information
  {
    "f-person/git-blame.nvim",
    config = function()
      vim.g.gitblame_enabled = 0
    end,
  },

  -- Git Signs - Git integration for signs and highlights
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "▌" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 0,
        virt_text_pos = "eol",
        virt_text = { { "blame", "Comment" } },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = vim.tbl_extend("force", { buffer = bufnr }, opts or {})
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "<leader>gp", gs.preview_hunk)
        map("n", "<leader>gt", gs.toggle_current_line_blame)
      end,
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function(_, opts)
      local plugin_loader = require("yoda.utils.plugin_loader")
      plugin_loader.safe_plugin_setup("gitsigns", opts)

      vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
      vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame", {})
    end,
  },

  -- Neogit - Modern git interface
  {
    "NeogitOrg/neogit",
    keys = { "<leader>gg" },
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua",              -- optional
      "echasnovski/mini.pick",         -- optional
      "folke/snacks.nvim",             -- optional
    },
    config = function()
      local neogit = require("neogit")

      -- 🧼 DRY: Refresh Snacks Explorer helper
      local function refresh_snacks_explorer()
        -- Schedule the refresh to avoid timing issues
        vim.schedule(function()
          -- Trigger User autocmds that explorers might listen to
          vim.api.nvim_exec_autocmds("User", {
            pattern = "NeogitStatusRefresh",
          })
          
          -- Find and refresh any open Snacks Explorer windows
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "snacks-explorer" then
              -- Force a refresh by calling the explorer refresh function
              local ok, snacks_explorer = pcall(require, "snacks.explorer")
              if ok and snacks_explorer.refresh then
                snacks_explorer.refresh()
              else
                -- Fallback: close and reopen the explorer
                vim.api.nvim_win_close(win, false)
                vim.defer_fn(function()
                  snacks_explorer.open()
                end, 100)
              end
            end
          end
        end)
      end

      neogit.setup({
        disable_commit_confirmation = true,
        disable_insert_on_commit = false,
        integrations = {
          diffview = true,
          telescope = true,
          fzf = true,
          mini = true,
          snacks = true,
        },
        event_handlers = {
          {
            event = "post_commit",
            handler = refresh_snacks_explorer,
          },
          {
            event = "post_stage",
            handler = refresh_snacks_explorer,
          },
          {
            event = "post_unstage",
            handler = refresh_snacks_explorer,
          },
          {
            event = "post_push",
            handler = refresh_snacks_explorer,
          },
        },
      })

      -- 🔑 Keymaps
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map("n", "<leader>gg", function()
        neogit.open()
      end, vim.tbl_extend("force", opts, { desc = "Neogit: Open" }))

      map("n", "<leader>gB", ":G blame<CR>", vim.tbl_extend("force", opts, {
        desc = "Git: Fugitive Blame",
      }))
    end,
  },

  -- Vim Fugitive - Git commands
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },
}

return plugins 