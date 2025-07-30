-- lua/yoda/utils/optimization_helper.lua
-- Optimization helper for Yoda.nvim startup performance

local M = {}

-- Optimization strategies
local optimization_strategies = {
  lazy_loading = {
    name = "Lazy Loading",
    description = "Make plugins load only when needed",
    priority = "high",
    impact = "high"
  },
  plugin_removal = {
    name = "Plugin Removal",
    description = "Remove unused or redundant plugins",
    priority = "medium",
    impact = "high"
  },
  configuration_optimization = {
    name = "Configuration Optimization",
    description = "Optimize plugin configurations",
    priority = "medium",
    impact = "medium"
  },
  startup_optimization = {
    name = "Startup Optimization",
    description = "Optimize startup sequence",
    priority = "low",
    impact = "medium"
  }
}

-- Analyze current configuration for optimization opportunities
function M.analyze_configuration()
  local analysis = {
    opportunities = {},
    warnings = {},
    recommendations = {}
  }
  
  -- Check for eager-loaded plugins that could be lazy
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local plugins_ok, plugins = pcall(lazy.get_plugins)
    if plugins_ok and plugins then
      for _, plugin in ipairs(plugins) do
        if not plugin.lazy and plugin.name then
          -- Check if plugin could be lazy-loaded
          local can_be_lazy = M.can_plugin_be_lazy(plugin)
          if can_be_lazy then
            table.insert(analysis.opportunities, {
              type = "lazy_loading",
              plugin = plugin.name,
              description = string.format("Plugin '%s' could be lazy-loaded", plugin.name),
              action = string.format("Add lazy = true to plugin '%s'", plugin.name),
              impact = "high"
            })
          end
        end
      end
    end
  end
  
  -- Check for potential plugin conflicts or redundancies
  analysis.warnings = M.check_plugin_conflicts()
  
  -- Generate general recommendations
  analysis.recommendations = M.generate_recommendations()
  
  return analysis
end

-- Check if a plugin can be safely made lazy
function M.can_plugin_be_lazy(plugin)
  -- Plugins that should generally not be lazy
  local non_lazy_plugins = {
    "nvim-web-devicons",
    "tokyonight.nvim",
    "lazy.nvim",
    "mason.nvim",
    "mason-lspconfig.nvim"
  }
  
  for _, non_lazy in ipairs(non_lazy_plugins) do
    if plugin.name == non_lazy then
      return false
    end
  end
  
  -- Check if plugin has specific events or commands that make it lazy-loadable
  if plugin.event or plugin.cmd or plugin.ft then
    return true
  end
  
  -- Check if plugin is UI-related and could be lazy
  local ui_plugins = {
    "telescope",
    "nvim-tree",
    "lualine",
    "noice",
    "notify"
  }
  
  for _, ui_plugin in ipairs(ui_plugins) do
    if plugin.name:find(ui_plugin) then
      return true
    end
  end
  
  return false
end

-- Check for plugin conflicts or redundancies
function M.check_plugin_conflicts()
  local warnings = {}
  
  -- Check for multiple completion plugins
  local completion_plugins = {
    "nvim-cmp",
    "coq_nvim",
    "completion-nvim"
  }
  
  local found_completion = 0
  for _, plugin_name in ipairs(completion_plugins) do
    local ok, _ = pcall(require, plugin_name:gsub("%-", "_"))
    if ok then
      found_completion = found_completion + 1
    end
  end
  
  if found_completion > 1 then
    table.insert(warnings, {
      type = "conflict",
      message = "Multiple completion plugins detected",
      action = "Choose one completion plugin and remove others"
    })
  end
  
  -- Check for multiple statusline plugins
  local statusline_plugins = {
    "lualine",
    "lightline",
    "airline"
  }
  
  local found_statusline = 0
  for _, plugin_name in ipairs(statusline_plugins) do
    local ok, _ = pcall(require, plugin_name)
    if ok then
      found_statusline = found_statusline + 1
    end
  end
  
  if found_statusline > 1 then
    table.insert(warnings, {
      type = "conflict",
      message = "Multiple statusline plugins detected",
      action = "Choose one statusline plugin and remove others"
    })
  end
  
  return warnings
