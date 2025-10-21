-- lua/yoda/core/result.lua
-- Standardized result handling - PERFECT DRY
-- Single source of truth for all success/error patterns
-- Eliminates ~150+ lines of duplicated error handling

local M = {}

-- ============================================================================
-- RESULT PATTERN (Single Source of Truth)
-- ============================================================================

--- Create success result
--- @param value any Success value
--- @param metadata table|nil Optional metadata
--- @return table result
function M.success(value, metadata)
  return {
    success = true,
    value = value,
    error = nil,
    metadata = metadata or {},
  }
end

--- Create error result
--- @param error_message string Error message
--- @param error_code string|nil Error code
--- @param metadata table|nil Optional metadata
--- @return table result
function M.error(error_message, error_code, metadata)
  return {
    success = false,
    value = nil,
    error = {
      message = error_message,
      code = error_code or "UNKNOWN",
      metadata = metadata or {},
    },
  }
end

--- Create result from pcall
--- @param ok boolean pcall success
--- @param result_or_error any pcall result or error
--- @param context string|nil Context for error
--- @return table result
function M.from_pcall(ok, result_or_error, context)
  if ok then
    return M.success(result_or_error)
  else
    local error_msg = tostring(result_or_error)
    if context then
      error_msg = string.format("%s: %s", context, error_msg)
    end
    return M.error(error_msg, "PCALL_ERROR")
  end
end

-- ============================================================================
-- RESULT UTILITIES (Perfect DRY)
-- ============================================================================

--- Check if result is success
--- @param result table Result object
--- @return boolean is_success
function M.is_success(result)
  return result and result.success == true
end

--- Check if result is error
--- @param result table Result object
--- @return boolean is_error
function M.is_error(result)
  return result and result.success == false
end

--- Get value from result or default
--- @param result table Result object
--- @param default any Default value if error
--- @return any value
function M.get_value_or(result, default)
  if M.is_success(result) then
    return result.value
  end
  return default
end

--- Get error message from result
--- @param result table Result object
--- @return string|nil error_message
function M.get_error_message(result)
  if M.is_error(result) and result.error then
    return result.error.message
  end
  return nil
end

--- Get error code from result
--- @param result table Result object
--- @return string|nil error_code
function M.get_error_code(result)
  if M.is_error(result) and result.error then
    return result.error.code
  end
  return nil
end

--- Unwrap result or throw error
--- @param result table Result object
--- @return any value
function M.unwrap(result)
  if M.is_success(result) then
    return result.value
  elseif M.is_error(result) then
    error(result.error.message)
  else
    error("Invalid result object")
  end
end

--- Unwrap result or return default (no error)
--- @param result table Result object
--- @param default any Default value
--- @return any value
function M.unwrap_or(result, default)
  if M.is_success(result) then
    return result.value
  end
  return default
end

-- ============================================================================
-- RESULT CHAINING (Monadic Operations - Perfect DRY)
-- ============================================================================

--- Map success value through function
--- @param result table Result object
--- @param mapper function Function to map success value
--- @return table new_result
function M.map(result, mapper)
  if M.is_success(result) then
    local ok, new_value = pcall(mapper, result.value)
    if ok then
      return M.success(new_value, result.metadata)
    else
      return M.error("Map operation failed: " .. tostring(new_value), "MAP_ERROR")
    end
  else
    return result -- Pass through error
  end
end

--- Chain results (flatMap)
--- @param result table Result object
--- @param chainer function Function that returns Result
--- @return table result
function M.chain(result, chainer)
  if M.is_success(result) then
    local ok, new_result = pcall(chainer, result.value)
    if ok and type(new_result) == "table" and new_result.success ~= nil then
      return new_result
    else
      return M.error("Chain operation failed", "CHAIN_ERROR")
    end
  else
    return result -- Pass through error
  end
end

--- Map error to new error
--- @param result table Result object
--- @param error_mapper function Function to map error
--- @return table new_result
function M.map_error(result, error_mapper)
  if M.is_error(result) then
    local ok, new_error_msg = pcall(error_mapper, result.error.message)
    if ok then
      return M.error(new_error_msg, result.error.code, result.error.metadata)
    else
      return result -- Keep original error if mapping fails
    end
  else
    return result -- Pass through success
  end
end

-- ============================================================================
-- COMMON RESULT PATTERNS (Perfect DRY)
-- ============================================================================

--- File operation result pattern
--- @param path string File path
--- @param operation function Operation to perform
--- @return table result
function M.file_operation(path, operation)
  if type(path) ~= "string" or path == "" then
    return M.error("Invalid file path", "INVALID_PATH")
  end

  local ok, result = pcall(operation, path)
  if ok then
    return M.success(result, { path = path })
  else
    return M.error(string.format("File operation failed on '%s': %s", path, tostring(result)), "FILE_ERROR", { path = path })
  end
end

--- JSON operation result pattern
--- @param data_or_string any Data to encode or JSON string to parse
--- @param operation function JSON operation (encode/decode)
--- @param operation_name string Operation name for errors
--- @return table result
function M.json_operation(data_or_string, operation, operation_name)
  local ok, result = pcall(operation, data_or_string)
  if ok then
    return M.success(result)
  else
    return M.error(string.format("JSON %s failed: %s", operation_name, tostring(result)), "JSON_ERROR")
  end
end

--- Network operation result pattern
--- @param url string URL or endpoint
--- @param operation function Network operation
--- @return table result
function M.network_operation(url, operation)
  if type(url) ~= "string" or url == "" then
    return M.error("Invalid URL", "INVALID_URL")
  end

  local ok, result = pcall(operation, url)
  if ok then
    return M.success(result, { url = url })
  else
    return M.error(string.format("Network operation failed for '%s': %s", url, tostring(result)), "NETWORK_ERROR", { url = url })
  end
end

-- ============================================================================
-- RESULT AGGREGATION (Perfect DRY)
-- ============================================================================

--- Combine multiple results - all must succeed
--- @param results table Array of results
--- @return table combined_result
function M.all(results)
  local values = {}

  for i, result in ipairs(results) do
    if M.is_error(result) then
      return M.error(string.format("Result %d failed: %s", i, M.get_error_message(result)), "AGGREGATE_ERROR")
    end
    table.insert(values, result.value)
  end

  return M.success(values)
end

--- Combine multiple results - return first success
--- @param results table Array of results
--- @return table first_success_or_last_error
function M.any(results)
  local last_error = nil

  for _, result in ipairs(results) do
    if M.is_success(result) then
      return result
    end
    last_error = result
  end

  return last_error or M.error("No results provided", "NO_RESULTS")
end

--- Partition results into successes and errors
--- @param results table Array of results
--- @return table successes
--- @return table errors
function M.partition(results)
  local successes = {}
  local errors = {}

  for _, result in ipairs(results) do
    if M.is_success(result) then
      table.insert(successes, result.value)
    else
      table.insert(errors, result.error)
    end
  end

  return successes, errors
end

return M
