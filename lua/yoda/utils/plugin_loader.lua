-- lua/yoda/utils/plugin_loader.lua
-- Robust plugin loading utility for Yoda.nvim

local M = {}

---
-- Safely loads and configures a plugin
-- @param plugin_name string The name of the plugin module
-- @param opts table Plugin options
-- @param fallback_opts table Fallback options if plugin fails to load
-- @return boolean Success status
function M.safe_plugin_setup(plugin_name, opts, fallback_opts)
  local ok, plugin = pcall(require, plugin_name)
  
  if not ok then
    vim.notify(string.format("Plugin '%s' not found or failed to load: %s", plugin_name, tostring(plugin)), vim.log.levels.WARN)
    return false
  end
  
  if not plugin or not plugin.setup then
    vim.notify(string.format("Plugin '%s' loaded but missing setup function", plugin_name), vim.log.levels.WARN)
    return false
  end
  
  -- Use fallback options if provided and plugin failed to load
  local final_opts = opts
  if fallback_opts and not ok then
    final_opts = fallback_opts
  end
  
  local setup_ok, setup_result = pcall(plugin.setup, final_opts)
  if not setup_ok then
    vim.notify(string.format("Failed to setup plugin '%s': %s", plugin_name, tostring(setup_result)), vim.log.levels.ERROR)
    return false
  end
  
  return true
end

---
-- Creates a safe config function for a plugin
-- @param plugin_name string The name of the plugin module
-- @param fallback_opts table Optional fallback options
-- @return function Config function
function M.create_safe_config(plugin_name, fallback_opts)
  return function(_, opts)
    M.safe_plugin_setup(plugin_name, opts, fallback_opts)
  end
end

---
-- Checks if a plugin is available
-- @param plugin_name string The name of the plugin module
-- @return boolean Available status
function M.is_plugin_available(plugin_name)
  local ok, plugin = pcall(require, plugin_name)
  return ok and plugin and plugin.setup ~= nil
end

---
-- Lists all available plugins
-- @param plugin_list table List of plugin names to check
-- @return table Available plugins
function M.get_available_plugins(plugin_list)
  local available = {}
  local unavailable = {}
  
  for _, plugin_name in ipairs(plugin_list) do
    if M.is_plugin_available(plugin_name) then
      table.insert(available, plugin_name)
    else
      table.insert(unavailable, plugin_name)
    end
  end
  
  return available, unavailable
end

---
-- Validates plugin dependencies
-- @param dependencies table List of dependency plugin names
-- @return table Missing dependencies
function M.validate_dependencies(dependencies)
  local missing = {}
  
  for _, dep in ipairs(dependencies) do
    if not M.is_plugin_available(dep) then
      table.insert(missing, dep)
    end
  end
  
  return missing
end

-- User commands for plugin management
vim.api.nvim_create_user_command("YodaCheckPlugins", function()
  local plugin_list = {
    "snacks",
    "noice",
    "showkeys",
    "gitsigns",
    "render-markdown",
    "obsidian",
    "lazydev",
    "telescope",
    "treesitter",
    "lspconfig",
    "mason",
    "cmp",
    "copilot",
    "neotest",
    "neogit",
  }
  
  local available, unavailable = M.get_available_plugins(plugin_list)
  
  print("=== Plugin Availability Check ===")
  print("Available plugins:")
  for _, plugin in ipairs(available) do
    print("  ✅ " .. plugin)
  end
  
  if #unavailable > 0 then
    print("\nUnavailable plugins:")
    for _, plugin in ipairs(unavailable) do
      print("  ❌ " .. plugin)
    end
  end
  
  print(string.format("\nTotal: %d available, %d unavailable", #available, #unavailable))
end, {})

vim.api.nvim_create_user_command("YodaPluginInfo", function()
  local plugin_name = vim.fn.input("Enter plugin name: ")
  if plugin_name == "" then
    return
  end
  
  local ok, plugin = pcall(require, plugin_name)
  if ok and plugin then
    print(string.format("=== Plugin Info: %s ===", plugin_name))
    print("Module loaded: ✅")
    print("Setup function: " .. (plugin.setup and "✅" or "❌"))
    
    -- Try to get version info
    if plugin._VERSION then
      print("Version: " .. plugin._VERSION)
    end
    
    -- List available functions
    local functions = {}
    for key, value in pairs(plugin) do
      if type(value) == "function" then
        table.insert(functions, key)
      end
    end
    
    if #functions > 0 then
      print("Available functions: " .. table.concat(functions, ", "))
    end
  else
    print(string.format("❌ Plugin '%s' not available: %s", plugin_name, tostring(plugin)))
  end
end, {})

return M 