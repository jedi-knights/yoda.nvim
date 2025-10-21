-- lua/yoda/config_loader.lua
-- Configuration loading utilities

local M = {}

--- Load JSON configuration file (uses consolidated core/io module)
--- @param path string Path to JSON file
--- @return table|nil Parsed JSON data
function M.load_json_config(path)
  -- Input validation for perfect assertiveness
  if type(path) ~= "string" or path == "" then
    vim.notify(
      "load_json_config: path must be a non-empty string",
      vim.log.levels.ERROR,
      { title = "Config Loader Error" }
    )
    return nil
  end
  
  local io = require("yoda.core.io")
  local ok, data = io.parse_json_file(path)
  return ok and data or nil
end

--- Load ingress mapping configuration
--- @return table|nil Parsed environment mapping
function M.load_ingress_mapping()
  local yaml_path = "ingress-mapping.yaml"
  local io = require("yoda.core.io")
  
  if not io.is_file(yaml_path) then
    return nil
  end

  local yaml_parser = require("yoda.yaml_parser")
  local result = yaml_parser.parse_ingress_mapping(yaml_path)
  if not result or not result.environments or not next(result.environments) then
    vim.notify("Failed to parse ingress-mapping.yaml", vim.log.levels.WARN)
    return nil
  end

  return result
end

--- Load environment and region configuration
--- @return table, string Configuration data and source type
function M.load_env_region()
  -- Use testing defaults (user-overridable for OCP)
  local defaults = require("yoda.testing.defaults")
  local fallback = {
    environments = defaults.get_environments(),
  }

  -- First try to load environments.json
  local file_path = "environments.json"
  local io = require("yoda.core.io")
  
  if io.is_file(file_path) then
    local config = M.load_json_config(file_path)
    if config then
      return config, "json"
    end
  end

  -- Fallback to ingress-mapping.yaml
  local ingress_map = M.load_ingress_mapping()
  if ingress_map then
    return ingress_map, "yaml"
  end

  return fallback, "fallback"
end

--- Load test picker marker from cache
--- @param cache_file string Path to cache file
--- @return table Default marker configuration
function M.load_marker(cache_file)
  -- Input validation
  if type(cache_file) ~= "string" or cache_file == "" then
    local defaults = require("yoda.testing.defaults")
    return defaults.get_marker_defaults()
  end
  
  local config = M.load_json_config(cache_file)
  
  -- Use testing defaults for fallback (OCP - user-overridable!)
  local defaults = require("yoda.testing.defaults")
  return config or defaults.get_marker_defaults()
end

-- NOTE: load_pytest_markers function has been moved to pytest-atlas.nvim plugin

--- Save test picker marker to cache
--- @param cache_file string Path to cache file
--- @param env string Environment name
--- @param region string Region name
--- @param markers string|nil Markers used
--- @param open_allure boolean|nil Whether to open Allure report
function M.save_marker(cache_file, env, region, markers, open_allure)
  local config = { 
    environment = env, 
    region = region,
    markers = markers or "bdd",
    open_allure = open_allure or false
  }
  local Path = require("plenary.path")
  local ok = pcall(function()
    Path.new(cache_file):write(vim.json.encode(config), "w")
  end)
  if not ok then
    vim.notify("Failed to save test picker marker", vim.log.levels.WARN)
  end
end

return M
