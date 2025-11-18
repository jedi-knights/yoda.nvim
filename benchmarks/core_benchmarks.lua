-- benchmarks/core_benchmarks.lua
-- Performance benchmarks for core utilities

local benchmark = require("yoda.performance.benchmark")
local string_utils = require("yoda.core.string")
local table_utils = require("yoda.core.table")
local io_utils = require("yoda.core.io")

-- ============================================================================
-- STRING UTILITIES BENCHMARKS
-- ============================================================================

local function bench_string_trim()
  benchmark.suite({
    {
      name = "trim() - short string",
      func = function()
        string_utils.trim("  hello  ")
      end,
    },
    {
      name = "trim() - long string",
      func = function()
        string_utils.trim("   " .. string.rep("word ", 100) .. "   ")
      end,
    },
    {
      name = "trim() - no whitespace",
      func = function()
        string_utils.trim("hello")
      end,
    },
  }, { iterations = 10000 })
end

local function bench_string_starts_with()
  benchmark.suite({
    {
      name = "starts_with() - match",
      func = function()
        string_utils.starts_with("hello world", "hello")
      end,
    },
    {
      name = "starts_with() - no match",
      func = function()
        string_utils.starts_with("hello world", "world")
      end,
    },
    {
      name = "starts_with() - empty prefix",
      func = function()
        string_utils.starts_with("hello world", "")
      end,
    },
  }, { iterations = 10000 })
end

local function bench_string_split()
  benchmark.suite({
    {
      name = "split() - small string",
      func = function()
        string_utils.split("a,b,c,d,e", ",")
      end,
    },
    {
      name = "split() - large string",
      func = function()
        local str = table.concat(
          vim.tbl_map(function(i)
            return tostring(i)
          end, vim.fn.range(100)),
          ","
        )
        string_utils.split(str, ",")
      end,
    },
  }, { iterations = 5000 })
end

-- ============================================================================
-- TABLE UTILITIES BENCHMARKS
-- ============================================================================

local function bench_table_merge()
  local small_table1 = { a = 1, b = 2, c = 3 }
  local small_table2 = { d = 4, e = 5 }

  local large_table1 = {}
  for i = 1, 100 do
    large_table1["key" .. i] = i
  end
  local large_table2 = {}
  for i = 101, 150 do
    large_table2["key" .. i] = i
  end

  benchmark.suite({
    {
      name = "merge() - small tables",
      func = function()
        table_utils.merge(small_table1, small_table2)
      end,
    },
    {
      name = "merge() - large tables",
      func = function()
        table_utils.merge(large_table1, large_table2)
      end,
    },
  }, { iterations = 5000 })
end

local function bench_table_deep_copy()
  local shallow_table = { a = 1, b = 2, c = 3, d = 4, e = 5 }
  local nested_table = {
    a = 1,
    b = { c = 2, d = { e = 3, f = { g = 4 } } },
    h = { i = 5, j = 6 },
  }

  benchmark.suite({
    {
      name = "deep_copy() - shallow table",
      func = function()
        table_utils.deep_copy(shallow_table)
      end,
    },
    {
      name = "deep_copy() - nested table",
      func = function()
        table_utils.deep_copy(nested_table)
      end,
    },
  }, { iterations = 5000 })
end

local function bench_table_contains()
  local small_array = { 1, 2, 3, 4, 5 }
  local large_array = vim.fn.range(1, 1000)

  benchmark.suite({
    {
      name = "contains() - small array (found)",
      func = function()
        table_utils.contains(small_array, 3)
      end,
    },
    {
      name = "contains() - small array (not found)",
      func = function()
        table_utils.contains(small_array, 10)
      end,
    },
    {
      name = "contains() - large array (found early)",
      func = function()
        table_utils.contains(large_array, 5)
      end,
    },
    {
      name = "contains() - large array (found late)",
      func = function()
        table_utils.contains(large_array, 995)
      end,
    },
  }, { iterations = 5000 })
end

-- ============================================================================
-- I/O UTILITIES BENCHMARKS
-- ============================================================================

local function bench_io_checks()
  -- Use common paths that likely exist
  local existing_file = vim.fn.stdpath("config") .. "/init.lua"
  local nonexistent_file = "/tmp/nonexistent_file_12345.txt"
  local existing_dir = vim.fn.stdpath("config")

  benchmark.suite({
    {
      name = "is_file() - existing file",
      func = function()
        io_utils.is_file(existing_file)
      end,
    },
    {
      name = "is_file() - nonexistent file",
      func = function()
        io_utils.is_file(nonexistent_file)
      end,
    },
    {
      name = "is_dir() - existing directory",
      func = function()
        io_utils.is_dir(existing_dir)
      end,
    },
    {
      name = "exists() - existing path",
      func = function()
        io_utils.exists(existing_file)
      end,
    },
  }, { iterations = 1000 })
end

-- ============================================================================
-- MAIN BENCHMARK RUNNER
-- ============================================================================

local function run_all_benchmarks()
  print("========================================")
  print("CORE UTILITIES PERFORMANCE BENCHMARKS")
  print("========================================")
  print("")

  print("--- STRING UTILITIES ---")
  bench_string_trim()
  print("")
  bench_string_starts_with()
  print("")
  bench_string_split()
  print("")

  print("--- TABLE UTILITIES ---")
  bench_table_merge()
  print("")
  bench_table_deep_copy()
  print("")
  bench_table_contains()
  print("")

  print("--- I/O UTILITIES ---")
  bench_io_checks()
  print("")

  print("========================================")
  print("BENCHMARKS COMPLETE")
  print("========================================")
end

-- Run benchmarks if executed directly
if vim.v.progname:find("nvim") then
  run_all_benchmarks()
end

return {
  run_all = run_all_benchmarks,
  string = {
    trim = bench_string_trim,
    starts_with = bench_string_starts_with,
    split = bench_string_split,
  },
  table = {
    merge = bench_table_merge,
    deep_copy = bench_table_deep_copy,
    contains = bench_table_contains,
  },
  io = {
    checks = bench_io_checks,
  },
}
