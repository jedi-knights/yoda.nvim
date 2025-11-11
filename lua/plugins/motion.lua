-- lua/plugins_new/motion.lua
-- Motion and navigation plugins

return {
  -- Leap - Fast motion between visible targets
  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    keys = {
      { "s", "<Plug>(leap)", mode = { "n", "x", "o" }, desc = "Leap forward" },
      { "S", "<Plug>(leap-from-window)", mode = "n", desc = "Leap from window" },
    },
  },

  -- Vim Tmux Navigator - Seamless navigation between vim and tmux
  {
    "christoomey/vim-tmux-navigator",
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Navigate previous" },
    },
  },
}
