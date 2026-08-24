-- tests/yoda/core/formatter_registry_spec.lua
-- Covers the contribution point opt-in language extras use to add formatters
-- and per-filetype formatter lists to conform.nvim without editing the core
-- conform spec.

local registry = require("yoda.core.formatter_registry")

describe("core.formatter_registry", function()
  before_each(function()
    registry._reset()
  end)

  after_each(function()
    registry._reset()
  end)

  it("starts empty", function()
    -- Assert
    assert.same({}, registry.formatters_by_ft())
    assert.same({}, registry.formatters())
  end)

  it("collects per-filetype formatter lists", function()
    -- Act
    registry.register({
      formatters_by_ft = { php = { "php_cs_fixer" } },
    })

    -- Assert
    assert.same({ php = { "php_cs_fixer" } }, registry.formatters_by_ft())
  end)

  it("collects custom formatter definitions", function()
    -- Act: some tools ship a custom command not in conform's built-in
    -- registry -- ktlint via a wrapper script, for example.
    registry.register({
      formatters = {
        ktlint = { command = "ktlint", args = { "--format" } },
      },
    })

    -- Assert
    assert.same(
      { ktlint = { command = "ktlint", args = { "--format" } } },
      registry.formatters()
    )
  end)

  it(
    "concatenates per-filetype lists when two extras target the same ft",
    function()
      -- Arrange: two extras that both want to format html buffers.
      registry.register({ formatters_by_ft = { html = { "prettier" } } })

      -- Act
      registry.register({ formatters_by_ft = { html = { "djlint" } } })

      -- Assert: order preserved so the earlier registration runs first;
      -- users compose the pipeline by extras-load order.
      assert.same(
        { html = { "prettier", "djlint" } },
        registry.formatters_by_ft()
      )
    end
  )

  it(
    "de-duplicates a formatter registered twice for the same filetype",
    function()
      -- Arrange
      registry.register({ formatters_by_ft = { php = { "php_cs_fixer" } } })

      -- Act: same formatter, same ft -- no duplicate entry.
      registry.register({ formatters_by_ft = { php = { "php_cs_fixer" } } })

      -- Assert
      assert.same({ php = { "php_cs_fixer" } }, registry.formatters_by_ft())
    end
  )

  it("keeps distinct filetypes independent when registered together", function()
    -- Act
    registry.register({
      formatters_by_ft = {
        php = { "php_cs_fixer" },
        blade = { "blade_formatter" },
      },
    })

    -- Assert
    assert.same({
      php = { "php_cs_fixer" },
      blade = { "blade_formatter" },
    }, registry.formatters_by_ft())
  end)

  it("first custom-formatter definition wins on collision", function()
    -- Arrange: two extras redefining the same formatter name is a bug in one
    -- of them; do not silently overwrite the earlier registration.
    registry.register({
      formatters = { ktlint = { command = "/opt/one/ktlint" } },
    })

    -- Act
    registry.register({
      formatters = { ktlint = { command = "/opt/two/ktlint" } },
    })

    -- Assert
    assert.equals("/opt/one/ktlint", registry.formatters().ktlint.command)
  end)

  it("accepts a registration carrying only one of the two maps", function()
    -- Act
    registry.register({ formatters_by_ft = { sql = { "sqlfluff" } } })

    -- Assert
    assert.same({ sql = { "sqlfluff" } }, registry.formatters_by_ft())
    assert.same({}, registry.formatters())
  end)

  it("returns copies so callers cannot mutate registry state", function()
    -- Arrange
    registry.register({ formatters_by_ft = { php = { "php_cs_fixer" } } })

    -- Act
    local by_ft = registry.formatters_by_ft()
    by_ft.php[1] = "MUTATED"
    by_ft.injected = { "x" }

    -- Assert
    assert.same({ php = { "php_cs_fixer" } }, registry.formatters_by_ft())
  end)

  it("rejects a non-table registration", function()
    -- Act / Assert
    assert.has_error(function()
      registry.register("prettier")
    end)
  end)
end)
