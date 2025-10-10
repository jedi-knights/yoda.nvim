-- lua/yoda/diagnostics/ai_cli.lua
-- AI CLI detection utilities (extracted from utils.lua for perfect SRP)
-- Provides Claude CLI path detection and version checking

local M = {}

-- ============================================================================
-- CLAUDE CLI DETECTION
-- ============================================================================

--- Get Claude CLI path with comprehensive search
--- @return string|nil Path to claude binary or nil if not found
function M.get_claude_path()
  -- Common locations where Claude CLI might be installed
  local common_paths = {
    -- System PATH
    function()
      return vim.fn.exepath("claude")
    end,

    -- User local binaries
    function()
      return vim.fn.expand("~/.local/bin/claude")
    end,
    function()
      return vim.fn.expand("~/.bun/bin/claude")
    end,
    function()
      return vim.fn.expand("~/.npm-global/bin/claude")
    end,

    -- Homebrew on macOS
    function()
      return "/opt/homebrew/bin/claude"
    end,
    function()
      return "/usr/local/bin/claude"
    end,

    -- Node.js global packages
    function()
      return vim.fn.expand("~/node_modules/.bin/claude")
    end,

    -- Windows paths
    function()
      return vim.fn.expand("~/AppData/Roaming/npm/claude.cmd")
    end,
    function()
      return vim.fn.expand("~/AppData/Roaming/npm/claude")
    end,
  }

  -- Check if a path exists and is executable
  local function is_executable(path)
    if not path or path == "" then
      return false
    end
    return vim.fn.executable(path) == 1
  end

  -- First, try to find in PATH
  local path = vim.fn.exepath("claude")
  if is_executable(path) then
    return path
  end

  -- Try common installation paths
  for _, path_func in ipairs(common_paths) do
    local ok, candidate_path = pcall(path_func)
    if ok and candidate_path and is_executable(candidate_path) then
      return candidate_path
    end
  end

  return nil
end

--- Check if Claude CLI is available
--- @return boolean True if Claude CLI is found
function M.is_claude_available()
  return M.get_claude_path() ~= nil
end

--- Get version of Claude CLI (if available)
--- @return string|nil version Version string or nil if unavailable
--- @return string|nil error Error message if failed
function M.get_claude_version()
  local claude_path = M.get_claude_path()
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

return M
