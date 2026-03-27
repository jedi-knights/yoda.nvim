-- lua/plugins/git.lua
-- Git integration: signs/blame (gitsigns), history viewer (diffview), staging UI (neogit).

return {
  {
    "lewis6991/gitsigns.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        attach_to_untracked = true,
        -- Show author/date/commit inline at EOL after the cursor settles.
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          -- 800ms: only show blame when the cursor has been still for a moment.
          -- delay = 0 ran a git blame lookup on every CursorMoved, adding
          -- continuous I/O overhead during normal navigation.
          delay = 800,
          ignore_whitespace = false,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = "single",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          -- Refresh git signs after git operations
          vim.api.nvim_create_autocmd("User", {
            pattern = "NeogitStatusRefreshed",
            callback = function()
              gs.refresh()
            end,
          })

          vim.api.nvim_create_autocmd("User", {
            pattern = "NeogitCommitComplete",
            callback = function()
              gs.refresh()
            end,
          })

          vim.api.nvim_create_autocmd("User", {
            pattern = "NeogitPushComplete",
            callback = function()
              gs.refresh()
            end,
          })

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Git: Next hunk" })

          map("n", "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Git: Prev hunk" })

          -- Actions
          map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Git: Stage hunk" })
          map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Git: Reset hunk" })
          map("n", "<leader>hS", gs.stage_buffer, { desc = "Git: Stage buffer" })
          map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Git: Undo stage hunk" })
          map("n", "<leader>hR", gs.reset_buffer, { desc = "Git: Reset buffer" })
          map("n", "<leader>hp", gs.preview_hunk, { desc = "Git: Preview hunk" })
          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end, { desc = "Git: Blame line (full)" })
          map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Git: Toggle line blame" })
          map("n", "<leader>hd", gs.diffthis, { desc = "Git: Diff this" })
          map("n", "<leader>hD", function()
            gs.diffthis("~")
          end, { desc = "Git: Diff this (against last commit)" })
          -- <leader>hT not <leader>td: td conflicts with Test: Debug nearest
          map("n", "<leader>hT", gs.toggle_deleted, { desc = "Git: Toggle deleted lines" })

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Git: Select hunk" })
        end,
      })
    end,
  },

  {
    "sindrets/diffview.nvim",
    lazy = true,
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewRefresh" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup({
        view = {
          default = {
            layout = "diff2_horizontal",
          },
          merge_tool = {
            layout = "diff3_horizontal",
          },
        },
      })
    end,
  },

  {
    "NeogitOrg/neogit",
    lazy = true,
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "echasnovski/mini.icons",
      "sindrets/diffview.nvim",
    },
    config = function()
      require("neogit").setup({
        disable_signs = false,
        disable_context_highlighting = false,
        disable_commit_confirmation = false,
        auto_refresh = true,
        sort_branches = "-committerdate",
        disable_builtin_notifications = false,
        use_magit_keybindings = false,
        commit_popup = {
          kind = "split",
        },
        popup = {
          kind = "split",
        },
        signs = {
          hunk = { "", "" },
          item = { ">", "v" },
          section = { ">", "v" },
        },
        integrations = {
          diffview = true,
        },
        sections = {
          untracked = { folded = false, hidden = false },
          unstaged = { folded = false, hidden = false },
          staged = { folded = false, hidden = false },
          stashes = { folded = true, hidden = false },
          unpulled = { folded = true, hidden = false },
          unmerged = { folded = false, hidden = false },
          recent = { folded = true, hidden = false },
        },
      })
    end,
  },
}
