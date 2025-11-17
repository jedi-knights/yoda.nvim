-- lua/yoda/autocmd_logger.lua
-- Detailed logging for autocmd operations to diagnose flickering and performance issues

local M = {}

local notify = require("yoda-adapters.notification")

local log_file = vim.fn.stdpath("data") .. "/yoda_autocmd.log"
local enabled = false

--- Enable autocmd logging
function M.enable()
  enabled = true
  -- Clear old log file
  local f = io.open(log_file, "w")
  if f then
    f:write(string.format("=== Yoda Autocmd Log Started: %s ===\n", os.date("%Y-%m-%d %H:%M:%S")))
    f:close()
  end
  notify.notify("Autocmd logging enabled: " .. log_file, "info")
end

--- Disable autocmd logging
function M.disable()
  enabled = false
  notify.notify("Autocmd logging disabled", "info")
end

--- Toggle autocmd logging
function M.toggle()
  if enabled then
    M.disable()
  else
    M.enable()
  end
end

--- Check if logging is enabled
--- @return boolean
function M.is_enabled()
  return enabled
end

--- Get log file path
--- @return string
function M.get_log_file()
  return log_file
end

--- Log an autocmd event
--- @param event string Event name
--- @param details table Event details
function M.log(event, details)
  if not enabled then
    return
  end

  local f = io.open(log_file, "a")
  if not f then
    return
  end

  local timestamp = string.format("[%s.%03d]", os.date("%H:%M:%S"), math.floor((vim.loop.hrtime() / 1000000) % 1000))
  local buf = details.buf or vim.api.nvim_get_current_buf()

  -- Check if buffer is valid before accessing properties
  if not vim.api.nvim_buf_is_valid(buf) then
    -- Log with minimal info for invalid buffer
    local parts = {
      timestamp,
      event,
      string.format("buf=%d", buf),
      "INVALID_BUFFER",
    }
    for k, v in pairs(details) do
      if k ~= "buf" then
        table.insert(parts, string.format("%s=%s", k, tostring(v)))
      end
    end
    f:write(table.concat(parts, " ") .. "\n")
    f:close()
    return
  end

  -- Safe buffer property access
  local ok_name, bufname = pcall(vim.api.nvim_buf_get_name, buf)
  local ok_ft, filetype = pcall(function()
    return vim.bo[buf].filetype
  end)
  local ok_bt, buftype = pcall(function()
    return vim.bo[buf].buftype
  end)

  bufname = ok_name and bufname or ""
  filetype = ok_ft and filetype or "unknown"
  buftype = ok_bt and buftype or "unknown"

  -- Build log line
  local parts = {
    timestamp,
    event,
    string.format("buf=%d", buf),
    string.format("ft=%s", filetype ~= "" and filetype or "none"),
    string.format("bt=%s", buftype ~= "" and buftype or "none"),
  }

  -- Add file name (last component only for brevity)
  if bufname ~= "" then
    local short_name = vim.fn.fnamemodify(bufname, ":t")
    table.insert(parts, string.format("file=%s", short_name))
  end

  -- Add custom details
  for k, v in pairs(details) do
    if k ~= "buf" then
      table.insert(parts, string.format("%s=%s", k, tostring(v)))
    end
  end

  f:write(table.concat(parts, " ") .. "\n")
  f:close()
end

--- Log start of an operation
--- @param operation string Operation name
--- @param details table Operation details
--- @return number Start time in milliseconds
function M.log_start(operation, details)
  if not enabled then
    return 0
  end

  local start_time = vim.loop.hrtime() / 1000000
  M.log(operation .. "_START", details)
  return start_time
end

--- Log end of an operation with duration
--- @param operation string Operation name
--- @param start_time number Start time from log_start
--- @param details table Operation details
function M.log_end(operation, start_time, details)
  if not enabled then
    return
  end

  local end_time = vim.loop.hrtime() / 1000000
  local duration = end_time - start_time
  details = details or {}
  details.duration_ms = string.format("%.2f", duration)
  M.log(operation .. "_END", details)
end

--- Open the log file for viewing
function M.view_log()
  vim.cmd("edit " .. log_file)
end

--- Clear the log file
function M.clear_log()
  local f = io.open(log_file, "w")
  if f then
    f:write(string.format("=== Yoda Autocmd Log Cleared: %s ===\n", os.date("%Y-%m-%d %H:%M:%S")))
    f:close()
  end
  notify.notify("Autocmd log cleared", "info")
end

return M
