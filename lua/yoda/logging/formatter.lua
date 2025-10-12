-- lua/yoda/logging/formatter.lua
-- Message formatting for logging system

local M = {}

--- Format a timestamp
--- @param format string|nil Timestamp format (strftime compatible)
--- @return string Formatted timestamp
local function format_timestamp(format)
  format = format or "%Y-%m-%d %H:%M:%S"
  return os.date(format)
end

--- Format context table as key=value pairs
--- @param context table|nil Context data
--- @return string Formatted context or empty string
local function format_context(context)
  if not context or type(context) ~= "table" then
    return ""
  end

  local pairs_list = {}
  for key, value in pairs(context) do
    -- Convert value to string
    local value_str
    if type(value) == "table" then
      value_str = vim.inspect(value)
    else
      value_str = tostring(value)
    end

    table.insert(pairs_list, string.format("%s=%s", key, value_str))
  end

  if #pairs_list == 0 then
    return ""
  end

  return " | " .. table.concat(pairs_list, " ")
end

--- Format a complete log message
--- @param level number Log level
--- @param msg string Message
--- @param context table|nil Optional context data
--- @param opts table|nil Formatting options
--- @return string Formatted message
function M.format(level, msg, context, opts)
  opts = opts or require("yoda.logging.config").get().format

  local parts = {}

  -- Add timestamp if enabled
  if opts.include_timestamp then
    table.insert(parts, "[" .. format_timestamp(opts.timestamp_format) .. "]")
  end

  -- Add level if enabled
  if opts.include_level then
    local config = require("yoda.logging.config")
    local level_name = config.LEVEL_NAMES[level] or "INFO"
    table.insert(parts, "[" .. level_name .. "]")
  end

  -- Add message
  table.insert(parts, msg)

  -- Add context if enabled
  if opts.include_context and context then
    table.insert(parts, format_context(context))
  end

  return table.concat(parts, " ")
end

--- Format a simple message (no timestamp, minimal formatting)
--- @param level number Log level
--- @param msg string Message
--- @return string Formatted message
function M.format_simple(level, msg)
  local config = require("yoda.logging.config")
  local level_name = config.LEVEL_NAMES[level] or "INFO"
  return string.format("[%s] %s", level_name, msg)
end

return M
