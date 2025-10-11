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
    return require("yoda.core.io")
  end)

  M.register("core.platform", function()
    return require("yoda.core.platform")
  end)

  M.register("core.string", function()
    return require("yoda.core.string")
  end)

  M.register("core.table", function()
    return require("yoda.core.table")
  end)

  -- ============================================================================
  -- Level 1: Adapters (depend on core utilities)
  -- ============================================================================

  M.register("adapters.notification", function()
    return require("yoda.adapters.notification")
  end)

  M.register("adapters.picker", function()
    return require("yoda.adapters.picker")
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
    return require("yoda.terminal.config")
  end)

  M.register("terminal.shell", function()
    return require("yoda.terminal.shell")
  end)

  M.register("terminal.venv", function()
    local Venv = require("yoda.terminal.venv")
    -- Dependencies: platform, io, picker (currently using require internally)
    return Venv
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
    return require("yoda.diagnostics.lsp")
  end)

  M.register("diagnostics.ai", function()
    local AI = require("yoda.diagnostics.ai")
    -- Dependencies: ai_cli (currently using require internally)
    return AI
  end)

  M.register("diagnostics.composite", function()
    return require("yoda.diagnostics.composite")
  end)

  M.register("diagnostics", function()
    return require("yoda.diagnostics")
  end)

  M.register("config_loader", function()
    return require("yoda.config_loader")
  end)

  M.register("yaml_parser", function()
    return require("yoda.yaml_parser")
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
