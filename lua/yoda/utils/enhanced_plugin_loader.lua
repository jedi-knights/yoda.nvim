-- lua/yoda/utils/enhanced_plugin_loader.lua
-- Enhanced plugin loader with comprehensive error recovery

local M = {}

-- Import error recovery system
local error_recovery = require("yoda.utils.error_recovery")

-- Plugin loading states
local PLUGIN_STATES = {
  LOADING = "loading",
  LOADED = "loaded",
  FAILED = "failed",
  DISABLED = "disabled",
  FALLBACK = "fallback"
}

-- Plugin loading data
local plugin_loading_data = {
  plugins = {},
  dependencies = {},
  conflicts = {},
  fallbacks = {},
  load_order = {}
}

-- Plugin fallback mappings
local PLUGIN_FALLBACKS = {
  -- Telescope alternatives
  ["telescope.nvim"] = {
    fallback = "fzf-lua",
    reason = "Faster alternative to telescope"
  },
  -- LSP alternatives
  ["nvim-lspconfig"] = {
    fallback = "lsp-zero",
    reason = "Simplified LSP setup"
  },
  -- Completion alternatives
  ["nvim-cmp"] = {
    fallback = "coq_nvim",
    reason = "Alternative completion engine"
  }
}

-- Enhanced plugin loading with error recovery
function M.load_plugin_safely(plugin_name, config_func, options)
  options = options or {}
  local fallback_plugin = options.fallback_plugin
  local max_retries = options.max_retries or 3
  local disable_on_failure = options.disable_on_failure or false
  
  -- Set context for error tracking
  error_recovery.set_context("enhanced_plugin_loader", "load_plugin", plugin_name)
  
  -- Check if plugin is already loaded
  if plugin_loading_data.plugins[plugin_name] then
    local state = plugin_loading_data.plugins[plugin_name].state
    if state == PLUGIN_STATES.LOADED then
      return true
    elseif state == PLUGIN_STATES.DISABLED then
      return false
    end
  end
  
  -- Initialize plugin entry
  plugin_loading_data.plugins[plugin_name] = {
    state = PLUGIN_STATES.LOADING,
    load_time = 0,
    error_count = 0,
    last_error = nil,
    fallback_used = false
  }
  
  -- Try to load the plugin
  local start_time = vim.loop.hrtime()
  local success = error_recovery.safe_execute(function()
    local plugin = require(plugin_name)
    
    -- Configure plugin if config function provided
    if config_func and plugin then
      config_func(plugin)
    end
    
    return plugin ~= nil
  end, string.format("load_%s", plugin_name), max_retries)
  
  local load_time = (vim.loop.hrtime() - start_time) / 1000000
  
  if success then
    -- Plugin loaded successfully
    plugin_loading_data.plugins[plugin_name].state = PLUGIN_STATES.LOADED
    plugin_loading_data.plugins[plugin_name].load_time = load_time
    
    error_recovery.clear_context()
    return true
  else
    -- Plugin failed to load
    plugin_loading_data.plugins[plugin_name].state = PLUGIN_STATES.FAILED
    plugin_loading_data.plugins[plugin_name].error_count = plugin_loading_data.plugins[plugin_name].error_count + 1
    
    -- Try fallback plugin
    if fallback_plugin or PLUGIN_FALLBACKS[plugin_name] then
      local fallback = fallback_plugin or PLUGIN_FALLBACKS[plugin_name].fallback
      local fallback_reason = PLUGIN_FALLBACKS[plugin_name] and PLUGIN_FALLBACKS[plugin_name].reason or "User-specified fallback"
      
      error_recovery.log_error(
        string.format("Plugin '%s' failed to load, trying fallback '%s'", plugin_name, fallback),
        "warning",
        "fallback"
      )
      
      -- Try fallback plugin
      local fallback_success = M.load_plugin_safely(fallback, options.fallback_config, {
        max_retries = 1,
        disable_on_failure = true
      })
      
      if fallback_success then
        plugin_loading_data.plugins[plugin_name].state = PLUGIN_STATES.FALLBACK
        plugin_loading_data.plugins[plugin_name].fallback_used = true
        plugin_loading_data.fallbacks[plugin_name] = fallback
        
        error_recovery.log_error(
          string.format("Using fallback plugin '%s' for '%s'", fallback, plugin_name),
          "info",
          "fallback"
        )
        
        error_recovery.clear_context()
        return true
      end
    end
    
    -- All attempts failed
    if disable_on_failure then
      plugin_loading_data.plugins[plugin_name].state = PLUGIN_STATES.DISABLED
      error_recovery.log_error(
        string.format("Plugin '%s' disabled due to repeated failures", plugin_name),
        "warning",
        "disable"
      )
    end
    
    error_recovery.clear_context()
    return false
  end
