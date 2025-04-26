-- lua/yoda/plugins/spec/editing.lua

return {
  -- Commenting support
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Surround text objects easily (e.g., cs'" to change surrounding quotes)
  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- Autopairs for brackets, parentheses, etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter", -- Lazy-load when entering Insert mode
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Better 'jump to anywhere' motions (optional, cool later)
  -- {
  --   "ggandor/leap.nvim",
  --   config = function()
  --     require("leap").add_default_mappings()
  --   end,
  -- },
}

