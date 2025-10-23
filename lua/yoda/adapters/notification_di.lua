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

  --- Send notification
  --- @param msg string Message to display
  --- @param level string|number Log level ("info", "warn", "error") or vim.log.levels
  --- @param opts table|nil Additional options
  function instance.notify(msg, level, opts)
    -- Validate inputs
    assert(type(msg) == "string", "Message must be a string")

    level = level or "info"
    opts = opts or {}

    -- Get and use appropriate backend
    local backend_name = detect_backend()
    local notify_fn = backends[backend_name]

    -- Convert level to appropriate format for backend
    if backend_name == "native" then
      -- Native expects numeric level
      if type(level) == "string" then
        local level_map = {
          trace = vim.log.levels.TRACE,
          debug = vim.log.levels.DEBUG,
          info = vim.log.levels.INFO,
          warn = vim.log.levels.WARN,
          error = vim.log.levels.ERROR,
        }
        level = level_map[level:lower()] or vim.log.levels.INFO
      end
    else
      -- Snacks/Noice prefer string levels
      if type(level) == "number" then
        local level_names = { [0] = "trace", "debug", "info", "warn", "error" }
        level = level_names[level] or "info"
      end
    end

    -- Call backend with error handling
    local ok, err = pcall(notify_fn, msg, level, opts)
    if not ok then
      -- Fallback to native if backend fails
      vim.notify(msg, vim.log.levels.INFO, opts)
    end
  end

  return instance
end

return M
