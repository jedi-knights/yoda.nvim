-- lua/yoda/core/validation.lua
-- Centralized validation utilities - PERFECT DRY
-- Single source of truth for all validation patterns
-- Eliminates ~100+ lines of duplicated validation code

local M = {}

-- ============================================================================
-- TYPE VALIDATION (Single Source of Truth)
-- ============================================================================

--- Assert parameter is specific type with descriptive error
--- @param param any Parameter to validate
--- @param expected_type string Expected type
--- @param param_name string Parameter name for error message
--- @param context table|nil Additional context for error
--- @return any param Returns param if valid (for chaining)
function M.assert_type(param, expected_type, param_name, context)
  local actual_type = type(param)
  if actual_type ~= expected_type then
    local error_msg = string.format("Parameter '%s' must be %s, got %s", param_name, expected_type, actual_type)

    if context then
      error_msg = error_msg .. string.format(" in %s", context.function_name or "unknown function")
    end

    error(error_msg)
  end
  return param
end

--- Validate type with optional default (no error throwing)
--- @param param any Parameter to validate
--- @param expected_type string Expected type
--- @param default any Default value if invalid
--- @return any param or default
function M.validate_type_or_default(param, expected_type, default)
  if type(param) == expected_type then
    return param
  end
  return default
end

--- Validate multiple parameters at once
--- @param validations table Array of {param, type, name, context?}
function M.assert_types(validations)
  for i, validation in ipairs(validations) do
    local param, expected_type, param_name, context = unpack(validation)
    M.assert_type(param, expected_type, param_name, context)
  end
end

-- ============================================================================
-- COMMON VALIDATION PATTERNS (Perfect DRY)
-- ============================================================================

--- Validate string is non-empty
--- @param str any String to validate
--- @param param_name string Parameter name
--- @param context table|nil Context
--- @return string str Non-empty string
function M.assert_non_empty_string(str, param_name, context)
  M.assert_type(str, "string", param_name, context)
  if str == "" then
    local error_msg = string.format("Parameter '%s' cannot be empty", param_name)
    if context and context.function_name then
      error_msg = error_msg .. string.format(" in %s", context.function_name)
    end
    error(error_msg)
  end
  return str
end

--- Validate table is non-empty
--- @param tbl any Table to validate
--- @param param_name string Parameter name
--- @param context table|nil Context
--- @return table tbl Non-empty table
function M.assert_non_empty_table(tbl, param_name, context)
  M.assert_type(tbl, "table", param_name, context)
  if next(tbl) == nil then
    local error_msg = string.format("Parameter '%s' cannot be empty table", param_name)
    if context and context.function_name then
      error_msg = error_msg .. string.format(" in %s", context.function_name)
    end
    error(error_msg)
  end
  return tbl
end

--- Validate function parameter
--- @param fn any Function to validate
--- @param param_name string Parameter name
--- @param context table|nil Context
--- @return function fn Valid function
function M.assert_function(fn, param_name, context)
  M.assert_type(fn, "function", param_name, context)
  return fn
end

--- Validate number is positive
--- @param num any Number to validate
--- @param param_name string Parameter name
--- @param context table|nil Context
--- @return number num Positive number
function M.assert_positive_number(num, param_name, context)
  M.assert_type(num, "number", param_name, context)
  if num <= 0 then
    local error_msg = string.format("Parameter '%s' must be positive, got %s", param_name, num)
    if context and context.function_name then
      error_msg = error_msg .. string.format(" in %s", context.function_name)
    end
    error(error_msg)
  end
  return num
end

--- Validate array contains specific values
--- @param array table Array to validate
--- @param allowed_values table List of allowed values
--- @param param_name string Parameter name
--- @param context table|nil Context
--- @return table array Valid array
function M.assert_allowed_values(array, allowed_values, param_name, context)
  M.assert_type(array, "table", param_name, context)

  local allowed_set = {}
  for _, value in ipairs(allowed_values) do
    allowed_set[value] = true
  end

  for i, value in ipairs(array) do
    if not allowed_set[value] then
      local error_msg = string.format(
        "Parameter '%s[%d]' has invalid value '%s', allowed values: %s",
        param_name,
        i,
        tostring(value),
        table.concat(allowed_values, ", ")
      )
      if context and context.function_name then
        error_msg = error_msg .. string.format(" in %s", context.function_name)
      end
      error(error_msg)
    end
  end

  return array
