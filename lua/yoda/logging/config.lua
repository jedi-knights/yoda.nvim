-- lua/yoda/logging/config.lua
-- Logging configuration with sensible defaults

local M = {}

-- Log levels (matches vim.log.levels for compatibility)
M.LEVELS = {
  TRACE = 0,
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
}

-- Level names for display
M.LEVEL_NAMES = {
  [0] = "TRACE",
  [1] = "DEBUG",
  [2] = "INFO",
  [3] = "WARN",
  [4] = "ERROR",
}

-- Default configuration
local defaults = {
  -- Minimum level to log (messages below this are filtered)
  level = M.LEVELS.INFO,

  -- Logging strategy: "console", "file", "notify", "multi"
  strategy = "notify",

  -- File logging configuration
  file = {
    path = vim.fn.stdpath("log") .. "/yoda.log",
    max_size = 1024 * 1024, -- 1MB
    rotate_count = 3, -- Keep 3 backup files
  },

  -- Message formatting
  format = {
    include_timestamp = true,
    include_level = true,
    include_context = true,
    timestamp_format = "%Y-%m-%d %H:%M:%S",
  },

  -- Performance
  lazy_evaluation = true, -- Support function messages
}

-- Current configuration (can be overridden)
local current_config = vim.deepcopy(defaults)

--- Get current configuration
--- @return table Configuration table
function M.get()
  return current_config
end

--- Update configuration (deep merge)
--- @param opts table Configuration options to merge
function M.update(opts)
  assert(type(opts) == "table", "opts must be a table")

  -- Deep merge with current config
  current_config = vim.tbl_deep_extend("force", current_config, opts)
end

--- Reset configuration to defaults
function M.reset()
  current_config = vim.deepcopy(defaults)
end

--- Get log file path
--- @return string Log file path
function M.get_log_file()
  return current_config.file.path
end

--- Set log file path
--- @param path string New log file path
function M.set_log_file(path)
  assert(type(path) == "string" and path ~= "", "path must be a non-empty string")
  current_config.file.path = path
end

--- Get current log level
--- @return number Current level
function M.get_level()
  return current_config.level
end

--- Set log level
--- @param level number|string Level (number or name like "debug")
function M.set_level(level)
  assert(type(level) == "number" or type(level) == "string", "level must be number or string")

  -- Convert string to number if needed
  if type(level) == "string" then
    local level_upper = level:upper()
    for num, name in pairs(M.LEVEL_NAMES) do
      if name == level_upper then
        current_config.level = num
        return
      end
    end
    error("invalid level name: " .. level .. " (expected: trace, debug, info, warn, error)")
  elseif type(level) == "number" then
    assert(level >= 0 and level <= 4, "level must be between 0 and 4")
    current_config.level = level
  end
end

--- Get current strategy name
--- @return string Strategy name
function M.get_strategy()
  return current_config.strategy
end

--- Set logging strategy
--- @param strategy string Strategy name ("console", "file", "notify", "multi")
function M.set_strategy(strategy)
  assert(type(strategy) == "string", "strategy must be a string")
  local valid_strategies = { console = true, file = true, notify = true, multi = true }
  assert(valid_strategies[strategy], "invalid strategy: " .. strategy .. " (expected: console, file, notify, or multi)")
  current_config.strategy = strategy
end

return M
