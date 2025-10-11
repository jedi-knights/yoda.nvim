-- Simple test runner for CI/CD with aggregated results
-- Usage: nvim --headless -u tests/minimal_init.lua -c "luafile tests/run_all.lua"

-- Load minimal init
vim.cmd("source tests/minimal_init.lua")

-- Enable code coverage if LuaCov is available
local coverage_enabled = false
local luacov_ok, luacov = pcall(require, "luacov")
if luacov_ok then
  coverage_enabled = true
  print("✅ LuaCov enabled - collecting coverage data")
else
  print("⚠️  LuaCov not found - skipping coverage collection")
end

-- Try to run tests with available harness
local function run_tests()
  local snacks_ok = pcall(require, "snacks")
  if snacks_ok then
    vim.cmd("SnacksTest tests/")
    return
  end

  local plenary_ok, test_harness = pcall(require, "plenary.test_harness")
  if plenary_ok then
    -- Capture test results
    local results = test_harness.test_directory("tests", {
      minimal_init = "./tests/minimal_init.lua",
    })

    -- Print aggregated summary
    print("\n" .. string.rep("=", 80))
    print("AGGREGATE TEST RESULTS")
    print(string.rep("=", 80))

    -- Count totals from results if available
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

      print(string.format("Test Files:     %d", file_count))
      print(string.format("Total Success:  %d", total_success))
      print(string.format("Total Failed:   %d", total_failed))
      print(string.format("Total Errors:   %d", total_errors))
      print(string.rep("=", 80))

      if total_failed > 0 or total_errors > 0 then
        vim.cmd("cquit 1")
      end
    else
      print("Test results not available for aggregation")
      print(string.rep("=", 80))
    end

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
  -- Save coverage data if enabled
  if coverage_enabled and luacov then
    print("\n📊 Saving coverage data...")
    luacov.save_stats()
  end
  vim.cmd("quitall!")
end
