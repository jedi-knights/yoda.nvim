-- lua/yoda/lib/utils.lua
-- Only truly reusable functions (kickstart-style minimal utilities)

local M = {}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

--- Trim whitespace from string
--- @param str string
--- @return string
function M.trim(str)
  return str:match("^%s*(.-)%s*$")
end

--- Check if a string starts with a prefix
--- @param str string
--- @param prefix string
--- @return boolean
function M.starts_with(str, prefix)
  return str:sub(1, #prefix) == prefix
end

--- Check if a string ends with a suffix
--- @param str string
--- @param suffix string
--- @return boolean
function M.ends_with(str, suffix)
  return str:sub(-#suffix) == suffix
end

--- Get the file extension from a path
--- @param path string
--- @return string
function M.get_extension(path)
  return path:match("^.+(%..+)$")
end

--- Check if a file exists
--- @param path string
--- @return boolean
function M.file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

--- Safe require with error handling
--- @param module string
--- @return boolean, any
function M.safe_require(module)
  return pcall(require, module)
end

--- Create a table with default values
--- @param defaults table
--- @param overrides table
--- @return table
function M.merge_tables(defaults, overrides)
  local result = {}
  for k, v in pairs(defaults) do
    result[k] = v
  end
  for k, v in pairs(overrides or {}) do
    result[k] = v
  end
  return result
end

--- Deep copy a table
--- @param orig table
--- @return table
function M.deep_copy(orig)
  local copy
  if type(orig) == "table" then
    copy = {}
    for key, value in next, orig, nil do
      copy[M.deep_copy(key)] = M.deep_copy(value)
    end
    setmetatable(copy, M.deep_copy(getmetatable(orig)))
  else
    copy = orig
  end
  return copy
end

--- Check if running in work environment
--- @return boolean
function M.is_work_env()
  return vim.env.YODA_ENV == "work"
end

--- Check if running in home environment
--- @return boolean
function M.is_home_env()
  return vim.env.YODA_ENV == "home"
end

--- Get current environment
--- @return string
function M.get_env()
  return vim.env.YODA_ENV or "unknown"
end

--- Notify with consistent formatting
--- @param msg string
--- @param level string|number
--- @param opts table
function M.notify(msg, level, opts)
  opts = opts or {}
  vim.notify(msg, level, opts)
end

--- Log debug information (only in verbose mode)
--- @param msg string
function M.debug(msg)
  if vim.g.yoda_config and vim.g.yoda_config.verbose_startup then
    vim.notify("[DEBUG] " .. msg, vim.log.levels.DEBUG)
  end
end

-- ============================================================================
-- AI INTEGRATION UTILITIES
-- ============================================================================

--- Claude CLI binary auto-discovery helper
--- @return string|nil
function M.get_claude_path()
  -- Common locations where Claude CLI might be installed
  local common_paths = {
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
--- @return boolean
function M.is_claude_available()
  return M.get_claude_path() ~= nil
end

--- Get version of Claude CLI (if available)
--- @return string|nil, string|nil
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
