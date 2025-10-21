-- lua/yoda/core/backends.lua
-- Unified backend detection system - PERFECT DRY
-- Single source of truth for all backend detection logic
-- Eliminates duplication across notification/picker adapters

local M = {}

local validation = require("yoda.core.validation")
local result = require("yoda.core.result")

-- ============================================================================
-- BACKEND DETECTION FRAMEWORK (Single Source of Truth)
-- ============================================================================

--- Backend detection configuration
local BACKEND_CONFIGS = {
  notification = {
    backends = {
      noice = {
        detection = function()
          return pcall(require, "noice")
        end,
        priority = 1,
      },
      snacks = {
        detection = function()
          return pcall(require, "snacks")
        end,
        priority = 2,
      },
      native = {
        detection = function()
          return true -- Always available
        end,
        priority = 999,
      },
    },
    default = "native",
  },

  picker = {
    backends = {
      snacks = {
        detection = function()
          return pcall(require, "snacks")
        end,
        priority = 1,
      },
      telescope = {
        detection = function()
          return pcall(require, "telescope")
        end,
        priority = 2,
      },
      native = {
        detection = function()
          return true -- Always available
        end,
        priority = 999,
      },
    },
    default = "native",
  },
}

--- Backend state cache (singleton pattern)
local _backend_cache = {}

-- ============================================================================
-- BACKEND DETECTION API (Perfect DRY)
-- ============================================================================

--- Detect best available backend for given adapter type
--- @param adapter_type string Adapter type ("notification", "picker")
--- @param preferred string|nil Preferred backend name
--- @return table result Success with backend name or error
function M.detect_backend(adapter_type, preferred)
  -- Validate input
  local ctx = validation.context("detect_backend", "backends")
  validation.assert_non_empty_string(adapter_type, "adapter_type", ctx)

  local config = BACKEND_CONFIGS[adapter_type]
  if not config then
    return result.error(string.format("Unknown adapter type: %s", adapter_type), "UNKNOWN_ADAPTER_TYPE")
  end

  -- Check for forced backend (testing mode)
  local forced_backend = _backend_cache[adapter_type .. "_forced"]
  if forced_backend then
    return result.success(forced_backend)
  end

  -- Check cache first
  local cache_key = adapter_type .. "_" .. (preferred or "auto")
  if _backend_cache[cache_key] then
    return result.success(_backend_cache[cache_key])
  end

  local selected_backend = nil

  -- Try preferred backend first
  if preferred then
    local backend_config = config.backends[preferred]
    if backend_config then
      if backend_config.detection() then
        selected_backend = preferred
      else
        -- Preferred not available, continue with auto-detection
      end
    else
      return result.error(string.format("Unknown backend '%s' for adapter type '%s'", preferred, adapter_type), "UNKNOWN_BACKEND")
    end
  end

  -- Auto-detect if no preferred or preferred unavailable
  if not selected_backend then
    local backends = {}
    for name, backend_config in pairs(config.backends) do
      if backend_config.detection() then
        table.insert(backends, {
          name = name,
          priority = backend_config.priority,
        })
      end
    end

    -- Sort by priority (lower = higher priority)
    table.sort(backends, function(a, b)
      return a.priority < b.priority
    end)

    if #backends > 0 then
      selected_backend = backends[1].name
    else
      return result.error(string.format("No backends available for adapter type '%s'", adapter_type), "NO_BACKENDS_AVAILABLE")
    end
  end

  -- Cache result
  _backend_cache[cache_key] = selected_backend

  return result.success(selected_backend)
end

--- Set backend preference for adapter type
--- @param adapter_type string Adapter type
--- @param backend_name string Backend name
--- @param force boolean Force backend even if not available (for testing)
--- @return table result Success or error
function M.set_backend(adapter_type, backend_name, force)
  local ctx = validation.context("set_backend", "backends")
  validation.assert_non_empty_string(adapter_type, "adapter_type", ctx)
  validation.assert_non_empty_string(backend_name, "backend_name", ctx)

  local config = BACKEND_CONFIGS[adapter_type]
  if not config then
    return result.error(string.format("Unknown adapter type: %s", adapter_type), "UNKNOWN_ADAPTER_TYPE")
  end

  if not config.backends[backend_name] then
    return result.error(string.format("Unknown backend '%s' for adapter type '%s'", backend_name, adapter_type), "UNKNOWN_BACKEND")
  end

  -- Clear cache and set preference
  local cache_key = adapter_type .. "_auto"
  _backend_cache[cache_key] = nil
  _backend_cache[adapter_type .. "_" .. backend_name] = backend_name
  
  -- If force mode (for testing), also set as forced preference
  if force then
    _backend_cache[adapter_type .. "_forced"] = backend_name
  end

  return result.success(backend_name)