end

-- Load plugin with dependency checking
function M.load_plugin_with_dependencies(plugin_name, config_func, dependencies, options)
  options = options or {}
  
  -- Check dependencies first
  for _, dep in ipairs(dependencies or {}) do
    local dep_ok = M.load_plugin_safely(dep, nil, {
      max_retries = 1,
      disable_on_failure = false
    })
    
    if not dep_ok then
      error_recovery.log_error(
        string.format("Dependency '%s' for plugin '%s' failed to load", dep, plugin_name),
        "error",
        "disable"
      )
      
      if options.require_dependencies then
        return false
      end
    end
  end
  
  -- Load the main plugin
  return M.load_plugin_safely(plugin_name, config_func, options)
end

-- Batch plugin loading with error recovery
function M.load_plugins_batch(plugin_specs)
  local results = {
    successful = {},
    failed = {},
    fallbacks = {},
    total_time = 0
  }
  
  local start_time = vim.loop.hrtime()
  
  for _, spec in ipairs(plugin_specs) do
    local plugin_name = spec.name
    local config_func = spec.config
    local dependencies = spec.dependencies
    local options = spec.options or {}
    
    local success = M.load_plugin_with_dependencies(plugin_name, config_func, dependencies, options)
    
    if success then
      local plugin_data = plugin_loading_data.plugins[plugin_name]
      if plugin_data.state == PLUGIN_STATES.FALLBACK then
        table.insert(results.fallbacks, {
          name = plugin_name,
          fallback = plugin_data.fallback_used and plugin_loading_data.fallbacks[plugin_name] or nil
        })
      else
        table.insert(results.successful, plugin_name)
      end
    else
      table.insert(results.failed, plugin_name)
    end
  end
  
  results.total_time = (vim.loop.hrtime() - start_time) / 1000000
  
  return results
end

-- Plugin conflict detection and resolution
function M.detect_plugin_conflicts()
  local conflicts = {}
  
  -- Check for common plugin conflicts
  local conflict_groups = {
    completion = {"nvim-cmp", "coq_nvim", "completion-nvim"},
    statusline = {"lualine", "lightline", "airline"},
    file_explorer = {"nvim-tree", "nerdtree", "netrw"},
    fuzzy_finder = {"telescope", "fzf", "fzf-lua"}
  }
  
  for group_name, plugins in pairs(conflict_groups) do
    local loaded_plugins = {}
    
    for _, plugin in ipairs(plugins) do
      if plugin_loading_data.plugins[plugin] and 
         plugin_loading_data.plugins[plugin].state == PLUGIN_STATES.LOADED then
        table.insert(loaded_plugins, plugin)
      end
    end
    
    if #loaded_plugins > 1 then
      table.insert(conflicts, {
        group = group_name,
        plugins = loaded_plugins,
        severity = "warning"
      })
    end
  end
  
  return conflicts
end

-- Plugin health check
function M.check_plugin_health()
  local health_report = {
    total_plugins = 0,
    loaded_plugins = 0,
    failed_plugins = 0,
    disabled_plugins = 0,
    fallback_plugins = 0,
    conflicts = {},
    recommendations = {}
  }
  
  for plugin_name, plugin_data in pairs(plugin_loading_data.plugins) do
    health_report.total_plugins = health_report.total_plugins + 1
    
    if plugin_data.state == PLUGIN_STATES.LOADED then
      health_report.loaded_plugins = health_report.loaded_plugins + 1
    elseif plugin_data.state == PLUGIN_STATES.FAILED then
      health_report.failed_plugins = health_report.failed_plugins + 1
    elseif plugin_data.state == PLUGIN_STATES.DISABLED then
      health_report.disabled_plugins = health_report.disabled_plugins + 1
    elseif plugin_data.state == PLUGIN_STATES.FALLBACK then
      health_report.fallback_plugins = health_report.fallback_plugins + 1
    end
  end
  
  -- Detect conflicts
  health_report.conflicts = M.detect_plugin_conflicts()
  
  -- Generate recommendations
  if health_report.failed_plugins > 0 then
    table.insert(health_report.recommendations, "Some plugins failed to load - check error report")
  end
  
  if #health_report.conflicts > 0 then
    table.insert(health_report.recommendations, "Plugin conflicts detected - consider removing duplicates")
  end
  
  if health_report.fallback_plugins > 0 then
    table.insert(health_report.recommendations, "Some plugins are using fallbacks - check if primary plugins are available")
  end
  
  return health_report
