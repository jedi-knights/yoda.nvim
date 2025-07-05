-- lua/yoda/plugins/spec/navigation.lua
-- Consolidated navigation and motion plugins configuration

return {

  -- Leap for enhanced motion
  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  -- Tmux navigator
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,  -- load immediately
  },

  -- Note: Blink is disabled to avoid conflicts with nvim-cmp
  -- This plugin provided blink completion but we're using nvim-cmp instead
} 