-- tests/yoda/core/neotest_registry_spec.lua
-- Tests the cross-lazyload adapter registration semantics. Mocks the
-- `neotest` module so setup() calls are captured without a real neotest
-- install on the runtimepath.

local registry = require("yoda.core.neotest_registry")

describe("core.neotest_registry", function()
  local setup_calls

  before_each(function()
    setup_calls = {}
    package.loaded["neotest"] = {
      setup = function(opts)
        table.insert(setup_calls, opts)
      end,
    }
    registry._reset()
  end)

  after_each(function()
    package.loaded["neotest"] = nil
  end)

  it("does not call setup before setup() is invoked", function()
    -- Arrange
    local adapter = { name = "fake" }

    -- Act
    registry.register(adapter)

    -- Assert
    assert.equals(0, #setup_calls)
  end)

  it("calls setup once with base opts + registered adapters", function()
    -- Arrange
    local adapter = { name = "python" }
    registry.register(adapter)

    -- Act
    registry.setup({ output = { enabled = true } })

    -- Assert
    assert.equals(1, #setup_calls)
    assert.same({ adapter }, setup_calls[1].adapters)
    assert.is_true(setup_calls[1].output.enabled)
  end)

  it("re-invokes setup when an adapter registers after core", function()
    -- Arrange
    registry.setup({ output = { enabled = true } })
    assert.equals(1, #setup_calls)

    -- Act
    registry.register({ name = "late" })

    -- Assert
    assert.equals(2, #setup_calls)
    assert.equals("late", setup_calls[2].adapters[1].name)
  end)

  it("preserves base opts across re-invocations", function()
    -- Arrange
    registry.setup({ output = { enabled = true }, custom = "value" })

    -- Act
    registry.register({ name = "adapter" })

    -- Assert
    assert.equals("value", setup_calls[2].custom)
    assert.is_true(setup_calls[2].output.enabled)
  end)

  it("accumulates multiple adapters registered before setup", function()
    -- Arrange
    registry.register({ name = "a" })
    registry.register({ name = "b" })

    -- Act
    registry.setup({})

    -- Assert
    assert.equals(2, #setup_calls[1].adapters)
    assert.equals("a", setup_calls[1].adapters[1].name)
    assert.equals("b", setup_calls[1].adapters[2].name)
  end)

  it("exposes adapters() for inspection", function()
    -- Arrange
    registry.register({ name = "one" })
    registry.register({ name = "two" })

    -- Act
    local adapters = registry.adapters()

    -- Assert
    assert.equals(2, #adapters)
  end)
end)
