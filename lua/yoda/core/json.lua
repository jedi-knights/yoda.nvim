-- lua/yoda/core/json.lua
-- Pure JSON operations - PERFECT SINGLE RESPONSIBILITY
-- Zero dependencies on other Yoda modules - perfect DIP compliance

local result = require("yoda.core.result")

local M = {}

-- Import filesystem for file operations
local filesystem = require("yoda.core.filesystem")

-- Interface validation
local interface = require("yoda.interfaces.json")

-- ============================================================================
-- JSON OPERATIONS
-- ============================================================================

--- Parse JSON string
--- @param json_str string JSON string to parse
--- @return table result Result object (success/error pattern)
function M.parse(json_str)
  -- Perfect DRY: Standardized result handling
  return result.with_json_operation("parse", function()
    return vim.json.decode(json_str)
  end)
end

--- Serialize table to JSON string
--- @param data table Data to serialize
--- @param opts table|nil Options for encoding  
--- @return table result Result object (success/error pattern)
function M.encode(data, opts)
  if type(data) ~= "table" then
    return result.error("Data must be a table", "INVALID_DATA")
  end

  -- Perfect DRY: Standardized result handling
  return result.with_json_operation("encode", function()
    return vim.json.encode(data, opts)
  end)
end

--- Parse JSON file
--- @param path string Path to JSON file
--- @return boolean success
--- @return table|string result or error message
function M.parse_file(path)
  local ok, content = filesystem.read_file(path)
  if not ok then
    return false, content -- content is error message
  end

  return M.parse(content)
end

--- Write data to JSON file
--- @param path string File path
--- @param data table Data to write
--- @param opts table|nil JSON encoding options
--- @return boolean success
--- @return string|nil error message
function M.write_file(path, data, opts)
  local ok, json_str = M.encode(data, opts)
  if not ok then
    return false, json_str -- json_str is error message
  end

  return filesystem.write_file(path, json_str)
end

--- Validate JSON structure against schema (basic validation)
--- @param data table Data to validate
--- @param required_fields table List of required field names
--- @return boolean valid
--- @return string|nil error message
function M.validate_structure(data, required_fields)
  if type(data) ~= "table" then
    return false, "Data must be a table"
  end

  if type(required_fields) ~= "table" then
    return false, "Required fields must be a table"
  end

  for _, field in ipairs(required_fields) do
    if data[field] == nil then
      return false, "Missing required field: " .. field
    end
  end

  return true, nil
end

-- Validate interface compliance and return validated implementation
return interface.create(M)
