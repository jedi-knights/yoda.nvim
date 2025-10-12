-- examples/logging_usage.lua
-- Examples of using the unified logging system

local logger = require("yoda.logging.logger")

-- ============================================================================
-- BASIC USAGE
-- ============================================================================

-- Simple logging at different levels
logger.trace("Very detailed trace information")
logger.debug("Debug information for development")
logger.info("General information")
logger.warn("Warning about potential issue")
logger.error("Error that occurred")

-- ============================================================================
-- LOGGING WITH CONTEXT
-- ============================================================================

-- Add structured context to log messages
logger.debug("Loading plugin", {
  plugin = "telescope",
  event = "VeryLazy",
  duration_ms = 150,
})

logger.error("Failed to parse file", {
  file = "/path/to/file.yaml",
  error = "Invalid syntax",
  line = 42,
})

-- ============================================================================
-- LAZY EVALUATION (Performance Optimization)
-- ============================================================================

-- Function messages are only evaluated if they will be logged
logger.debug(function()
  -- This expensive operation only runs if DEBUG level is enabled
  local huge_table = { lots = "of", nested = { data = "here" } }
  return "Expensive computation: " .. vim.inspect(huge_table)
end)

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

-- Development mode: Console output
logger.set_strategy("console")
logger.set_level("debug")

-- Production mode: Notifications only
logger.set_strategy("notify")
logger.set_level("warn")

-- Troubleshooting: Log to file
logger.set_strategy("file")
logger.set_level("trace")
logger.set_file_path(vim.fn.getcwd() .. "/yoda-debug.log")

-- Best of both: Console + File
logger.set_strategy("multi")
logger.set_level("debug")

-- ============================================================================
-- ENVIRONMENT-BASED CONFIGURATION
-- ============================================================================

-- Configure based on environment
if vim.env.YODA_ENV == "development" then
  logger.setup({
    strategy = "multi", -- Console + File
    level = logger.LEVELS.DEBUG,
    file = {
      path = vim.fn.getcwd() .. "/yoda-dev.log",
    },
  })
elseif vim.env.YODA_DEBUG then
  logger.setup({
    strategy = "file",
    level = logger.LEVELS.TRACE,
    file = {
      path = vim.fn.getcwd() .. "/yoda-trace.log",
    },
  })
else
  -- Normal user mode
  logger.setup({
    strategy = "notify",
    level = logger.LEVELS.INFO,
  })
end

-- ============================================================================
-- MODULE-SPECIFIC USAGE
-- ============================================================================

-- In your module (e.g., lua/yoda/my_module.lua)
local M = {}

function M.complex_operation(data)
  logger.debug("Starting complex operation", { input_size = #data })

  for i, item in ipairs(data) do
    logger.trace(function()
      return "Processing item " .. i .. ": " .. vim.inspect(item)
    end)

    local ok, result = pcall(M.process_item, item)
    if not ok then
      logger.error("Failed to process item", {
        index = i,
        item = item,
        error = result,
      })
    else
      logger.debug("Processed item successfully", { index = i })
    end
  end

  logger.info("Complex operation complete", {
    total_items = #data,
    timestamp = os.date("%Y-%m-%d %H:%M:%S"),
  })
end

-- ============================================================================
-- DEBUGGING WORKFLOW
-- ============================================================================

-- When debugging an issue:
-- 1. Enable file logging with trace level
logger.set_strategy("file")
logger.set_level("trace")
logger.set_file_path(vim.fn.getcwd() .. "/debug.log")

-- 2. Reproduce the issue
-- ... your code runs ...

-- 3. Check the log file
-- :!cat debug.log
-- Or open in Neovim:
-- :edit debug.log

-- 4. Clear logs when done
logger.clear()

-- 5. Return to normal mode
logger.set_strategy("notify")
logger.set_level("info")

-- ============================================================================
-- PERFORMANCE PROFILING
-- ============================================================================

-- Add timing information to logs
local start_time = vim.loop.hrtime()

-- ... do work ...

local end_time = vim.loop.hrtime()
local duration_ms = (end_time - start_time) / 1000000

logger.debug("Operation completed", {
  operation = "load_config",
  duration_ms = duration_ms,
  status = "success",
})

-- ============================================================================
-- INTEGRATION WITH EXISTING CODE
-- ============================================================================

-- Replace existing logging patterns:

-- OLD: print("Debug: " .. msg)
-- NEW: logger.debug(msg)

-- OLD: vim.notify("Error: " .. msg, vim.log.levels.ERROR)
-- NEW: logger.error(msg)

-- OLD: if verbose then print("Details: " .. details) end
-- NEW: logger.debug(details)  -- Level filtering handles this

-- OLD: custom debug_log table + file write
-- NEW: logger.set_strategy("file") + logger.trace(msg)

return logger

