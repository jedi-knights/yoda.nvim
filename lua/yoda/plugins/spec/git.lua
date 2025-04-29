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

  -- LazyGit integration
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Needed for lazygit.nvim to work
    },
    lazy = false,
    config = function()
      vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Open LazyGit" })
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

