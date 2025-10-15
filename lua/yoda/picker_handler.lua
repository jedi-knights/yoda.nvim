-- lua/yoda/picker_handler.lua
-- Test picker UI handling - Wizard pattern with low complexity
-- All functions refactored to have cyclomatic complexity ≤ 7

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

local DEFAULT_MARKERS = {
  "bdd",
  "unit",
  "functional",
  "smoke",
  "critical",
  "performance",
  "regression",
  "integration",
}

local ALLURE_OPTIONS = {
  "Yes, open Allure report",
  "No, skip Allure report",
}

local CACHE_FILE_PATH = vim.fn.stdpath("cache") .. "/yoda_testpicker_marker.json"

-- ============================================================================
-- Cache Management (Extracted for DRY)
-- ============================================================================

--- Load cached test configuration
--- Complexity: 1
--- @return table Cached configuration
local function load_cached_config()
  local config_loader = require("yoda.config_loader")
  return config_loader.load_marker(CACHE_FILE_PATH)
end

--- Save test configuration to cache
--- Complexity: 1
--- @param env string Environment
--- @param region string Region
--- @param markers string Markers
--- @param open_allure boolean Allure preference
local function save_cached_config(env, region, markers, open_allure)
  local config_loader = require("yoda.config_loader")
  config_loader.save_marker(CACHE_FILE_PATH, env, region, markers, open_allure)
end

-- ============================================================================
-- Reordering Logic (Extracted for DRY - Used in 5 places!)
-- ============================================================================

--- Reorder items to show default first
--- Complexity: 4 (1 if + 1 insert + 1 loop + 1 conditional insert)
--- @param items table Array of items
--- @param default any Default item to show first
--- @return table Reordered items
local function reorder_with_default_first(items, default)
  if not default then
    return items
  end

  local reordered = { default }
  for _, item in ipairs(items) do
    if item ~= default then
      table.insert(reordered, item)
    end
  end
  return reordered
end

-- ============================================================================
-- Picker Wrapper (Extracted for DRY)
-- ============================================================================

--- Safe picker selection with cancellation handling
--- Complexity: 2 (1 if + callback)
--- @param items table Items to select from
--- @param options table Picker options
--- @param callback function Callback function
local function safe_picker_select(items, options, callback)
  local picker = require("snacks.picker")
  picker.select(items, options, function(selection)
    if not selection then
      callback(nil)
      return
    end
    callback(selection)
  end)
end

-- ============================================================================
-- Data Extraction Helpers
-- ============================================================================

--- Extract environment names from configuration
--- Complexity: 3 (1 if + 1 loop + 1 sort)
--- @param env_region table Environment configuration
--- @return table Sorted list of environment names
local function extract_env_names(env_region)
  if env_region.env_order then
    return env_region.env_order
  end

  local env_names = {}
  for env_name, _ in pairs(env_region.environments or env_region) do
    table.insert(env_names, env_name)
  end
  table.sort(env_names)
  return env_names
end

--- Load markers with fallback to defaults
--- Complexity: 1
--- @return table Available markers
local function load_markers()
  local config_loader = require("yoda.config_loader")
  local markers = config_loader.load_pytest_markers("pytest.ini")
  return markers or DEFAULT_MARKERS
end

--- Parse environment and region from combined label
--- Complexity: 1
--- @param label string Label in format "env (region)"
--- @return string|nil, string|nil Environment and region
local function parse_env_region_label(label)
  return label:match("^(.+)%s+%((.+)%)$")
end

--- Check if marker exists in markers list
--- Complexity: 2 (1 loop + 1 if)
--- @param markers table Array of markers
--- @param marker string Marker to find
--- @return boolean
local function marker_exists(markers, marker)
  for _, m in ipairs(markers) do
    if m == marker then
      return true
    end
  end
  return false
end

--- Determine Allure preference from selection
--- Complexity: 2 (1 if + 1 comparison)
--- @param selection string|nil Selected option
--- @param default boolean Default preference
--- @return boolean Whether to open Allure
local function determine_allure_preference(selection, default)
  if selection == nil then
    return default
  end
  return selection == ALLURE_OPTIONS[1]
end

--- Generate environment-region combination labels
--- Complexity: 2 (2 nested loops)
--- @param env_region table Environment and region configuration
--- @return table List of formatted labels
local function generate_env_region_labels(env_region)
  local items = {}
  for _, env in ipairs(env_region.environments) do
    for _, region in ipairs(env_region.regions) do
      table.insert(items, env .. " (" .. region .. ")")
    end
  end
  return items
end

-- ============================================================================
-- Wizard Steps (Each step is now a focused function)
-- ============================================================================

