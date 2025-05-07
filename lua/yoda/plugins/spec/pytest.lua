return {
  {
    "jedi-knights/pytest.nvim",
    dir = "~/src/github/jedi-knights/pytest.nvim",
    lazy = false,
    ft = "python",
    config = function()
      require("pytest").setup()
    end,
  },
}

