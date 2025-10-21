-- lua/yoda/compat/io.lua
-- PURE compatibility layer for backwards compatibility ONLY
-- Single responsibility: Maintain API compatibility with existing code
-- Does NOT implement business logic - only delegates

local M = {}

-- Import focused modules through loader for perfect decoupling
local core_loader = require("yoda.core.loader")

-- Lazy-loaded modules to prevent circular dependencies
local _filesystem = nil
local _json = nil
local _temp = nil

--- Get filesystem module (lazy loaded)
--- @return table
local function get_filesystem()
  if not _filesystem then
    _filesystem = core_loader.load_core("filesystem")
  end
  return _filesystem
end

--- Get JSON module (lazy loaded)
--- @return table
local function get_json()
  if not _json then
    _json = core_loader.load_core("json")
  end
  return _json
end

--- Get temp module (lazy loaded)
--- @return table
local function get_temp()
  if not _temp then
    _temp = core_loader.load_core("temp")
  end
  return _temp
end

-- ============================================================================
-- COMPATIBILITY DELEGATES (NO BUSINESS LOGIC)
-- ============================================================================

-- Filesystem compatibility delegates
function M.is_file(path)
  return get_filesystem().is_file(path)
end

function M.is_dir(path)
  return get_filesystem().is_dir(path)
end

function M.exists(path)
  return get_filesystem().exists(path)
end

function M.file_exists(path)
  return get_filesystem().file_exists(path)
end

function M.read_file(path)
  -- Backward compatibility: Convert result to (boolean, value_or_error) pattern
  local filesystem_result = get_filesystem().read_file(path)
  local result_util = require("yoda.core.result")
  
  if result_util.is_success(filesystem_result) then
    return true, filesystem_result.value
  else
    return false, result_util.get_error_message(filesystem_result)
  end
end

-- JSON compatibility delegates
function M.parse_json_file(path)
  -- Backward compatibility: Convert result to (boolean, value_or_error) pattern
  local json_result = get_json().parse_file(path)
  local result_util = require("yoda.core.result")
  
  if result_util.is_success(json_result) then
    return true, json_result.value
  else
    return false, result_util.get_error_message(json_result)
  end
end

function M.write_json_file(path, data)
  -- Backward compatibility: Convert result to (boolean, value_or_error) pattern
  local json_result = get_json().write_file(path, data)
  local result_util = require("yoda.core.result")
  
  if result_util.is_success(json_result) then
    return true
  else
    return false, result_util.get_error_message(json_result)
  end
end

-- Temp file compatibility delegates
function M.create_temp_file(content)
  return get_temp().create_file(content)
end

function M.create_temp_dir()
  return get_temp().create_dir()
end

-- Export focused modules for direct access (compatibility)
M.filesystem = get_filesystem
M.json = get_json
M.temp = get_temp

return M
