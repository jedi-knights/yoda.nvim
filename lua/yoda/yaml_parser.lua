-- lua/yoda/yaml_parser.lua
-- Pure Lua YAML parser for ingress-mapping.yaml structure

local M = {}

--- Parse YAML file and extract environments and regions
--- @param yaml_path string Path to the YAML file
--- @return table|nil Table with environment names as keys and region arrays as values
function M.parse_ingress_mapping(yaml_path)
  local Path = require("plenary.path")
  local ok, content = pcall(Path.new(yaml_path).read, Path.new(yaml_path))
  if not ok then
    vim.notify("Failed to read YAML file: " .. yaml_path, vim.log.levels.ERROR)
    return nil
  end
  
  local lines = vim.split(content, "\n")
  local environments = {}
  local env_order = {}  -- Track order of environments
  
  -- Write debug output to file
  local debug_file = vim.fn.stdpath("cache") .. "/yoda_yaml_debug.log"
  local debug_log = {}
  table.insert(debug_log, "=== YAML Parser Debug ===")
  table.insert(debug_log, "File: " .. yaml_path)
  table.insert(debug_log, "Lines: " .. #lines)
  table.insert(debug_log, "")
  
  -- Simple approach: find all environments and their regions
  local current_env = nil
  local current_regions = {}
  
  for i, line in ipairs(lines) do
    local trimmed = line:match("^%s*(.-)%s*$")
    if trimmed == "" or trimmed:match("^#") then
      goto continue
    end
    
    local indent = #(line:match("^(%s*)") or "")
    table.insert(debug_log, string.format("Line %d: indent=%d content='%s'", i, indent, trimmed))
    
    -- Environment definition: "- name: fastly/qa/prod" at indent 2
    if trimmed:match("^-%s*name:%s*(.+)") and indent == 2 then
      local env_name = trimmed:match("^-%s*name:%s*(.+)")
      if env_name == "fastly" or env_name == "qa" or env_name == "prod" then
        -- Save previous environment
        if current_env then
          environments[current_env] = current_regions
          table.insert(debug_log, "*** Saved environment " .. current_env .. " with " .. #current_regions .. " regions")
        end
        
        -- Start new environment
        current_env = env_name
        current_regions = {}
        table.insert(env_order, env_name)  -- Track order
        table.insert(debug_log, "*** Found environment: " .. current_env .. " at line " .. i)
      end
      goto continue
    end
    
    -- Region definition: "- name: region_name" at indent 6 (under regions:)
    if trimmed:match("^-%s*name:%s*(.+)") and indent == 6 and current_env then
      local region_name = trimmed:match("^-%s*name:%s*(.+)")
      table.insert(current_regions, region_name)
      table.insert(debug_log, "*** Found region: " .. region_name .. " for environment " .. current_env .. " at line " .. i)
      goto continue
    end
    
    ::continue::
  end
  
  -- Save last environment
  if current_env then
    environments[current_env] = current_regions
    table.insert(debug_log, "*** Final environment " .. current_env .. " with " .. #current_regions .. " regions")
  end
  
  -- Debug: print final result
  table.insert(debug_log, "")
  table.insert(debug_log, "=== FINAL RESULTS ===")
  table.insert(debug_log, "Environment order: " .. vim.inspect(env_order))
  for env_name, regions in pairs(environments) do
    table.insert(debug_log, "Environment: " .. env_name .. " -> " .. vim.inspect(regions))
  end
  
  -- Write debug log to file
  local debug_content = table.concat(debug_log, "\n")
  local file = io.open(debug_file, "w")
  if file then
    file:write(debug_content)
    file:close()
    vim.notify("Debug log written to: " .. debug_file, vim.log.levels.INFO)
  end
  
  return {
    environments = environments,
    env_order = env_order
  }
end

return M