end

--- Reset backend detection for adapter type
--- @param adapter_type string Adapter type
--- @return table result Success or error
function M.reset_backend(adapter_type)
  local ctx = validation.context("reset_backend", "backends")
  validation.assert_non_empty_string(adapter_type, "adapter_type", ctx)

  -- Clear all cache entries for this adapter type
  local keys_to_remove = {}
  for key, _ in pairs(_backend_cache) do
    if key:match("^" .. adapter_type .. "_") then
      table.insert(keys_to_remove, key)
    end
  end

  for _, key in ipairs(keys_to_remove) do
    _backend_cache[key] = nil
  end

  return result.success(true)
end

--- Get all available backends for adapter type
--- @param adapter_type string Adapter type
--- @return table result Success with array of backend names or error
function M.get_available_backends(adapter_type)
  local ctx = validation.context("get_available_backends", "backends")
  validation.assert_non_empty_string(adapter_type, "adapter_type", ctx)

  local config = BACKEND_CONFIGS[adapter_type]
  if not config then
    return result.error(string.format("Unknown adapter type: %s", adapter_type), "UNKNOWN_ADAPTER_TYPE")
  end

  local available = {}
  for name, backend_config in pairs(config.backends) do
    if backend_config.detection() then
      table.insert(available, {
        name = name,
        priority = backend_config.priority,
      })
    end
  end

  -- Sort by priority
  table.sort(available, function(a, b)
    return a.priority < b.priority
  end)

  local backend_names = {}
  for _, backend in ipairs(available) do
    table.insert(backend_names, backend.name)
  end

  return result.success(backend_names)
end

--- Get current backend for adapter type
--- @param adapter_type string Adapter type
--- @return table result Success with backend name or error
function M.get_current_backend(adapter_type)
  return M.detect_backend(adapter_type)
end

-- ============================================================================
-- BACKEND REGISTRATION (Perfect Extensibility)
-- ============================================================================

--- Register new backend for adapter type
--- @param adapter_type string Adapter type
--- @param backend_name string Backend name
--- @param backend_config table Backend configuration
--- @return table result Success or error
function M.register_backend(adapter_type, backend_name, backend_config)
  local ctx = validation.context("register_backend", "backends")
  validation.assert_non_empty_string(adapter_type, "adapter_type", ctx)
  validation.assert_non_empty_string(backend_name, "backend_name", ctx)
  validation.assert_type(backend_config, "table", "backend_config", ctx)
  validation.assert_function(backend_config.detection, "backend_config.detection", ctx)

  -- Create adapter type if doesn't exist
  if not BACKEND_CONFIGS[adapter_type] then
    BACKEND_CONFIGS[adapter_type] = {
      backends = {},
      default = "native",
    }
  end

  -- Set default priority if not provided
  backend_config.priority = backend_config.priority or 100

  BACKEND_CONFIGS[adapter_type].backends[backend_name] = backend_config

  -- Clear cache for this adapter type
  M.reset_backend(adapter_type)

  return result.success(true)
end

--- Get backend configuration for introspection
--- @param adapter_type string Adapter type
--- @return table result Success with configuration or error
function M.get_backend_config(adapter_type)
  local ctx = validation.context("get_backend_config", "backends")
  validation.assert_non_empty_string(adapter_type, "adapter_type", ctx)

  local config = BACKEND_CONFIGS[adapter_type]
  if not config then
    return result.error(string.format("Unknown adapter type: %s", adapter_type), "UNKNOWN_ADAPTER_TYPE")
  end

  -- Return copy to prevent modification
  local config_copy = {
    backends = {},
    default = config.default,
  }

  for name, backend_config in pairs(config.backends) do
    config_copy.backends[name] = {
      priority = backend_config.priority,
      -- Don't copy detection function for security
    }
  end

  return result.success(config_copy)
end

-- ============================================================================
-- UTILITIES
-- ============================================================================

--- Clear all backend caches
function M.clear_cache()
  _backend_cache = {}
end

--- Get cache status for debugging
--- @return table cache_info
function M.get_cache_info()
  local info = {
    cache_size = 0,
    cached_adapters = {},
  }

  for key, value in pairs(_backend_cache) do
    info.cache_size = info.cache_size + 1
    local adapter_type = key:match("^([^_]+)_")
    if adapter_type then
      info.cached_adapters[adapter_type] = info.cached_adapters[adapter_type] or {}
      table.insert(info.cached_adapters[adapter_type], {
        key = key,
        backend = value,
      })
    end
  end

  return info
end

return M
