-- lua/yoda/testing/defaults.lua
-- Default test configuration (user-overridable for perfect OCP)
-- Users can extend without modifying source code via vim.g.yoda_test_config

local M = {}

-- ============================================================================
-- DEFAULT CONFIGURATIONS (can be overridden by user)
-- ============================================================================

M.ENVIRONMENTS = {
  qa = { "auto", "use1" },
  fastly = { "auto" },
  prod = { "auto", "use1", "usw2", "euw1", "apse1" },
}

M.ENVIRONMENT_ORDER = { "qa", "fastly", "prod" }

M.MARKERS = {
  "bdd", -- Default BDD tests
  "unit", -- Unit tests
  "functional", -- Functional tests
  "smoke", -- Smoke tests
  "critical", -- Critical path tests
  "performance", -- Performance tests
  "regression", -- Regression tests
  "integration", -- Integration tests
  "location", -- Location-based tests
  "api", -- API tests
  "ui", -- UI tests
  "slow", -- Slow running tests
}

M.MARKER_DEFAULTS = {
  environment = "qa",
  region = "auto",
  markers = "bdd",
  open_allure = false,
}

-- ============================================================================
-- PUBLIC API
-- ============================================================================

--- Get test configuration (user-overridable via vim.g.yoda_test_config)
--- @return table Configuration with environments, markers, etc.
function M.get_config()
  -- Check for user override first (OCP - extend without modification!)
  if vim.g.yoda_test_config then
    return vim.tbl_deep_extend("force", {
      environments = M.ENVIRONMENTS,
      environment_order = M.ENVIRONMENT_ORDER,
      markers = M.MARKERS,
      marker_defaults = M.MARKER_DEFAULTS,
    }, vim.g.yoda_test_config)
  end

  return {
    environments = M.ENVIRONMENTS,
    environment_order = M.ENVIRONMENT_ORDER,
    markers = M.MARKERS,
    marker_defaults = M.MARKER_DEFAULTS,
  }
end

--- Get environments configuration
--- @return table Environments with regions
function M.get_environments()
  local config = M.get_config()
  return config.environments
end

--- Get environment order
--- @return table Ordered list of environment names
function M.get_environment_order()
  local config = M.get_config()
  return config.environment_order or M.ENVIRONMENT_ORDER
end

--- Get markers list
--- @return table Available test markers
function M.get_markers()
  local config = M.get_config()
  return config.markers or M.MARKERS
end

--- Get marker defaults
--- @return table Default marker configuration
function M.get_marker_defaults()
  local config = M.get_config()
  return config.marker_defaults or M.MARKER_DEFAULTS
end

return M
