-- lua/yoda/yaml_parser.lua
-- Pure Lua YAML parser for ingress-mapping.yaml structure
-- Uses unified logging system for trace debugging

local logger = require("yoda.logging.logger")
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
--- @param current_env string|nil Current environment
--- @param current_regions table Current regions array
local function save_environment(environments, current_env, current_regions)
  if not current_env then
    return
  end

  environments[current_env] = current_regions
  logger.trace("Saved environment", { env = current_env, regions = #current_regions })
end

--- Process environment line
--- Complexity: 1 (simple operations)
--- @param env_order table Environment order array
--- @param env_name string Environment name
--- @param line_num number Line number
local function log_new_environment(env_order, env_name, line_num)
  table.insert(env_order, env_name)
  logger.trace("Found environment", { env = env_name, line = line_num })
end

--- Process region line
--- Complexity: 1 (simple operations)
--- @param current_regions table Regions array
--- @param region_name string Region name
--- @param current_env string Current environment
local function add_region(current_regions, region_name, current_env)
  table.insert(current_regions, region_name)
  logger.trace("Found region", { region = region_name, env = current_env })
end

--- Removed: write_debug_log - now handled by unified logger with file strategy

--- Process single YAML line
--- Complexity: 6 (1 skip + 2 env checks + 2 region checks + 1 log)
--- @param line string Line content
--- @param line_num number Line number
--- @param state table Parser state {current_env, current_regions, environments, env_order}
local function process_line(line, line_num, state)
  local trimmed = line:match("^%s*(.-)%s*$")

  -- Skip empty/comment lines
  if is_skip_line(trimmed) then
    return
  end

  local indent = #(line:match("^(%s*)") or "")
  logger.trace(function()
    return create_line_log(line_num, indent, trimmed)
  end)

  -- Check for environment definition
  local env_name = extract_environment_name(trimmed, indent)
  if env_name then
    save_environment(state.environments, state.current_env, state.current_regions)
    state.current_env = env_name
    state.current_regions = {}
    log_new_environment(state.env_order, env_name, line_num)
    return
  end

  -- Check for region definition
  local region_name = extract_region_name(trimmed, indent, state.current_env)
  if region_name then
    add_region(state.current_regions, region_name, state.current_env)
  end
end

--- Add final debug information
--- Complexity: 2 (1 loop + simple operations)
--- @param env_order table Environment order
--- @param environments table Environments map
local function finalize_debug_log(env_order, environments)
  logger.trace("YAML parsing complete", { env_order = env_order })

  for env_name, regions in pairs(environments) do
    logger.trace("Environment result", { env = env_name, regions = regions })
  end
end

--- Parse YAML file and extract environments and regions
--- Complexity: 4 (1 read check + 1 loop + 1 save + 1 finalize)
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
  }

  -- Setup debug logging with unified logger
  local lines = vim.split(content, "\n")
  logger.debug("Starting YAML parse", { file = yaml_path, lines = #lines })

  -- Process each line
  for i, line in ipairs(lines) do
    process_line(line, i, state)
  end

  -- Save final environment
  save_environment(state.environments, state.current_env, state.current_regions)

  -- Finalize debug logging
  finalize_debug_log(state.env_order, state.environments)

  logger.info("YAML parsing complete", {
    file = yaml_path,
    environments = #state.env_order,
  })

  return {
    environments = state.environments,
    env_order = state.env_order,
  }
end

return M