end

-- Print plugin health report
function M.print_plugin_health_report()
  local health = M.check_plugin_health()
  
  print("=== Yoda.nvim Plugin Health Report ===")
  print(string.format("Total Plugins: %d", health.total_plugins))
  print(string.format("Loaded: %d", health.loaded_plugins))
  print(string.format("Failed: %d", health.failed_plugins))
  print(string.format("Disabled: %d", health.disabled_plugins))
  print(string.format("Using Fallbacks: %d", health.fallback_plugins))
  
  if #health.conflicts > 0 then
    print("\n⚠️  Plugin Conflicts:")
    for _, conflict in ipairs(health.conflicts) do
      print(string.format("  %s: %s", conflict.group, table.concat(conflict.plugins, ", ")))
    end
  end
  
  if #health.recommendations > 0 then
    print("\n💡 Recommendations:")
    for _, rec in ipairs(health.recommendations) do
      print(string.format("  💡 %s", rec))
    end
  end
  
  print("=====================================")
end

-- Plugin recovery functions
function M.recover_failed_plugins()
  local recovered = 0
  
  for plugin_name, plugin_data in pairs(plugin_loading_data.plugins) do
    if plugin_data.state == PLUGIN_STATES.FAILED then
      -- Reset plugin state
      plugin_data.state = PLUGIN_STATES.LOADING
      plugin_data.error_count = 0
      plugin_data.last_error = nil
      
      -- Try to reload
      local success = M.load_plugin_safely(plugin_name, nil, {
        max_retries = 2,
        disable_on_failure = true
      })
      
      if success then
        recovered = recovered + 1
      end
    end
  end
  
  return recovered
end

-- Get plugin loading statistics
function M.get_plugin_stats()
  local stats = {
    total = 0,
    loaded = 0,
    failed = 0,
    disabled = 0,
    fallback = 0,
    avg_load_time = 0
  }
  
  local total_load_time = 0
  local loaded_count = 0
  
  for _, plugin_data in pairs(plugin_loading_data.plugins) do
    stats.total = stats.total + 1
    
    if plugin_data.state == PLUGIN_STATES.LOADED then
      stats.loaded = stats.loaded + 1
      total_load_time = total_load_time + plugin_data.load_time
      loaded_count = loaded_count + 1
    elseif plugin_data.state == PLUGIN_STATES.FAILED then
      stats.failed = stats.failed + 1
    elseif plugin_data.state == PLUGIN_STATES.DISABLED then
      stats.disabled = stats.disabled + 1
    elseif plugin_data.state == PLUGIN_STATES.FALLBACK then
      stats.fallback = stats.fallback + 1
    end
  end
  
  if loaded_count > 0 then
    stats.avg_load_time = total_load_time / loaded_count
  end
  
  return stats
end

-- User commands
vim.api.nvim_create_user_command("YodaPluginHealth", function()
  M.print_plugin_health_report()
end, { desc = "Show plugin health report" })

vim.api.nvim_create_user_command("YodaRecoverPlugins", function()
  local recovered = M.recover_failed_plugins()
  vim.notify(string.format("Recovered %d plugins", recovered), vim.log.levels.INFO, {
    title = "Yoda Plugin Recovery",
    timeout = 3000
  })
end, { desc = "Attempt to recover failed plugins" })

vim.api.nvim_create_user_command("YodaPluginStats", function()
  local stats = M.get_plugin_stats()
  print("=== Yoda.nvim Plugin Statistics ===")
  print(string.format("Total Plugins: %d", stats.total))
  print(string.format("Successfully Loaded: %d", stats.loaded))
  print(string.format("Failed: %d", stats.failed))
  print(string.format("Disabled: %d", stats.disabled))
  print(string.format("Using Fallbacks: %d", stats.fallback))
  print(string.format("Average Load Time: %.2f ms", stats.avg_load_time))
  print("===================================")
end, { desc = "Show plugin loading statistics" })

return M 