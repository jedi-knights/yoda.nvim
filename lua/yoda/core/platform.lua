-- lua/yoda/core/platform.lua
-- Platform detection utilities (consolidated from multiple modules)
-- Eliminates is_windows() duplication

local M = {}

-- ============================================================================
-- PLATFORM DETECTION
-- ============================================================================

--- Check if running on Windows (consolidated from 2 implementations)
--- @return boolean
function M.is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

--- Check if running on macOS
--- @return boolean
function M.is_macos()
  return vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
end

--- Check if running on Linux
--- @return boolean
function M.is_linux()
  return vim.fn.has("unix") == 1 and not M.is_macos()
end

--- Get platform name
--- @return string Platform name ("windows", "macos", "linux", "unknown")
function M.get_platform()
  if M.is_windows() then
    return "windows"
  elseif M.is_macos() then
    return "macos"
  elseif M.is_linux() then
    return "linux"
  end
  return "unknown"
end

-- ============================================================================
-- PATH UTILITIES
-- ============================================================================

--- Get path separator for current platform
--- @return string Path separator ("/" or "\\")
function M.get_path_sep()
  return M.is_windows() and "\\" or "/"
end

--- Join path components with platform-appropriate separator
--- @param ... string Path components
--- @return string Joined path
function M.join_path(...)
  local parts = { ... }
  local sep = M.get_path_sep()
  return table.concat(parts, sep)
end

--- Normalize path separators for current platform
--- @param path string Path with mixed separators
--- @return string Path with platform-appropriate separators
function M.normalize_path(path)
  if M.is_windows() then
    return path:gsub("/", "\\")
  else
    return path:gsub("\\", "/")
  end
end

return M
