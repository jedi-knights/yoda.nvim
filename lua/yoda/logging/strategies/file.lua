-- lua/yoda/logging/strategies/file.lua
-- File output strategy with rotation support

local M = {}

--- Get file size in bytes
--- @param filepath string File path
--- @return number File size or 0 if not exists
local function get_file_size(filepath)
  local stat = vim.loop.fs_stat(filepath)
  return stat and stat.size or 0
end

--- Rotate log file if needed
--- @param filepath string Log file path
--- @param max_size number Maximum file size before rotation
--- @param rotate_count number Number of backup files to keep
local function rotate_if_needed(filepath, max_size, rotate_count)
  if get_file_size(filepath) < max_size then
    return
  end

  -- Remove oldest backup
  local oldest_backup = filepath .. "." .. rotate_count
  if vim.fn.filereadable(oldest_backup) == 1 then
    vim.fn.delete(oldest_backup)
  end

  -- Shift existing backups
  for i = rotate_count - 1, 1, -1 do
    local old_file = filepath .. "." .. i
    if vim.fn.filereadable(old_file) == 1 then
      local new_file = filepath .. "." .. (i + 1)
      vim.fn.rename(old_file, new_file)
    end
  end

  -- Rotate current log to .1
  if vim.fn.filereadable(filepath) == 1 then
    vim.fn.rename(filepath, filepath .. ".1")
  end
end

--- Write log message to file
--- @param message string Formatted log message
--- @param level number Log level
function M.write(message, level)
  -- Input validation
  if type(message) ~= "string" then
    return
  end

  local config = require("yoda.logging.config").get()
  local filepath = config.file.path

  -- Ensure directory exists
  local dir = vim.fn.fnamemodify(filepath, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end

  -- Rotate if needed
  rotate_if_needed(filepath, config.file.max_size, config.file.rotate_count)

  -- Append to file
  local file = io.open(filepath, "a")
  if file then
    file:write(message .. "\n")
    file:close()
  end
end

--- Flush file output (ensure writes are committed)
function M.flush()
  -- File is closed after each write, so already flushed
end

--- Clear log file
function M.clear()
  local config = require("yoda.logging.config").get()
  local filepath = config.file.path

  if vim.fn.filereadable(filepath) == 1 then
    vim.fn.delete(filepath)
  end
end

return M
