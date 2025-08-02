-- Comprehensive Plugin Validator for Yoda.nvim
local M = {}

-- Plugin validation data
local validation_results = {}
local compatibility_matrix = {}

-- Plugin compatibility matrix
local PLUGIN_COMPATIBILITY = {
  ["lazy.nvim"] = {
    min_nvim_version = "0.8.0",
    dependencies = {},
    conflicts = {}
  },
  ["telescope.nvim"] = {
    min_nvim_version = "0.8.0",
    dependencies = {"plenary.nvim"},
    conflicts = {}
  },
  ["nvim-cmp"] = {
    min_nvim_version = "0.8.0",
    dependencies = {},
    conflicts = {}
  },
  ["mason.nvim"] = {
    min_nvim_version = "0.8.0",
    dependencies = {},
    conflicts = {}
  },
  ["nvim-treesitter"] = {
    min_nvim_version = "0.8.0",
    dependencies = {},
    conflicts = {}
  },
  ["lspconfig"] = {
    min_nvim_version = "0.8.0",
    dependencies = {},
    conflicts = {}
  }
}

-- Check Neovim version compatibility
function M.check_nvim_version(plugin_name)
  local plugin_info = PLUGIN_COMPATIBILITY[plugin_name]
  if not plugin_info then
    return true -- Unknown plugin, assume compatible
  end
  
  local required_version = plugin_info.min_nvim_version
  local current_version = vim.version()
  
  -- Simple version comparison (major.minor.patch)
  local function parse_version(version_str)
    local major, minor, patch = version_str:match("(%d+)%.(%d+)%.(%d+)")
    return {tonumber(major), tonumber(minor), tonumber(patch)}
  end
  
  local required = parse_version(required_version)
  local current = parse_version(current_version)
  
  for i = 1, 3 do
    if current[i] > required[i] then
      return true
    elseif current[i] < required[i] then
      return false
    end
  end
  
  return true
end

-- Check plugin dependencies
function M.check_dependencies(plugin_name)
  local plugin_info = PLUGIN_COMPATIBILITY[plugin_name]
  if not plugin_info or not plugin_info.dependencies then
    return true
  end
  
  local missing_deps = {}
  for _, dep in ipairs(plugin_info.dependencies) do
    local ok, _ = pcall(require, dep)
    if not ok then
      table.insert(missing_deps, dep)
    end
  end
  
  return #missing_deps == 0, missing_deps
end

-- Check for plugin conflicts
function M.check_conflicts(plugin_name)
  local plugin_info = PLUGIN_COMPATIBILITY[plugin_name]
  if not plugin_info or not plugin_info.conflicts then
    return true
  end
  
  local conflicts = {}
  for _, conflict in ipairs(plugin_info.conflicts) do
    local ok, _ = pcall(require, conflict)
    if ok then
      table.insert(conflicts, conflict)
    end
  end
  
  return #conflicts == 0, conflicts
end

-- Validate plugin configuration
function M.validate_plugin_config(plugin_name, config)
  local issues = {}
  
  -- Check for required configuration fields
  local required_fields = {
    ["telescope.nvim"] = {"defaults"},
    ["nvim-cmp"] = {"sources"},
    ["mason.nvim"] = {},
    ["lspconfig"] = {}
  }
  
  local required = required_fields[plugin_name] or {}
  for _, field in ipairs(required) do
    if not config or not config[field] then
      table.insert(issues, string.format("Missing required field: %s", field))
    end
  end
  
  -- Plugin-specific validation
  if plugin_name == "telescope.nvim" and config then
    if config.defaults and config.defaults.mappings then
      -- Check for common telescope mapping issues
      local mappings = config.defaults.mappings
      if mappings.i and mappings.i["<C-j>"] then
        -- This might conflict with other plugins
        table.insert(issues, "Telescope mapping <C-j> might conflict with other plugins")
      end
    end
  end
  
  return #issues == 0, issues
end

