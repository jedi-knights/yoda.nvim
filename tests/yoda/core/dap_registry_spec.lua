-- tests/yoda/core/dap_registry_spec.lua
-- Tests the cross-lazyload DAP configurator semantics. The registry never
-- requires `dap` itself -- the core spec hands the module in -- so a plain
-- table stands in for it here.

local registry = require("yoda.core.dap_registry")

describe("core.dap_registry", function()
  local dap

  before_each(function()
    dap = { adapters = {}, configurations = {} }
    registry._reset()
  end)

  it("does not run a configurator before the core applies", function()
    -- Arrange
    local ran = false

    -- Act
    registry.register(function()
      ran = true
    end)

    -- Assert
    assert.is_false(ran)
    assert.equals(1, #registry.configurators())
  end)

  it("runs queued configurators when the core applies", function()
    -- Arrange
    registry.register(function(d)
      d.adapters["pwa-node"] = { type = "server" }
    end)

    -- Act
    registry.apply(dap)

    -- Assert
    assert.same({ type = "server" }, dap.adapters["pwa-node"])
  end)

  it("runs a configurator immediately when registered after apply", function()
    -- Arrange
    registry.apply(dap)

    -- Act
    registry.register(function(d)
      d.adapters.late = { type = "executable" }
    end)

    -- Assert
    assert.same({ type = "executable" }, dap.adapters.late)
  end)

  it("passes the dap module through to the configurator", function()
    -- Arrange
    local received

    -- Act
    registry.register(function(d)
      received = d
    end)
    registry.apply(dap)

    -- Assert
    assert.equals(dap, received)
  end)

  it("isolates a raising configurator from the ones after it", function()
    -- Arrange
    local reached = false
    registry.register(function()
      error("boom")
    end)
    registry.register(function()
      reached = true
    end)

    -- Act
    local ok = pcall(registry.apply, dap)

    -- Assert
    assert.is_true(ok)
    assert.is_true(reached)
  end)

  it("rejects a non-function configurator", function()
    -- Act / Assert
    assert.has_error(function()
      registry.register({ not_a = "function" })
    end)
  end)

  it("rejects apply() without the dap module", function()
    -- Act / Assert
    assert.has_error(function()
      registry.apply(nil)
    end)
  end)
end)
