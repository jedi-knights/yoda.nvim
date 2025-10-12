-- lua/yoda/logging/strategies/console.lua
-- Console output strategy using print()

local M = {}

--- Write log message to console
--- @param message string Formatted log message
--- @param level number Log level
function M.write(message, level)
  -- Input validation
  if type(message) ~= "string" then
    return
  end

  -- Output to console using print
  print(message)
end

--- Flush console output (no-op for console)
function M.flush()
  -- Console output is already flushed
end

return M
