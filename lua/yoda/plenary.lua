-- Test runner for Yoda.nvim
-- Uses plenary.nvim test harness
local M = {}

-- Try to load test harness (fallback to plenary)
local function get_test_harness()
  -- Check for plenary test harness
  local plenary_ok = pcall(require, "plenary.test_harness")
  if plenary_ok then
    return "plenary"
  end

  return nil
end

-- Run all tests in the "tests" directory
function M.run_all_tests()
  local harness = get_test_harness()

  if harness == "plenary" then
    local test_harness = require("plenary.test_harness")
    test_harness.test_directory("tests", {
      minimal_init = "./tests/minimal_init.lua",
    })
  else
    vim.notify("No test harness found. Install plenary.nvim", vim.log.levels.ERROR)
  end
end

-- Run tests in the currently open file
function M.run_current_file()
  local harness = get_test_harness()
  local file = vim.api.nvim_buf_get_name(0)

  if harness == "plenary" then
    local Path = require("plenary.path")
    if not Path:new(file):exists() then
      vim.notify("Current file does not exist on disk", vim.log.levels.WARN)
      return
    end
    local test_harness = require("plenary.test_harness")
    test_harness.test_directory(file, {
      minimal_init = "./tests/minimal_init.lua",
    })
  else
    vim.notify("No test harness found. Install plenary.nvim", vim.log.levels.ERROR)
  end
end

-- Alias for backwards compatibility and pytest-atlas fallback
M.run_current_test = M.run_current_file

-- Watch mode (auto-run on save)
function M.watch_tests()
  vim.notify("Watch mode is not supported with plenary test harness", vim.log.levels.WARN)
end

-- Register keymaps
-- NOTE: <leader>tt is now handled by pytest-atlas.nvim plugin
vim.keymap.set("n", "<leader>ta", M.run_all_tests, { desc = "Test: Run all tests" })
vim.keymap.set("n", "<leader>tw", M.watch_tests, { desc = "Test: Watch mode" })

return M