--- Wizard Step 1: Select Environment
--- Complexity: 4 (1 load + 1 reorder + 1 picker + 1 callback check)
--- @param env_names table Available environments
--- @param callback function Callback(selected_env)
local function wizard_step_select_environment(env_names, callback)
  local cached = load_cached_config()
  local reordered = reorder_with_default_first(env_names, cached.environment)

  safe_picker_select(reordered, { prompt = "Select Environment:" }, function(selected_env)
    if not selected_env then
      callback(nil)
      return
    end
    callback(selected_env)
  end)
end

--- Wizard Step 2: Select Region
--- Complexity: 5 (1 lookup + 1 check + 1 load + 1 reorder + 1 picker)
--- @param env_region table Environment configuration
--- @param selected_env string Selected environment
--- @param callback function Callback(selected_region)
local function wizard_step_select_region(env_region, selected_env, callback)
  local regions = (env_region.environments or env_region)[selected_env]

  if not regions or #regions == 0 then
    vim.notify("No regions found for environment: " .. selected_env, vim.log.levels.WARN)
    callback(nil)
    return
  end

  local cached = load_cached_config()
  local reordered = reorder_with_default_first(regions, cached.region)

  safe_picker_select(reordered, {
    prompt = "Select Region for " .. selected_env .. ":",
  }, callback)
end

--- Wizard Step 3: Select Markers
--- Complexity: 4 (1 load + 1 check + 1 reorder + 1 picker)
--- @param callback function Callback(selected_markers)
local function wizard_step_select_markers(callback)
  local cached = load_cached_config()
  local markers = load_markers()

  -- Validate cached marker exists
  local default_markers = cached.markers
  if default_markers and not marker_exists(markers, default_markers) then
    default_markers = nil
  end

  local reordered = reorder_with_default_first(markers, default_markers)

  safe_picker_select(reordered, {
    prompt = "Select Test Markers",
  }, callback)
end

--- Wizard Step 4: Select Allure Preference
--- Complexity: 3 (1 load + 1 reorder + 1 picker)
--- @param callback function Callback(open_allure)
local function wizard_step_select_allure(callback)
  local cached = load_cached_config()
  local default_allure = cached.open_allure or false
  local default_text = default_allure and ALLURE_OPTIONS[1] or ALLURE_OPTIONS[2]

  local reordered = reorder_with_default_first(ALLURE_OPTIONS, default_text)

  safe_picker_select(reordered, {
    prompt = "Generate Allure Report?",
  }, function(selected)
    if not selected then
      callback(nil)
      return
    end
    callback(determine_allure_preference(selected, default_allure))
  end)
end

-- ============================================================================
-- Configuration Display and Command Generation
-- ============================================================================

--- Generate pytest command preview
--- Complexity: 5 (venv check + args build + allure check + markers check + join)
--- @param env string Environment
--- @param region string Region
--- @param markers string Markers
--- @param open_allure boolean Allure preference
--- @return string Command that will be executed
local function generate_pytest_command(env, region, markers, open_allure)
  local venvs = require("yoda.terminal.venv").find_virtual_envs()
  local pytest_cmd = "pytest"

  -- Use virtual environment if available
  if #venvs > 0 then
    local venv = venvs[1]
    pytest_cmd = venv .. "/bin/pytest"
  end

  -- Build command arguments
  local pytest_args = { "--tb=short", "-v" }

  if markers and markers ~= "" then
    table.insert(pytest_args, "-m")
    table.insert(pytest_args, markers)
  end

  if open_allure then
    table.insert(pytest_args, "--alluredir=allure-results")
  end

  return pytest_cmd .. " " .. table.concat(pytest_args, " ")
end

--- Format test configuration for display
--- Complexity: 6 (env format + region format + markers format + allure format + venv check + join)
--- @param env string Environment
--- @param region string Region
--- @param markers string Markers
--- @param open_allure boolean Allure preference
--- @return string Formatted configuration display
local function format_test_config_display(env, region, markers, open_allure)
  local config_lines = {}

  -- Environment and Region
  table.insert(config_lines, "Environment: " .. (env or "Not set"))
  table.insert(config_lines, "Region: " .. (region or "Not set"))

  -- Markers
  local markers_display = markers and markers ~= "" and markers or "None"
  table.insert(config_lines, "Markers: " .. markers_display)

  -- Allure Report
  local allure_display = open_allure and "Yes" or "No"
  table.insert(config_lines, "Allure Report: " .. allure_display)

  -- Virtual Environment
  local venvs = require("yoda.terminal.venv").find_virtual_envs()
  local venv_display = #venvs > 0 and venvs[1] or "System Python"
  table.insert(config_lines, "Python Env: " .. venv_display)

  -- Command Preview
  local command = generate_pytest_command(env, region, markers, open_allure)
  table.insert(config_lines, "Command: " .. command)

  return table.concat(config_lines, "\n")
