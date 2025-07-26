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
    spec.dir = vim.fn.expand(local_path)
    if type(remote_spec) == "string" then
      spec.name = remote_spec
    elseif type(remote_spec) == "table" then
      for k, v in pairs(remote_spec) do
        spec[k] = v
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
    local exists = vim.fn.isdirectory(vim.fn.expand(path)) == 1
    table.insert(results, string.format("%s: %s%s", name, path, exists and " (found)" or " (not found)"))
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

vim.api.nvim_create_user_command("PluginDevStatus", function()
  require("yoda.utils.plugin_dev").check_plugin_dev_status()
end, {})

vim.api.nvim_create_user_command("PluginDevDebug", function()
  require("yoda.utils.plugin_dev").debug_plugin_specs()
end, {})

return M 