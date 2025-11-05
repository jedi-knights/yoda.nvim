-- lua/yoda/performance/benchmark.lua
-- Micro-benchmarking framework for Yoda.nvim
-- Measures function performance with statistical analysis

local M = {}

-- ============================================================================
-- TIMING UTILITIES
-- ============================================================================

--- Get high-resolution time in milliseconds
--- @return number timestamp Current time in milliseconds
local function get_time_ms()
  return vim.loop.hrtime() / 1000000
end

--- Get high-resolution time in microseconds
--- @return number timestamp Current time in microseconds
local function get_time_us()
  return vim.loop.hrtime() / 1000
end

-- ============================================================================
-- STATISTICAL ANALYSIS
-- ============================================================================

--- Calculate mean of array
--- @param values table Array of numbers
--- @return number mean Mean value
local function calculate_mean(values)
  local sum = 0
  for _, v in ipairs(values) do
    sum = sum + v
  end
  return sum / #values
end

--- Calculate median of array
--- @param values table Array of numbers
--- @return number median Median value
local function calculate_median(values)
  local sorted = vim.deepcopy(values)
  table.sort(sorted)
  local n = #sorted
  if n % 2 == 0 then
    return (sorted[n / 2] + sorted[n / 2 + 1]) / 2
  else
    return sorted[math.ceil(n / 2)]
  end
end

