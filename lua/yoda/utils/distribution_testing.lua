-- lua/yoda/utils/distribution_testing.lua
-- Distribution testing and health check system for Yoda.nvim

local M = {}

-- Test data and results
local test_data = {
  tests = {},
  results = {},
  health_checks = {},
  performance_metrics = {},
  test_suites = {}
}

-- Test categories
local TEST_CATEGORIES = {
  CORE = "core",
  PLUGINS = "plugins",
  LSP = "lsp",
  PERFORMANCE = "performance",
  INTEGRATION = "integration",
  HEALTH = "health"
}

-- Test status
local TEST_STATUS = {
  PASSED = "passed",
  FAILED = "failed",
  SKIPPED = "skipped",
  WARNING = "warning"
}

-- Health check levels
local HEALTH_LEVELS = {
  CRITICAL = "critical",
  ERROR = "error",
  WARNING = "warning",
  INFO = "info",
  SUCCESS = "success"
}

-- Define test suites
local TEST_SUITES = {
  core_tests = {
    name = "Core Distribution Tests",
    description = "Test core distribution functionality",
    category = TEST_CATEGORIES.CORE,
    tests = {
      {
        name = "Leader Key Configuration",
        description = "Verify leader key is properly set",
        test_func = function()
          return vim.g.mapleader == " " and vim.g.maplocalleader == " "
        end,
        critical = true
      },
      {
        name = "Yoda Config Loading",
        description = "Verify Yoda configuration is loaded",
        test_func = function()
          return vim.g.yoda_config ~= nil
        end,
        critical = true
      },
      {
        name = "Core Modules Loading",
        description = "Test core module loading",
        test_func = function()
          local modules = {"options", "keymaps", "autocmds", "functions"}
          for _, module in ipairs(modules) do
            local ok = pcall(require, "yoda.core." .. module)
            if not ok then
              return false
            end
          end
          return true
        end,
        critical = true
      },
      {
        name = "Utility Modules Loading",
        description = "Test utility module loading",
        test_func = function()
          local modules = {"error_recovery", "interactive_help", "feature_discovery"}
          for _, module in ipairs(modules) do
            local ok = pcall(require, "yoda.utils." .. module)
            if not ok then
              return false
            end
          end
          return true
        end,
        critical = false
      }
    }
  },
  
  plugin_tests = {
    name = "Plugin System Tests",
    description = "Test plugin loading and functionality",
    category = TEST_CATEGORIES.PLUGINS,
    tests = {
      {
        name = "Lazy.nvim Loading",
        description = "Verify Lazy.nvim is loaded",
        test_func = function()
          local ok = pcall(require, "lazy")
          return ok
        end,
        critical = true
      },
      {
        name = "Plugin Installation",
        description = "Check if essential plugins are installed",
        test_func = function()
          local lazy = require("lazy")
          local plugins = lazy.get_plugins()
          local essential_plugins = {"telescope", "nvim-tree", "tokyonight"}
          
          for _, plugin_name in ipairs(essential_plugins) do
            local found = false
            for _, plugin in pairs(plugins) do
              if plugin.name:find(plugin_name) then
                found = true
                break
              end
            end
            if not found then
              return false
            end
          end
          return true
        end,
        critical = true
      },
      {
        name = "Plugin Loading",
        description = "Test plugin loading functionality",
        test_func = function()
          local enhanced_loader = require("yoda.utils.enhanced_plugin_loader")
          if enhanced_loader then
            return true
          end
          return false
        end,
        critical = false
      }
    }
  },
  
  lsp_tests = {
    name = "LSP System Tests",
    description = "Test LSP configuration and functionality",
    category = TEST_CATEGORIES.LSP,
    tests = {
      {
        name = "LSP Config Loading",
        description = "Verify LSP configuration is loaded",
        test_func = function()
          local ok = pcall(require, "yoda.lsp")
          return ok
        end,
        critical = true
      },
      {
        name = "Mason Integration",
        description = "Test Mason integration",
        test_func = function()
          local ok = pcall(require, "mason")
          return ok
        end,
        critical = false
      },
      {
        name = "LSP Capabilities",
        description = "Test LSP capabilities",
        test_func = function()
          local lsp = require("yoda.lsp")
          if lsp and lsp.capabilities then
            local caps = lsp.capabilities()
            return caps ~= nil
          end
          return false
        end,
        critical = false
      }
    }
  },
  
  performance_tests = {
    name = "Performance Tests",
    description = "Test performance and optimization features",
    category = TEST_CATEGORIES.PERFORMANCE,
    tests = {
      {
        name = "Startup Profiling",
        description = "Test startup profiling system",
        test_func = function()
          local ok = pcall(require, "yoda.utils.startup_profiler")
          return ok
        end,
        critical = false
      },
      {
        name = "Performance Monitoring",
        description = "Test performance monitoring",
        test_func = function()
          local ok = pcall(require, "yoda.utils.performance_monitor")
          return ok
        end,
        critical = false
      },
      {
        name = "Optimization Helper",
        description = "Test optimization helper",
        test_func = function()
          local ok = pcall(require, "yoda.utils.optimization_helper")
          return ok
        end,
        critical = false
      }
    }
  },
  
  integration_tests = {
    name = "Integration Tests",
    description = "Test integration between components",
    category = TEST_CATEGORIES.INTEGRATION,
    tests = {
      {
        name = "Error Recovery Integration",
        description = "Test error recovery integration",
        test_func = function()
          local error_recovery = require("yoda.utils.error_recovery")
          local enhanced_loader = require("yoda.utils.enhanced_plugin_loader")
          return error_recovery ~= nil and enhanced_loader ~= nil
        end,
        critical = false
      },
      {
        name = "Help System Integration",
        description = "Test help system integration",
        test_func = function()
          local help_system = require("yoda.utils.interactive_help")
          local feature_discovery = require("yoda.utils.feature_discovery")
          return help_system ~= nil and feature_discovery ~= nil
        end,
        critical = false
      },
      {
        name = "Keymap Integration",
        description = "Test keymap logging integration",
        test_func = function()
          local keymap_utils = require("yoda.utils.keymap_utils")
          return keymap_utils ~= nil
        end,
        critical = false
      }
    }
  },
  
  health_tests = {
    name = "Health Check Tests",
    description = "Comprehensive health checks",
    category = TEST_CATEGORIES.HEALTH,
    tests = {
      {
        name = "Neovim Version",
        description = "Check Neovim version compatibility",
        test_func = function()
          local version = vim.fn.has("nvim-0.8.0")
          return version == 1
        end,
        critical = true
      },
      {
        name = "System Requirements",
        description = "Check system requirements",
        test_func = function()
          local has_git = vim.fn.executable("git") == 1
          local has_node = vim.fn.executable("node") == 1
          return has_git and has_node
        end,
        critical = true
      },
      {
        name = "File Permissions",
        description = "Check file permissions",
        test_func = function()
          local data_dir = vim.fn.stdpath("data")
          local config_dir = vim.fn.stdpath("config")
          return vim.fn.isdirectory(data_dir) == 1 and vim.fn.isdirectory(config_dir) == 1
        end,
        critical = true
      }
    }
  }
}

