-- lua/yoda/picker_handler.lua
-- Test picker UI handling

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

local DEFAULT_MARKERS = {
  "bdd",           -- Default BDD tests
  "unit",          -- Unit tests
  "functional",    -- Functional tests
  "smoke",         -- Smoke tests
  "critical",      -- Critical path tests
  "performance",   -- Performance tests
  "regression",    -- Regression tests
  "integration",   -- Integration tests
}

local ALLURE_OPTIONS = {
  "Yes, open Allure report",
  "No, skip Allure report"
}

local CACHE_FILE_PATH = vim.fn.stdpath("cache") .. "/yoda_testpicker_marker.json"

-- ============================================================================
-- Helper Functions
-- ============================================================================

--- Create a safe picker selection with cancellation handling
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

--- Extract environment names from configuration
--- @param env_region table Environment configuration
--- @return table Sorted list of environment names
local function extract_env_names(env_region)
  local env_names = {}
  if env_region.env_order then
    -- Use the order from YAML file
    env_names = env_region.env_order
  else
    -- Fallback to alphabetical order for JSON/fallback
    for env_name, _ in pairs(env_region.environments or env_region) do
      table.insert(env_names, env_name)
    end
    table.sort(env_names)
  end
  return env_names
end

--- Load markers with fallback to defaults
--- @return table Available markers
local function load_markers()
  local config_loader = require("yoda.config_loader")
  local markers = config_loader.load_pytest_markers("pytest.ini")
  return markers or DEFAULT_MARKERS
end

--- Parse environment and region from combined label
--- @param label string Label in format "env (region)"
--- @return string|nil, string|nil Environment and region
local function parse_env_region_label(label)
  return label:match("^(.+)%s+%((.+)%)$")
end

--- Determine Allure preference from selection
--- @param selection string|nil Selected option
--- @param default boolean Default preference
--- @return boolean Whether to open Allure
local function determine_allure_preference(selection, default)
  if selection == nil then
    return default
  end
  return selection == ALLURE_OPTIONS[1]
end

--- Select region for chosen environment
--- @param env_region table Environment configuration
--- @param selected_env string Selected environment
--- @param callback function Callback function
local function select_region(env_region, selected_env, callback)
  local regions = (env_region.environments or env_region)[selected_env]
  if not regions or #regions == 0 then
    vim.notify("No regions found for environment: " .. selected_env, vim.log.levels.WARN)
    callback(nil)
    return
  end

  safe_picker_select(regions, { 
    prompt = "Select Region for " .. selected_env .. ":" 
  }, function(selected_region)
    if not selected_region then
      callback(nil)
      return
    end
    callback(selected_region)
  end)
end

--- Select test markers with caching
--- @param callback function Callback function
local function select_markers(callback)
  local config_loader = require("yoda.config_loader")
  local cached_config = config_loader.load_marker(CACHE_FILE_PATH)
  local markers = load_markers()
  local default_markers = cached_config.markers or "bdd"
  
  safe_picker_select(markers, { 
    prompt = string.format("Select Test Markers (press Enter for '%s'):", default_markers)
  }, function(selected_markers)
    local markers_to_use = selected_markers or default_markers
    callback(markers_to_use)
  end)
end

--- Select Allure preference with caching
--- @param callback function Callback function
local function select_allure_preference(callback)
  local config_loader = require("yoda.config_loader")
  local cached_config = config_loader.load_marker(CACHE_FILE_PATH)
  local default_allure = cached_config.open_allure or false
  local default_allure_text = default_allure and ALLURE_OPTIONS[1] or ALLURE_OPTIONS[2]
  
  safe_picker_select(ALLURE_OPTIONS, { 
    prompt = string.format("Open Allure report after tests complete? (press Enter for '%s')", default_allure_text)
  }, function(selected_allure)
    local open_allure = determine_allure_preference(selected_allure, default_allure)
    callback(open_allure)
  end)
end

--- Handle YAML-based multi-step selection
--- @param env_region table Environment to regions mapping
--- @param callback function Callback function
function M.handle_yaml_selection(env_region, callback)
  -- Step 1: Select environment
  local env_names = extract_env_names(env_region)
  
  safe_picker_select(env_names, { prompt = "Select Environment:" }, function(selected_env)
    if not selected_env then
      callback(nil)
      return
    end

    -- Step 2: Select region
    select_region(env_region, selected_env, function(selected_region)
      if not selected_region then
        callback(nil)
        return
      end

      -- Step 3: Select markers
      select_markers(function(markers_to_use)
        if not markers_to_use then
          callback(nil)
          return
        end

        -- Step 4: Select Allure preference
        select_allure_preference(function(open_allure)
          if open_allure == nil then
            callback(nil)
            return
          end

          -- Save selections to cache
          local config_loader = require("yoda.config_loader")
          config_loader.save_marker(CACHE_FILE_PATH, selected_env, selected_region, markers_to_use, open_allure)
          
          callback({ 
            environment = selected_env, 
            region = selected_region,
            markers = markers_to_use,
            open_allure = open_allure
          })
        end)
      end)
    end)
  end)
end

--- Generate environment-region combination labels
--- @param env_region table Environment and region configuration
--- @return table List of formatted labels
local function generate_env_region_labels(env_region)
  local items = {}
  for _, env in ipairs(env_region.environments) do
    for _, region in ipairs(env_region.regions) do
      local label = env .. " (" .. region .. ")"
      table.insert(items, label)
    end
  end
  return items
end

--- Handle JSON/fallback single-step selection
--- @param env_region table Environment and region configuration
--- @param callback function Callback function
function M.handle_json_selection(env_region, callback)
  local items = generate_env_region_labels(env_region)
  
  safe_picker_select(items, { prompt = "Select Test Environment:" }, function(choice)
    if not choice then
      callback(nil)
      return
    end
    
    -- Parse the selected label back to env and region
    local env, region = parse_env_region_label(choice)
    if env and region then
      callback({ environment = env, region = region })
    else
      vim.notify("Failed to parse environment and region from selection", vim.log.levels.ERROR)
      callback(nil)
    end
  end)
end

return M