-- Comprehensive plugin validation
function M.validate_plugin(plugin_name, config)
  local result = {
    plugin = plugin_name,
    valid = true,
    issues = {},
    warnings = {},
    recommendations = {}
  }
  
  -- Check Neovim version compatibility
  if not M.check_nvim_version(plugin_name) then
    result.valid = false
    table.insert(result.issues, "Incompatible with current Neovim version")
  end
  
  -- Check dependencies
  local deps_ok, missing_deps = M.check_dependencies(plugin_name)
  if not deps_ok then
    result.valid = false
    table.insert(result.issues, string.format("Missing dependencies: %s", table.concat(missing_deps, ", ")))
  end
  
  -- Check conflicts
  local conflicts_ok, conflicts = M.check_conflicts(plugin_name)
  if not conflicts_ok then
    table.insert(result.warnings, string.format("Potential conflicts: %s", table.concat(conflicts, ", ")))
  end
  
  -- Validate configuration
  local config_ok, config_issues = M.validate_plugin_config(plugin_name, config)
  if not config_ok then
    result.valid = false
    for _, issue in ipairs(config_issues) do
      table.insert(result.issues, issue)
    end
  end
  
  -- Performance recommendations
  if plugin_name == "telescope.nvim" then
    table.insert(result.recommendations, "Consider lazy-loading telescope for better startup performance")
  elseif plugin_name == "nvim-treesitter" then
    table.insert(result.recommendations, "Ensure only necessary parsers are installed")
  end
  
  validation_results[plugin_name] = result
  return result
end

-- Validate all loaded plugins
function M.validate_all_plugins()
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then
    return {valid = false, issues = {"lazy.nvim not available"}}
  end
  
  local plugins_ok, plugins = pcall(lazy.get_plugins)
  if not plugins_ok then
    return {valid = false, issues = {"Failed to get plugin list"}}
  end
  
  local overall_result = {
    valid = true,
    plugins_validated = 0,
    issues = {},
    warnings = {},
    recommendations = {}
  }
  
  for _, plugin in ipairs(plugins) do
    if plugin.name then
      local result = M.validate_plugin(plugin.name, plugin.config)
      overall_result.plugins_validated = overall_result.plugins_validated + 1
      
      if not result.valid then
        overall_result.valid = false
        for _, issue in ipairs(result.issues) do
          table.insert(overall_result.issues, string.format("%s: %s", plugin.name, issue))
        end
      end
      
      for _, warning in ipairs(result.warnings) do
        table.insert(overall_result.warnings, string.format("%s: %s", plugin.name, warning))
      end
      
      for _, rec in ipairs(result.recommendations) do
        table.insert(overall_result.recommendations, string.format("%s: %s", plugin.name, rec))
      end
    end
  end
  
  return overall_result
end

-- Generate validation report
function M.generate_report()
  local report = M.validate_all_plugins()
  
  vim.health.start("Plugin Validation")
  
  if report.valid then
    vim.health.ok(string.format("All %d plugins validated successfully", report.plugins_validated))
  else
    vim.health.error(string.format("Found issues with %d plugins", #report.issues))
    for _, issue in ipairs(report.issues) do
      vim.health.error(issue)
    end
  end
  
  if #report.warnings > 0 then
    vim.health.warn(string.format("Found %d warnings", #report.warnings))
    for _, warning in ipairs(report.warnings) do
      vim.health.warn(warning)
    end
  end
  
  if #report.recommendations > 0 then
    vim.health.info(string.format("Found %d recommendations", #report.recommendations))
    for _, rec in ipairs(report.recommendations) do
      vim.health.info(rec)
    end
  end
end

-- Check for common plugin issues
function M.check_common_issues()
  local issues = {}
  
  -- Check for duplicate plugins
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local plugins_ok, plugins = pcall(lazy.get_plugins)
    if plugins_ok then
      local plugin_names = {}
      for _, plugin in ipairs(plugins) do
        if plugin.name then
          if plugin_names[plugin.name] then
            table.insert(issues, string.format("Duplicate plugin: %s", plugin.name))
          else
            plugin_names[plugin.name] = true
          end
        end
      end
    end
  end
  
  -- Check for missing essential plugins
  local essential_plugins = {"lazy", "mason", "lspconfig"}
  for _, plugin in ipairs(essential_plugins) do
    local ok, _ = pcall(require, plugin)
    if not ok then
      table.insert(issues, string.format("Missing essential plugin: %s", plugin))
    end
  end
  
  return issues
end

-- Register validation commands
vim.api.nvim_create_user_command("YodaValidatePlugins", function()
  M.generate_report()
end, { desc = "Validate all Yoda.nvim plugins" })

vim.api.nvim_create_user_command("YodaPluginIssues", function()
  local issues = M.check_common_issues()
  if #issues == 0 then
    vim.notify("No common plugin issues found", vim.log.levels.INFO)
  else
    vim.notify(string.format("Found %d issues: %s", #issues, table.concat(issues, ", ")), 
      vim.log.levels.WARN)
  end
end, { desc = "Check for common plugin issues" })

return M 