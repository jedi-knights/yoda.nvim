-- lua/yoda/logging/logger.lua
-- Unified logging facade with multiple strategies (Strategy pattern - GoF #8)
-- Provides consistent logging API across all Yoda.nvim modules

local M = {}

-- Re-export log levels for convenience
M.LEVELS = require("yoda.logging.config").LEVELS

-- Strategy cache (lazy loaded)
local strategies = {}

--- Get strategy module (lazy loaded)
--- @param name string Strategy name
--- @return table Strategy module
local function get_strategy(name)
  if not strategies[name] then
    local ok, strategy = pcall(require, "yoda.logging.strategies." .. name)
    if ok then
      strategies[name] = strategy
    else
      -- Fallback to console if strategy fails to load
      strategies[name] = require("yoda.logging.strategies.console")
    end
  end
  return strategies[name]
end

--- Check if message should be logged based on level
--- @param level number Message level
--- @return boolean True if should log
local function should_log(level)
  local config = require("yoda.logging.config")
  return level >= config.get_level()
end

--- Evaluate message (supports lazy evaluation for performance)
--- @param msg string|function Message or function that returns message
--- @return string Evaluated message
local function evaluate_message(msg)
  if type(msg) == "function" then
    local ok, result = pcall(msg)
    return ok and tostring(result) or "[Error evaluating message]"
  end
  return tostring(msg)
end

--- Core logging function (internal)
--- @param level number Log level
--- @param msg string|function Message or lazy message function
--- @param context table|nil Optional context data
function M.log(level, msg, context)
  -- Level filtering (early bailout for performance)
  if not should_log(level) then
    return
  end

  -- Lazy evaluation (only if message will be logged)
  local evaluated_msg = evaluate_message(msg)

  -- Format message
  local formatter = require("yoda.logging.formatter")
  local formatted = formatter.format(level, evaluated_msg, context)

  -- Get current strategy and write
  local config = require("yoda.logging.config")
  local strategy_name = config.get_strategy()
  local strategy = get_strategy(strategy_name)

  strategy.write(formatted, level)
end

--- Log trace message (most verbose)
--- @param msg string|function Message
--- @param context table|nil Optional context
function M.trace(msg, context)
  M.log(M.LEVELS.TRACE, msg, context)
end

--- Log debug message
--- @param msg string|function Message
--- @param context table|nil Optional context
function M.debug(msg, context)
  M.log(M.LEVELS.DEBUG, msg, context)
end

--- Log info message
--- @param msg string|function Message
--- @param context table|nil Optional context
function M.info(msg, context)
  M.log(M.LEVELS.INFO, msg, context)
end

--- Log warning message
--- @param msg string|function Message
--- @param context table|nil Optional context
function M.warn(msg, context)
  M.log(M.LEVELS.WARN, msg, context)
end

--- Log error message
--- @param msg string|function Message
--- @param context table|nil Optional context
function M.error(msg, context)
  M.log(M.LEVELS.ERROR, msg, context)
end

--- Set logging strategy
--- @param strategy string Strategy name ("console", "file", "notify", "multi")
function M.set_strategy(strategy)
  require("yoda.logging.config").set_strategy(strategy)
end

--- Set log level
--- @param level number|string Level (number or name like "debug")
function M.set_level(level)
  require("yoda.logging.config").set_level(level)
end

--- Set log file path (for file strategy)
--- @param path string Log file path
function M.set_file_path(path)
  require("yoda.logging.config").set_log_file(path)
end

--- Configure logger
--- @param opts table Configuration options
function M.setup(opts)
  require("yoda.logging.config").update(opts)
end

--- Flush output (ensure all writes committed)
function M.flush()
  local config = require("yoda.logging.config")
  local strategy_name = config.get_strategy()
  local strategy = get_strategy(strategy_name)

  if strategy.flush then
    strategy.flush()
  end
end

--- Clear logs (for file strategy)
function M.clear()
  local config = require("yoda.logging.config")
  local strategy_name = config.get_strategy()
  local strategy = get_strategy(strategy_name)

  if strategy.clear then
    strategy.clear()
  end
end

--- Reset configuration to defaults
function M.reset()
  require("yoda.logging.config").reset()
  strategies = {} -- Clear strategy cache
end

return M
