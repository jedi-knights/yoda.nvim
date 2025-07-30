-- lua/yoda/utils/automated_testing.lua
-- Automated testing framework for CI/CD integration

local M = {}

-- Import testing system
local testing = require("yoda.utils.distribution_testing")

-- Automated test configuration
local CI_CONFIG = {
  -- CI environment detection
  is_ci = os.getenv("CI") ~= nil or os.getenv("GITHUB_ACTIONS") ~= nil,
  
  -- Test timeouts (seconds)
  test_timeout = 30,
  health_check_timeout = 10,
  
  -- Report formats
  output_formats = {"json", "xml", "text"},
  
  -- Exit codes
  exit_codes = {
    success = 0,
    test_failure = 1,
    critical_failure = 2,
    timeout = 3,
    error = 4
  }
}

-- Test result storage for CI
local ci_results = {
  tests = {},
  health_checks = {},
  performance_metrics = {},
  metadata = {
    timestamp = os.time(),
    neovim_version = vim.fn.has("nvim-0.8.0") == 1 and "0.8.0+" or "Unknown",
    platform = vim.fn.has("unix") == 1 and "Unix" or "Windows",
    ci_environment = CI_CONFIG.is_ci and "CI" or "Local"
  }
}

-- Run automated test suite
function M.run_automated_tests()
  local start_time = os.time()
  local results = {
    success = true,
    exit_code = CI_CONFIG.exit_codes.success,
    tests = {},
    health_checks = {},
    summary = {
      total_tests = 0,
      passed_tests = 0,
      failed_tests = 0,
      critical_failures = 0,
      duration = 0
    }
  }
  
  -- Run all tests
  local test_results = testing.run_all_tests()
  if test_results then
    results.tests = test_results
    results.summary.total_tests = test_results.summary.total_tests
    results.summary.passed_tests = test_results.summary.passed_tests
    results.summary.failed_tests = test_results.summary.failed_tests
    results.summary.critical_failures = test_results.summary.critical_failures
    
    -- Check for critical failures
    if test_results.summary.critical_failures > 0 then
      results.success = false
      results.exit_code = CI_CONFIG.exit_codes.critical_failure
    elseif test_results.summary.failed_tests > 0 then
      results.success = false
      results.exit_code = CI_CONFIG.exit_codes.test_failure
    end
  end
  
  -- Run health checks
  local health_results = testing.run_health_check()
  if health_results then
    results.health_checks = health_results
    
    -- Check for critical health issues
    if health_results.overall.level == "error" then
      results.success = false
      results.exit_code = CI_CONFIG.exit_codes.critical_failure
    end
  end
  
  results.summary.duration = os.time() - start_time
  ci_results = results
  
  return results
end

-- Generate JSON report for CI
function M.generate_json_report(results)
  local report = {
    metadata = {
      timestamp = os.time(),
      neovim_version = vim.fn.has("nvim-0.8.0") == 1 and "0.8.0+" or "Unknown",
      platform = vim.fn.has("unix") == 1 and "Unix" or "Windows",
      ci_environment = CI_CONFIG.is_ci and "CI" or "Local"
    },
    summary = results.summary,
    success = results.success,
    exit_code = results.exit_code,
    tests = results.tests,
    health_checks = results.health_checks
  }
  
  return vim.json.encode(report)
end

-- Generate XML report for CI
function M.generate_xml_report(results)
  local xml = '<?xml version="1.0" encoding="UTF-8"?>\n'
  xml = xml .. '<testsuites>\n'
  
  -- Add metadata
  xml = xml .. string.format('  <metadata timestamp="%d" neovim_version="%s" platform="%s" ci_environment="%s" />\n',
    os.time(),
    vim.fn.has("nvim-0.8.0") == 1 and "0.8.0+" or "Unknown",
    vim.fn.has("unix") == 1 and "Unix" or "Windows",
    CI_CONFIG.is_ci and "CI" or "Local"
  )
  
  -- Add test results
  if results.tests and results.tests.suites then
    for _, suite in ipairs(results.tests.suites) do
      xml = xml .. string.format('  <testsuite name="%s" tests="%d" failures="%d" time="%.2f">\n',
        suite.name,
        suite.summary.total,
        suite.summary.failed,
        suite.summary.duration or 0
      )
      
      for _, test in ipairs(suite.tests) do
        local status = test.status == "passed" and "success" or "failure"
        xml = xml .. string.format('    <testcase name="%s" status="%s" time="%.2f">\n',
          test.name,
          status,
          test.duration
        )
        
        if test.status == "failed" and test.error then
          xml = xml .. string.format('      <failure message="%s" />\n', test.error)
        end
        
        xml = xml .. '    </testcase>\n'
      end
      
      xml = xml .. '  </testsuite>\n'
    end
  end
  
  xml = xml .. '</testsuites>'
  return xml
