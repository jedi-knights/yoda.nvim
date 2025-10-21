-- lua/yoda/core/temp.lua
-- Temporary file and directory operations - perfect single responsibility
-- Handles creation and management of temporary resources

local M = {}

-- ============================================================================
-- TEMPORARY FILE OPERATIONS
-- ============================================================================

--- Create temporary file with content
--- @param content string File content
--- @return string|nil path Temporary file path or nil on failure
--- @return string|nil error Error message if failed
function M.create_file(content)
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

--- Create temporary file with JSON content
--- @param data table Data to write as JSON
--- @return string|nil path Temporary file path or nil on failure
--- @return string|nil error Error message if failed
function M.create_json_file(data)
  -- Avoid circular dependency by using vim.json directly
  local ok, json_str = pcall(vim.json.encode, data)

  if not ok then
    return nil, "Failed to encode JSON: " .. json_str
  end

  return M.create_file(json_str)
end

--- Create temporary directory
--- @return string|nil path Temporary directory path or nil on failure
--- @return string|nil error Error message if failed
function M.create_dir()
  local temp_path = vim.fn.tempname()
  local success = vim.fn.mkdir(temp_path)

  if success ~= 1 then
    return nil, "Failed to create temporary directory: " .. temp_path
  end

  return temp_path, nil
end

--- Create temporary directory with subdirectories
--- @param structure table Directory structure to create
--- @return string|nil path Temporary directory path or nil on failure
--- @return string|nil error Error message if failed
function M.create_structured_dir(structure)
  local base_dir, err = M.create_dir()
  if not base_dir then
    return nil, err
  end

  if type(structure) == "table" then
    for _, subdir in ipairs(structure) do
      local subdir_path = base_dir .. "/" .. subdir
      local success = vim.fn.mkdir(subdir_path, "p")
      if success ~= 1 then
        return nil, "Failed to create subdirectory: " .. subdir_path
      end
    end
  end

  return base_dir, nil
end

--- Clean up temporary file (optional utility)
--- @param path string Path to temporary file
--- @return boolean success
--- @return string|nil error Error message if failed
function M.cleanup_file(path)
  if type(path) ~= "string" or path == "" then
    return false, "Invalid path"
  end

  local success = vim.fn.delete(path)
  if success ~= 0 then
    return false, "Failed to delete temporary file: " .. path
  end

  return true, nil
end

--- Clean up temporary directory
--- @param path string Path to temporary directory
--- @return boolean success
--- @return string|nil error Error message if failed
function M.cleanup_dir(path)
  if type(path) ~= "string" or path == "" then
    return false, "Invalid path"
  end

  local success = vim.fn.delete(path, "rf")
  if success ~= 0 then
    return false, "Failed to delete temporary directory: " .. path
  end

  return true, nil
end

return M
