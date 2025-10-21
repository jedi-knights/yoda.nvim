-- lua/yoda/config/manager.lua
-- Configuration management with SOLID principles
-- Single source of truth for all configuration access

local M = {}

-- Private state - perfect encapsulation
local _config = {}
local _initialized = false
local _defaults = {
  verbose_startup = false,
  debug_mode = false,
  auto_save = true,
  theme = "tokyonight",
  lsp_timeout = 5000,
  diagnostics_enabled = true,
}

-- Configuration schema for validation
local CONFIG_SCHEMA = {
  verbose_startup = "boolean",
  debug_mode = "boolean",
  auto_save = "boolean",
  theme = "string",
  lsp_timeout = "number",
  diagnostics_enabled = "boolean",
}

--- Initialize configuration manager
--- @param opts table|nil Override options
function M.init(opts)
  if _initialized then
    return
  end

  -- Load from vim.g first
  local vim_config = vim.g.yoda_config or {}

  -- Merge defaults, vim config, and provided options
  _config = vim.tbl_deep_extend("force", _defaults, vim_config, opts or {})

  -- Validate configuration
  local valid, err = M.validate(_config)
  if not valid then
    vim.notify("Invalid Yoda configuration: " .. err, vim.log.levels.WARN)
    -- Use defaults for invalid config
    _config = vim.tbl_deep_extend("force", _defaults, {})
  end

  _initialized = true
end

--- Get configuration value
--- @param key string Configuration key
--- @param default any Default value if key not found
--- @return any value
function M.get(key, default)
  if not _initialized then
    M.init()
  end

  if key == nil then
    -- Return full configuration (deep copy for safety)
    return vim.tbl_deep_extend("force", {}, _config)
  end

  local value = _config[key]
  if value == nil then
    return default
  end

  return value
end

--- Set configuration value
--- @param key string Configuration key
--- @param value any Configuration value
--- @return boolean success
--- @return string|nil error
function M.set(key, value)
  if not _initialized then
    M.init()
  end

  if type(key) ~= "string" or key == "" then
    return false, "Key must be a non-empty string"
  end

  -- Validate type if schema exists
  local expected_type = CONFIG_SCHEMA[key]
  if expected_type and type(value) ~= expected_type then
    return false, string.format("Expected %s for key '%s', got %s", expected_type, key, type(value))
  end

  _config[key] = value
  return true, nil
end

--- Update multiple configuration values
--- @param updates table Key-value pairs to update
--- @return boolean success
--- @return string|nil error
function M.update(updates)
  if type(updates) ~= "table" then
    return false, "Updates must be a table"
  end

  -- Validate all updates first
  for key, value in pairs(updates) do
    local ok, err = M.set(key, value)
    if not ok then
      return false, "Failed to set '" .. key .. "': " .. err
    end
  end

  return true, nil
end

--- Validate configuration against schema
--- @param config table Configuration to validate
--- @return boolean valid
--- @return string|nil error
function M.validate(config)
  if type(config) ~= "table" then
    return false, "Configuration must be a table"
  end

  for key, value in pairs(config) do
    local expected_type = CONFIG_SCHEMA[key]
    if expected_type then
      if type(value) ~= expected_type then
        return false, string.format("Key '%s': expected %s, got %s", key, expected_type, type(value))
      end
    end
  end

  return true, nil
end

--- Check if in debug mode
--- @return boolean
function M.is_debug()
  return M.get("debug_mode", false)
end

--- Check if verbose startup is enabled
--- @return boolean
function M.is_verbose()
  return M.get("verbose_startup", false)
end

--- Check if auto-save is enabled
--- @return boolean
function M.is_auto_save()
  return M.get("auto_save", true)
end

--- Get theme name
--- @return string
function M.get_theme()
  return M.get("theme", "tokyonight")
end

--- Get LSP timeout
--- @return number
function M.get_lsp_timeout()
  return M.get("lsp_timeout", 5000)
end

--- Check if diagnostics are enabled
--- @return boolean
function M.is_diagnostics_enabled()
  return M.get("diagnostics_enabled", true)
end

--- Reset configuration to defaults
function M.reset()
  _config = vim.tbl_deep_extend("force", {}, _defaults)
  _initialized = true
end

--- Export configuration to vim.g (for compatibility)
function M.export_to_vim_g()
  vim.g.yoda_config = vim.tbl_deep_extend("force", {}, _config)
end

--- Get configuration metadata
--- @return table metadata
function M.get_metadata()
  return {
    initialized = _initialized,
    schema_keys = vim.tbl_keys(CONFIG_SCHEMA),
    current_keys = vim.tbl_keys(_config),
    is_valid = M.validate(_config),
  }
end

return M