end

--- Display test configuration preview to user
--- Complexity: 2 (format + notify)
--- @param env string Environment
--- @param region string Region
--- @param markers string Markers
--- @param open_allure boolean Allure preference
local function display_test_config_preview(env, region, markers, open_allure)
  local config_display = format_test_config_display(env, region, markers, open_allure)
  vim.notify("Test Configuration:\n" .. config_display, vim.log.levels.INFO)
end

-- ============================================================================
-- Wizard Orchestration (Chain of wizard steps)
-- ============================================================================

--- Execute YAML-based multi-step wizard
--- Complexity: 2 (1 extract + 1 step1 call)
--- @param env_region table Environment to regions mapping
--- @param callback function Callback function
function M.handle_yaml_selection(env_region, callback)
  local env_names = extract_env_names(env_region)

  -- Chain wizard steps using extracted functions
  wizard_step_select_environment(env_names, function(selected_env)
    if not selected_env then
      callback(nil)
      return
    end

    wizard_step_select_region(env_region, selected_env, function(selected_region)
      if not selected_region then
        callback(nil)
        return
      end

      wizard_step_select_markers(function(markers_to_use)
        if not markers_to_use then
          callback(nil)
          return
        end

        wizard_step_select_allure(function(open_allure)
          if open_allure == nil then
            callback(nil)
            return
          end

          -- Save and return results
          save_cached_config(selected_env, selected_region, markers_to_use, open_allure)

          -- Display configuration preview
          display_test_config_preview(selected_env, selected_region, markers_to_use, open_allure)

          callback({
            environment = selected_env,
            region = selected_region,
            markers = markers_to_use,
            open_allure = open_allure,
          })
        end)
      end)
    end)
  end)
end

--- Handle JSON/fallback single-step selection
--- Complexity: 6 (1 generate + 1 load + 1 if + 1 reorder + 1 picker + 1 parse check)
--- @param env_region table Environment and region configuration
--- @param callback function Callback function
function M.handle_json_selection(env_region, callback)
  local items = generate_env_region_labels(env_region)
  local cached = load_cached_config()

  local default_label = nil
  if cached.environment and cached.region then
    default_label = cached.environment .. " (" .. cached.region .. ")"
  end

  local reordered = reorder_with_default_first(items, default_label)

  safe_picker_select(reordered, { prompt = "Select Test Environment:" }, function(choice)
    if not choice then
      callback(nil)
      return
    end

    local env, region = parse_env_region_label(choice)
    if env and region then
      -- For JSON selection, we need to get markers and allure settings from cache
      local markers = cached.markers or ""
      local open_allure = cached.open_allure or false

      -- Display configuration preview
      display_test_config_preview(env, region, markers, open_allure)

      callback({ environment = env, region = region })
    else
      vim.notify("Failed to parse environment and region from selection", vim.log.levels.ERROR)
      callback(nil)
    end
  end)
end

-- ============================================================================
-- Public API
-- ============================================================================

--- Display current test configuration
--- Complexity: 3 (load config + extract values + display)
--- @param env string|nil Optional environment override
--- @param region string|nil Optional region override
--- @param markers string|nil Optional markers override
--- @param open_allure boolean|nil Optional allure override
function M.display_current_config(env, region, markers, open_allure)
  local cached = load_cached_config()

  local display_env = env or cached.environment or "Not set"
  local display_region = region or cached.region or "Not set"
  local display_markers = markers or cached.markers or ""
  local display_allure = open_allure ~= nil and open_allure or (cached.open_allure or false)

  display_test_config_preview(display_env, display_region, display_markers, display_allure)
end

--- Generate command preview for current configuration
--- Complexity: 3 (load config + extract values + generate)
--- @param env string|nil Optional environment override
--- @param region string|nil Optional region override
--- @param markers string|nil Optional markers override
--- @param open_allure boolean|nil Optional allure override
--- @return string Command that would be executed
function M.generate_command_preview(env, region, markers, open_allure)
  local cached = load_cached_config()

  local cmd_env = env or cached.environment or ""
  local cmd_region = region or cached.region or ""
  local cmd_markers = markers or cached.markers or ""
  local cmd_allure = open_allure ~= nil and open_allure or (cached.open_allure or false)

  return generate_pytest_command(cmd_env, cmd_region, cmd_markers, cmd_allure)
end

return M