end

-- ============================================================================
-- INTERFACE VALIDATION (Perfect DRY)
-- ============================================================================

--- Validate object implements required methods
--- @param obj any Object to validate
--- @param required_methods table List of required method names
--- @param obj_name string Object name for error messages
--- @param context table|nil Context
--- @return table obj Valid object
function M.assert_interface(obj, required_methods, obj_name, context)
  M.assert_type(obj, "table", obj_name, context)

  for _, method_name in ipairs(required_methods) do
    if type(obj[method_name]) ~= "function" then
      local error_msg = string.format("Object '%s' missing required method '%s'", obj_name, method_name)
      if context and context.function_name then
        error_msg = error_msg .. string.format(" in %s", context.function_name)
      end
      error(error_msg)
    end
  end

  return obj
end

-- ============================================================================
-- VALIDATION HELPERS (Perfect DRY)
-- ============================================================================

--- Create validation context
--- @param function_name string Function name
--- @param module_name string|nil Module name
--- @return table context
function M.context(function_name, module_name)
  return {
    function_name = function_name,
    module_name = module_name,
  }
end

--- Validate with custom predicate
--- @param param any Parameter to validate
--- @param predicate function Validation predicate
--- @param error_message string Error message if validation fails
--- @param context table|nil Context
--- @return any param Valid parameter
function M.assert_predicate(param, predicate, error_message, context)
  if not predicate(param) then
    local error_msg = error_message
    if context and context.function_name then
      error_msg = error_msg .. string.format(" in %s", context.function_name)
    end
    error(error_msg)
  end
  return param
end

--- Safe validation that returns success/error instead of throwing
--- @param param any Parameter to validate
--- @param validator function Validator function that throws on error
--- @return boolean success
--- @return any result_or_error
function M.safe_validate(param, validator)
  local ok, result = pcall(validator, param)
  if ok then
    return true, param
  else
    return false, result -- result is error message
  end
end

-- ============================================================================
-- COMMON VALIDATION SETS (Perfect DRY)
-- ============================================================================

M.COMMON_VALIDATIONS = {
  -- Path validation
  file_path = function(path, param_name, context)
    M.assert_non_empty_string(path, param_name, context)
    return path
  end,

  -- Log level validation
  log_level = function(level, param_name, context)
    local allowed_levels = { "trace", "debug", "info", "warn", "error" }
    if type(level) == "string" then
      M.assert_allowed_values({ level }, allowed_levels, param_name, context)
    elseif type(level) == "number" then
      M.assert_predicate(level, function(l)
        return l >= 0 and l <= 4
      end, string.format("Log level must be 0-4, got %s", level), context)
    else
      error(string.format("Log level must be string or number, got %s", type(level)))
    end
    return level
  end,

  -- Notification options validation
  notify_opts = function(opts, param_name, context)
    if opts ~= nil then
      M.assert_type(opts, "table", param_name, context)
    end
    return opts or {}
  end,
}

--- Apply common validation by name
--- @param param any Parameter to validate
--- @param validation_name string Validation name
--- @param param_name string Parameter name
--- @param context table|nil Context
--- @return any validated_param
function M.apply_common(param, validation_name, param_name, context)
  local validator = M.COMMON_VALIDATIONS[validation_name]
  if not validator then
    error("Unknown validation: " .. validation_name)
  end
  return validator(param, param_name, context)
end

-- ============================================================================
-- PERFECT DRY: Unified Type Validation System
-- Eliminates 66+ instances of duplicated type checking patterns
-- ============================================================================

