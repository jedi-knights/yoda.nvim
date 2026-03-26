-- lua/plugins/pytest-atlas.lua

return {
  "ocrosby/pytest-atlas.nvim",
  lazy = true,
  keys = {
    {
      "<leader>tt",
      function()
        local ok, pytest_atlas = pcall(require, "pytest-atlas")
        if ok then
          pytest_atlas.run_tests()
        else
          vim.notify("Failed to load pytest-atlas: " .. tostring(pytest_atlas), vim.log.levels.ERROR)
        end
      end,
      desc = "Test: Run pytest with picker",
    },
  },
  cmd = { "PytestAtlasRun", "PytestAtlasStatus" },
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    local ok, pytest_atlas = pcall(require, "pytest-atlas")
    if not ok then
      vim.notify("Failed to load pytest-atlas: " .. tostring(pytest_atlas), vim.log.levels.ERROR)
      return
    end

    local success, err = pcall(function()
      pytest_atlas.setup({
        keymap = "<leader>tt",
        enable_keymap = false,
        picker = "snacks",
        debug = false,
      })
    end)

    if not success then
      vim.notify("pytest-atlas setup failed: " .. tostring(err), vim.log.levels.ERROR)
    end
  end,
}
