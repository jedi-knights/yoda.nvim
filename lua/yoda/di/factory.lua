-- lua/yoda/di/factory.lua
-- DI Factory - eliminates ALL dual implementation duplication
-- Single source of truth: converts ANY module to DI-compatible version
-- PERFECT DRY: Zero code duplication for DI patterns

local M = {}

-- ============================================================================
-- DI WRAPPER FACTORY (Perfect DRY Solution)
-- ============================================================================

--- Create DI-compatible version of any module without code duplication
--- @param module_factory function Factory function that creates the module
--- @param dependencies_schema table Schema defining required dependencies
--- @return table di_module_factory
function M.create_di_module(module_factory, dependencies_schema)
  return {
    --- Create DI instance with injected dependencies
    --- @param deps table Dependencies to inject
    --- @return table configured_module
    new = function(deps)
      -- Validate dependencies
      local validation_errors = M._validate_dependencies(deps, dependencies_schema)
      if #validation_errors > 0 then
        error("DI validation failed: " .. table.concat(validation_errors, ", "))
      end

      -- Create base module
      local base_module = module_factory()

      -- Inject dependencies
      local di_module = M._inject_dependencies(base_module, deps, dependencies_schema)

      -- Add DI metadata
      di_module._di = true
      di_module._dependencies = deps
      di_module._schema = dependencies_schema

      return di_module
    end,

    -- Expose schema for introspection
    schema = dependencies_schema,
    factory = module_factory,
  }
end

--- Universal DI wrapper for standard modules (Perfect DRY)
--- @param module_path string Path to standard module
--- @param dependencies_schema table Dependency requirements
--- @return table di_wrapper
function M.wrap_standard_module(module_path, dependencies_schema)
  return M.create_di_module(function()
    return require(module_path)
  end, dependencies_schema or {})
end

-- ============================================================================
-- DEPENDENCY INJECTION LOGIC (Single Source of Truth)
-- ============================================================================

--- Inject dependencies into module methods
--- @param module table Base module
--- @param deps table Dependencies to inject
--- @param schema table Dependency schema
--- @return table module_with_injected_deps
function M._inject_dependencies(module, deps, schema)
  local injected = {}

  -- Copy all methods from base module
  for name, method in pairs(module) do
    if type(method) == "function" and not name:match("^_") then
      -- Wrap method with dependency injection
      injected[name] = M._create_injected_method(method, deps)
    else
      -- Copy non-function properties as-is
      injected[name] = method
    end
  end

  -- Add dependency access methods
  injected.get_dependency = function(dep_name)
    return deps[dep_name]
  end

  injected.list_dependencies = function()
    local dep_list = {}
    for dep_name, _ in pairs(deps) do
      table.insert(dep_list, dep_name)
    end
    return dep_list
  end

  return injected
end

--- Create method wrapper with dependency access
--- @param original_method function Original method
--- @param deps table Available dependencies
--- @return function wrapped_method
function M._create_injected_method(original_method, deps)
  return function(...)
    -- Method can access dependencies via closure
    -- This allows DI methods to use injected dependencies
    local env = getfenv(original_method)
    local new_env = setmetatable({
      -- Provide dependency access
      deps = deps,
      get_dep = function(name)
        return deps[name]
      end,
    }, { __index = env })

    -- Create method with dependency access
    local injected_method = setfenv(original_method, new_env)
    return injected_method(...)
  end
end

--- Validate dependencies against schema
--- @param deps table Dependencies provided
--- @param schema table Required dependency schema
--- @return table errors List of validation errors
function M._validate_dependencies(deps, schema)
  local errors = {}

  if type(deps) ~= "table" then
    table.insert(errors, "Dependencies must be a table")
    return errors
  end

  -- Check required dependencies
  for dep_name, dep_config in pairs(schema) do
    local dependency = deps[dep_name]

    if dep_config.required and dependency == nil then
      table.insert(errors, "Missing required dependency: " .. dep_name)
    end

    if dependency and dep_config.type then
      local actual_type = type(dependency)
      if actual_type ~= dep_config.type then
        table.insert(errors, string.format("Dependency '%s' must be %s, got %s", dep_name, dep_config.type, actual_type))
      end
    end

    if dependency and dep_config.interface then
      -- Validate interface compliance
      local valid, err = M._validate_interface(dependency, dep_config.interface)
      if not valid then
        table.insert(errors, string.format("Dependency '%s' interface validation failed: %s", dep_name, err))
      end
    end
  end

  return errors
end

--- Validate dependency implements required interface
--- @param dependency any Dependency to validate
--- @param interface_name string Interface name
--- @return boolean valid
--- @return string|nil error
function M._validate_interface(dependency, interface_name)
  if type(dependency) ~= "table" then
    return false, "Interface dependencies must be tables"
  end

  -- Basic interface validation (can be extended)
  if interface_name == "notification" then
    if type(dependency.notify) ~= "function" then
      return false, "Missing notify() method"
    end
  elseif interface_name == "picker" then
    if type(dependency.select) ~= "function" then
      return false, "Missing select() method"
    end
  end

  return true, nil
end

-- ============================================================================
-- STANDARD DI SCHEMAS (Perfect DRY - Reusable Patterns)
-- ============================================================================

M.SCHEMAS = {
  -- Standard notification dependency
  notification = {
    notify = {
      required = true,
      type = "table",
      interface = "notification",
    },
  },

  -- Standard picker dependency
  picker = {
    picker = {
      required = true,
      type = "table",
      interface = "picker",
    },
  },

  -- Standard I/O dependencies
  io = {
    io = {
      required = true,
      type = "table",
    },
  },

  -- Platform dependency
  platform = {
    platform = {
      required = true,
      type = "table",
    },
  },

  -- Combined common dependencies
  common = {
    notify = {
      required = false,
      type = "table",
      interface = "notification",
    },
    io = {
      required = false,
      type = "table",
    },
    platform = {
      required = false,
      type = "table",
    },
  },
}

--- Get standard schema by name
--- @param schema_name string Schema name
--- @return table schema
function M.get_schema(schema_name)
  return M.SCHEMAS[schema_name] or {}
end

--- Combine multiple schemas
--- @param ... string Schema names to combine
--- @return table combined_schema
function M.combine_schemas(...)
  local combined = {}
  local schema_names = { ... }

  for _, schema_name in ipairs(schema_names) do
    local schema = M.get_schema(schema_name)
    for dep_name, dep_config in pairs(schema) do
      combined[dep_name] = dep_config
    end
  end

  return combined
end

return M
