-- lua/yoda/yaml_parser.lua
-- Pure Lua YAML parser for ingress-mapping.yaml structure
-- Refactored for low cyclomatic complexity (all functions ≤ 7)

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

local KNOWN_ENVIRONMENTS = { fastly = true, qa = true, prod = true }
local ENVIRONMENT_INDENT = 2
local REGION_INDENT = 6

-- ============================================================================
-- Helper Functions (Low Complexity)
-- ============================================================================

--- Read YAML file content
--- Complexity: 2 (1 if + 1 early return)
--- @param yaml_path string Path to YAML file
--- @return boolean, string|nil Success status, content or error
local function read_yaml_file(yaml_path)
  local Path = require("plenary.path")
  local ok, content = pcall(Path.new(yaml_path).read, Path.new(yaml_path))
  if not ok then
    vim.notify("Failed to read YAML file: " .. yaml_path, vim.log.levels.ERROR)
    return false, nil
  end
  return true, content
end

--- Check if line is empty or comment
--- Complexity: 1 (1 or condition)
--- @param trimmed string Trimmed line content
--- @return boolean
local function is_skip_line(trimmed)
  return trimmed == "" or trimmed:match("^#") ~= nil
end

--- Extract environment name from line
--- Complexity: 3 (1 match + 1 and + 1 table lookup)
--- @param trimmed string Trimmed line content
--- @param indent number Line indentation
--- @return string|nil Environment name if valid
local function extract_environment_name(trimmed, indent)
  if indent ~= ENVIRONMENT_INDENT then
    return nil
  end

  local env_name = trimmed:match("^-%s*name:%s*(.+)")
  if env_name and KNOWN_ENVIRONMENTS[env_name] then
    return env_name
  end
  return nil
end

--- Extract region name from line
--- Complexity: 3 (2 and conditions + 1 match)
--- @param trimmed string Trimmed line content
--- @param indent number Line indentation
--- @param current_env string|nil Current environment context
--- @return string|nil Region name if valid
local function extract_region_name(trimmed, indent, current_env)
  if indent ~= REGION_INDENT or not current_env then
    return nil
  end

  return trimmed:match("^-%s*name:%s*(.+)")
end

--- Create debug log entry for line
--- Complexity: 1 (simple format)
--- @param i number Line number
--- @param indent number Indentation
--- @param trimmed string Content
--- @return string Debug log entry
local function create_line_log(i, indent, trimmed)
  return string.format("Line %d: indent=%d content='%s'", i, indent, trimmed)
end

--- Save current environment to results
--- Complexity: 2 (1 if + simple operations)
--- @param environments table Environments map
--- @param debug_log table Debug log array
--- @param current_env string|nil Current environment
--- @param current_regions table Current regions array
local function save_environment(environments, debug_log, current_env, current_regions)
  if not current_env then
    return
  end

  environments[current_env] = current_regions
  table.insert(debug_log, "*** Saved environment " .. current_env .. " with " .. #current_regions .. " regions")
end

--- Process environment line
--- Complexity: 1 (simple operations)
--- @param debug_log table Debug log array
--- @param env_order table Environment order array
--- @param env_name string Environment name
--- @param line_num number Line number
local function log_new_environment(debug_log, env_order, env_name, line_num)
  table.insert(env_order, env_name)
  table.insert(debug_log, "*** Found environment: " .. env_name .. " at line " .. line_num)
end

--- Process region line
--- Complexity: 1 (simple operations)
--- @param debug_log table Debug log array
--- @param current_regions table Regions array
--- @param region_name string Region name
--- @param current_env string Current environment
local function add_region(debug_log, current_regions, region_name, current_env)
  table.insert(current_regions, region_name)
  table.insert(debug_log, "*** Found region: " .. region_name .. " for environment " .. current_env)
end

--- Write debug log to file
--- Complexity: 2 (1 if + file operations)
--- @param debug_file string Debug file path
--- @param debug_log table Debug log entries
local function write_debug_log(debug_file, debug_log)
  local debug_content = table.concat(debug_log, "\n")
  local file = io.open(debug_file, "w")
  if file then
    file:write(debug_content)
    file:close()
    vim.notify("Debug log written to: " .. debug_file, vim.log.levels.INFO)
  end
end

--- Process single YAML line
--- Complexity: 6 (1 skip + 2 env checks + 2 region checks + 1 log)
--- @param line string Line content
--- @param line_num number Line number
--- @param state table Parser state {current_env, current_regions, environments, env_order, debug_log}
local function process_line(line, line_num, state)
  local trimmed = line:match("^%s*(.-)%s*$")

  -- Skip empty/comment lines
  if is_skip_line(trimmed) then
    return
  end

  local indent = #(line:match("^(%s*)") or "")
  table.insert(state.debug_log, create_line_log(line_num, indent, trimmed))

  -- Check for environment definition
  local env_name = extract_environment_name(trimmed, indent)
  if env_name then
    save_environment(state.environments, state.debug_log, state.current_env, state.current_regions)
    state.current_env = env_name
    state.current_regions = {}
    log_new_environment(state.debug_log, state.env_order, env_name, line_num)
    return
  end

  -- Check for region definition
  local region_name = extract_region_name(trimmed, indent, state.current_env)
  if region_name then
    add_region(state.debug_log, state.current_regions, region_name, state.current_env)
  end
end

--- Add final debug information
--- Complexity: 2 (1 loop + simple operations)
--- @param debug_log table Debug log entries
--- @param env_order table Environment order
--- @param environments table Environments map
local function finalize_debug_log(debug_log, env_order, environments)
  table.insert(debug_log, "")
  table.insert(debug_log, "=== FINAL RESULTS ===")
  table.insert(debug_log, "Environment order: " .. vim.inspect(env_order))
  
  for env_name, regions in pairs(environments) do
    table.insert(debug_log, "Environment: " .. env_name .. " -> " .. vim.inspect(regions))
  end
end

--- Parse YAML file and extract environments and regions
--- Complexity: 4 (1 read check + 1 loop + 1 save + 1 write)
--- @param yaml_path string Path to the YAML file
--- @return table|nil Table with environment names as keys and region arrays as values
function M.parse_ingress_mapping(yaml_path)
  -- Read file
  local ok, content = read_yaml_file(yaml_path)
  if not ok then
    return nil
  end

  -- Initialize parser state
  local state = {
    current_env = nil,
    current_regions = {},
    environments = {},
    env_order = {},
    debug_log = {},
  }

  -- Setup debug logging
  table.insert(state.debug_log, "=== YAML Parser Debug ===")
  table.insert(state.debug_log, "File: " .. yaml_path)
  local lines = vim.split(content, "\n")
  table.insert(state.debug_log, "Lines: " .. #lines)
  table.insert(state.debug_log, "")

  -- Process each line
  for i, line in ipairs(lines) do
    process_line(line, i, state)
  end

  -- Save final environment
  save_environment(state.environments, state.debug_log, state.current_env, state.current_regions)

  -- Finalize debug logging
  finalize_debug_log(state.debug_log, state.env_order, state.environments)

  -- Write debug output
  local debug_file = vim.fn.stdpath("cache") .. "/yoda_yaml_debug.log"
  write_debug_log(debug_file, state.debug_log)

  return {
    environments = state.environments,
    env_order = state.env_order,
  }
end

return M