end

-- Generate text report for CI
function M.generate_text_report(results)
  local report = {}
  
  table.insert(report, "=== Yoda.nvim Automated Test Report ===")
  table.insert(report, string.format("Generated: %s", os.date()))
  table.insert(report, string.format("CI Environment: %s", CI_CONFIG.is_ci and "Yes" or "No"))
  table.insert(report, string.format("Neovim Version: %s", vim.fn.has("nvim-0.8.0") == 1 and "0.8.0+" or "Unknown"))
  table.insert(report, string.format("Platform: %s", vim.fn.has("unix") == 1 and "Unix" or "Windows"))
  table.insert(report, "")
  
  -- Test summary
  table.insert(report, "Test Results:")
  table.insert(report, string.format("  Total Tests: %d", results.summary.total_tests))
  table.insert(report, string.format("  Passed: %d", results.summary.passed_tests))
  table.insert(report, string.format("  Failed: %d", results.summary.failed_tests))
  table.insert(report, string.format("  Critical Failures: %d", results.summary.critical_failures))
  table.insert(report, string.format("  Duration: %d seconds", results.summary.duration))
  table.insert(report, "")
  
  -- Health check summary
  if results.health_checks and results.health_checks.overall then
    table.insert(report, "Health Check:")
    table.insert(report, string.format("  Overall: %s", results.health_checks.overall.level:upper()))
    table.insert(report, string.format("  Issues: %d", results.health_checks.overall.total_issues))
    table.insert(report, "")
  end
  
  -- Success/failure status
  table.insert(report, string.format("Overall Status: %s", results.success and "PASSED" or "FAILED"))
  table.insert(report, string.format("Exit Code: %d", results.exit_code))
  table.insert(report, "=====================================")
  
  return table.concat(report, "\n")
end

-- Run tests with timeout
function M.run_tests_with_timeout()
  local start_time = os.time()
  local results = nil
  local completed = false
  
  -- Set up timeout
  vim.defer_fn(function()
    if not completed then
      completed = true
      results = {
        success = false,
        exit_code = CI_CONFIG.exit_codes.timeout,
        error = "Test execution timed out"
      }
    end
  end, CI_CONFIG.test_timeout * 1000)
  
  -- Run tests
  results = M.run_automated_tests()
  completed = true
  
  return results
end

-- Save report to file
function M.save_report(results, format, filename)
  local content = ""
  
  if format == "json" then
    content = M.generate_json_report(results)
  elseif format == "xml" then
    content = M.generate_xml_report(results)
  elseif format == "text" then
    content = M.generate_text_report(results)
  else
    error("Unsupported format: " .. format)
  end
  
  -- Write to file
  local file = io.open(filename, "w")
  if file then
    file:write(content)
    file:close()
    return true
  else
    return false
  end
end

-- Run comprehensive automated testing
function M.run_comprehensive_testing()
  local results = M.run_tests_with_timeout()
  
  -- Generate reports in all formats
  local reports_dir = vim.fn.stdpath("data") .. "/yoda_test_reports"
  vim.fn.mkdir(reports_dir, "p")
  
  local timestamp = os.date("%Y%m%d_%H%M%S")
  
  -- Save reports
  M.save_report(results, "json", reports_dir .. "/test_report_" .. timestamp .. ".json")
  M.save_report(results, "xml", reports_dir .. "/test_report_" .. timestamp .. ".xml")
  M.save_report(results, "text", reports_dir .. "/test_report_" .. timestamp .. ".txt")
  
  -- Print summary
  if CI_CONFIG.is_ci then
    print(M.generate_text_report(results))
  else
    testing.print_test_results(results.tests)
    testing.print_health_results(results.health_checks)
  end
  
  return results
end

-- Performance regression testing
function M.run_performance_tests()
  local performance_results = {
    startup_time = 0,
    memory_usage = 0,
    plugin_load_times = {},
    critical_paths = {}
  }
  
  -- Measure startup time
  local startup_time = vim.g.yoda_startup_time or 0
  performance_results.startup_time = startup_time
  
  -- Measure memory usage
  local memory_info = vim.loop.get_memory_info()
  if memory_info then
    performance_results.memory_usage = memory_info.rss / 1024 / 1024 -- MB
  end
  
  -- Measure plugin load times
  local lazy = require("lazy")
  if lazy then
    local plugins = lazy.get_plugins()
    for _, plugin in pairs(plugins) do
      if plugin.load_time then
        table.insert(performance_results.plugin_load_times, {
          name = plugin.name,
          load_time = plugin.load_time
        })
      end
    end
  end
  
  -- Sort by load time
  table.sort(performance_results.plugin_load_times, function(a, b)
    return a.load_time > b.load_time
  end)
  
  return performance_results
end

