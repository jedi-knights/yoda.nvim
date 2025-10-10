-- Simple test runner for CI/CD
-- Usage: nvim --headless -u tests/minimal_init.lua -c "luafile tests/run_all.lua"

-- Load minimal init
vim.cmd("source tests/minimal_init.lua")

-- Try to run tests with available harness
local function run_tests()
  local snacks_ok = pcall(require, "snacks")
  if snacks_ok then
    vim.cmd("SnacksTest tests/")
    return
  end

  local plenary_ok, test_harness = pcall(require, "plenary.test_harness")
  if plenary_ok then
    test_harness.test_directory("tests", {
      minimal_init = "./tests/minimal_init.lua",
    })
    return
  end

  print("ERROR: No test harness found!")
  vim.cmd("cquit 1")
end

-- Run and exit
local ok, err = pcall(run_tests)
if not ok then
  print("ERROR: " .. tostring(err))
  vim.cmd("cquit 1")
else
  vim.cmd("quitall!")
end

