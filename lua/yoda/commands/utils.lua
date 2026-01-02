-- lua/yoda/commands/utils.lua
-- Shared utilities for command modules

local M = {}

-- Helper to get logger (lazy-loaded to avoid test failures)
local function get_logger()
  local ok, logger = pcall(require, "yoda-logging.logger")
  if not ok then
    -- Fallback logger for tests
    return {
      set_strategy = function() end,
      set_level = function() end,
      debug = function(msg)
        print(msg)
      end,
      info = function(msg)
        print(msg)
      end,
      error = function(msg)
        print(msg)
      end,
    }
  end
  return logger
end

-- Helper to get configured logger (reduces duplication)
function M.get_console_logger(level)
  level = level or "info"
  local logger = get_logger()
  logger.set_strategy("console")
  logger.set_level(level)
  return logger
end

return M
