-- lua/yoda/core/large_file.lua
-- Pure helpers for large-file detection. Buffer / autocmd / plugin wiring
-- lives in yoda.ui.large_file.

local M = {}

--- Format a file size for display in one of B / KB / MB.
--- @param bytes number File size in bytes
--- @return string Formatted size
function M.format_size(bytes)
  if bytes < 1024 then
    return bytes .. "B"
  elseif bytes < 1024 * 1024 then
    return string.format("%.1fKB", bytes / 1024)
  else
    return string.format("%.1fMB", bytes / (1024 * 1024))
  end
end

--- Test whether a file size exceeds the configured large-file threshold.
--- @param size number|nil File size in bytes; nil returns false
--- @param threshold number Threshold in bytes
--- @return boolean
function M.exceeds_threshold(size, threshold)
  return type(size) == "number" and size > threshold
end

return M
