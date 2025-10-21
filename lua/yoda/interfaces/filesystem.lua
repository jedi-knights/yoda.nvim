-- lua/yoda/interfaces/filesystem.lua
-- Filesystem interface contract - defines expected behavior
-- Perfect encapsulation through explicit interface definition

--- @class FilesystemInterface
--- @field is_file fun(path: string): boolean
--- @field is_dir fun(path: string): boolean
--- @field exists fun(path: string): boolean
--- @field file_exists fun(path: string): boolean
--- @field read_file fun(path: string): boolean, string|nil
--- @field write_file fun(path: string, content: string): boolean, string|nil

local M = {}

--- Validate that an object implements the Filesystem interface
--- @param impl table Object to validate
--- @return boolean valid
--- @return string|nil error
function M.validate(impl)
  if type(impl) ~= "table" then
    return false, "Implementation must be a table"
  end

  local required_methods = {
    "is_file",
    "is_dir",
    "exists",
    "file_exists",
    "read_file",
    "write_file",
  }

  for _, method in ipairs(required_methods) do
    if type(impl[method]) ~= "function" then
      return false, "Missing or invalid method: " .. method
    end
  end

  return true, nil
end

--- Create a validated filesystem implementation
--- @param impl table Implementation to wrap
--- @return table validated_impl
function M.create(impl)
  local valid, err = M.validate(impl)
  if not valid then
    error("Invalid filesystem implementation: " .. err)
  end

  -- Add interface metadata
  impl._interface = "FilesystemInterface"
  impl._version = "1.0.0"

  return impl
end

return M
