local test_harness = require("plenary.test_harness")
local Path = require("plenary.path")

-- Helper to run all tests in the "tests" directory
local function run_all_tests()
  test_harness.test_directory("tests", {
    minimal_init = "./tests/minimal_init.lua", -- optional
  })
end

-- Helper to run tests only in the currently open file
local function run_current_file()
  local file = vim.api.nvim_buf_get_name(0)
  if not Path:new(file):exists() then
    vim.notify("Current file does not exist on disk", vim.log.levels.WARN)
    return
  end
  test_harness.test_directory(file, {
    minimal_init = "./tests/minimal_init.lua", -- optional
  })
end

-- Register keymaps
vim.keymap.set("n", "<leader>tt", run_current_file, { desc = "Run Plenary Tests: Current File" })
vim.keymap.set("n", "<leader>ta", run_all_tests, { desc = "Run Plenary Tests: All in ./tests" })

-- Optional: register with which-key if you're using it
local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
  wk.register({
    t = {
      name = "+tests",
      t = "Run Current Plenary Test File",
      a = "Run All Plenary Tests",
    },
  }, { prefix = "<leader>" })
end
