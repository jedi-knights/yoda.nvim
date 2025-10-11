-- examples/di_usage.lua
-- Examples demonstrating Dependency Injection in Yoda.nvim

-- ============================================================================
-- Example 1: Using the Container (Recommended)
-- ============================================================================

local function example_container_usage()
  local Container = require("yoda.container")

  -- Bootstrap all services
  Container.bootstrap()

  -- Resolve and use services
  local io = Container.resolve("core.io")
  local platform = Container.resolve("core.platform")
  local venv = Container.resolve("terminal.venv")

  -- Use services
  print("Platform:", platform.get_platform())
  print("Is file:", io.is_file("init.lua"))

  -- venv now has injected dependencies!
  local venvs = venv.find_virtual_envs()
  print("Found venvs:", vim.inspect(venvs))
end

-- ============================================================================
-- Example 2: Manual Dependency Injection (Testing)
-- ============================================================================

local function example_manual_di()
  -- Create fake dependencies for testing
  local fake_io = {
    is_file = function(path)
      return path == "test.txt"
    end,
    is_dir = function(path)
      return path == "venv"
    end,
  }

  local fake_platform = {
    is_windows = function()
      return false
    end,
  }

  local fake_picker = {
    select = function(items, opts, callback)
      -- Auto-select first item
      callback(items[1])
    end,
  }

  -- Inject fakes
  local VenvDI = require("yoda.terminal.venv_di")
  local venv = VenvDI.new({
    platform = fake_platform,
    io = fake_io,
    picker = fake_picker,
  })

  -- Now we can test with complete control!
  print("Testing with fakes...")
  local path = venv.get_activate_script_path("/test/venv")
  print("Activate path:", path)
end

-- ============================================================================
-- Example 3: Hybrid Approach (Backwards Compatibility)
-- ============================================================================

local function example_hybrid()
  -- Old code still works!
  local utils = require("yoda.utils")
  local terminal = require("yoda.terminal")

  -- These delegate to DI versions through container
  utils.notify("Still works!", "info")
  terminal.open_floating()

  -- New code can use container directly
  local Container = require("yoda.container")
  Container.bootstrap()
  local venv = Container.resolve("terminal.venv")
  venv.find_virtual_envs()
end

-- ============================================================================
-- Example 4: Custom Composition Root
-- ============================================================================

local function example_custom_composition()
  local Container = require("yoda.container")

  -- Clear default registrations
  Container.reset()

  -- Register custom implementations
  Container.register("logger", function()
    return {
      info = function(msg)
        print("[INFO] " .. msg)
      end,
      error = function(msg)
        print("[ERROR] " .. msg)
      end,
    }
  end)

  Container.register("app", function()
    local logger = Container.resolve("logger")
    return {
      run = function()
        logger.info("App running with custom logger!")
      end,
    }
  end)

  -- Use custom composition
  local app = Container.resolve("app")
  app.run()
end

-- ============================================================================
-- Run Examples
-- ============================================================================

print("=== DI Usage Examples ===\n")

print("Example 1: Container Usage")
example_container_usage()

print("\nExample 2: Manual DI (Testing)")
example_manual_di()

print("\nExample 3: Hybrid Approach")
example_hybrid()

print("\nExample 4: Custom Composition")
example_custom_composition()

print("\n=== Examples Complete ===")

