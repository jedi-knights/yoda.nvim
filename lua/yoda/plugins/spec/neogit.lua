return {
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
    local neogit = require('neogit')
    neogit.setup({
      disable_commit_confirmation = true,
      disable_insert_on_commit = false,
      integrations = {
        diffview = true, -- requires diffview.nvim
        telescope = true, -- requires telescope.nvim
        fzf = true, -- requires fzf-lua
        mini = true, -- requires mini.pick
        snacks = true, -- requires snacks.nvim
      },
      event_handlers = {
        -- Trigger when a commit finishes
        {
          event = "post_commit",
          handler = function()
            require("neo-tree.sources.manager").refresh("filesystem")
            require("neo-tree.sources.manager").refresh("git_status")
          end,
        },
        -- Trigger after staging files
        {
          event = "post_stage",
          handler = function()
            require("neo-tree.sources.manager").refresh("filesystem")
            require("neo-tree.sources.manager").refresh("git_status")
          end,
        },
        -- Trigger after unstaging
        {
          event = "post_unstage",
          handler = function()
            require("neo-tree.sources.manager").refresh("filesystem")
            require("neo-tree.sources.manager").refresh("git_status")
          end,
        },
      },
    })

    -- Keybindings
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    map('n', '<leader>gg', function() neogit.open() end, vim.tbl_extend("force", opts, { desc = "Neogit: Open" }))

    map('n', '<leader>gc', function() neogit.open({ kind = 'commit' }) end, vim.tbl_extend("force", opts, { desc = "Neogit: Commit" }))
    map('n', '<leader>gP', function() neogit.open({ kind = 'push' }) end, vim.tbl_extend("force", opts, { desc = "Neogit: Push" }))
    map('n', '<leader>gp', function() neogit.open({ kind = 'pull' }) end, vim.tbl_extend("force", opts, { desc = "Neogit: Pull" }))
    map('n', '<leader>gl', function() neogit.open({ kind = 'log' }) end, vim.tbl_extend("force", opts, { desc = "Neogit: Log" }))
    map('n', '<leader>gn', function() neogit.open({ kind = 'branch' }) end, vim.tbl_extend("force", opts, { desc = "Neogit: Branch" }))

    map('n', '<leader>gb', ":Telescope git_branches<CR>", vim.tbl_extend("force", opts, { desc = "Git: Telescope Branches" }))
    map('n', '<leader>gB', ":G blame<CR>", vim.tbl_extend("force", opts, { desc = "Git: Fugitive Blame" }))
  end,
}

