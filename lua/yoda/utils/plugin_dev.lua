-- lua/yoda/utils/plugin_dev.lua
-- Utility for local/remote plugin development in Yoda.nvim

local M = {}

local config_path = vim.fn.stdpath("config") .. "/plugin_dev.lua"
local plugin_dev_config = nil

-- Attempt to load the plugin_dev.lua config file
local function load_config()
  if plugin_dev_config ~= nil then
    return plugin_dev_config
  end
  local ok, config = pcall(dofile, config_path)
  if ok and type(config) == "table" then
    plugin_dev_config = config
    return config
  else
    plugin_dev_config = {}
    return plugin_dev_config
  end
end

---
--- Returns a plugin spec for local or remote development.
-- @param name (string) The plugin key (e.g., 'pytest', 'go_task')
-- @param remote_spec (string|table) The remote plugin spec (e.g., 'jedi-knights/pytest.nvim')
-- @param opts (table) Additional plugin options (optional)
-- @return table Plugin spec for Lazy.nvim
function M.local_or_remote_plugin(name, remote_spec, opts)
  opts = opts or {}
  local config = load_config()
  local local_path = config[name]
  local spec = vim.deepcopy(opts)
  
  if local_path and type(local_path) == "string" and #local_path > 0 then
    -- Use local path for development
    local expanded_path = vim.fn.expand(local_path)
    
    -- Check if the local path exists
    if vim.fn.isdirectory(expanded_path) == 1 then
      spec.dir = expanded_path
      
      -- Disable all documentation generation for local plugins to prevent Lazy.nvim issues
      spec.disable_docs = true
      spec.readme = false
      spec.doc = false
      spec.docs = false
      
      -- Add development-specific options
      spec.dev = true
      spec.pin = false
      
      -- Set the plugin name for proper identification
      if type(remote_spec) == "string" then
        spec.name = remote_spec
      elseif type(remote_spec) == "table" then
        for k, v in pairs(remote_spec) do
          spec[k] = v
        end
      end
      
      -- Log local plugin loading for debugging
      vim.schedule(function()
        vim.notify(string.format("Loading %s from local path: %s", name, expanded_path), vim.log.levels.INFO, {
          title = "Plugin Dev",
          timeout = 2000
        })
      end)
    else
      -- Local path doesn't exist, fall back to remote
      vim.schedule(function()
        vim.notify(string.format("Local path for %s not found: %s. Falling back to remote.", name, expanded_path), vim.log.levels.WARN, {
          title = "Plugin Dev",
          timeout = 3000
        })
      end)
      
      -- Use remote spec
      if type(remote_spec) == "string" then
        table.insert(spec, 1, remote_spec)
      elseif type(remote_spec) == "table" then
        for k, v in pairs(remote_spec) do
          spec[k] = v
        end
      end
    end
  else
    -- Use remote spec
    if type(remote_spec) == "string" then
      table.insert(spec, 1, remote_spec)
    elseif type(remote_spec) == "table" then
      for k, v in pairs(remote_spec) do
        spec[k] = v
      end
    end
  end
  
  return spec
end

---
-- Checks which plugins are being loaded from local paths via plugin_dev
function M.check_plugin_dev_status()
  local config = load_config()
  local results = {}
  for name, path in pairs(config) do
    local expanded_path = vim.fn.expand(path)
    local exists = vim.fn.isdirectory(expanded_path) == 1
    table.insert(results, string.format("%s: %s%s", name, expanded_path, exists and " (found)" or " (not found)"))
  end
  if #results == 0 then
    print("[plugin_dev] No local plugins configured.")
  else
    print("[plugin_dev] Local plugin paths:")
    for _, line in ipairs(results) do
      print("  " .. line)
    end
  end
end

---
-- Debug function to show generated plugin specs
function M.debug_plugin_specs()
  local config = load_config()
  print("[plugin_dev] Generated plugin specs:")
  
  -- Test go_task
  local go_task_spec = M.local_or_remote_plugin("go_task", "jedi-knights/go-task.nvim", { lazy = false })
  print("  go_task:", vim.inspect(go_task_spec))
  
  -- Test invoke
  local invoke_spec = M.local_or_remote_plugin("invoke", "jedi-knights/invoke.nvim", { lazy = false })
  print("  invoke:", vim.inspect(invoke_spec))
  
  -- Test pytest
  local pytest_spec = M.local_or_remote_plugin("pytest", "jedi-knights/pytest.nvim", {})
  print("  pytest:", vim.inspect(pytest_spec))
end

---
-- Clean up Lazy.nvim documentation cache for local plugins
function M.cleanup_docs_cache()
  local config = load_config()
  local lazy_state = vim.fn.stdpath("state") .. "/lazy"
  local readme_dir = lazy_state .. "/readme"
  
  -- Remove readme directory if it exists
  if vim.fn.isdirectory(readme_dir) == 1 then
    vim.fn.delete(readme_dir, "rf")
    vim.notify("Cleaned up Lazy.nvim documentation cache", vim.log.levels.INFO, {
      title = "Plugin Dev",
      timeout = 2000
    })
  end
end

---
-- Reload plugins with proper cleanup
function M.reload_plugins()
  -- Clean up documentation cache first
  M.cleanup_docs_cache()
  
  -- Reload Lazy.nvim
  require("lazy").reload()
  
  vim.notify("Plugins reloaded successfully", vim.log.levels.INFO, {
    title = "Plugin Dev",
    timeout = 2000
  })
end

vim.api.nvim_create_user_command("PluginDevStatus", function()
  require("yoda.utils.plugin_dev").check_plugin_dev_status()
end, {})

vim.api.nvim_create_user_command("PluginDevDebug", function()
  require("yoda.utils.plugin_dev").debug_plugin_specs()
end, {})

vim.api.nvim_create_user_command("PluginDevCleanup", function()
  require("yoda.utils.plugin_dev").cleanup_docs_cache()
end, {})

vim.api.nvim_create_user_command("PluginDevReload", function()
  require("yoda.utils.plugin_dev").reload_plugins()
end, {})

return M 