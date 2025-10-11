-- lua/yoda/core/io_di.lua
-- File I/O utilities with Dependency Injection
-- Core utility module - minimal dependencies

local M = {}

--- Create new IO instance (DI factory pattern)
--- Core modules have minimal dependencies, but we maintain consistency
--- @param deps table|nil Optional dependencies {plenary_path}
--- @return table IO instance
function M.new(deps)
  deps = deps or {}

  local instance = {}

  -- ============================================================================
  -- File/Directory Existence (Pure Functions - No Dependencies)
  -- ============================================================================

  --- Check if file exists using vim.fn.filereadable
  --- @param path string File path
  --- @return boolean
  function instance.is_file(path)
    if type(path) ~= "string" or path == "" then
      return false
    end
    return vim.fn.filereadable(path) == 1
  end

  --- Check if directory exists using vim.fn.isdirectory
  --- @param path string Directory path
  --- @return boolean
  function instance.is_dir(path)
    if type(path) ~= "string" or path == "" then
      return false
    end
    return vim.fn.isdirectory(path) == 1
  end

  --- Check if path exists (file or directory)
  --- @param path string Path to check
  --- @return boolean
  function instance.exists(path)
    return instance.is_file(path) or instance.is_dir(path)
  end

  -- ============================================================================
  -- File Reading/Writing
  -- ============================================================================

  --- Read entire file contents
  --- @param path string File path
  --- @return string|nil, string|nil Content or nil, error message
  function instance.read_file(path)
    if type(path) ~= "string" or path == "" then
      return nil, "Invalid path"
    end

    local file, err = io.open(path, "r")
    if not file then
      return nil, err or "Could not open file"
    end

    local content = file:read("*all")
    file:close()

    if not content then
      return nil, "Could not read file"
    end

    return content, nil
  end

  -- ============================================================================
  -- JSON Operations
  -- ============================================================================

  --- Parse JSON file
  --- @param path string Path to JSON file
  --- @return table|nil, string|nil Parsed data or nil, error message
  function instance.parse_json_file(path)
    local content, read_err = instance.read_file(path)
    if not content then
      return nil, read_err
    end

    local ok, data = pcall(vim.json.decode, content)
    if not ok then
      return nil, "Invalid JSON: " .. tostring(data)
    end

    return data, nil
  end

  --- Write data to JSON file
  --- @param path string Path to write
  --- @param data table Data to encode
  --- @return boolean, string|nil Success status, error message
  function instance.write_json_file(path, data)
    if type(data) ~= "table" then
      return false, "Data must be a table"
    end

    local ok, json = pcall(vim.json.encode, data)
    if not ok then
      return false, "JSON encode failed: " .. tostring(json)
    end

    local file, err = io.open(path, "w")
    if not file then
      return false, err or "Could not open file for writing"
    end

    file:write(json)
    file:close()

    return true, nil
  end

  -- ============================================================================
  -- Temporary Files/Directories
  -- ============================================================================

  --- Create temporary file with content
  --- @param content string File content
  --- @return string|nil, string|nil Temp file path or nil, error message
  function instance.create_temp_file(content)
    if type(content) ~= "string" then
      return nil, "Content must be a string"
    end

    local temp_path = vim.fn.tempname()
    local file, err = io.open(temp_path, "w")

    if not file then
      return nil, err or "Could not create temp file"
    end

    file:write(content)
    file:close()

    return temp_path, nil
  end

  --- Create temporary directory
  --- @return string|nil, string|nil Temp directory path or nil, error message
  function instance.create_temp_dir()
    -- Use plenary if injected, otherwise fallback
    if deps.plenary_path then
      local ok, Path = pcall(require, "plenary.path")
      if ok then
        local temp_path = Path:new(vim.fn.tempname())
        local success, mkdir_err = pcall(function()
          temp_path:mkdir()
        end)

        if not success then
          return nil, mkdir_err or "Failed to create directory"
        end

        return temp_path.filename, nil
      end
    end

    -- Fallback: use tempname
    local temp_path = vim.fn.tempname()
    return temp_path, nil
  end

  return instance
end

return M
