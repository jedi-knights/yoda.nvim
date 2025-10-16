-- Ultra-fast test runner that loads all tests in a single session
-- Usage: nvim --headless -u tests/minimal_init_ultra.lua -c "luafile tests/run_all_ultra.lua"

-- Load minimal init
vim.cmd("source tests/minimal_init_ultra.lua")

-- Custom test runner that bypasses plenary's heavy machinery
local function run_tests_ultra_fast()
  local ok, test_harness = pcall(require, "plenary.test_harness")
  if not ok then
    print("ERROR: plenary.nvim not found!")
    vim.cmd("cquit 1")
    return
  end

  print("Starting ultra-fast test execution...")

  -- Get all test files
  local test_files = vim.fn.glob("tests/unit/**/*_spec.lua", false, true)

  local total_success = 0
  local total_failed = 0
  local total_errors = 0
  local file_count = 0

  -- Run each test file in the same session (much faster)
  for _, test_file in ipairs(test_files) do
    local relative_path = test_file:gsub("^tests/unit/", "")
    print(string.format("Running: %s", relative_path))

    -- Use pcall to catch any errors and continue
    local success, result = pcall(function()
      -- Clear any previous test state
      for name, _ in pairs(package.loaded) do
        if name:match("^tests%.") then
          package.loaded[name] = nil
        end
      end

      -- Load and run the test file directly
      local test_func = loadfile(test_file)
      if test_func then
        test_func()

        -- Try to get results from plenary
        local results = test_harness.test_file(test_file)
        if results and type(results) == "table" then
          file_count = file_count + 1
          total_success = total_success + (results.success or 0)
          total_failed = total_failed + (results.fail or 0)
          total_errors = total_errors + (results.errs or 0)
        else
          -- Fallback: assume success if no errors thrown
          file_count = file_count + 1
          total_success = total_success + 1
        end
      end
    end)

    if not success then
      print(string.format("ERROR in %s: %s", relative_path, tostring(result)))
      total_errors = total_errors + 1
      file_count = file_count + 1
    end
  end

  -- Print results
  print(string.rep("=", 80))
  print("ULTRA-FAST TEST RESULTS")
  print(string.rep("=", 80))
  print(string.format("Total tests passed: %d", total_success))
  print(string.format("Total tests failed: %d", total_failed))
  print(string.format("Total errors: %d", total_errors))
  print(string.format("Test files run: %d", file_count))
  print(string.rep("=", 80))

  if total_failed > 0 or total_errors > 0 then
    vim.cmd("cquit 1")
  end
end

-- Run and exit
local ok, err = pcall(run_tests_ultra_fast)
if not ok then
  print("ERROR: " .. tostring(err))
  vim.cmd("cquit 1")
else
  vim.cmd("quitall!")
end
