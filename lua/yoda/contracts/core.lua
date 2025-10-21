-- lua/yoda/contracts/core.lua
-- Core module contracts - perfect assertiveness through explicit contracts
-- Defines precise behavior expectations and validation rules

local M = {}

local errors = require("yoda.core.errors")

-- Contract violation error category
local CONTRACT_VIOLATION = "contract_violation"

--- Contract for string operations
M.string = {
  --- Contract for trim function
  --- @param str any Input (should be string)
  --- @return string trimmed_string
  trim = function(str)
    -- Pre-condition: input must be string or convertible
    if str == nil then
      return ""
    end

    local valid, error_obj = errors.validate_type(str, "string", "str", {
      function_name = "trim",
      expected_behavior = "Remove leading/trailing whitespace",
    })

    if not valid then
      -- Convert to string if possible, otherwise return empty
      if type(str) == "number" then
        str = tostring(str)
      else
        return ""
      end
    end

    -- Post-condition: result is always a string
    local result = str:match("^%s*(.-)%s*$") or ""

    errors.assert(type(result) == "string", CONTRACT_VIOLATION, "trim() must return string", { result = result })

    return result
  end,

  --- Contract for starts_with function
  --- @param str string String to check
  --- @param prefix string Prefix to look for
  --- @return boolean
  starts_with = function(str, prefix)
    -- Pre-conditions
    errors.assert(type(str) == "string", CONTRACT_VIOLATION, "starts_with() str must be string", { str = str })
    errors.assert(type(prefix) == "string", CONTRACT_VIOLATION, "starts_with() prefix must be string", { prefix = prefix })

    -- Empty prefix always matches
    if prefix == "" then
      return true
    end

    local result = str:sub(1, #prefix) == prefix

    -- Post-condition: result is always boolean
    errors.assert(type(result) == "boolean", CONTRACT_VIOLATION, "starts_with() must return boolean", { result = result })

    return result
  end,
}

--- Contract for filesystem operations
M.filesystem = {
  --- Contract for file existence check
  --- @param path string File path
  --- @return boolean exists
  is_file = function(path)
    -- Pre-condition: path must be non-empty string
    local valid, error_obj = errors.validate_type(path, "string", "path", {
      function_name = "is_file",
      expected_behavior = "Check if file exists and is readable",
    })

    if not valid then
      return false
    end

    if path == "" then
      return false
    end

    local result = vim.fn.filereadable(path) == 1

    -- Post-condition: result is always boolean
    errors.assert(type(result) == "boolean", CONTRACT_VIOLATION, "is_file() must return boolean", { result = result, path = path })

    return result
  end,

  --- Contract for file reading
  --- @param path string File path
  --- @return boolean success
  --- @return string|nil content_or_error
  read_file = function(path)
    -- Pre-condition: path must be string
    local valid, error_obj = errors.validate_type(path, "string", "path", {
      function_name = "read_file",
      expected_behavior = "Read file content safely",
    })

    if not valid then
      return false, errors.format(error_obj)
    end

    -- Check if file exists first
    if not M.filesystem.is_file(path) then
      return false, "File not found: " .. path
    end

    local Path = require("plenary.path")
    local ok, content = pcall(Path.new(path).read, Path.new(path))

    local success = ok and content ~= nil
    local result = success and content or ("Failed to read file: " .. tostring(content))

    -- Post-condition: first return is always boolean
    errors.assert(type(success) == "boolean", CONTRACT_VIOLATION, "read_file() first return must be boolean", { success = success, path = path })

    -- Post-condition: if success, second return is string
    if success then
      errors.assert(
        type(result) == "string",
        CONTRACT_VIOLATION,
        "read_file() success must return string content",
        { result_type = type(result), path = path }
      )
    end

    return success, result
  end,
}

--- Contract for JSON operations
M.json = {
  --- Contract for JSON parsing
  --- @param json_str string JSON string
  --- @return boolean success
  --- @return table|string result_or_error
  parse = function(json_str)
    -- Pre-condition: json_str must be non-empty string
    local valid, error_obj = errors.validate_type(json_str, "string", "json_str", {
      function_name = "parse",
      expected_behavior = "Parse JSON string into Lua table",
    })

    if not valid then
      return false, errors.format(error_obj)
    end

    if json_str == "" then
      return false, "JSON string cannot be empty"
    end

    local ok, parsed = pcall(vim.json.decode, json_str)

    -- Post-condition: first return is always boolean
    errors.assert(type(ok) == "boolean", CONTRACT_VIOLATION, "parse() first return must be boolean", { ok = ok })

    -- Post-condition: if success, second return is table
    if ok then
      errors.assert(type(parsed) == "table", CONTRACT_VIOLATION, "parse() success must return table", { parsed_type = type(parsed) })
    end

    local result = ok and parsed or ("Invalid JSON: " .. tostring(parsed))
    return ok, result
  end,
}

--- Validate contract compliance for a module
--- @param module table Module to validate
--- @param contract_name string Contract name
--- @return boolean valid
--- @return string|nil error
function M.validate_module(module, contract_name)
  local contract = M[contract_name]
  if not contract then
    return false, "Unknown contract: " .. contract_name
  end

  for method_name, _ in pairs(contract) do
    if type(module[method_name]) ~= "function" then
      return false, string.format("Module missing method: %s", method_name)
    end
  end

  return true, nil
end

return M
