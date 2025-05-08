-- lua/yoda/plugins/spec/git.lua

return {
  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup()

      vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
      vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame", {})
    end,
  },

  -- Vim-fugitive (Git CLI inside Neovim)
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },


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
      local neogit = require('neogit')
      neogit.setup {}

      -- Keybindings
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map('n', '<leader>gg', function() neogit.open() end, opts)
      map('n', '<leader>gc', function() neogit.open({ 'commit' }) end, opts)
      map('n', '<leader>gP', function() neogit.open({ 'push' }) end, opts)
      map('n', '<leader>gp', function() neogit.open({ 'pull' }) end, opts)
      map('n', '<leader>gl', function() neogit.open({ 'log' }) end, opts)
      map('n', '<leader>gs', function() neogit.open({ 'status' }) end, opts)
      map('n', '<leader>gb', ":Telescope git_branches<CR>", opts)
      map('n', '<leader>gB', ":G blame<CR>", opts)
      map('n', '<leader>gn', function() neogit.open({ 'branch' }) end, opts)
    end,
  },

  -- Git blame annotations (optional)
  -- {
  --   "f-person/git-blame.nvim",
  --   config = function()
  --     vim.g.gitblame_enabled = 0
  --   end,
  -- },
}