--- Unified type validation with automatic error handling
--- @param value any Value to validate
--- @param expected_type string Expected type name
--- @param param_name string Parameter name for error messages
--- @param context table Context from validation.context()
--- @param allow_nil boolean Whether to allow nil values (default: false)
--- @return boolean success Whether validation passed
function M.validate_type(value, expected_type, param_name, context, allow_nil)
  if allow_nil and value == nil then
    return true
  end
  
  local actual_type = type(value)
  if actual_type ~= expected_type then
    local error_msg = string.format(
      "%s.%s(): %s must be %s, got %s",
      context.module_name, context.function_name, param_name, expected_type, actual_type
    )
    vim.notify(error_msg, vim.log.levels.ERROR, { title = context.module_name .. " Error" })
    return false
  end
  return true
end

--- Validate string is non-empty with automatic error handling
--- @param value any Value to validate
--- @param param_name string Parameter name for error messages  
--- @param context table Context from validation.context()
--- @param allow_nil boolean Whether to allow nil values (default: false)
--- @return boolean success Whether validation passed
function M.validate_non_empty_string(value, param_name, context, allow_nil)
  if allow_nil and value == nil then
    return true
  end
  
  if type(value) ~= "string" or value == "" then
    local error_msg = string.format(
      "%s.%s(): %s must be a non-empty string, got %s",
      context.module_name, context.function_name, param_name, type(value)
    )
    vim.notify(error_msg, vim.log.levels.ERROR, { title = context.module_name .. " Error" })
    return false
  end
  return true
end

--- Validate function with automatic error handling
--- @param value any Value to validate
--- @param param_name string Parameter name for error messages
--- @param context table Context from validation.context()
--- @param allow_nil boolean Whether to allow nil values (default: false)
--- @return boolean success Whether validation passed
function M.validate_function(value, param_name, context, allow_nil)
  return M.validate_type(value, "function", param_name, context, allow_nil)
end

--- Validate table with automatic error handling
--- @param value any Value to validate
--- @param param_name string Parameter name for error messages
--- @param context table Context from validation.context()
--- @param allow_nil boolean Whether to allow nil values (default: false)
--- @return boolean success Whether validation passed
function M.validate_table(value, param_name, context, allow_nil)
  return M.validate_type(value, "table", param_name, context, allow_nil)
end

--- Validate number with automatic error handling  
--- @param value any Value to validate
--- @param param_name string Parameter name for error messages
--- @param context table Context from validation.context()
--- @param allow_nil boolean Whether to allow nil values (default: false)
--- @return boolean success Whether validation passed
function M.validate_number(value, param_name, context, allow_nil)
  return M.validate_type(value, "number", param_name, context, allow_nil)
end

--- Validate boolean with automatic error handling
--- @param value any Value to validate
--- @param param_name string Parameter name for error messages
--- @param context table Context from validation.context()
--- @param allow_nil boolean Whether to allow nil values (default: false)
--- @return boolean success Whether validation passed
function M.validate_boolean(value, param_name, context, allow_nil)
  return M.validate_type(value, "boolean", param_name, context, allow_nil)
end

-- ============================================================================
-- Convenience Macros for Common Validation Patterns
-- ============================================================================

--- Validate and return early if validation fails
--- @param value any Value to validate
--- @param expected_type string Expected type name
--- @param param_name string Parameter name for error messages
--- @param context table Context from validation.context()
--- @param allow_nil boolean Whether to allow nil values (default: false)
--- @param return_value any Value to return if validation fails (default: nil)
--- @return any|nil return_value if validation fails, otherwise nothing
function M.validate_or_return(value, expected_type, param_name, context, allow_nil, return_value)
  if not M.validate_type(value, expected_type, param_name, context, allow_nil) then
    return return_value
  end
end

--- Validate string or return early if validation fails
--- @param value any Value to validate
--- @param param_name string Parameter name for error messages
--- @param context table Context from validation.context()
--- @param allow_nil boolean Whether to allow nil values (default: false)
--- @param return_value any Value to return if validation fails (default: nil)
--- @return any|nil return_value if validation fails, otherwise nothing
function M.validate_string_or_return(value, param_name, context, allow_nil, return_value)
  if not M.validate_non_empty_string(value, param_name, context, allow_nil) then
    return return_value
  end
end

return M