-- Run a single test
function M.run_test(test_suite, test)
  local start_time = vim.loop.hrtime()
  local success, result = pcall(test.test_func)
  local end_time = vim.loop.hrtime()
  local duration = (end_time - start_time) / 1000000
  
  local test_result = {
    suite = test_suite.name,
    test = test.name,
    description = test.description,
    status = success and result and TEST_STATUS.PASSED or TEST_STATUS.FAILED,
    duration = duration,
    critical = test.critical,
    timestamp = os.time()
  }
  
  if not success then
    test_result.error = result
  end
  
  table.insert(test_data.results, test_result)
  return test_result
end

-- Run a test suite
function M.run_test_suite(suite_name)
  local suite = TEST_SUITES[suite_name]
  if not suite then
    return nil
  end
  
  local suite_results = {
    name = suite.name,
    description = suite.description,
    category = suite.category,
    tests = {},
    summary = {
      total = 0,
      passed = 0,
      failed = 0,
      skipped = 0,
      critical_failures = 0
    }
  }
  
  for _, test in ipairs(suite.tests) do
    local result = M.run_test(suite, test)
    table.insert(suite_results.tests, result)
    
    suite_results.summary.total = suite_results.summary.total + 1
    if result.status == TEST_STATUS.PASSED then
      suite_results.summary.passed = suite_results.summary.passed + 1
    elseif result.status == TEST_STATUS.FAILED then
      suite_results.summary.failed = suite_results.summary.failed + 1
      if result.critical then
        suite_results.summary.critical_failures = suite_results.summary.critical_failures + 1
      end
    elseif result.status == TEST_STATUS.SKIPPED then
      suite_results.summary.skipped = suite_results.summary.skipped + 1
    end
  end
  
  test_data.test_suites[suite_name] = suite_results
  return suite_results
