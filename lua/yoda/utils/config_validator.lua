-- lua/yoda/utils/config_validator.lua
-- Configuration validation utilities for Yoda.nvim

local M = {}

-- Validation rules for different configuration types
local validation_rules = {
  plugin_spec = {
    required_fields = { "name" },
    optional_fields = { "config", "opts", "dependencies", "lazy", "event", "cmd" },
    field_types = {
      name = "string",
      config = "function",
      opts = { "table", "function" },
      dependencies = "table",
      lazy = "boolean",
      event = { "string", "table" },
      cmd = { "string", "table" },
    }
  },
  
  keymap = {
    required_fields = { "mode", "lhs", "rhs" },
    optional_fields = { "opts", "desc" },
    field_types = {
      mode = "string",
      lhs = "string",
      rhs = { "string", "function" },
      opts = "table",
      desc = "string",
    }
  },
  
  autocmd = {
    required_fields = { "event" },
    optional_fields = { "pattern", "callback", "command", "desc" },
    field_types = {
      event = { "string", "table" },
      pattern = { "string", "table" },
      callback = "function",
      command = "string",
      desc = "string",
    }
  }
}

-- Helper function to check if value is of expected type
local function is_valid_type(value, expected_types)
  if type(expected_types) == "string" then
    return type(value) == expected_types
  elseif type(expected_types) == "table" then
    for _, expected_type in ipairs(expected_types) do
      if type(value) == expected_type then
        return true
      end
    end
    return false
  end
  return false
end

-- Validate plugin specification
function M.validate_plugin_spec(plugin_spec)
  local errors = {}
  local warnings = {}
  
  -- Check if plugin_spec is a table
  if type(plugin_spec) ~= "table" then
    table.insert(errors, "Plugin spec must be a table")
    return false, errors, warnings
  end
  
  -- Check for required fields
  local rules = validation_rules.plugin_spec
  for _, field in ipairs(rules.required_fields) do
    if not plugin_spec[field] then
      table.insert(errors, string.format("Missing required field: %s", field))
    end
  end
  
  -- Check field types
  for field, expected_types in pairs(rules.field_types) do
    if plugin_spec[field] and not is_valid_type(plugin_spec[field], expected_types) then
      table.insert(errors, string.format("Invalid type for field '%s': expected %s, got %s", 
        field, type(expected_types) == "table" and table.concat(expected_types, " or ") or expected_types, 
        type(plugin_spec[field])))
    end
  end
  
  -- Check for unknown fields
  for field, _ in pairs(plugin_spec) do
    local is_known = false
    for _, known_field in ipairs(rules.required_fields) do
      if field == known_field then
        is_known = true
        break
      end
    end
    for _, known_field in ipairs(rules.optional_fields) do
      if field == known_field then
        is_known = true
        break
      end
    end
    if not is_known then
      table.insert(warnings, string.format("Unknown field: %s", field))
    end
  end
  
  return #errors == 0, errors, warnings
end

-- Validate keymap specification
function M.validate_keymap_spec(keymap_spec)
  local errors = {}
  local warnings = {}
  
  if type(keymap_spec) ~= "table" then
    table.insert(errors, "Keymap spec must be a table")
    return false, errors, warnings
  end
  
  local rules = validation_rules.keymap
  for _, field in ipairs(rules.required_fields) do
    if not keymap_spec[field] then
      table.insert(errors, string.format("Missing required field: %s", field))
    end
  end
  
  for field, expected_types in pairs(rules.field_types) do
    if keymap_spec[field] and not is_valid_type(keymap_spec[field], expected_types) then
      table.insert(errors, string.format("Invalid type for field '%s': expected %s, got %s", 
        field, type(expected_types) == "table" and table.concat(expected_types, " or ") or expected_types, 
        type(keymap_spec[field])))
    end
  end
  
  return #errors == 0, errors, warnings
end

-- Validate autocommand specification
function M.validate_autocmd_spec(autocmd_spec)
  local errors = {}
  local warnings = {}
  
  if type(autocmd_spec) ~= "table" then
    table.insert(errors, "Autocmd spec must be a table")
    return false, errors, warnings
  end
  
  local rules = validation_rules.autocmd
  for _, field in ipairs(rules.required_fields) do
    if not autocmd_spec[field] then
      table.insert(errors, string.format("Missing required field: %s", field))
    end
  end
  
  for field, expected_types in pairs(rules.field_types) do
    if autocmd_spec[field] and not is_valid_type(autocmd_spec[field], expected_types) then
      table.insert(errors, string.format("Invalid type for field '%s': expected %s, got %s", 
        field, type(expected_types) == "table" and table.concat(expected_types, " or ") or expected_types, 
        type(autocmd_spec[field])))
    end
  end
  
  return #errors == 0, errors, warnings
end