-- Integration test runner
function M.run_integration_tests()
  local integration_results = {
    tests = {},
    summary = {
      total = 0,
      passed = 0,
      failed = 0
    }
  }
  
  -- Test keymap functionality
  local keymap_test = {
    name = "Keymap Functionality",
    description = "Test that keymaps are properly registered",
    test_func = function()
      -- Test a few essential keymaps
      local keymaps = {
        "<leader>ff", -- File finder
        "<leader>e",  -- File explorer
        "<leader>ac"  -- AI chat
      }
      
      for _, keymap in ipairs(keymaps) do
        local ok = pcall(vim.keymap.get, "n", keymap)
        if not ok then
          return false
        end
      end
      return true
    end
  }
  
  -- Test command functionality
  local command_test = {
    name = "Command Functionality",
    description = "Test that user commands are registered",
    test_func = function()
      local commands = {
        "YodaShowConfig",
        "YodaHealthCheck",
        "YodaRunTests"
      }
      
      for _, command in ipairs(commands) do
        local ok = pcall(vim.api.nvim_get_commands, {})
        if not ok then
          return false
        end
      end
      return true
    end
  }
  
  -- Run integration tests
  local tests = {keymap_test, command_test}
  for _, test in ipairs(tests) do
    local start_time = vim.loop.hrtime()
    local success, result = pcall(test.test_func)
    local end_time = vim.loop.hrtime()
    local duration = (end_time - start_time) / 1000000
    
    local test_result = {
      name = test.name,
      description = test.description,
      status = success and result and "passed" or "failed",
      duration = duration
    }
    
    table.insert(integration_results.tests, test_result)
    integration_results.summary.total = integration_results.summary.total + 1
    
    if test_result.status == "passed" then
      integration_results.summary.passed = integration_results.summary.passed + 1
    else
      integration_results.summary.failed = integration_results.summary.failed + 1
    end
  end
  
  return integration_results
end

-- CI/CD specific functions
function M.setup_ci_environment()
  -- Configure for CI environment
  if CI_CONFIG.is_ci then
    -- Disable interactive features
    vim.g.yoda_config = vim.g.yoda_config or {}
    vim.g.yoda_config.show_loading_messages = false
    vim.g.yoda_config.show_environment_notification = false
    vim.g.yoda_config.enable_startup_profiling = false
    
    -- Set shorter timeouts
    vim.o.timeoutlen = 1000
    vim.o.ttimeoutlen = 100
  end
end

-- Generate CI summary
function M.generate_ci_summary(results)
  local summary = {
    status = results.success and "PASSED" or "FAILED",
    exit_code = results.exit_code,
    test_summary = {
      total = results.summary.total_tests,
      passed = results.summary.passed_tests,
      failed = results.summary.failed_tests,
      critical_failures = results.summary.critical_failures
    },
    health_summary = results.health_checks and results.health_checks.overall or nil,
    duration = results.summary.duration
  }
  
  return summary
end

-- User commands for automated testing
vim.api.nvim_create_user_command("YodaAutomatedTests", function()
  local results = M.run_comprehensive_testing()
  local summary = M.generate_ci_summary(results)
  
  vim.notify(string.format("Automated tests completed: %s (%d/%d passed)", 
    summary.status, summary.test_summary.passed, summary.test_summary.total),
    summary.status == "PASSED" and vim.log.levels.INFO or vim.log.levels.ERROR,
    { title = "Yoda Automated Testing" }
  )
end, { desc = "Run comprehensive automated testing" })

vim.api.nvim_create_user_command("YodaPerformanceTests", function()
  local results = M.run_performance_tests()
  
  print("=== Yoda.nvim Performance Test Results ===")
  print(string.format("Startup Time: %.2f ms", results.startup_time))
  print(string.format("Memory Usage: %.2f MB", results.memory_usage))
  
  if #results.plugin_load_times > 0 then
    print("\nSlowest Plugins:")
    for i = 1, math.min(5, #results.plugin_load_times) do
      local plugin = results.plugin_load_times[i]
      print(string.format("  %s: %.2f ms", plugin.name, plugin.load_time))
    end
  end
  
  print("=========================================")
end, { desc = "Run performance tests" })

vim.api.nvim_create_user_command("YodaIntegrationTests", function()
  local results = M.run_integration_tests()
  
  print("=== Yoda.nvim Integration Test Results ===")
  print(string.format("Total Tests: %d", results.summary.total))
  print(string.format("Passed: %d", results.summary.passed))
  print(string.format("Failed: %d", results.summary.failed))
  
  for _, test in ipairs(results.tests) do
    local status_icon = test.status == "passed" and "✅" or "❌"
    print(string.format("  %s %s (%.2fms)", status_icon, test.name, test.duration))
  end
  
  print("==========================================")
end, { desc = "Run integration tests" })

-- Setup CI environment on load
M.setup_ci_environment()

return M 