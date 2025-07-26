-- lua/yoda/utils/plugin_validator.lua
-- Plugin validation utility for Yoda.nvim

local M = {}

---
-- Validates plugin specifications for common issues
-- @param specs table Plugin specifications to validate
-- @return table Issues found
function M.validate_plugin_specs(specs)
  local issues = {}
  
  for i, spec in ipairs(specs) do
    local plugin_name = spec[1] or "unknown"
    
    -- Check for missing config function when opts is present
    if spec.opts and not spec.config then
      table.insert(issues, {
        type = "missing_config",
        plugin = plugin_name,
        index = i,
        message = string.format("Plugin '%s' has opts but no config function", plugin_name)
      })
    end
    
    -- Check for missing setup call in config function
    if spec.config and type(spec.config) == "function" then
      -- This is a basic check - we can't easily parse the function body
      -- but we can check if it's likely to call setup
      local config_str = tostring(spec.config)
      if not config_str:match("setup") then
        table.insert(issues, {
          type = "missing_setup",
          plugin = plugin_name,
          index = i,
          message = string.format("Plugin '%s' config function may not call setup", plugin_name)
        })
      end
    end
    
    -- Check for invalid plugin names
    if type(plugin_name) ~= "string" or plugin_name == "" then
      table.insert(issues, {
        type = "invalid_name",
        plugin = tostring(plugin_name),
        index = i,
        message = string.format("Invalid plugin name at index %d: %s", i, tostring(plugin_name))
      })
    end
    
    -- Check for missing dependencies
    if spec.dependencies then
      for j, dep in ipairs(spec.dependencies) do
        if type(dep) ~= "string" or dep == "" then
          table.insert(issues, {
            type = "invalid_dependency",
            plugin = plugin_name,
            index = i,
            dep_index = j,
            message = string.format("Plugin '%s' has invalid dependency at index %d: %s", plugin_name, j, tostring(dep))
          })
        end
      end
    end
  end
  
  return issues
end

---
-- Validates a single plugin specification
-- @param spec table Plugin specification to validate
-- @param index number Index of the plugin in the specs array
-- @return table Issues found
function M.validate_plugin_spec(spec, index)
  local issues = {}
  local plugin_name = spec[1] or "unknown"
  
  -- Check for required fields
  if not spec[1] then
    table.insert(issues, {
      type = "missing_name",
      plugin = plugin_name,
      index = index,
      message = "Plugin specification missing name"
    })
  end
  
  -- Check for opts without config
  if spec.opts and not spec.config then
    table.insert(issues, {
      type = "missing_config",
      plugin = plugin_name,
      index = index,
      message = string.format("Plugin '%s' has opts but no config function", plugin_name)
    })
  end
  
  -- Check for config without opts (this might be intentional)
  if spec.config and not spec.opts then
    table.insert(issues, {
      type = "missing_opts",
      plugin = plugin_name,
      index = index,
      message = string.format("Plugin '%s' has config function but no opts (this may be intentional)", plugin_name)
    })
  end
  
  return issues
end

---
-- Generates a fix suggestion for a plugin issue
-- @param issue table Issue to generate fix for
-- @return string Fix suggestion
function M.generate_fix_suggestion(issue)
  if issue.type == "missing_config" then
    return string.format([[
Add config function to plugin '%s':
{
  "%s",
  config = function(_, opts)
    require("%s").setup(opts)
  end,
  opts = {
    -- your options here
  },
}]], issue.plugin, issue.plugin, issue.plugin:match("([^/]+)$") or issue.plugin)
  elseif issue.type == "missing_setup" then
    return string.format([[
Ensure config function calls setup for plugin '%s':
config = function(_, opts)
  require("%s").setup(opts)
end]], issue.plugin, issue.plugin:match("([^/]+)$") or issue.plugin)
  elseif issue.type == "invalid_name" then
    return "Fix plugin name - should be a non-empty string"
  elseif issue.type == "invalid_dependency" then
    return "Fix dependency - should be a non-empty string"
  else
    return "Unknown issue type - manual review required"
  end
end

---
-- Validates all plugin specifications in the Yoda configuration
-- @return table All issues found
function M.validate_yoda_plugins()
  local all_issues = {}
  
  -- Try to load the main plugin spec first
  local ok, all_plugins = pcall(require, "yoda.plugins.spec")
  if ok and type(all_plugins) == "table" then
    -- Validate all plugins at once
    local issues = M.validate_plugin_specs(all_plugins)
    for _, issue in ipairs(issues) do
      issue.file = "yoda.plugins.spec"
      table.insert(all_issues, issue)
    end
  else
    -- Fallback: load individual spec files
    local spec_files = {
      "yoda.plugins.spec.core",
      "yoda.plugins.spec.ui",
      "yoda.plugins.spec.lsp",
      "yoda.plugins.spec.completion",
      "yoda.plugins.spec.ai",
      "yoda.plugins.spec.testing",
      "yoda.plugins.spec.git",
      "yoda.plugins.spec.markdown",
      "yoda.plugins.spec.dap",
      "yoda.plugins.spec.db",
      "yoda.plugins.spec.motion",
      "yoda.plugins.spec.development",
    }
    
    for _, spec_file in ipairs(spec_files) do
      local ok, specs = pcall(require, spec_file)
      if ok and type(specs) == "table" then
        local issues = M.validate_plugin_specs(specs)
        for _, issue in ipairs(issues) do
          issue.file = spec_file
          table.insert(all_issues, issue)
        end
      else
        -- Don't treat missing spec files as errors - they might not exist
        if not ok and not string.find(specs, "module.*not found") then
          table.insert(all_issues, {
            type = "load_error",
            file = spec_file,
            message = string.format("Failed to load %s: %s", spec_file, tostring(specs))
          })
        end
      end
    end
  end
  
  return all_issues
end

---
-- Reports plugin validation issues
-- @param issues table Issues to report
function M.report_issues(issues)
  if #issues == 0 then
    vim.notify("✅ All plugin specifications are valid", vim.log.levels.INFO)
    return
  end
  
  local report = {"🔍 Plugin Validation Issues Found:"}
  for i, issue in ipairs(issues) do
    table.insert(report, string.format("%d. %s", i, issue.message))
    if issue.file then
      table.insert(report, string.format("   File: %s", issue.file))
    end
    table.insert(report, string.format("   Fix: %s", M.generate_fix_suggestion(issue)))
    table.insert(report, "")
  end
  
  vim.notify(table.concat(report, "\n"), vim.log.levels.WARN, {
    title = "Plugin Validation",
    timeout = 10000
  })
end

-- User commands for plugin validation
vim.api.nvim_create_user_command("YodaValidatePlugins", function()
  local issues = M.validate_yoda_plugins()
  M.report_issues(issues)
end, {})

vim.api.nvim_create_user_command("YodaFixPluginConfigs", function()
  local issues = M.validate_yoda_plugins()
  if #issues == 0 then
    vim.notify("✅ No plugin configuration issues found", vim.log.levels.INFO)
    return
  end
  
  local fix_count = 0
  for _, issue in ipairs(issues) do
    if issue.type == "missing_config" then
      vim.notify(string.format("⚠️  Manual fix required for %s: Add config function", issue.plugin), vim.log.levels.WARN)
      fix_count = fix_count + 1
    end
  end
  
  vim.notify(string.format("🔧 %d plugin configuration issues need manual fixes", fix_count), vim.log.levels.WARN)
end, {})

return M 