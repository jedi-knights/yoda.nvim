-- lua/yoda/core/safe.lua
-- Unified safe execution system - PERFECT DRY
-- Single source of truth for all pcall patterns - eliminates 57+ instances of duplication

local result = require("yoda.core.result")
local validation = require("yoda.core.validation")

local M = {}

-- ============================================================================
-- Core Safe Execution Patterns
-- ============================================================================

--- Execute function safely with standardized result handling
--- @param operation function Function to execute safely
--- @param error_context string Context for error messages
--- @return table result Result object (success/error pattern)
function M.execute(operation, error_context)
  local ctx = validation.context("execute", "core.safe")
  validation.assert_function(operation, "operation", ctx)
  validation.assert_non_empty_string(error_context, "error_context", ctx)
  
  local ok, result_value = pcall(operation)
  if ok then
    return result.success(result_value)
  else
    return result.error(
      string.format("Safe execution failed in %s: %s", error_context, tostring(result_value)),
      "SAFE_EXECUTION_ERROR",
      { context = error_context }
    )
  end
end

--- Safely require a module
--- @param module_path string Module path to require
--- @return table result Result object with module or error
function M.require(module_path)
  local ctx = validation.context("require", "core.safe")
  validation.assert_non_empty_string(module_path, "module_path", ctx)
  
  return M.execute(function()
    return require(module_path)
  end, "module require: " .. module_path)
end

--- Safely execute vim command
--- @param cmd string Vim command to execute
--- @return table result Result object (success/error pattern)
function M.vim_cmd(cmd)
  local ctx = validation.context("vim_cmd", "core.safe")
  validation.assert_non_empty_string(cmd, "cmd", ctx)
  
  return M.execute(function()
    vim.cmd(cmd)
    return true
  end, "vim command: " .. cmd)
end

--- Safely call vim API function
--- @param api_func function Vim API function
--- @param args table Arguments for the function
--- @param api_name string Name of API for error context
--- @return table result Result object (success/error pattern)  
function M.vim_api(api_func, args, api_name)
  local ctx = validation.context("vim_api", "core.safe")
  validation.assert_function(api_func, "api_func", ctx)
  validation.assert_type(args, "table", "args", ctx)
  validation.assert_non_empty_string(api_name, "api_name", ctx)
  
  return M.execute(function()
    return api_func(unpack(args))
  end, "vim API: " .. api_name)
end

--- Safely encode JSON
--- @param data table Data to encode
--- @return table result Result object (success/error pattern)
function M.json_encode(data)
  local ctx = validation.context("json_encode", "core.safe")
  validation.assert_type(data, "table", "data", ctx)
  
  return M.execute(function()
    return vim.json.encode(data)
  end, "JSON encode")
end

--- Safely decode JSON  
--- @param json_str string JSON string to decode
--- @return table result Result object (success/error pattern)
function M.json_decode(json_str)
  local ctx = validation.context("json_decode", "core.safe")
  validation.assert_non_empty_string(json_str, "json_str", ctx)
  
  return M.execute(function()
    return vim.json.decode(json_str)
  end, "JSON decode")
end

--- Safely read file using plenary
--- @param path string File path to read
--- @return table result Result object (success/error pattern)
function M.file_read(path)
  local ctx = validation.context("file_read", "core.safe")
  validation.assert_non_empty_string(path, "path", ctx)
  
  return M.execute(function()
    local Path = require("plenary.path")
    return Path.new(path):read()
  end, "file read: " .. path)
end

--- Safely write file using plenary
--- @param path string File path to write
--- @param content string Content to write
--- @return table result Result object (success/error pattern)
function M.file_write(path, content)
  local ctx = validation.context("file_write", "core.safe")
  validation.assert_non_empty_string(path, "path", ctx)
  validation.assert_type(content, "string", "content", ctx)
  
  return M.execute(function()
    local Path = require("plenary.path")
    Path.new(path):write(content, "w")
    return true
  end, "file write: " .. path)
end

--- Safely execute system command
--- @param cmd string Command to execute
--- @return table result Result object (success/error pattern)
function M.system_cmd(cmd)
  local ctx = validation.context("system_cmd", "core.safe")
  validation.assert_non_empty_string(cmd, "cmd", ctx)
  
  return M.execute(function()
    return vim.fn.system(cmd)
  end, "system command: " .. cmd)
end

--- Safely close vim window
--- @param win_id number Window ID to close
--- @param force boolean Whether to force close
--- @return table result Result object (success/error pattern)
function M.close_window(win_id, force)
  local ctx = validation.context("close_window", "core.safe")
  validation.assert_type(win_id, "number", "win_id", ctx)
  
  return M.execute(function()
    vim.api.nvim_win_close(win_id, force or false)
    return true
  end, "close window: " .. win_id)
end

-- ============================================================================
-- Backward Compatibility Wrappers (for gradual migration)
-- ============================================================================

--- Legacy pcall wrapper for gradual migration
--- @param fn function Function to call safely
--- @param ... any Arguments to pass to function
--- @return boolean success Whether the call succeeded
--- @return any result Result value or error message
function M.pcall(fn, ...)
  local exec_result = M.execute(function()
    return fn(...)
  end, "legacy pcall")
  
  if result.is_success(exec_result) then
    return true, exec_result.value
  else
    return false, result.get_error_message(exec_result)
  end
end

return M