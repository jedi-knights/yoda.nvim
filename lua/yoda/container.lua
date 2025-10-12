-- lua/yoda/container.lua
-- Lightweight dependency injection container for Yoda.nvim
-- Follows composition root pattern - wire all dependencies here

local M = {}

-- Private registry
local services = {}
local factories = {}
local sealed = false

--- Register a factory function for a service
--- @param name string Service name
--- @param factory function Factory function that creates the service
function M.register(name, factory)
  assert(type(name) == "string" and name ~= "", "Service name must be a non-empty string")
  assert(type(factory) == "function", "Factory must be a function")
  assert(not sealed, "Container is sealed - cannot register more services")

  factories[name] = factory
end

--- Resolve a service by name (lazy instantiation)
--- @param name string Service name
--- @return any Service instance
function M.resolve(name)
  assert(type(name) == "string", "Service name must be a string")

  -- Return cached service if already instantiated
  if services[name] then
    return services[name]
  end

  -- Get factory
  local factory = factories[name]
  if not factory then
    error(string.format("Service not found: %s", name))
  end

  -- Instantiate service (factory can call M.resolve for dependencies)
  local service = factory()
  services[name] = service

  return service
end

--- Check if a service is registered
--- @param name string Service name
--- @return boolean
function M.has(name)
  return factories[name] ~= nil
end

--- Seal the container (prevent further registration)
function M.seal()
  sealed = true
end

--- Reset container (for testing)
function M.reset()
  services = {}
  factories = {}
  sealed = false
end

--- Bootstrap all core services (composition root)
--- @return table Container instance for chaining
function M.bootstrap()
  -- ============================================================================
  -- Level 0: Core Utilities (no dependencies)
  -- ============================================================================

  M.register("core.io", function()
    local IO = require("yoda.core.io_di")
    return IO.new({})
  end)

  M.register("core.platform", function()
    local Platform = require("yoda.core.platform_di")
    return Platform.new({})
  end)

  M.register("core.string", function()
    local String = require("yoda.core.string_di")
    return String.new({})
  end)

  M.register("core.table", function()
    local Table = require("yoda.core.table_di")
    return Table.new({})
  end)

  -- Logging (new in this version - provides unified logging across all modules)
  M.register("logging", function()
    return require("yoda.logging.logger")
  end)

  -- ============================================================================
  -- Level 1: Adapters (depend on core utilities)
  -- ============================================================================

  M.register("adapters.notification", function()
    local Notification = require("yoda.adapters.notification_di")
    return Notification.new({})
  end)

  M.register("adapters.picker", function()
    local Picker = require("yoda.adapters.picker_di")
    return Picker.new({})
  end)

  M.register("window_utils", function()
    return require("yoda.window_utils")
  end)

  -- ============================================================================
  -- Level 2: Domain Modules (depend on core + adapters)
  -- ============================================================================

  M.register("environment", function()
    local Environment = require("yoda.environment")
    -- Could inject notification adapter here in future
    return Environment
  end)

  M.register("terminal.config", function()
    local Config = require("yoda.terminal.config_di")
    return Config.new({
      notify = M.resolve("adapters.notification").notify,
      logger = M.resolve("logging"),
    })
  end)

  M.register("terminal.shell", function()
    local Shell = require("yoda.terminal.shell_di")
    return Shell.new({
      config = M.resolve("terminal.config"),
      notify = M.resolve("adapters.notification").notify,
      logger = M.resolve("logging"),
    })
  end)

  M.register("terminal.venv", function()
    local Venv = require("yoda.terminal.venv_di")
    return Venv.new({
      platform = M.resolve("core.platform"),
      io = M.resolve("core.io"),
      picker = M.resolve("adapters.picker"),
      logger = M.resolve("logging"),
    })
  end)

  M.register("terminal.builder", function()
    return require("yoda.terminal.builder")
  end)

  M.register("terminal", function()
    return require("yoda.terminal")
  end)

  M.register("diagnostics.ai_cli", function()
    return require("yoda.diagnostics.ai_cli")
  end)

  M.register("diagnostics.lsp", function()
    local LSP = require("yoda.diagnostics.lsp_di")
    return LSP.new({
      notify = M.resolve("adapters.notification").notify,
      logger = M.resolve("logging"),
    })
  end)

  M.register("diagnostics.ai", function()
    local AI = require("yoda.diagnostics.ai_di")
    return AI.new({
      ai_cli = M.resolve("diagnostics.ai_cli"),
      notify = M.resolve("adapters.notification").notify,
      logger = M.resolve("logging"),
    })
  end)

  M.register("diagnostics.composite", function()
    return require("yoda.diagnostics.composite")
  end)

  M.register("diagnostics", function()
    return require("yoda.diagnostics")
  end)

  M.register("config_loader", function()
    local loader = require("yoda.config_loader")
    -- config_loader can access logger directly (it's available globally)
    return loader
  end)

  M.register("yaml_parser", function()
    local parser = require("yoda.yaml_parser")
    -- yaml_parser already uses logger directly (migrated)
    return parser
  end)

  -- ============================================================================
  -- Level 3: Application Services
  -- ============================================================================

  M.register("utils", function()
    return require("yoda.utils")
  end)

  -- Seal container after bootstrap to prevent accidental registration
  M.seal()

  return M
end

--- Convenience method: resolve multiple services
--- @param names table Array of service names
--- @return table Map of name -> service
function M.resolve_many(names)
  local result = {}
  for _, name in ipairs(names) do
    result[name] = M.resolve(name)
  end
  return result
end

return M
