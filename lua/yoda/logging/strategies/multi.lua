-- lua/yoda/logging/strategies/multi.lua
-- Multi-strategy that combines console and file output

local M = {}

--- Write log message to both console and file
--- @param message string Formatted log message
--- @param level number Log level
function M.write(message, level)
  -- Input validation
  if type(message) ~= "string" then
    return
  end

  -- Write to console
  local console = require("yoda.logging.strategies.console")
  console.write(message, level)

  -- Write to file
  local file = require("yoda.logging.strategies.file")
  file.write(message, level)
end

--- Flush both console and file
function M.flush()
  local console = require("yoda.logging.strategies.console")
  console.flush()

  local file = require("yoda.logging.strategies.file")
  file.flush()
end

--- Clear file logs (console can't be cleared)
function M.clear()
  local file = require("yoda.logging.strategies.file")
  if file.clear then
    file.clear()
  end
end

return M
