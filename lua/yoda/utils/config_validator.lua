-- lua/yoda/utils/config_validator.lua
-- Configuration validation utilities for Yoda.nvim

local M = {}

-- Validation error types
local ERROR_TYPES = {
  MISSING_DEPENDENCY = "missing_dependency",
  INVALID_CONFIG = "invalid_config",
  ENVIRONMENT_MISMATCH = "environment_mismatch",
  PLUGIN_CONFLICT = "plugin_conflict"
}

-- Validate environment configuration
function M.validate_environment_config()
  local errors = {}
  local warnings = {}
  
  -- Check YODA_ENV environment variable
  local env = vim.env.YODA_ENV
  if not env then
    table.insert(warnings, "YODA_ENV not set, using default 'home' environment")
  elseif env ~= "home" and env ~= "work" then
    table.insert(errors, string.format("Invalid YODA_ENV value: %s (expected 'home' or 'work')", env))
  end
  
  -- Check yoda_config global variable
  if not vim.g.yoda_config then
    table.insert(warnings, "yoda_config not set, using default configuration")
  else
    -- Validate yoda_config structure
    local config = vim.g.yoda_config
    if type(config.verbose_startup) ~= "boolean" and config.verbose_startup ~= nil then
      table.insert(errors, "yoda_config.verbose_startup must be a boolean")
    end
    if type(config.show_loading_messages) ~= "boolean" and config.show_loading_messages ~= nil then
      table.insert(errors, "yoda_config.show_loading_messages must be a boolean")
    end
    if type(config.show_environment_notification) ~= "boolean" and config.show_environment_notification ~= nil then
      table.insert(errors, "yoda_config.show_environment_notification must be a boolean")
    end
  end
  
  -- Check required Neovim version
  local nvim_version = vim.version()
  if nvim_version.major < 0 or nvim_version.minor < 9 then
    table.insert(errors, "Yoda.nvim requires Neovim 0.9.0 or higher")
  end
  
  -- Check required Lua version
  if _VERSION < "Lua 5.1" then
    table.insert(errors, "Yoda.nvim requires Lua 5.1 or higher")
  end
  
  return #errors == 0, errors, warnings
end

-- Validate plugin dependencies
function M.validate_plugin_dependencies(plugin_specs)
  local errors = {}
  local warnings = {}
  
  -- Check for missing dependencies
  for plugin_name, spec in pairs(plugin_specs) do
    if spec.dependencies then
      for _, dep in ipairs(spec.dependencies) do
        local dep_name = type(dep) == "string" and dep or dep[1]
        if not plugin_specs[dep_name] then
          table.insert(errors, string.format("Plugin '%s' depends on missing plugin '%s'", plugin_name, dep_name))
        end
      end
    end
  end
  
  -- Check for circular dependencies
  local visited = {}
  local recursion_stack = {}
  
  local function has_circular_dependency(plugin_name)
    if recursion_stack[plugin_name] then
      return true
    end
    
    if visited[plugin_name] then
      return false
    end
    
    visited[plugin_name] = true
    recursion_stack[plugin_name] = true
    
    local spec = plugin_specs[plugin_name]
    if spec and spec.dependencies then
      for _, dep in ipairs(spec.dependencies) do
        local dep_name = type(dep) == "string" and dep or dep[1]
        if has_circular_dependency(dep_name) then
          return true
        end
      end
    end
    
    recursion_stack[plugin_name] = false
    return false
  end
  
  for plugin_name, _ in pairs(plugin_specs) do
    if has_circular_dependency(plugin_name) then
      table.insert(errors, string.format("Circular dependency detected involving plugin '%s'", plugin_name))
    end
  end
  
  return #errors == 0, errors, warnings
end

-- Validate keymap configuration
function M.validate_keymap_config()
  local errors = {}
  local warnings = {}
  
  -- Check for conflicting keymaps
  if _G.yoda_keymap_log then
    local keymap_counts = {}
    for _, keymap in ipairs(_G.yoda_keymap_log) do
      local key = keymap.mode .. keymap.lhs
      keymap_counts[key] = (keymap_counts[key] or 0) + 1
    end
    
    for key, count in pairs(keymap_counts) do
      if count > 1 then
        table.insert(warnings, string.format("Duplicate keymap detected: %s (%d times)", key, count))
      end
    end
  end
  
  return #errors == 0, errors, warnings
end

-- Run comprehensive validation
function M.run_validation()
  local all_errors = {}
  local all_warnings = {}
  
  -- Validate environment configuration
  local env_ok, env_errors, env_warnings = M.validate_environment_config()
  if not env_ok then
    vim.list_extend(all_errors, env_errors)
  end
  vim.list_extend(all_warnings, env_warnings)
  
  -- Validate plugin dependencies (if plugin specs are available)
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local plugins = lazy.get_plugins()
    local plugin_specs = {}
    for _, plugin in ipairs(plugins) do
      plugin_specs[plugin.name] = plugin
    end
    
    local deps_ok, deps_errors, deps_warnings = M.validate_plugin_dependencies(plugin_specs)
    if not deps_ok then
      vim.list_extend(all_errors, deps_errors)
    end
    vim.list_extend(all_warnings, deps_warnings)
  end
  
  -- Validate keymap configuration
  local keymap_ok, keymap_errors, keymap_warnings = M.validate_keymap_config()
  if not keymap_ok then
    vim.list_extend(all_errors, keymap_errors)
  end
  vim.list_extend(all_warnings, keymap_warnings)
  
  -- Report results
  if #all_errors > 0 then
    vim.notify("Configuration validation failed:", vim.log.levels.ERROR, { title = "Config Validator" })
    for _, error in ipairs(all_errors) do
      vim.notify("  ❌ " .. error, vim.log.levels.ERROR)
    end
  end
  
  if #all_warnings > 0 then
    vim.notify("Configuration warnings:", vim.log.levels.WARN, { title = "Config Validator" })
    for _, warning in ipairs(all_warnings) do
      vim.notify("  ⚠️ " .. warning, vim.log.levels.WARN)
    end
  end
  
  if #all_errors == 0 and #all_warnings == 0 then
    vim.notify("✅ Configuration validation passed", vim.log.levels.INFO, { title = "Config Validator" })
  end
  
  return #all_errors == 0, all_errors, all_warnings
end

-- Register validation commands
vim.api.nvim_create_user_command("YodaValidateConfig", function()
  M.run_validation()
end, { desc = "Validate Yoda.nvim configuration" })

return M 