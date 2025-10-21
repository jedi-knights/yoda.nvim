-- lua/yoda/interfaces/json.lua
-- JSON interface contract - defines expected behavior
-- Perfect encapsulation through explicit interface definition

--- @class JsonInterface
--- @field parse fun(json_str: string): boolean, table|string
--- @field encode fun(data: table, opts?: table): boolean, string|nil
--- @field parse_file fun(path: string): boolean, table|string
--- @field write_file fun(path: string, data: table, opts?: table): boolean, string|nil
--- @field validate_structure fun(data: table, required_fields: table): boolean, string|nil

local M = {}

--- Validate that an object implements the JSON interface
--- @param impl table Object to validate
--- @return boolean valid
--- @return string|nil error
function M.validate(impl)
  if type(impl) ~= "table" then
    return false, "Implementation must be a table"
  end

  local required_methods = {
    "parse",
    "encode",
    "parse_file",
    "write_file",
    "validate_structure",
  }

  for _, method in ipairs(required_methods) do
    if type(impl[method]) ~= "function" then
      return false, "Missing or invalid method: " .. method
    end
  end

  return true, nil
end

--- Create a validated JSON implementation
--- @param impl table Implementation to wrap
--- @return table validated_impl
function M.create(impl)
  local valid, err = M.validate(impl)
  if not valid then
    error("Invalid JSON implementation: " .. err)
  end

  -- Add interface metadata
  impl._interface = "JsonInterface"
  impl._version = "1.0.0"

  return impl
end

return M
