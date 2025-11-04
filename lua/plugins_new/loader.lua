-- lua/plugins/init.lua
-- Modular plugin loader with safety features

local M = {}

-- Track loading errors for diagnostics
M.errors = {}

-- Safely load a plugin module
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    local error_msg = string.format("Failed to load plugin module '%s': %s", module, result)
    table.insert(M.errors, error_msg)
    vim.notify(error_msg, vim.log.levels.ERROR)
    return {}
  end

  if type(result) ~= "table" then
    local error_msg = string.format("Plugin module '%s' did not return a table", module)
    table.insert(M.errors, error_msg)
    vim.notify(error_msg, vim.log.levels.ERROR)
    return {}
  end

  return result
end

-- Plugin modules (add to this list as we migrate)
local modules = {
  "plugins_new.core",
  "plugins_new.motion",
  "plugins_new.ai",
  "plugins_new.explorer",
  -- More will be added incrementally
  -- Note: motion plugins (leap, vim-tmux-navigator) migrated
  -- Note: ai plugins (copilot, opencode) migrated
  -- Note: explorer plugins (snacks, nvim-tree, devicons) migrated
}

-- Load all plugin modules
function M.load()
  local all_plugins = {}
  local plugin_names = {}

  for _, module in ipairs(modules) do
    local plugins = safe_require(module)

    -- Check for duplicates within new structure
    for _, plugin in ipairs(plugins) do
      local name = type(plugin) == "string" and plugin or plugin[1]
      if plugin_names[name] then
        vim.notify(string.format("Duplicate plugin '%s' in module '%s'", name, module), vim.log.levels.WARN)
      else
        plugin_names[name] = module
        table.insert(all_plugins, plugin)
      end
    end
  end

  return all_plugins
end

-- Diagnostics function
function M.diagnostics()
  return {
    errors = M.errors,
    modules_loaded = #modules,
  }
end

return M
