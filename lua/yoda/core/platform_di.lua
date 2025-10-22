-- lua/yoda/core/platform_di.lua
-- Platform detection utilities with Dependency Injection
-- Pure utility module - no dependencies needed, but maintains consistency

local M = {}

--- Create new platform utilities instance (DI factory pattern)
--- @param deps table|nil No dependencies needed for pure utilities
--- @return table Platform utilities instance
function M.new(deps)
  deps = deps or {}
  local instance = {}

  -- ============================================================================
  -- Platform Detection
  -- ============================================================================

  --- Check if running on Windows
  --- @return boolean
  function instance.is_windows()
    return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
  end

  --- Check if running on macOS
  --- @return boolean
  function instance.is_macos()
    return vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
  end

  --- Check if running on Linux
  --- @return boolean
  function instance.is_linux()
    return vim.fn.has("unix") == 1 and not instance.is_macos()
  end

  --- Get platform name
  --- @return string "windows"|"macos"|"linux"|"unknown"
  function instance.get_platform()
    if instance.is_windows() then
      return "windows"
    elseif instance.is_macos() then
      return "macos"
    elseif instance.is_linux() then
      return "linux"
    else
      return "unknown"
    end
  end

  -- ============================================================================
  -- Path Utilities
  -- ============================================================================

  --- Get platform-specific path separator
  --- @return string
  function instance.get_path_sep()
    return instance.is_windows() and "\\" or "/"
  end

  --- Join path components
  --- @param ... string Path components
  --- @return string
  function instance.join_path(...)
    local parts = { ... }
    local sep = instance.get_path_sep()
    return table.concat(parts, sep)
  end

  --- Normalize path separators for current platform
  --- @param path string
  --- @return string
  function instance.normalize_path(path)
    if type(path) ~= "string" then
      return ""
    end

    if instance.is_windows() then
      -- Convert forward slashes to backslashes on Windows
      return path:gsub("/", "\\")
    else
      -- Convert backslashes to forward slashes on Unix
      return path:gsub("\\", "/")
    end
  end

  return instance
end

return M