end

-- Run all tests
function M.run_all_tests()
  local all_results = {
    suites = {},
    summary = {
      total_suites = 0,
      total_tests = 0,
      passed_tests = 0,
      failed_tests = 0,
      critical_failures = 0,
      start_time = os.time()
    }
  }
  
  for suite_name, _ in pairs(TEST_SUITES) do
    local suite_result = M.run_test_suite(suite_name)
    if suite_result then
      table.insert(all_results.suites, suite_result)
      all_results.summary.total_suites = all_results.summary.total_suites + 1
      all_results.summary.total_tests = all_results.summary.total_tests + suite_result.summary.total
      all_results.summary.passed_tests = all_results.summary.passed_tests + suite_result.summary.passed
      all_results.summary.failed_tests = all_results.summary.failed_tests + suite_result.summary.failed
      all_results.summary.critical_failures = all_results.summary.critical_failures + suite_result.summary.critical_failures
    end
  end
  
  all_results.summary.end_time = os.time()
  all_results.summary.duration = all_results.summary.end_time - all_results.summary.start_time
  
  return all_results
end

-- Health check functions
function M.health_check_core()
  local health = {
    level = HEALTH_LEVELS.SUCCESS,
    issues = {},
    recommendations = {}
  }
  
  -- Check Neovim version
  if vim.fn.has("nvim-0.8.0") ~= 1 then
    table.insert(health.issues, "Neovim version should be 0.8.0 or higher")
    health.level = HEALTH_LEVELS.ERROR
  end
  
  -- Check leader key
  if vim.g.mapleader ~= " " then
    table.insert(health.issues, "Leader key should be set to space")
    health.level = HEALTH_LEVELS.WARNING
  end
  
  -- Check Yoda config
  if not vim.g.yoda_config then
    table.insert(health.issues, "Yoda configuration not found")
    health.level = HEALTH_LEVELS.ERROR
  end
  
  -- Check core modules
  local core_modules = {"options", "keymaps", "autocmds", "functions"}
  for _, module in ipairs(core_modules) do
    local ok = pcall(require, "yoda.core." .. module)
    if not ok then
      table.insert(health.issues, "Core module 'yoda.core." .. module .. "' failed to load")
      health.level = HEALTH_LEVELS.ERROR
    end
  end
  
  return health
end

function M.health_check_plugins()
  local health = {
    level = HEALTH_LEVELS.SUCCESS,
    issues = {},
    recommendations = {}
  }
  
  -- Check Lazy.nvim
  local lazy_ok = pcall(require, "lazy")
  if not lazy_ok then
    table.insert(health.issues, "Lazy.nvim not found")
    health.level = HEALTH_LEVELS.ERROR
  else
    local lazy = require("lazy")
    local plugins = lazy.get_plugins()
    
    -- Check essential plugins
    local essential_plugins = {
      {name = "telescope", desc = "File finding and fuzzy search"},
      {name = "nvim-tree", desc = "File explorer"},
      {name = "tokyonight", desc = "Color scheme"}
    }
    
    for _, plugin_info in ipairs(essential_plugins) do
      local found = false
      for _, plugin in pairs(plugins) do
        if plugin.name:find(plugin_info.name) then
          found = true
          break
        end
      end
      if not found then
        table.insert(health.issues, "Essential plugin '" .. plugin_info.name .. "' not found")
        health.level = HEALTH_LEVELS.WARNING
      end
    end
  end
  
  return health
end