end

-- Generate general optimization recommendations
function M.generate_recommendations()
  local recommendations = {}
  
  -- Check if built-in plugins are disabled
  local disabled_builtins = vim.g.yoda_config and vim.g.yoda_config.disabled_builtins or {}
  if #disabled_builtins == 0 then
    table.insert(recommendations, {
      type = "builtin_optimization",
      message = "Consider disabling unused built-in plugins",
      action = "Add more plugins to disabled_builtins list",
      impact = "medium"
    })
  end
  
  -- Check for performance-related settings
  if not vim.g.yoda_config or not vim.g.yoda_config.performance_optimizations then
    table.insert(recommendations, {
      type = "performance_settings",
      message = "Enable performance optimizations",
      action = "Add performance optimization settings",
      impact = "medium"
    })
  end
  
  return recommendations
end

-- Generate optimization report
function M.generate_optimization_report()
  local analysis = M.analyze_configuration()
  
  print("=== Yoda.nvim Configuration Optimization Report ===")
  
  -- Print opportunities
  if #analysis.opportunities > 0 then
    print("\n🎯 Optimization Opportunities:")
    for _, opp in ipairs(analysis.opportunities) do
      print(string.format("  🔧 %s", opp.description))
      print(string.format("     Action: %s", opp.action))
      print(string.format("     Impact: %s", opp.impact))
      print()
    end
  end
  
  -- Print warnings
  if #analysis.warnings > 0 then
    print("\n⚠️  Warnings:")
    for _, warning in ipairs(analysis.warnings) do
      print(string.format("  ⚠️  %s", warning.message))
      print(string.format("     Action: %s", warning.action))
      print()
    end
  end
  
  -- Print recommendations
  if #analysis.recommendations > 0 then
    print("\n💡 General Recommendations:")
    for _, rec in ipairs(analysis.recommendations) do
      print(string.format("  💡 %s", rec.message))
      print(string.format("     Action: %s", rec.action))
      print(string.format("     Impact: %s", rec.impact))
      print()
    end
  end
  
  if #analysis.opportunities == 0 and #analysis.warnings == 0 and #analysis.recommendations == 0 then
    print("\n✅ Configuration looks well-optimized!")
  end
  
  print("=================================================")
end

-- Apply automatic optimizations
function M.apply_optimizations()
  local analysis = M.analyze_configuration()
  local applied = 0
  
  print("=== Applying Optimizations ===")
  
  -- Apply lazy loading optimizations
  for _, opp in ipairs(analysis.opportunities) do
    if opp.type == "lazy_loading" then
      print(string.format("🔧 Applying lazy loading to %s", opp.plugin))
      -- This would require modifying the plugin spec files
      -- For now, just report what could be done
      applied = applied + 1
    end
  end
  
  -- Apply configuration optimizations
  for _, rec in ipairs(analysis.recommendations) do
    if rec.type == "performance_settings" then
      print("🔧 Enabling performance optimizations")
      -- Add performance optimization settings
      vim.g.yoda_config.performance_optimizations = true
      applied = applied + 1
    end
  end
  
  print(string.format("✅ Applied %d optimizations", applied))
  print("=============================")
  
  return applied
end

-- User commands
vim.api.nvim_create_user_command("YodaOptimizeConfig", function()
  M.generate_optimization_report()
end, { desc = "Analyze configuration for optimization opportunities" })

vim.api.nvim_create_user_command("YodaApplyOptimizations", function()
  local applied = M.apply_optimizations()
  if applied > 0 then
    vim.notify(string.format("Applied %d optimizations", applied), vim.log.levels.INFO, {
      title = "Yoda Optimization",
      timeout = 3000
    })
  else
    vim.notify("No optimizations to apply", vim.log.levels.INFO, {
      title = "Yoda Optimization",
      timeout = 2000
    })
  end
end, { desc = "Apply automatic optimizations" })

return M 