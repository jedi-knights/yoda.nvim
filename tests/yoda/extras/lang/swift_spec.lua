-- tests/yoda/extras/lang/swift_spec.lua
local helpers = require("tests.helpers")
local registry = require("yoda.core.lsp_registry")
local ts_registry = require("yoda.core.treesitter_registry")
local formatter_registry = require("yoda.core.formatter_registry")
local linter_registry = require("yoda.core.linter_registry")

describe("extras.lang.swift", function()
  local function load_module()
    package.loaded["yoda.extras.lang.swift"] = nil
    return require("yoda.extras.lang.swift")
  end

  before_each(function()
    registry._reset()
    ts_registry._reset()
    formatter_registry._reset()
    linter_registry._reset()
    package.loaded["yoda.extras.lang.swift"] = nil
  end)

  after_each(function()
    registry._reset()
    ts_registry._reset()
    formatter_registry._reset()
    linter_registry._reset()
  end)

  it("contributes swift treesitter parser", function()
    -- Arrange: avoid unrelated side-effects during load.
    local exec_restore = helpers.mock(vim.fn, "executable", function()
      return 0
    end)
    local schedule_restore = helpers.mock(vim, "schedule", function() end)

    -- Act
    load_module()

    -- Assert
    assert.same({ "swift" }, ts_registry.parsers())

    schedule_restore()
    exec_restore()
  end)

  it("contributes swift_format as the swift formatter", function()
    -- Arrange
    local exec_restore = helpers.mock(vim.fn, "executable", function()
      return 0
    end)
    local schedule_restore = helpers.mock(vim, "schedule", function() end)

    -- Act
    load_module()

    -- Assert
    assert.same(
      { swift = { "swift_format" } },
      formatter_registry.formatters_by_ft()
    )

    schedule_restore()
    exec_restore()
  end)

  it("contributes swiftlint as the swift linter", function()
    -- Arrange
    local exec_restore = helpers.mock(vim.fn, "executable", function()
      return 0
    end)
    local schedule_restore = helpers.mock(vim, "schedule", function() end)

    -- Act
    load_module()

    -- Assert
    assert.same({ swift = { "swiftlint" } }, linter_registry.linters_by_ft())

    schedule_restore()
    exec_restore()
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
