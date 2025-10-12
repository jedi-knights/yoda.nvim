-- lua/yoda/logging/strategies/notify.lua
-- Notification strategy using vim.notify (via adapter)

local M = {}

--- Convert log level to notify level
--- @param level number Log level
--- @return number Notify level
local function to_notify_level(level)
  local config = require("yoda.logging.config")

  -- Map log levels to vim.log.levels
  if level >= config.LEVELS.ERROR then
    return vim.log.levels.ERROR
  elseif level >= config.LEVELS.WARN then
    return vim.log.levels.WARN
  elseif level >= config.LEVELS.INFO then
    return vim.log.levels.INFO
  elseif level >= config.LEVELS.DEBUG then
    return vim.log.levels.DEBUG
  else
    return vim.log.levels.TRACE
  end
end

--- Write log message via notification system
--- @param message string Formatted log message
--- @param level number Log level
function M.write(message, level)
  -- Input validation
  if type(message) ~= "string" then
    return
  end

  -- Convert level
  local notify_level = to_notify_level(level)

  -- Use notification adapter for DIP
  local ok, adapter = pcall(require, "yoda.adapters.notification")
  if ok and adapter then
    adapter.notify(message, notify_level, { title = "Yoda" })
  else
    -- Fallback to native vim.notify
    vim.notify(message, notify_level, { title = "Yoda" })
  end
end

--- Flush notification output (no-op for notifications)
function M.flush()
  -- Notifications are sent immediately
end

return M
