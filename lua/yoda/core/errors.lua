-- lua/yoda/core/errors.lua
-- Comprehensive error handling system - perfect assertive programming
-- Provides consistent, clear error messages and recovery strategies

local M = {}

-- Error categories for better organization
local ERROR_CATEGORIES = {
  VALIDATION = "validation",
  IO = "io",
  CONFIGURATION = "configuration",
  DEPENDENCY = "dependency",
  RUNTIME = "runtime",
}

-- Error severity levels
local SEVERITY = {
  INFO = "info",
  WARN = "warn",
  ERROR = "error",
  CRITICAL = "critical",
}

M.CATEGORIES = ERROR_CATEGORIES
M.SEVERITY = SEVERITY

-- Private error registry
local _error_registry = {}
local _error_count = 0

--- Create structured error with context
--- @param category string Error category
--- @param message string Error message
--- @param context table|nil Additional context
--- @return table error_obj
function M.create(category, message, context)
  local error_obj = {
    id = _error_count + 1,
    category = category,
    message = message,
    context = context or {},
    timestamp = os.time(),
    stack_trace = debug.traceback("", 2), -- Skip this function
  }

  _error_count = _error_count + 1
  _error_registry[error_obj.id] = error_obj

  return error_obj
end

--- Format error for display
--- @param error_obj table Error object
--- @param include_stack boolean|nil Include stack trace
--- @return string formatted
function M.format(error_obj, include_stack)
  if type(error_obj) ~= "table" then
    return "Invalid error object"
  end

  local parts = {
    string.format("[%s] %s", string.upper(error_obj.category or "UNKNOWN"), error_obj.message or "No message"),
  }

  -- Add context if present
  if error_obj.context and next(error_obj.context) then
    table.insert(parts, "Context: " .. vim.inspect(error_obj.context))
  end

  -- Add timestamp
  if error_obj.timestamp then
    table.insert(parts, "Time: " .. os.date("%Y-%m-%d %H:%M:%S", error_obj.timestamp))
  end

  -- Add stack trace if requested
  if include_stack and error_obj.stack_trace then
    table.insert(parts, "Stack:\n" .. error_obj.stack_trace)
  end

  return table.concat(parts, "\n")
end

--- Assert with custom error message
--- @param condition any Condition to check
--- @param category string Error category
--- @param message string Error message
--- @param context table|nil Additional context
function M.assert(condition, category, message, context)
  if not condition then
    local error_obj = M.create(category, message, context)
    error(M.format(error_obj))
  end
end

--- Validate parameter type with descriptive errors
--- @param param any Parameter to validate
--- @param expected_type string Expected type
--- @param param_name string Parameter name
--- @param context table|nil Additional context
--- @return boolean valid
--- @return table|nil error_obj
function M.validate_type(param, expected_type, param_name, context)
  local actual_type = type(param)

  if actual_type ~= expected_type then
    local error_obj = M.create(
      ERROR_CATEGORIES.VALIDATION,
      string.format("Parameter '%s' must be %s, got %s", param_name, expected_type, actual_type),
      vim.tbl_extend("force", {
        param_name = param_name,
        expected_type = expected_type,
        actual_type = actual_type,
        param_value = param,
      }, context or {})
    )

    return false, error_obj
  end

  return true, nil
end

--- Safe function call with error handling
--- @param fn function Function to call
--- @param category string Error category
--- @param context table|nil Additional context
--- @return boolean success
--- @return any result_or_error
function M.safe_call(fn, category, context)
  if type(fn) ~= "function" then
    local error_obj = M.create(ERROR_CATEGORIES.VALIDATION, "Expected function for safe_call", context)
    return false, error_obj
  end

  local ok, result = pcall(fn)

  if not ok then
    local error_obj = M.create(category or ERROR_CATEGORIES.RUNTIME, "Function call failed: " .. tostring(result), context)
    return false, error_obj
  end

  return true, result
end

--- Wrap function with automatic error handling
--- @param fn function Function to wrap
--- @param category string Error category
--- @return function wrapped_function
function M.wrap(fn, category)
  return function(...)
    local ok, result = M.safe_call(fn, category)
    if not ok then
      -- Log error but don't throw
      vim.notify(M.format(result), vim.log.levels.ERROR)
      return nil
    end
    return result
  end
end

--- Get error statistics
--- @return table stats
function M.get_stats()
  local category_counts = {}

  for _, error_obj in pairs(_error_registry) do
    local category = error_obj.category or "unknown"
    category_counts[category] = (category_counts[category] or 0) + 1
  end

  return {
    total_errors = _error_count,
    by_category = category_counts,
    registry_size = vim.tbl_count(_error_registry),
  }
end

--- Clear error registry (for testing)
function M.clear()
  _error_registry = {}
  _error_count = 0
end

--- Get recent errors
--- @param limit number|nil Maximum number of errors to return
--- @return table errors
function M.get_recent(limit)
  limit = limit or 10

  local errors = {}
  for _, error_obj in pairs(_error_registry) do
    table.insert(errors, error_obj)
  end

  -- Sort by timestamp (most recent first)
  table.sort(errors, function(a, b)
    return (a.timestamp or 0) > (b.timestamp or 0)
  end)

  -- Limit results
  local result = {}
  for i = 1, math.min(limit, #errors) do
    table.insert(result, errors[i])
  end

  return result
end

return M
