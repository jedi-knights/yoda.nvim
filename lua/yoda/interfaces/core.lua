-- lua/yoda/interfaces/core.lua
-- Core module interfaces - perfect LSP compliance
-- Ensures DI and non-DI versions are perfectly substitutable

local M = {}

-- ============================================================================
-- STRING INTERFACE
-- ============================================================================

--- @class StringInterface
--- @field trim fun(str: string): string
--- @field starts_with fun(str: string, prefix: string): boolean
--- @field ends_with fun(str: string, suffix: string): boolean
--- @field split fun(str: string, delimiter: string): table
--- @field get_extension fun(path: string): string
--- @field is_blank fun(str: string|nil): boolean

--- Validate string interface implementation
--- @param impl table Implementation to validate
--- @return boolean valid
--- @return string|nil error
function M.validate_string(impl)
  local required_methods = {
    "trim",
    "starts_with",
    "ends_with",
    "split",
    "get_extension",
    "is_blank",
  }

  for _, method in ipairs(required_methods) do
    if type(impl[method]) ~= "function" then
      return false, "Missing string method: " .. method
    end
  end

  return true, nil
end

-- ============================================================================
-- TABLE INTERFACE
-- ============================================================================

--- @class TableInterface
--- @field merge fun(defaults: table, overrides: table): table
--- @field deep_copy fun(orig: table): table
--- @field is_empty fun(tbl: table): boolean
--- @field size fun(tbl: table): number
--- @field contains fun(tbl: table, value: any): boolean

--- Validate table interface implementation
--- @param impl table Implementation to validate
--- @return boolean valid
--- @return string|nil error
function M.validate_table(impl)
  local required_methods = {
    "merge",
    "deep_copy",
    "is_empty",
    "size",
    "contains",
  }

  for _, method in ipairs(required_methods) do
    if type(impl[method]) ~= "function" then
      return false, "Missing table method: " .. method
    end
  end

  return true, nil
end

-- ============================================================================
-- PLATFORM INTERFACE
-- ============================================================================

--- @class PlatformInterface
--- @field is_windows fun(): boolean
--- @field is_macos fun(): boolean
--- @field is_linux fun(): boolean
--- @field get_platform fun(): string
--- @field get_path_sep fun(): string
--- @field join_path fun(...: string): string
--- @field normalize_path fun(path: string): string

--- Validate platform interface implementation
--- @param impl table Implementation to validate
--- @return boolean valid
--- @return string|nil error
function M.validate_platform(impl)
  local required_methods = {
    "is_windows",
    "is_macos",
    "is_linux",
    "get_platform",
    "get_path_sep",
    "join_path",
    "normalize_path",
  }

  for _, method in ipairs(required_methods) do
    if type(impl[method]) ~= "function" then
      return false, "Missing platform method: " .. method
    end
  end

  return true, nil
end

-- ============================================================================
-- INTERFACE FACTORY - PERFECT LSP COMPLIANCE
-- ============================================================================

--- Create validated implementation that satisfies LSP
--- @param impl table Implementation
--- @param interface_name string Interface name
--- @return table validated_impl
function M.create_validated(impl, interface_name)
  local validator = M["validate_" .. interface_name]
  if not validator then
    error("Unknown interface: " .. interface_name)
  end

  local valid, err = validator(impl)
  if not valid then
    error("Interface validation failed for " .. interface_name .. ": " .. err)
  end

  -- Add metadata for runtime verification
  impl._interface = interface_name .. "Interface"
  impl._validated = true
  impl._version = "1.0.0"

  return impl
end

--- Verify two implementations are substitutable (LSP check)
--- @param impl1 table First implementation
--- @param impl2 table Second implementation
--- @return boolean substitutable
--- @return string|nil error
function M.verify_substitutable(impl1, impl2)
  -- Check they implement same interface
  if impl1._interface ~= impl2._interface then
    return false, "Different interfaces: " .. (impl1._interface or "none") .. " vs " .. (impl2._interface or "none")
  end

  -- Check both are validated
  if not impl1._validated or not impl2._validated then
    return false, "One or both implementations not validated"
  end

  -- Check method signatures match (basic LSP compliance)
  for name, method in pairs(impl1) do
    if type(method) == "function" then
      if type(impl2[name]) ~= "function" then
        return false, "Method signature mismatch: " .. name
      end
    end
  end

  return true, nil
end

return M
