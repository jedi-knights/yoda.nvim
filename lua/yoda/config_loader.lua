-- lua/yoda/config_loader.lua
-- Configuration loading utilities

local M = {}

--- Load JSON configuration file
--- @param path string Path to JSON file
--- @return table|nil Parsed JSON data
function M.load_json_config(path)
  local Path = require("plenary.path")
  local ok, content = pcall(Path.new(path).read, Path.new(path))
  if not ok then
    return nil
  end
  
  local ok_json, parsed = pcall(vim.json.decode, content)
  return ok_json and parsed or nil
end

--- Load ingress mapping configuration
--- @return table|nil Parsed environment mapping
function M.load_ingress_mapping()
  local yaml_path = "ingress-mapping.yaml"
  if vim.fn.filereadable(yaml_path) ~= 1 then
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
  local fallback = {
    -- Nested structure matching YAML parser output
    environments = {
      qa = { "auto", "use1" },
      fastly = { "auto" },
      prod = { "auto", "use1", "usw2", "euw1", "apse1" },
    },
  }

  -- First try to load environments.json
  local file_path = "environments.json"
  if vim.fn.filereadable(file_path) == 1 then
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
  local config = M.load_json_config(cache_file)
  return config or { 
    environment = "qa", 
    region = "auto", 
    markers = "bdd",
    open_allure = false
  }
end

--- Parse pytest.ini file to extract markers
--- @param pytest_ini_path string Path to pytest.ini file
--- @return table|nil Array of marker names
function M.load_pytest_markers(pytest_ini_path)
  local Path = require("plenary.path")
  local ok, content = pcall(Path.new(pytest_ini_path).read, Path.new(pytest_ini_path))
  if not ok then
    return nil
  end
  
  local lines = vim.split(content, "\n")
  local markers = {}
  local in_markers_section = false
  
  for _, line in ipairs(lines) do
    local trimmed = line:match("^%s*(.-)%s*$")
    
    -- Check if we're entering the markers section
    if trimmed:match("^markers%s*=") then
      in_markers_section = true
      -- Extract markers from the same line if they exist
      local markers_line = trimmed:match("^markers%s*=%s*(.+)")
      if markers_line then
        -- Parse markers from the line
        for marker in markers_line:gmatch("([^%s,]+)") do
          if marker ~= "" then
            table.insert(markers, marker)
          end
        end
      end
      goto continue
    end
    
    -- If we're in markers section, continue parsing
    if in_markers_section then
      -- Stop if we hit a new section (starts with [)
      if trimmed:match("^%[") then
        break
      end
      
      -- Skip empty lines and comments
      if trimmed == "" or trimmed:match("^#") then
        goto continue
      end
      
      -- Extract marker name (everything before the colon)
      local marker = trimmed:match("^([^:]+)")
      if marker then
        marker = marker:match("^%s*(.-)%s*$") -- trim whitespace
        if marker ~= "" then
          table.insert(markers, marker)
        end
      end
    end
    
    ::continue::
  end
  
  return #markers > 0 and markers or nil
end

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
