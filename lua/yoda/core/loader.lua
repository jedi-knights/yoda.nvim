-- lua/yoda/core/loader.lua
-- Core module loader - eliminates coupling through lazy loading
-- Perfect loose coupling through dependency-free module access

local M = {}

-- Module cache to prevent multiple loads
local _cache = {}

-- Core module registry with interface validation
local CORE_MODULES = {
  filesystem = {
    path = "yoda.core.filesystem",
    interface = "yoda.interfaces.filesystem",
  },
  json = {
    path = "yoda.core.json",
    interface = "yoda.interfaces.json",
  },
  temp = {
    path = "yoda.core.temp",
    interface = nil, -- No interface yet
  },
  string = {
    path = "yoda.core.string",
    interface = nil, -- No interface yet
  },
  table = {
    path = "yoda.core.table",
    interface = nil, -- No interface yet
  },
  platform = {
    path = "yoda.core.platform",
    interface = nil, -- No interface yet
  },
}

--- Load core module with interface validation
--- @param module_name string Core module name
--- @return table module Loaded and validated module
function M.load_core(module_name)
  -- Check cache first
  if _cache[module_name] then
    return _cache[module_name]
  end

  local module_config = CORE_MODULES[module_name]
  if not module_config then
    error("Unknown core module: " .. module_name)
  end

  -- Load the module
  local ok, module = pcall(require, module_config.path)
  if not ok then
    error("Failed to load core module '" .. module_name .. "': " .. module)
  end

  -- Validate interface if defined
  if module_config.interface then
    local interface_ok, interface = pcall(require, module_config.interface)
    if interface_ok then
      local valid, err = interface.validate(module)
      if not valid then
        error("Core module '" .. module_name .. "' interface validation failed: " .. err)
      end
    end
  end

  -- Cache and return
  _cache[module_name] = module
  return module
end

--- Get all available core modules
--- @return table module_list
function M.list_core_modules()
  local modules = {}
  for name, _ in pairs(CORE_MODULES) do
    table.insert(modules, name)
  end
  table.sort(modules)
  return modules
end

--- Clear module cache (for testing)
function M.clear_cache()
  _cache = {}
end

--- Check if module implements interface
--- @param module_name string Core module name
--- @return boolean has_interface
function M.has_interface(module_name)
  local module_config = CORE_MODULES[module_name]
  return module_config and module_config.interface ~= nil
end

return M