function M.health_check_lsp()
  local health = {
    level = HEALTH_LEVELS.SUCCESS,
    issues = {},
    recommendations = {}
  }
  
  -- Check LSP modules
  local lsp_ok = pcall(require, "yoda.lsp")
  if not lsp_ok then
    table.insert(health.issues, "LSP configuration not found")
    health.level = HEALTH_LEVELS.ERROR
  end
  
  -- Check Mason
  local mason_ok = pcall(require, "mason")
  if not mason_ok then
    table.insert(health.issues, "Mason not found")
    health.level = HEALTH_LEVELS.WARNING
  end
  
  -- Check LSP clients
  if vim.lsp then
    local clients = vim.lsp.get_active_clients()
    if #clients == 0 then
      table.insert(health.issues, "No active LSP clients")
      health.level = HEALTH_LEVELS.INFO
    end
  end
  
  return health
end

function M.health_check_performance()
  local health = {
    level = HEALTH_LEVELS.SUCCESS,
    issues = {},
    recommendations = {}
  }
  
  -- Check startup time
  local startup_time = vim.g.yoda_startup_time or 0
  if startup_time > 2000 then
    table.insert(health.issues, "Startup time is slow (" .. startup_time .. "ms)")
    health.level = HEALTH_LEVELS.WARNING
    table.insert(health.recommendations, "Consider enabling startup profiling")
  end
  
  -- Check profiling modules
  local profiler_ok = pcall(require, "yoda.utils.startup_profiler")
  if not profiler_ok then
    table.insert(health.issues, "Startup profiler not available")
    health.level = HEALTH_LEVELS.INFO
  end
  
  return health
end

function M.health_check_utils()
  local health = {
    level = HEALTH_LEVELS.SUCCESS,
    issues = {},
    recommendations = {}
  }
  
  -- Check utility modules
  local utils = {
    "error_recovery",
    "interactive_help", 
    "feature_discovery",
    "enhanced_plugin_loader"
  }
  
  for _, util in ipairs(utils) do
    local ok = pcall(require, "yoda.utils." .. util)
    if not ok then
      table.insert(health.issues, "Utility module 'yoda.utils." .. util .. "' failed to load")
      health.level = HEALTH_LEVELS.WARNING
    end
  end
  
  return health
end

-- Run comprehensive health check
function M.run_health_check()
  local health_results = {
    core = M.health_check_core(),
    plugins = M.health_check_plugins(),
    lsp = M.health_check_lsp(),
    performance = M.health_check_performance(),
    utils = M.health_check_utils(),
    timestamp = os.time()
  }
  
  -- Calculate overall health
  local overall_level = HEALTH_LEVELS.SUCCESS
  local total_issues = 0
  
  for category, health in pairs(health_results) do
    if category ~= "timestamp" then
      if health.level == HEALTH_LEVELS.ERROR then
        overall_level = HEALTH_LEVELS.ERROR
      elseif health.level == HEALTH_LEVELS.WARNING and overall_level ~= HEALTH_LEVELS.ERROR then
        overall_level = HEALTH_LEVELS.WARNING
      end
      total_issues = total_issues + #health.issues
    end
  end
  
  health_results.overall = {
    level = overall_level,
    total_issues = total_issues
  }
  
  test_data.health_checks = health_results
  return health_results
end

-- Print test results
function M.print_test_results(results)
  print("=== Yoda.nvim Test Results ===")
  print(string.format("Total Suites: %d", results.summary.total_suites))
  print(string.format("Total Tests: %d", results.summary.total_tests))
  print(string.format("Passed: %d", results.summary.passed_tests))
  print(string.format("Failed: %d", results.summary.failed_tests))
  print(string.format("Critical Failures: %d", results.summary.critical_failures))
  print(string.format("Duration: %d seconds", results.summary.duration))
  
  for _, suite in ipairs(results.suites) do
    print(string.format("\n📋 %s", suite.name))
    print(string.format("   Tests: %d/%d passed", suite.summary.passed, suite.summary.total))
    
    for _, test in ipairs(suite.tests) do
      local status_icon = {
        [TEST_STATUS.PASSED] = "✅",
        [TEST_STATUS.FAILED] = "❌",
        [TEST_STATUS.SKIPPED] = "⏭️",
        [TEST_STATUS.WARNING] = "⚠️"
      }
      
      print(string.format("   %s %s (%.2fms)", 
        status_icon[test.status] or "❓", 
        test.name, 
        test.duration))
      
      if test.status == TEST_STATUS.FAILED and test.error then
        print(string.format("      Error: %s", test.error))
      end
    end
  end
  
  print("==============================")
