return {
  "jedi-knights/pytest.nvim",
  dir = "~/src/github.com/jedi-knights/pytest.nvim",
  lazy = false,

  cond = function()
    return require("pytest.detect").should_load_plugin()
  end,

  config = function()
    local ok, pytest = pcall(require, "pytest")
    if ok then
      pytest.setup()
    else
      vim.notify("pytest.nvim failed to load", vim.log.levels.WARN)
    end

    vim.keymap.set("n", "<leader>pt", function()
      require("pytest.commands").start()
    end, { desc = "Run pytest" })
  end,
}

