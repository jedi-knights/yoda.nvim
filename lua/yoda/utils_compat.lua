-- lua/yoda/utils_compat.lua
-- Backwards compatibility wrapper for utils.lua
-- Delegates to DI container while maintaining existing API

local M = {}

-- ============================================================================
-- Lazy Container Resolution (Singleton)
-- ============================================================================

local _container = nil
local _services = {}

local function get_container()
  if not _container then
    _container = require("yoda.container")
    _container.bootstrap()
  end
  return _container
end

local function resolve_service(name)
  if not _services[name] then
    _services[name] = get_container().resolve(name)
  end
  return _services[name]
end

-- ============================================================================
-- STRING UTILITIES (delegated to core.string via container)
-- ============================================================================

function M.trim(str)
  return resolve_service("core.string").trim(str)
end

function M.starts_with(str, prefix)
  return resolve_service("core.string").starts_with(str, prefix)
end

function M.ends_with(str, suffix)
  return resolve_service("core.string").ends_with(str, suffix)
end

function M.split(str, delimiter)
  return resolve_service("core.string").split(str, delimiter)
end

-- ============================================================================
-- FILE UTILITIES (delegated to core.io via container)
-- ============================================================================

function M.file_exists(path)
  return resolve_service("core.io").is_file(path)
end

function M.read_file(path)
  return resolve_service("core.io").read_file(path)
end

-- ============================================================================
-- TABLE UTILITIES (delegated to core.table via container)
-- ============================================================================

function M.merge_tables(defaults, overrides)
  return resolve_service("core.table").merge(defaults, overrides)
end

function M.deep_copy(orig)
  return resolve_service("core.table").deep_copy(orig)
end

-- ============================================================================
-- NOTIFICATION (delegated to adapters.notification via container)
-- ============================================================================

function M.notify(msg, level, opts)
  return resolve_service("adapters.notification").notify(msg, level, opts)
end

-- Alias for backwards compatibility
M.log = M.notify

-- ============================================================================
-- ENVIRONMENT (delegated to environment module via container)
-- ============================================================================

function M.is_work_env()
  return resolve_service("environment").get_mode() == "work"
end

function M.is_home_env()
  return resolve_service("environment").get_mode() == "home"
end

function M.get_env()
  return resolve_service("environment").get_mode()
end

-- ============================================================================
-- SAFE MODULE LOADING
-- ============================================================================

function M.safe_require(module, opts)
  opts = opts or {}
  local ok, result = pcall(require, module)

  if not ok then
    if opts.notify ~= false and not opts.silent then
      M.notify(string.format("Failed to load %s", module), "error", { title = "Module Error" })
    end
    return false, opts.fallback or result
  end

  return true, result
end

-- ============================================================================
-- EXPORTS (for compatibility)
-- ============================================================================

-- Re-export core modules for backwards compatibility
M.string_utils = resolve_service
M.io_utils = resolve_service
M.platform_utils = resolve_service
M.table_utils = resolve_service

return M