end

-- Print health check results
function M.print_health_results(results)
  print("=== Yoda.nvim Health Check ===")
  
  local level_icons = {
    [HEALTH_LEVELS.CRITICAL] = "🚨",
    [HEALTH_LEVELS.ERROR] = "❌",
    [HEALTH_LEVELS.WARNING] = "⚠️",
    [HEALTH_LEVELS.INFO] = "ℹ️",
    [HEALTH_LEVELS.SUCCESS] = "✅"
  }
  
  print(string.format("Overall Health: %s %s", 
    level_icons[results.overall.level], 
    results.overall.level:upper()))
  print(string.format("Total Issues: %d", results.overall.total_issues))
  
  for category, health in pairs(results) do
    if category ~= "overall" and category ~= "timestamp" then
      print(string.format("\n📋 %s: %s %s", 
        category:upper(), 
        level_icons[health.level], 
        health.level:upper()))
      
      if #health.issues > 0 then
        print("   Issues:")
        for _, issue in ipairs(health.issues) do
          print(string.format("   • %s", issue))
        end
      end
      
      if #health.recommendations > 0 then
        print("   Recommendations:")
        for _, rec in ipairs(health.recommendations) do
          print(string.format("   💡 %s", rec))
        end
      end
    end
  end
  
  print("==============================")
end

-- Generate test report
function M.generate_test_report()
  local results = M.run_all_tests()
  local health = M.run_health_check()
  
  local report = {
    test_results = results,
    health_check = health,
    timestamp = os.time(),
    neovim_version = vim.fn.has("nvim-0.8.0") == 1 and "0.8.0+" or "Unknown",
    platform = vim.fn.has("unix") == 1 and "Unix" or "Windows"
  }
  
  return report
end

-- User commands
vim.api.nvim_create_user_command("YodaRunTests", function()
  local results = M.run_all_tests()
  M.print_test_results(results)
end, { desc = "Run all distribution tests" })

vim.api.nvim_create_user_command("YodaHealthCheck", function()
  local health = M.run_health_check()
  M.print_health_results(health)
end, { desc = "Run comprehensive health check" })

vim.api.nvim_create_user_command("YodaTestSuite", function()
  local suite_name = vim.fn.input("Enter test suite name: ")
  if suite_name and suite_name ~= "" then
    local results = M.run_test_suite(suite_name)
    if results then
      M.print_test_results({suites = {results}, summary = results.summary})
    else
      vim.notify("Test suite not found: " .. suite_name, vim.log.levels.ERROR)
    end
  end
end, { desc = "Run specific test suite" })

vim.api.nvim_create_user_command("YodaTestReport", function()
  local report = M.generate_test_report()
  
  -- Create floating window with report
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(20, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
    title = " Yoda Test Report ",
    title_pos = "center"
  })
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  
  -- Generate report content
  local lines = {
    "=== Yoda.nvim Test Report ===",
    string.format("Generated: %s", os.date()),
    string.format("Neovim Version: %s", report.neovim_version),
    string.format("Platform: %s", report.platform),
    "",
    "Test Results:",
    string.format("  Total Suites: %d", report.test_results.summary.total_suites),
    string.format("  Total Tests: %d", report.test_results.summary.total_tests),
    string.format("  Passed: %d", report.test_results.summary.passed_tests),
    string.format("  Failed: %d", report.test_results.summary.failed_tests),
    string.format("  Critical Failures: %d", report.test_results.summary.critical_failures),
    "",
    "Health Check:",
    string.format("  Overall: %s", report.health_check.overall.level:upper()),
    string.format("  Issues: %d", report.health_check.overall.total_issues),
    "",
    "Recommendations:",
    "  • Run :YodaHealthCheck for detailed health info",
    "  • Run :YodaRunTests for comprehensive testing",
    "  • Check documentation for troubleshooting"
  }
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Add keymaps
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })
  
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })
end, { desc = "Generate comprehensive test report" })

return M 