-- Validate environment configuration
function M.validate_environment_config()
  local errors = {}
  local warnings = {}
  
  local env = vim.env.YODA_ENV
  if env and env ~= "home" and env ~= "work" then
    table.insert(warnings, string.format("Unknown YODA_ENV value: %s (expected 'home' or 'work')", env))
  end
  
  -- Check for required environment variables
  if env == "work" then
    local required_vars = { "CLAUDE_API_KEY", "OPENAI_API_KEY" }
    local has_any = false
    for _, var in ipairs(required_vars) do
      if vim.env[var] then
        has_any = true
        break
      end
    end
    if not has_any then
      table.insert(warnings, "Work environment detected but no AI API key found (CLAUDE_API_KEY or OPENAI_API_KEY)")
    end
  end
  
  return #errors == 0, errors, warnings
end

-- Validate plugin dependencies
function M.validate_plugin_dependencies(plugin_specs)
  local errors = {}
  local warnings = {}
  
  local plugin_names = {}
  for _, spec in ipairs(plugin_specs) do
    if spec[1] then
      table.insert(plugin_names, spec[1])
    end
  end
  
  for _, spec in ipairs(plugin_specs) do
    if spec.dependencies then
      for _, dep in ipairs(spec.dependencies) do
        local dep_name = type(dep) == "string" and dep or dep[1]
        local found = false
        for _, name in ipairs(plugin_names) do
          if name == dep_name then
            found = true
            break
          end
        end
        if not found then
          table.insert(warnings, string.format("Plugin dependency not found: %s", dep_name))
        end
      end
    end
  end
  
  return #errors == 0, errors, warnings
end

-- Comprehensive configuration validation
function M.validate_configuration()
  local all_errors = {}
  local all_warnings = {}
  
  -- Validate environment
  local env_ok, env_errors, env_warnings = M.validate_environment_config()
  if not env_ok then
    vim.list_extend(all_errors, env_errors)
  end
  vim.list_extend(all_warnings, env_warnings)
  
  -- Validate plugin specifications
  local plugin_specs = require("yoda.plugins.spec")
  for category, plugins in pairs(plugin_specs) do
    if type(plugins) == "table" then
      for i, plugin in ipairs(plugins) do
        local ok, errors, warnings = M.validate_plugin_spec(plugin)
        if not ok then
          for _, error in ipairs(errors) do
            table.insert(all_errors, string.format("[%s][%d]: %s", category, i, error))
          end
        end
        for _, warning in ipairs(warnings) do
          table.insert(all_warnings, string.format("[%s][%d]: %s", category, i, warning))
        end
      end
    end
  end
  
  -- Validate plugin dependencies
  local deps_ok, deps_errors, deps_warnings = M.validate_plugin_dependencies(plugin_specs)
  if not deps_ok then
    vim.list_extend(all_errors, deps_errors)
  end
  vim.list_extend(all_warnings, deps_warnings)
  
  return #all_errors == 0, all_errors, all_warnings
end

-- Print validation results
function M.print_validation_results()
  local ok, errors, warnings = M.validate_configuration()
  
  if #errors > 0 then
    vim.notify("Configuration validation errors:", vim.log.levels.ERROR)
    for _, error in ipairs(errors) do
      vim.notify("  " .. error, vim.log.levels.ERROR)
    end
  end
  
  if #warnings > 0 then
    vim.notify("Configuration validation warnings:", vim.log.levels.WARN)
    for _, warning in ipairs(warnings) do
      vim.notify("  " .. warning, vim.log.levels.WARN)
    end
  end
  
  if ok then
    vim.notify("✅ Configuration validation passed", vim.log.levels.INFO)
  else
    vim.notify("❌ Configuration validation failed", vim.log.levels.ERROR)
  end
  
  return ok
end

-- Register validation commands
vim.api.nvim_create_user_command("YodaValidateConfig", function()
  M.print_validation_results()
end, { desc = "Validate Yoda configuration" })

vim.api.nvim_create_user_command("YodaValidatePlugins", function()
  local plugin_specs = require("yoda.plugins.spec")
  local all_errors = {}
  local all_warnings = {}
  
  for category, plugins in pairs(plugin_specs) do
    if type(plugins) == "table" then
      for i, plugin in ipairs(plugins) do
        local ok, errors, warnings = M.validate_plugin_spec(plugin)
        if not ok then
          for _, error in ipairs(errors) do
            table.insert(all_errors, string.format("[%s][%d]: %s", category, i, error))
          end
        end
        for _, warning in ipairs(warnings) do
          table.insert(all_warnings, string.format("[%s][%d]: %s", category, i, warning))
        end
      end
    end
  end
  
  if #all_errors > 0 then
    vim.notify("Plugin validation errors:", vim.log.levels.ERROR)
    for _, error in ipairs(all_errors) do
      vim.notify("  " .. error, vim.log.levels.ERROR)
    end
  end
  
  if #all_warnings > 0 then
    vim.notify("Plugin validation warnings:", vim.log.levels.WARN)
    for _, warning in ipairs(all_warnings) do
      vim.notify("  " .. warning, vim.log.levels.WARN)
    end
  end
  
  if #all_errors == 0 then
    vim.notify("✅ Plugin validation passed", vim.log.levels.INFO)
  else
    vim.notify("❌ Plugin validation failed", vim.log.levels.ERROR)
  end
end, { desc = "Validate plugin specifications" })

return M 