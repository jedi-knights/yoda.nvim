return {
  {
    "jedi-knights/pytest.nvim",
    dir = "~/src/github.com/jedi-knights/pytest.nvim",
    lazy = false,
    ft = "python",
    config = function()
      require("pytest").setup()
    end,
  },
}

