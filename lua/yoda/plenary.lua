-- Test runner for Yoda.nvim
-- Prefers snacks.nvim test harness, falls back to plenary
local M = {}

-- Try to load test harness (prefer snacks, fallback to plenary)
local function get_test_harness()
  -- Try snacks first (preferred)
  local snacks_ok = pcall(require, "snacks")
  if snacks_ok then
    return "snacks"
  end

  -- Fallback to plenary
  local plenary_ok = pcall(require, "plenary.test_harness")
  if plenary_ok then
    return "plenary"
  end

  return nil
end

-- Run all tests in the "tests" directory
function M.run_all_tests()
  local harness = get_test_harness()

  if harness == "snacks" then
    vim.cmd("SnacksTest tests/")
  elseif harness == "plenary" then
    local test_harness = require("plenary.test_harness")
    test_harness.test_directory("tests", {
      minimal_init = "./tests/minimal_init.lua",
    })
  else
    vim.notify("No test harness found. Install snacks.nvim or plenary.nvim", vim.log.levels.ERROR)
  end
end

-- Run tests in the currently open file
function M.run_current_file()
  local harness = get_test_harness()
  local file = vim.api.nvim_buf_get_name(0)

  if harness == "snacks" then
    vim.cmd("SnacksTest " .. file)
  elseif harness == "plenary" then
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
    vim.notify("No test harness found. Install snacks.nvim or plenary.nvim", vim.log.levels.ERROR)
  end
end

-- Alias for backwards compatibility and pytest-atlas fallback
M.run_current_test = M.run_current_file

-- Watch mode (auto-run on save)
function M.watch_tests()
  local harness = get_test_harness()

  if harness == "snacks" then
    vim.cmd("SnacksTestWatch tests/")
  else
    vim.notify("Watch mode requires snacks.nvim", vim.log.levels.ERROR)
  end
end

-- Register keymaps
-- NOTE: <leader>tt is now handled by pytest-atlas.nvim plugin
vim.keymap.set("n", "<leader>ta", M.run_all_tests, { desc = "Test: Run all tests" })
vim.keymap.set("n", "<leader>tw", M.watch_tests, { desc = "Test: Watch mode" })

return M