--- Calculate standard deviation
--- @param values table Array of numbers
--- @param mean number Mean value
--- @return number stddev Standard deviation
local function calculate_stddev(values, mean)
  local sum_sq = 0
  for _, v in ipairs(values) do
    sum_sq = sum_sq + (v - mean) ^ 2
  end
  return math.sqrt(sum_sq / #values)
end

--- Calculate min, max, percentiles
--- @param values table Array of numbers
--- @return table stats {min, max, p50, p95, p99}
local function calculate_stats(values)
  local sorted = vim.deepcopy(values)
  table.sort(sorted)
  local n = #sorted

  return {
    min = sorted[1],
    max = sorted[n],
    p50 = sorted[math.ceil(n * 0.50)],
    p95 = sorted[math.ceil(n * 0.95)],
    p99 = sorted[math.ceil(n * 0.99)],
  }
end

-- ============================================================================
-- BENCHMARKING ENGINE
-- ============================================================================

--- Run function multiple times and collect timing data
--- @param func function Function to benchmark
--- @param iterations number Number of iterations
--- @param warmup number|nil Warmup iterations (default: 10% of iterations)
--- @return table results {times, mean, median, stddev, min, max, p95, p99}
local function benchmark_function(func, iterations, warmup)
  assert(type(func) == "function", "func must be a function")
  assert(type(iterations) == "number" and iterations > 0, "iterations must be positive")

  warmup = warmup or math.ceil(iterations * 0.1)

  -- Warmup phase (JIT compilation, cache warming)
  for i = 1, warmup do
    func()
  end

  -- Measurement phase
  local times = {}
  for i = 1, iterations do
    local start = get_time_us()
    func()
    local elapsed = get_time_us() - start
    table.insert(times, elapsed)
  end

  -- Calculate statistics
  local mean = calculate_mean(times)
  local median = calculate_median(times)
  local stddev = calculate_stddev(times, mean)
  local stats = calculate_stats(times)

  return {
    times = times,
    iterations = iterations,
    warmup = warmup,
    mean = mean,
    median = median,
    stddev = stddev,
    min = stats.min,
    max = stats.max,
    p50 = stats.p50,
    p95 = stats.p95,
    p99 = stats.p99,
  }
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

--- Benchmark a function
--- @param name string Benchmark name
--- @param func function Function to benchmark
--- @param options table|nil {iterations = 1000, warmup = nil, unit = "us"}
--- @return table results Benchmark results
function M.benchmark(name, func, options)
  options = options or {}
  local iterations = options.iterations or 1000
  local warmup = options.warmup
  local unit = options.unit or "us" -- "us" or "ms"

  local results = benchmark_function(func, iterations, warmup)
  results.name = name
  results.unit = unit

  -- Convert to milliseconds if requested
  if unit == "ms" then
    results.mean = results.mean / 1000
    results.median = results.median / 1000
    results.stddev = results.stddev / 1000
    results.min = results.min / 1000
    results.max = results.max / 1000
    results.p95 = results.p95 / 1000
    results.p99 = results.p99 / 1000
  end

  return results
end

--- Compare two functions
--- @param name1 string First function name
--- @param func1 function First function
--- @param name2 string Second function name
--- @param func2 function Second function
--- @param options table|nil Benchmark options
--- @return table comparison {results1, results2, speedup}
function M.compare(name1, func1, name2, func2, options)
  local results1 = M.benchmark(name1, func1, options)
  local results2 = M.benchmark(name2, func2, options)

  local speedup = results2.mean / results1.mean

  return {
    baseline = results1,
    comparison = results2,
    speedup = speedup,
    faster = speedup > 1 and name1 or name2,
    slower = speedup > 1 and name2 or name1,
  }
end

--- Benchmark suite - run multiple benchmarks
--- @param suite table Array of {name, func} or {name, func, options}
--- @param options table|nil Default options for all benchmarks
--- @return table results Array of benchmark results
function M.suite(suite, options)
  local results = {}

  for _, bench in ipairs(suite) do
    local name = bench.name or bench[1]
    local func = bench.func or bench[2]
    local bench_options = vim.tbl_extend("force", options or {}, bench.options or bench[3] or {})

    local result = M.benchmark(name, func, bench_options)
    table.insert(results, result)
  end

  return results
end

--- Format benchmark results as string
--- @param results table Benchmark results
--- @return string formatted Formatted results
function M.format(results)
  local lines = {}

  table.insert(lines, string.format("Benchmark: %s", results.name))
  table.insert(lines, string.format("Iterations: %d (warmup: %d)", results.iterations, results.warmup))
  table.insert(lines, "")
  table.insert(lines, string.format("Mean:   %.2f %s", results.mean, results.unit))
  table.insert(lines, string.format("Median: %.2f %s", results.median, results.unit))
  table.insert(lines, string.format("StdDev: %.2f %s", results.stddev, results.unit))
  table.insert(lines, "")
  table.insert(lines, string.format("Min:    %.2f %s", results.min, results.unit))
  table.insert(lines, string.format("Max:    %.2f %s", results.max, results.unit))
  table.insert(lines, string.format("P50:    %.2f %s", results.p50, results.unit))
  table.insert(lines, string.format("P95:    %.2f %s", results.p95, results.unit))
  table.insert(lines, string.format("P99:    %.2f %s", results.p99, results.unit))

  return table.concat(lines, "\n")
end

--- Format comparison results
--- @param comparison table Comparison results
--- @return string formatted Formatted comparison
function M.format_comparison(comparison)
  local lines = {}

  local baseline = comparison.baseline
  local comp = comparison.comparison

  table.insert(lines, string.format("Comparison: %s vs %s", baseline.name, comp.name))
  table.insert(lines, "")
  table.insert(lines, string.format("%-20s %10s %10s %10s", "Metric", baseline.name, comp.name, "Speedup"))
  table.insert(lines, string.rep("-", 50))
  table.insert(lines, string.format("%-20s %10.2f %10.2f %10.2fx", "Mean (" .. baseline.unit .. ")", baseline.mean, comp.mean, comparison.speedup))
  table.insert(lines, string.format("%-20s %10.2f %10.2f", "Median (" .. baseline.unit .. ")", baseline.median, comp.median))
  table.insert(lines, string.format("%-20s %10.2f %10.2f", "P95 (" .. baseline.unit .. ")", baseline.p95, comp.p95))
  table.insert(lines, "")

  if comparison.speedup > 1 then
    table.insert(lines, string.format("✅ %s is %.2fx faster", comparison.faster, comparison.speedup))
  elseif comparison.speedup < 1 then
    table.insert(lines, string.format("⚠️  %s is %.2fx slower", comparison.slower, 1 / comparison.speedup))
  else
    table.insert(lines, "⚖️  Both have similar performance")
  end

  return table.concat(lines, "\n")
end

--- Print benchmark results
--- @param results table Benchmark results
function M.print(results)
  print(M.format(results))
end

--- Print comparison results
--- @param comparison table Comparison results
function M.print_comparison(comparison)
  print(M.format_comparison(comparison))
end

--- Save results to JSON file
--- @param results table Benchmark results
--- @param filepath string File path
--- @return boolean success
function M.save_results(results, filepath)
  local json = vim.json.encode(results)
  local file = io.open(filepath, "w")
  if not file then
    return false
  end
  file:write(json)
  file:close()
  return true
end

--- Load results from JSON file
--- @param filepath string File path
--- @return table|nil results Benchmark results or nil
function M.load_results(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil
  end
  local content = file:read("*all")
  file:close()
  return vim.json.decode(content)
end

--- Detect performance regression
--- @param baseline table Baseline results
--- @param current table Current results
--- @param threshold number Acceptable slowdown threshold (default: 1.1 = 10%)
--- @return boolean is_regression
--- @return number ratio Current/baseline ratio
function M.detect_regression(baseline, current, threshold)
  threshold = threshold or 1.1

  local ratio = current.mean / baseline.mean
  local is_regression = ratio > threshold

  return is_regression, ratio
end

return M
