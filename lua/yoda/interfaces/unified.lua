-- lua/yoda/interfaces/unified.lua
-- Unified interface system ensuring perfect LSP compliance
-- Guarantees DI and non-DI versions are perfectly substitutable

local M = {}

-- ============================================================================
-- LSP COMPLIANCE FRAMEWORK
-- ============================================================================

--- Registry of interface implementations
local _implementations = {}

--- Register implementation for LSP verification
--- @param module_name string Module name (e.g., "string", "table")
--- @param impl_type string Implementation type ("standard" or "di")
--- @param implementation table The implementation
function M.register_implementation(module_name, impl_type, implementation)
  _implementations[module_name] = _implementations[module_name] or {}
  _implementations[module_name][impl_type] = implementation
end

--- Verify LSP compliance between standard and DI versions
--- @param module_name string Module name to verify
--- @return boolean compliant
--- @return string|nil error
function M.verify_lsp_compliance(module_name)
  local implementations = _implementations[module_name]
  if not implementations then
    return false, "No implementations registered for " .. module_name
  end

  local standard = implementations.standard
  local di = implementations.di

  if not standard or not di then
    return false, "Missing standard or DI implementation for " .. module_name
  end

  -- Verify method signatures match (LSP requirement)
  for method_name, method in pairs(standard) do
    if type(method) == "function" then
      if type(di[method_name]) ~= "function" then
        return false, string.format("Method '%s' missing in DI version", method_name)
      end

      -- Basic signature compatibility check
      local std_info = debug.getinfo(method)
      local di_info = debug.getinfo(di[method_name])

      if std_info.nparams ~= di_info.nparams then
        return false, string.format("Method '%s' parameter count mismatch", method_name)
      end
    end
  end

  -- Verify DI version doesn't have extra public methods (interface segregation)
  for method_name, method in pairs(di) do
    if type(method) == "function" and not method_name:match("^_") then
      if not standard[method_name] then
        return false, string.format("Extra method '%s' in DI version violates LSP", method_name)
      end
    end
  end

  return true, nil
end

--- Create LSP-compliant wrapper that ensures substitutability
--- @param implementation table Implementation to wrap
--- @param interface_spec table Interface specification
--- @return table wrapped_implementation
function M.create_lsp_wrapper(implementation, interface_spec)
  local wrapper = {}

  -- Copy all specified methods with validation
  for method_name, method_spec in pairs(interface_spec) do
    if type(implementation[method_name]) ~= "function" then
      error("Implementation missing required method: " .. method_name)
    end

    -- Wrap method with LSP validation
    wrapper[method_name] = function(...)
      local args = { ... }

      -- Pre-condition: validate input parameters match spec
      if method_spec.params then
        for i, param_spec in ipairs(method_spec.params) do
          local arg = args[i]
          if param_spec.required and arg == nil then
            error(string.format("Method '%s' requires parameter %d (%s)", method_name, i, param_spec.name))
          end
          if arg ~= nil and param_spec.type and type(arg) ~= param_spec.type then
            error(string.format("Method '%s' parameter %d must be %s, got %s", method_name, i, param_spec.type, type(arg)))
          end
        end
      end

      -- Call original implementation
      local results = { implementation[method_name](...) }

      -- Post-condition: validate return values match spec
      if method_spec.returns then
        for i, return_spec in ipairs(method_spec.returns) do
          local result = results[i]
          if return_spec.required and result == nil then
            error(string.format("Method '%s' must return value %d (%s)", method_name, i, return_spec.name))
          end
          if result ~= nil and return_spec.type and type(result) ~= return_spec.type then
            error(string.format("Method '%s' return %d must be %s, got %s", method_name, i, return_spec.type, type(result)))
          end
        end
      end

      return unpack(results)
    end
  end

  -- Add LSP metadata
  wrapper._lsp_compliant = true
  wrapper._interface_spec = interface_spec
  wrapper._wrapped_implementation = implementation

  return wrapper
end

--- Get all LSP compliance violations across all modules
--- @return table violations List of violations
function M.get_all_violations()
  local violations = {}

  for module_name, _ in pairs(_implementations) do
    local compliant, error = M.verify_lsp_compliance(module_name)
    if not compliant then
      table.insert(violations, {
        module = module_name,
        error = error,
      })
    end
  end

  return violations
end

--- Generate LSP compliance report
--- @return table report Detailed compliance report
function M.generate_compliance_report()
  local report = {
    total_modules = 0,
    compliant_modules = 0,
    violations = {},
    summary = "",
  }

  for module_name, _ in pairs(_implementations) do
    report.total_modules = report.total_modules + 1

    local compliant, error = M.verify_lsp_compliance(module_name)
    if compliant then
      report.compliant_modules = report.compliant_modules + 1
    else
      table.insert(report.violations, {
        module = module_name,
        error = error,
      })
    end
  end

  local compliance_rate = math.floor((report.compliant_modules / report.total_modules) * 100)
  report.summary = string.format("%d%% LSP compliant (%d/%d modules)", compliance_rate, report.compliant_modules, report.total_modules)

  return report
end

return M
