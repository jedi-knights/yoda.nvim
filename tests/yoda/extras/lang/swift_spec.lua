-- tests/yoda/extras/lang/swift_spec.lua
local helpers = require("tests.helpers")
local registry = require("yoda.core.lsp_registry")

describe("extras.lang.swift", function()
  local function load_module()
    package.loaded["yoda.extras.lang.swift"] = nil
    return require("yoda.extras.lang.swift")
  end

  before_each(function()
    registry._reset()
    package.loaded["yoda.extras.lang.swift"] = nil
  end)

  after_each(function()
    registry._reset()
  end)

  it("does NOT register sourcekit with Mason -- toolchain-provided", function()
    -- Arrange: sourcekit-lsp ships with the Swift toolchain, not Mason.
    local exec_restore = helpers.mock(vim.fn, "executable", function()
      return 1
    end)
    local enable_restore = helpers.mock(vim.lsp, "enable", function() end)

    -- Act
    load_module()

    -- Assert
    assert.same({}, registry.servers())
    assert.same({}, registry.dap_adapters())

    exec_restore()
    enable_restore()
  end)

  it(
    "returns an empty spec list -- no plugins beyond native LSP wiring",
    function()
      -- Arrange
      local exec_restore = helpers.mock(vim.fn, "executable", function()
        return 0
      end)

      -- Act
      local specs = load_module()

      -- Assert
      assert.same({}, specs)

      exec_restore()
    end
  )

  it("enables sourcekit directly when its binary is on PATH", function()
    -- Arrange: bypass Mason for a toolchain-provided LSP by calling
    -- vim.lsp.enable in the extra itself.
    local exec_restore = helpers.mock(vim.fn, "executable", function(name)
      assert.equals("sourcekit-lsp", name)
      return 1
    end)
    local enable_spy, enable_data = helpers.spy()
    local enable_restore = helpers.mock(vim.lsp, "enable", enable_spy)

    -- Act
    load_module()

    -- Assert
    helpers.assert_called(enable_data, 1)
    assert.equals("sourcekit", enable_data.last_call[1])

    exec_restore()
    enable_restore()
  end)

  it("notifies without enabling when sourcekit-lsp is missing", function()
    -- Arrange
    local exec_restore = helpers.mock(vim.fn, "executable", function()
      return 0
    end)
    local enable_spy, enable_data = helpers.spy()
    local enable_restore = helpers.mock(vim.lsp, "enable", enable_spy)
    local notify_spy, notify_data = helpers.spy()
    local notify_restore = helpers.mock(vim, "notify", notify_spy)
    local schedule_restore = helpers.mock(vim, "schedule", function(fn)
      fn()
    end)

    -- Act
    load_module()

    -- Assert
    helpers.assert_not_called(enable_data)
    helpers.assert_called(notify_data, 1)
    assert.matches("sourcekit%-lsp not found", notify_data.last_call[1])
    assert.equals(vim.log.levels.INFO, notify_data.last_call[2])

    schedule_restore()
    notify_restore()
    enable_restore()
    exec_restore()
  end)
end)
