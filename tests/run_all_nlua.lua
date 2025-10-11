#!/usr/bin/env nlua
-- Test runner for nlua with LuaCov coverage collection
-- Usage: nlua tests/run_all_nlua.lua

-- Get root directory
local root = vim.fn.getcwd()

-- Add luarocks paths for LuaCov
local home = os.getenv("HOME")
if home then
  package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.4/?.lua"
  package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.4/?/init.lua"
end

-- Load LuaCov FIRST (before any modules to track)
local luacov_ok, luacov = pcall(require, "luacov")
if luacov_ok then
  print("✅ LuaCov enabled - collecting coverage data")
else
  print("⚠️  LuaCov not found - skipping coverage collection")
  print("   Install with: luarocks install --local luacov")
end

-- Set up paths to find yoda modules
package.path = package.path .. ";" .. root .. "/lua/?.lua"
package.path = package.path .. ";" .. root .. "/lua/?/init.lua"

-- Add lazy.nvim plugin paths (so we can find plenary)
local lazy_root = vim.fn.stdpath("data") .. "/lazy"
if vim.fn.isdirectory(lazy_root) == 1 then
  -- Add plenary path
  local plenary_path = lazy_root .. "/plenary.nvim"
  if vim.fn.isdirectory(plenary_path) == 1 then
    package.path = package.path .. ";" .. plenary_path .. "/lua/?.lua"
    package.path = package.path .. ";" .. plenary_path .. "/lua/?/init.lua"
  end
end

-- Load minimal init to set up test environment (this will bootstrap lazy if needed)
dofile(root .. "/tests/minimal_init.lua")

-- Load plenary test harness
local test_harness_ok, test_harness = pcall(require, "plenary.test_harness")
if not test_harness_ok then
  print("ERROR: Failed to load plenary.test_harness")
  print(test_harness)
  os.exit(1)
end

-- Run all tests
print("\nStarting test run with nlua...\n")
local results = test_harness.test_directory("tests", {
  minimal_init = "./tests/minimal_init.lua",
})

-- Save coverage data if LuaCov is loaded
if luacov_ok and luacov then
  print("\n📊 Saving coverage data...")
  luacov.save_stats()
  print("✅ Coverage data saved to luacov.stats.out")
  print("   Run 'make coverage-report' to generate human-readable report")
end

-- Print aggregate summary
print("\n" .. string.rep("=", 80))
print("NLUA TEST RESULTS")
print(string.rep("=", 80))

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

  -- Exit with error code if any tests failed
  if total_failed > 0 or total_errors > 0 then
    os.exit(1)
  end
else
  print("Test results not available")
  print(string.rep("=", 80))
  os.exit(1)
end

-- Success!
os.exit(0)

