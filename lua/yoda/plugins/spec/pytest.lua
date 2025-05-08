return {
  {
    "jedi-knights/pytest.nvim",
    dir = "~/src/github.com/jedi-knights/pytest.nvim",
    lazy = false,
    ft = "python",
    config = function()
      local ok, pytest = pcall(require, "pytest")
      if ok then
        pytest.setup()
      else
        vim.notify("pytest.nvim failed to load", vim.log.levels.WARN)
      end
    end,
  },
}

