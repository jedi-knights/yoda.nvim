-- Surround text objects easily (e.g., cs'" to change surrounding quotes)
return {
  "kylechui/nvim-surround",
  config = function()
    require("nvim-surround").setup()
  end,
}

