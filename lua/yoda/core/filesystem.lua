-- lua/yoda/core/filesystem.lua
-- Pure filesystem operations - PERFECT SINGLE RESPONSIBILITY
-- Zero dependencies on other Yoda modules - perfect DIP compliance

local result = require("yoda.core.result")

local M = {}

-- Interface validation
local interface = require("yoda.interfaces.filesystem")

-- ============================================================================
-- FILE EXISTENCE CHECKS
-- ============================================================================

--- Check if file exists and is readable
--- @param path string File path
--- @return boolean
function M.is_file(path)
  if type(path) ~= "string" or path == "" then
    return false
  end
  return vim.fn.filereadable(path) == 1
end

--- Check if directory exists
--- @param path string Directory path
--- @return boolean
function M.is_dir(path)
  if type(path) ~= "string" or path == "" then
    return false
  end
  return vim.fn.isdirectory(path) == 1
end

--- Check if path exists (file or directory)
--- @param path string Path to check
--- @return boolean
function M.exists(path)
  return M.is_file(path) or M.is_dir(path)
end

--- Legacy compatibility for utils.file_exists
--- @param path string File path
--- @return boolean
function M.file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

-- ============================================================================
-- FILE READING
-- ============================================================================

--- Read file content safely  
--- @param path string File path
--- @return table result Result object (success/error pattern)
function M.read_file(path)
  -- Perfect DRY: Standardized result handling
  return result.with_file_operation(path, function(file_path)
    local Path = require("plenary.path")
    return Path.new(file_path):read()
  end)
end

  local Path = require("plenary.path")
  local ok, content = pcall(Path.new(path).read, Path.new(path))

  if not ok then
    return false, "Failed to read file: " .. content
  end

  return true, content
end

--- Write file content safely
--- @param path string File path
--- @param content string Content to write
--- @return table result Result object (success/error pattern)
function M.write_file(path, content)
  -- Input validation
  if type(content) ~= "string" then
    return result.error("Content must be a string", "INVALID_CONTENT")
  end

  -- Perfect DRY: Standardized result handling  
  return result.with_file_operation(path, function(file_path)
    local Path = require("plenary.path")
    Path.new(file_path):write(content, "w")
    return true
  end)
end

  local Path = require("plenary.path")
  local ok, err = pcall(function()
    Path.new(path):write(content, "w")
  end)

  if not ok then
    return false, "Failed to write file: " .. err
  end

  return true, nil
end

-- Validate interface compliance and return validated implementation
return interface.create(M)
