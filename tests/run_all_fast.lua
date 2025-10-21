-- Fast test runner for development
-- Usage: nvim --headless -u tests/minimal_init_fast.lua -c "luafile tests/run_all_fast.lua"

-- Load minimal init
vim.cmd("source tests/minimal_init_fast.lua")

-- Silence output during test runs for speed
local original_print = print
print = function() end
local original_write = io.write
io.write = function() end

-- Fast test runner that bypasses plugin loading overhead
local function run_tests_fast()
  local plenary_ok, test_harness = pcall(require, "plenary.test_harness")
  if not plenary_ok then
    print("ERROR: plenary.nvim not found!")
    vim.cmd("cquit 1")
    return
  end

  -- Run tests with minimal configuration
  local results = test_harness.test_directory("tests", {
    minimal_init = "./tests/minimal_init_fast.lua",
  })

  -- Re-enable printing for final results
  print = original_print
  io.write = original_write

  -- Print aggregated summary
  print("\n" .. string.rep("=", 80))
  print("AGGREGATE TEST RESULTS")
  print(string.rep("=", 80))

  -- Count totals from results
  if results then
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
      vim.cmd("cquit 1")
    end
  else
    print("Test results not available for aggregation")
    print(string.rep("=", 80))
  end
end

-- Run and exit
local ok, err = pcall(run_tests_fast)
if not ok then
  print("ERROR: " .. tostring(err))
  vim.cmd("cquit 1")
else
  vim.cmd("quitall!")
end
