-- Fast test runner for development
-- Usage: nvim --headless -u tests/minimal_init_fast.lua -c "luafile tests/run_all_fast.lua"

-- This script runs all tests with minimal output for speed
-- After tests complete, it prints an aggregate summary

-- Ensure minimal_init_fast is loaded
if not package.loaded["plenary.test_harness"] then
  vim.cmd("source tests/minimal_init_fast.lua")
end

-- Run tests and print summary
local function run()
  local test_harness = require("plenary.test_harness")

  -- Run all tests
  local results = test_harness.test_directory("tests", {
    minimal_init = "./tests/minimal_init_fast.lua",
  })

  -- Print aggregate summary
  print("\n" .. string.rep("=", 80))
  print("AGGREGATE TEST RESULTS")
  print(string.rep("=", 80))

  if results and type(results) == "table" then
    local total_success = 0
    local total_failed = 0
    local total_errors = 0
    local file_count = 0

    for file, result in pairs(results) do
      if type(result) == "table" then
        file_count = file_count + 1
        total_success = total_success + (result.success or 0)
        total_failed = total_failed + (result.fail or 0)
        total_errors = total_errors + (result.errs or 0)
      end
    end

    print(string.format("Total tests passed: %d", total_success))
    print(string.format("Total tests failed: %d", total_failed))
    print(string.format("Total errors: %d", total_errors))
    print(string.format("Test files run: %d", file_count))
    print(string.rep("=", 80))

    if total_failed > 0 or total_errors > 0 then
      print("❌ Tests failed!")
      vim.cmd("cquit 1")
    else
      print("✅ All tests passed!")
      vim.cmd("quitall!")
    end
  else
    print("ERROR: Could not get test results")
    vim.cmd("cquit 1")
  end
end

-- Execute
local ok, err = pcall(run)
if not ok then
  print("ERROR: " .. tostring(err))
  vim.cmd("cquit 1")
end
