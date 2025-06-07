-- Autopairs for brackets, parentheses, etc.
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter", -- Lazy-load when entering Insert mode
  config = function()
    require("nvim-autopairs").setup()
  end,
}

