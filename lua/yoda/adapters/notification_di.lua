-- lua/yoda/adapters/notification_di.lua
-- Notification adapter with Dependency Injection
-- Abstracts notification backends (noice, snacks, native) for Dependency Inversion Principle

local M = {}

--- Create notification adapter instance with dependencies
--- @param deps table|nil Optional {default_backend = string}
--- @return table Notification adapter instance
function M.new(deps)
  deps = deps or {}

  -- Private state (encapsulated via closure)
  local backend = nil
  local initialized = false

  local instance = {}

  -- Backend implementations
  local backends = {
    noice = function(msg, level, opts)
      local ok, noice = pcall(require, "noice")
      if ok then
        noice.notify(msg, level, opts)
      else
        vim.notify(msg, level, opts)
      end
    end,

    snacks = function(msg, level, opts)
      local ok, snacks = pcall(require, "snacks")
      if ok and snacks.notifier then
        snacks.notifier.notify(msg, level, opts)
      else
        vim.notify(msg, level, opts)
      end
    end,

    native = function(msg, level, opts)
      vim.notify(msg, level, opts)
    end,
  }

  -- ============================================================================
  -- Backend Detection (Singleton Pattern)
  -- ============================================================================

  --- Detect available notification backend
  --- @return string Backend name ("noice"|"snacks"|"native")
  local function detect_backend()
    -- Return cached backend if already initialized
    if backend and initialized then
      return backend
    end

    -- Check for user configuration
    local config = require("yoda.config")
    local user_backend = config.get_notify_backend() or deps.default_backend
    if user_backend and backends[user_backend] then
      backend = user_backend
      initialized = true
      return backend
    end

    -- Auto-detect: try noice first
    local ok_noice = pcall(require, "noice")
    if ok_noice then
      backend = "noice"
      initialized = true
      return backend
    end

    -- Fall back to snacks
    local ok_snacks, snacks = pcall(require, "snacks")
    if ok_snacks and snacks.notifier then
      backend = "snacks"
      initialized = true
      return backend
    end

    -- Final fallback: native vim.notify
    backend = "native"
    initialized = true
    return backend
  end

  -- ============================================================================
  -- Level Conversion Helpers (Complexity: 2 each)
  -- ============================================================================

  --- Convert level to numeric format (for native backend)
  --- @param level string|number Level to convert
  --- @return number Numeric level
  local function convert_to_numeric_level(level)
    if type(level) == "number" then
      return level
    end

    local level_map = {
      trace = vim.log.levels.TRACE,
      debug = vim.log.levels.DEBUG,
      info = vim.log.levels.INFO,
      warn = vim.log.levels.WARN,
      error = vim.log.levels.ERROR,
    }
    return level_map[level:lower()] or vim.log.levels.INFO
  end

  --- Convert level to string format (for snacks/noice backends)
  --- @param level string|number Level to convert
  --- @return string String level
  local function convert_to_string_level(level)
    if type(level) == "string" then
      return level
    end

    local level_names = { [0] = "trace", "debug", "info", "warn", "error" }
    return level_names[level] or "info"
  end

  --- Convert level for specific backend (Complexity: 1)
  --- @param level string|number Level to convert
  --- @param backend_name string Backend name
  --- @return string|number Converted level
  local function convert_level_for_backend(level, backend_name)
    if backend_name == "native" then
      return convert_to_numeric_level(level)
    else
      return convert_to_string_level(level)
    end
  end

  -- ============================================================================
  -- Public API
  -- ============================================================================

  --- Get current backend name
  --- @return string
  function instance.get_backend()
    return detect_backend()
  end

  --- Set backend explicitly
  --- @param backend_name string Backend to use
  function instance.set_backend(backend_name)
    if backends[backend_name] then
      backend = backend_name
      initialized = true
    else
      error("Unknown backend: " .. backend_name)
    end
  end

  --- Reset backend detection (for testing)
  function instance.reset_backend()
    backend = nil
    initialized = false
  end

  --- Send notification (Complexity: 2)
  --- @param msg string Message to display
  --- @param level string|number Log level ("info", "warn", "error") or vim.log.levels
  --- @param opts table|nil Additional options
  function instance.notify(msg, level, opts)
    -- Validate inputs
    assert(type(msg) == "string", "Message must be a string")

    level = level or "info"
    opts = opts or {}

    -- Get backend and convert level
    local backend_name = detect_backend()
    local converted_level = convert_level_for_backend(level, backend_name)
    local notify_fn = backends[backend_name]

    -- Call backend with error handling
    local ok, err = pcall(notify_fn, msg, converted_level, opts)
    if not ok then
      -- Fallback to native if backend fails
      vim.notify(msg, vim.log.levels.INFO, opts)
    end
  end

  return instance
end

return M
