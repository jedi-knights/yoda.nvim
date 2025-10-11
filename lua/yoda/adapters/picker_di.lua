-- lua/yoda/adapters/picker_di.lua
-- Picker adapter with Dependency Injection
-- Abstracts picker backends (snacks, telescope, native) for Dependency Inversion Principle

local M = {}

--- Create picker adapter instance with dependencies
--- @param deps table|nil Optional {default_backend = string}
--- @return table Picker adapter instance
function M.new(deps)
  deps = deps or {}

  -- Private state (encapsulated via closure)
  local backend = nil
  local initialized = false

  local instance = {}

  -- Backend implementations
  local backends = {
    snacks = function(items, opts, on_choice)
      local ok, snacks = pcall(require, "snacks")
      if ok and snacks.picker then
        snacks.picker.pick({
          items = items,
          prompt = opts.prompt or "Select:",
          format = opts.format_item,
          confirm = function(item)
            on_choice(item)
          end,
        })
      else
        vim.ui.select(items, opts, on_choice)
      end
    end,

    telescope = function(items, opts, on_choice)
      local ok, telescope = pcall(require, "telescope.pickers")
      if ok then
        -- Use telescope picker
        vim.ui.select(items, opts, on_choice)
      else
        vim.ui.select(items, opts, on_choice)
      end
    end,

    native = function(items, opts, on_choice)
      vim.ui.select(items, opts, on_choice)
    end,
  }

  -- ============================================================================
  -- Backend Detection (Singleton Pattern)
  -- ============================================================================

  --- Detect available picker backend
  --- @return string Backend name ("snacks"|"telescope"|"native")
  local function detect_backend()
    -- Return cached backend if already initialized
    if backend and initialized then
      return backend
    end

    -- Check for user configuration
    local user_backend = vim.g.yoda_picker_backend or deps.default_backend
    if user_backend and backends[user_backend] then
      backend = user_backend
      initialized = true
      return backend
    end

    -- Auto-detect: try snacks first
    local ok_snacks, snacks = pcall(require, "snacks")
    if ok_snacks and snacks.picker then
      backend = "snacks"
      initialized = true
      return backend
    end

    -- Try telescope
    local ok_telescope = pcall(require, "telescope")
    if ok_telescope then
      backend = "telescope"
      initialized = true
      return backend
    end

    -- Final fallback: native vim.ui.select
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

  --- Create picker configuration
  --- @param backend_name string Backend name
  --- @return table Picker implementation
  function instance.create(backend_name)
    return backends[backend_name] or backends.native
  end

  --- Show picker with items
  --- @param items table Array of items to select from
  --- @param opts table Options {prompt, format_item}
  --- @param callback function Callback(selected_item)
  function instance.select(items, opts, callback)
    -- Validate inputs
    assert(type(items) == "table", "Items must be a table")
    assert(type(callback) == "function", "Callback must be a function")

    opts = opts or {}

    -- Get and use appropriate backend
    local backend_name = detect_backend()
    local select_fn = backends[backend_name]

    select_fn(items, opts, callback)
  end

  return instance
end

return M
