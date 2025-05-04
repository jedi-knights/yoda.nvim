return {
  {
    "jedi-knights/pytest.nvim",
    ft = "python",
    config = function()
      require("pytest").setup()
    end,
  },
}
