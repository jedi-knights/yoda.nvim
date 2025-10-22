-- lua/yoda/core/io.lua
-- File system and I/O utilities (consolidated from multiple modules)
-- Eliminates JSON parsing and file reading duplication

local M = {}

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

--- Read file content safely (consolidated from multiple modules)
--- @param path string File path
--- @return boolean success
--- @return string|nil content or error message
function M.read_file(path)
  if not M.is_file(path) then
    return false, "File not found: " .. path
  end

  local Path = require("plenary.path")
  local ok, content = pcall(Path.new(path).read, Path.new(path))

  if not ok then
    return false, "Failed to read file: " .. content
  end

  return true, content
end

-- ============================================================================
-- JSON OPERATIONS (consolidated from functions.lua and config_loader.lua)
-- ============================================================================

--- Parse JSON file (consolidates parse_json_config and load_json_config)
--- @param path string Path to JSON file
--- @return boolean success
--- @return table|string result or error message
function M.parse_json_file(path)
  local ok, content = M.read_file(path)
  if not ok then
    return false, content -- content is error message
  end

  local ok_json, parsed = pcall(vim.json.decode, content)
  if not ok_json then
    return false, "Invalid JSON: " .. parsed
  end

  return true, parsed
end

--- Write JSON file
--- @param path string File path
--- @param data table Data to write
--- @return boolean success
--- @return string|nil error message
function M.write_json_file(path, data)
  if type(data) ~= "table" then
    return false, "Data must be a table"
  end

  local ok, json_str = pcall(vim.json.encode, data)
  if not ok then
    return false, "Failed to encode JSON: " .. json_str
  end

  local Path = require("plenary.path")
  local ok_write, err = pcall(function()
    Path.new(path):write(json_str, "w")
  end)

  if not ok_write then
    return false, "Failed to write file: " .. err
  end

  return true, nil
end

-- ============================================================================
-- TEMPORARY FILES (rescued from deprecated functions.lua)
-- ============================================================================

--- Create temporary file with content
--- @param content string File content
--- @return string|nil path Temporary file path or nil on failure
--- @return string|nil error Error message if failed
function M.create_temp_file(content)
  if type(content) ~= "string" then
    return nil, "Content must be a string"
  end

  local temp_path = vim.fn.tempname()
  local file = io.open(temp_path, "w")

  if not file then
    return nil, "Failed to create temporary file: " .. temp_path
  end

  file:write(content)
  file:close()
  return temp_path, nil
end

--- Create temporary directory
--- @return string|nil path Temporary directory path or nil on failure
--- @return string|nil error Error message if failed
function M.create_temp_dir()
  local temp_path = vim.fn.tempname()
  local success = vim.fn.mkdir(temp_path)

  if success ~= 1 then
    return nil, "Failed to create temporary directory: " .. temp_path
  end

  return temp_path, nil
end

return M
