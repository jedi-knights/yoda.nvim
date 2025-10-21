-- lua/yoda/interfaces/granular.lua
-- Ultra-granular interfaces for perfect ISP compliance
-- Each interface represents the smallest possible set of cohesive methods

local M = {}

-- ============================================================================
-- GRANULAR STRING INTERFACES (Perfect ISP)
-- ============================================================================

--- @class WhitespaceInterface - ONLY whitespace operations
--- @field trim fun(str: string): string
--- @field is_blank fun(str: string|nil): boolean

--- @class StringMatchingInterface - ONLY matching operations
--- @field starts_with fun(str: string, prefix: string): boolean
--- @field ends_with fun(str: string, suffix: string): boolean

--- @class StringSplittingInterface - ONLY splitting operations
--- @field split fun(str: string, delimiter: string): table

--- @class PathExtensionInterface - ONLY path extension operations
--- @field get_extension fun(path: string): string

-- ============================================================================
-- GRANULAR TABLE INTERFACES (Perfect ISP)
-- ============================================================================

--- @class TableMergingInterface - ONLY merging operations
--- @field merge fun(defaults: table, overrides: table): table

--- @class TableCopyingInterface - ONLY copying operations
--- @field deep_copy fun(orig: table): table

--- @class TableQueryInterface - ONLY query operations
--- @field is_empty fun(tbl: table): boolean
--- @field size fun(tbl: table): number
--- @field contains fun(tbl: table, value: any): boolean

-- ============================================================================
-- GRANULAR FILESYSTEM INTERFACES (Perfect ISP)
-- ============================================================================

--- @class FileExistenceInterface - ONLY existence checking
--- @field is_file fun(path: string): boolean
--- @field is_dir fun(path: string): boolean
--- @field exists fun(path: string): boolean
--- @field file_exists fun(path: string): boolean

--- @class FileIOInterface - ONLY file I/O operations
--- @field read_file fun(path: string): boolean, string|nil
--- @field write_file fun(path: string, content: string): boolean, string|nil

-- ============================================================================
-- GRANULAR JSON INTERFACES (Perfect ISP)
-- ============================================================================

--- @class JsonParsingInterface - ONLY parsing operations
--- @field parse fun(json_str: string): boolean, table|string

--- @class JsonEncodingInterface - ONLY encoding operations
--- @field encode fun(data: table, opts?: table): boolean, string|nil

--- @class JsonFileInterface - ONLY file operations
--- @field parse_file fun(path: string): boolean, table|string
--- @field write_file fun(path: string, data: table, opts?: table): boolean, string|nil

--- @class JsonValidationInterface - ONLY validation operations
--- @field validate_structure fun(data: table, required_fields: table): boolean, string|nil

-- ============================================================================
-- GRANULAR PLATFORM INTERFACES (Perfect ISP)
-- ============================================================================

--- @class PlatformDetectionInterface - ONLY detection operations
--- @field is_windows fun(): boolean
--- @field is_macos fun(): boolean
--- @field is_linux fun(): boolean
--- @field get_platform fun(): string

--- @class PathOperationsInterface - ONLY path operations
--- @field get_path_sep fun(): string
--- @field join_path fun(...: string): string
--- @field normalize_path fun(path: string): string

-- ============================================================================
-- INTERFACE COMPOSITION FOR BACKWARDS COMPATIBILITY
-- ============================================================================

--- Compose granular interfaces into larger ones for compatibility
--- @param ... table List of interface implementations
--- @return table composed_interface
function M.compose_interfaces(...)
  local composed = {}
  local interfaces = { ... }

  for _, interface in ipairs(interfaces) do
    for method_name, method in pairs(interface) do
      if type(method) == "function" and not method_name:match("^_") then
        if composed[method_name] then
          error("Method collision in interface composition: " .. method_name)
        end
        composed[method_name] = method
      end
    end
  end

  return composed
end

--- Validate that implementation only uses methods from specified interfaces
--- @param implementation table Implementation to validate
--- @param interface_names table List of granular interface names
--- @return boolean valid
--- @return string|nil error
function M.validate_isp_compliance(implementation, interface_names)
  local allowed_methods = {}

  -- Collect all allowed methods from specified interfaces
  for _, interface_name in ipairs(interface_names) do
    local interface_spec = M[interface_name .. "_methods"]
    if interface_spec then
      for _, method_name in ipairs(interface_spec) do
        allowed_methods[method_name] = true
      end
    end
  end

  -- Check implementation only has allowed methods
  for method_name, method in pairs(implementation) do
    if type(method) == "function" and not method_name:match("^_") then
      if not allowed_methods[method_name] then
        return false, "Method '" .. method_name .. "' not allowed by specified interfaces"
      end
    end
  end

  return true, nil
end

-- Method lists for validation (Perfect ISP specification)
M.WhitespaceInterface_methods = { "trim", "is_blank" }
M.StringMatchingInterface_methods = { "starts_with", "ends_with" }
M.StringSplittingInterface_methods = { "split" }
M.PathExtensionInterface_methods = { "get_extension" }

M.TableMergingInterface_methods = { "merge" }
M.TableCopyingInterface_methods = { "deep_copy" }
M.TableQueryInterface_methods = { "is_empty", "size", "contains" }

M.FileExistenceInterface_methods = { "is_file", "is_dir", "exists", "file_exists" }
M.FileIOInterface_methods = { "read_file", "write_file" }

M.JsonParsingInterface_methods = { "parse" }
M.JsonEncodingInterface_methods = { "encode" }
M.JsonFileInterface_methods = { "parse_file", "write_file" }
M.JsonValidationInterface_methods = { "validate_structure" }

M.PlatformDetectionInterface_methods = { "is_windows", "is_macos", "is_linux", "get_platform" }
M.PathOperationsInterface_methods = { "get_path_sep", "join_path", "normalize_path" }

--- Create minimal interface client that only depends on what it needs
--- @param full_implementation table Full implementation
--- @param required_interfaces table List of required interface names
--- @return table minimal_client
function M.create_minimal_client(full_implementation, required_interfaces)
  local minimal = {}

  for _, interface_name in ipairs(required_interfaces) do
    local methods = M[interface_name .. "_methods"]
    if methods then
      for _, method_name in ipairs(methods) do
        if full_implementation[method_name] then
          minimal[method_name] = full_implementation[method_name]
        end
      end
    end
  end

  -- Add metadata
  minimal._interfaces = required_interfaces
  minimal._minimal_client = true

  return minimal
end

return M
