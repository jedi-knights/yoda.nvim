-- lua/yoda/plugins/spec/motion.lua
-- Consolidated motion plugin specifications

local plugins = {
  -- Leap - Fast motion between visible targets
  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  -- Vim Tmux Navigator - Seamless navigation between vim and tmux
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,  -- load immediately
  },

  -- Blink - Disabled to avoid conflicts with nvim-cmp
  -- This plugin provided blink completion but we're using nvim-cmp instead
  -- {
  --   "folke/flash.nvim",
  --   event = "VeryLazy",
  --   config = function()
  --     require("flash").setup()
  --   end,
  -- },
}

return plugins 