-- lua/yoda/config.lua
-- Centralized configuration management
-- Single source of truth for all vim.g.yoda_* globals

local M = {}

-- ============================================================================
-- Configuration Getters (Encapsulates vim.g access)
-- ============================================================================

--- Get main Yoda configuration
--- @return table|nil Main configuration object
function M.get_config()
  return vim.g.yoda_config
end

--- Check if environment notification should be shown
--- @return boolean True if notification should be shown
function M.should_show_environment_notification()
  local config = M.get_config()
  return config and config.show_environment_notification or false
end

--- Check if verbose startup logging is enabled
--- @return boolean True if verbose startup is enabled
function M.is_verbose_startup()
  local config = M.get_config()
  return config and config.verbose_startup or false
end

--- Get notification backend preference
--- @return string|nil Backend name ("noice", "snacks", "native") or nil for auto-detect
function M.get_notify_backend()
  return vim.g.yoda_notify_backend
end

--- Get picker backend preference
--- @return string|nil Backend name ("snacks", "telescope", "native") or nil for auto-detect
function M.get_picker_backend()
  return vim.g.yoda_picker_backend
end

--- Get test configuration overrides
--- @return table|nil Test configuration overrides or nil
function M.get_test_config()
  return vim.g.yoda_test_config
end

-- ============================================================================
-- Configuration Setters (For testing and programmatic config)
-- ============================================================================

--- Set main Yoda configuration
--- @param config table Configuration object
function M.set_config(config)
  if type(config) == "table" then
    vim.g.yoda_config = config
  end
end

--- Set notification backend
--- @param backend string Backend name ("noice", "snacks", "native")
function M.set_notify_backend(backend)
  local valid_backends = { noice = true, snacks = true, native = true }
  if type(backend) == "string" and valid_backends[backend] then
    vim.g.yoda_notify_backend = backend
  end
end

--- Set picker backend
--- @param backend string Backend name ("snacks", "telescope", "native")
function M.set_picker_backend(backend)
  local valid_backends = { snacks = true, telescope = true, native = true }
  if type(backend) == "string" and valid_backends[backend] then
    vim.g.yoda_picker_backend = backend
  end
end

--- Set test configuration overrides
--- @param config table Test configuration overrides
function M.set_test_config(config)
  if type(config) == "table" then
    vim.g.yoda_test_config = config
  end
end

-- ============================================================================
-- Configuration Validation
-- ============================================================================

--- Validate configuration structure
--- @return boolean, string|nil Valid status and error message
function M.validate()
  local config = M.get_config()

  if not config then
    return true, nil -- No config is valid (use defaults)
  end

  if type(config) ~= "table" then
    return false, "yoda_config must be a table"
  end

  -- Validate boolean fields
  local boolean_fields = { "show_environment_notification", "verbose_startup" }
  for _, field in ipairs(boolean_fields) do
    if config[field] ~= nil and type(config[field]) ~= "boolean" then
      return false, string.format("yoda_config.%s must be a boolean", field)
    end
  end

  return true, nil
end

-- ============================================================================
-- Default Configuration
-- ============================================================================

--- Get default configuration
--- @return table Default configuration
function M.get_defaults()
  return {
    show_environment_notification = true,
    verbose_startup = false,
  }
end

--- Initialize with defaults if not set
function M.init_defaults()
  if not M.get_config() then
    M.set_config(M.get_defaults())
  end
end

return M
