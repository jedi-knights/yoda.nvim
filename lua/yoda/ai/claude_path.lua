-- lua/yoda/ai/claude_path.lua
-- Claude CLI binary auto-discovery helper
-- Tries to find Claude CLI in common locations with graceful fallback

local M = {}

-- Common locations where Claude CLI might be installed
local COMMON_PATHS = {
  -- System PATH
  function() return vim.fn.exepath("claude") end,
  
  -- User local binaries
  function() return vim.fn.expand("~/.local/bin/claude") end,
  function() return vim.fn.expand("~/.bun/bin/claude") end,
  function() return vim.fn.expand("~/.npm-global/bin/claude") end,
  
  -- Homebrew on macOS
  function() return "/opt/homebrew/bin/claude" end,
  function() return "/usr/local/bin/claude" end,
  
  -- Node.js global packages
  function() return vim.fn.expand("~/node_modules/.bin/claude") end,
  
  -- Windows paths (if needed)
  function() return vim.fn.expand("~/AppData/Roaming/npm/claude.cmd") end,
  function() return vim.fn.expand("~/AppData/Roaming/npm/claude") end,
}

-- Check if a path exists and is executable
local function is_executable(path)
  if not path or path == "" then
    return false
  end
  
  -- Check if file exists and is executable
  return vim.fn.executable(path) == 1
end

-- Get Claude CLI path with auto-discovery
function M.get()
  -- First, try to find in PATH
  local path = vim.fn.exepath("claude")
  if is_executable(path) then
    return path
  end
  
  -- Try common installation paths
  for _, path_func in ipairs(COMMON_PATHS) do
    local ok, candidate_path = pcall(path_func)
    if ok and candidate_path and is_executable(candidate_path) then
      return candidate_path
    end
  end
  
  -- Not found
  return nil
end

-- Check if Claude CLI is available
function M.is_available()
  return M.get() ~= nil
end

-- Get version of Claude CLI (if available)
function M.get_version()
  local claude_path = M.get()
  if not claude_path then
    return nil, "Claude CLI not found"
  end
  
  local ok, result = pcall(function()
    return vim.fn.system({ claude_path, "--version" }):gsub("^%s*(.-)%s*$", "%1")
  end)
  
  if not ok then
    return nil, "Failed to get version"
  end
  
  return result, nil
end

-- Validate Claude CLI installation
function M.validate()
  local claude_path = M.get()
  if not claude_path then
    return false, "Claude CLI not found in PATH or common locations"
  end
  
  local version, err = M.get_version()
  if not version then
    return false, "Claude CLI found but version check failed: " .. (err or "unknown error")
  end
  
  return true, "Claude CLI " .. version .. " found at " .. claude_path
end

return M
