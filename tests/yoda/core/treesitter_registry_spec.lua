-- tests/yoda/core/treesitter_registry_spec.lua
-- Covers the contribution point opt-in language extras use to add
-- nvim-treesitter parsers to the core ensure_installed list.

local registry = require("yoda.core.treesitter_registry")

describe("core.treesitter_registry", function()
  before_each(function()
    registry._reset()
  end)

  after_each(function()
    registry._reset()
  end)

  it("starts empty", function()
    -- Assert
    assert.same({}, registry.parsers())
  end)

  it("collects parsers from a single registration", function()
    -- Act
    registry.register({ parsers = { "php", "phpdoc" } })

    -- Assert
    assert.same({ "php", "phpdoc" }, registry.parsers())
  end)

  it("concatenates parsers from multiple registrations", function()
    -- Arrange
    registry.register({ parsers = { "kotlin" } })

    -- Act
    registry.register({ parsers = { "swift" } })

    -- Assert
    assert.same({ "kotlin", "swift" }, registry.parsers())
  end)

  it("de-duplicates a parser registered by two extras", function()
    -- Arrange: html and web both want the html parser, for example.
    registry.register({ parsers = { "html" } })

    -- Act
    registry.register({ parsers = { "html" } })

    -- Assert
    assert.same({ "html" }, registry.parsers())
  end)

  it("accepts an empty registration", function()
    -- Act
    registry.register({})

    -- Assert
    assert.same({}, registry.parsers())
  end)

  it("returns a copy so callers cannot mutate registry state", function()
    -- Arrange
    registry.register({ parsers = { "php" } })

    -- Act
    local parsers = registry.parsers()
    table.insert(parsers, "injected")

    -- Assert
    assert.same({ "php" }, registry.parsers())
  end)

  it("rejects a non-table registration", function()
    -- Act / Assert
    assert.has_error(function()
      registry.register("php")
    end)
  end)
end)
