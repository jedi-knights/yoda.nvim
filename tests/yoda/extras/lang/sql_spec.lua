-- tests/yoda/extras/lang/sql_spec.lua
local registry = require("yoda.core.lsp_registry")
local ts_registry = require("yoda.core.treesitter_registry")
local formatter_registry = require("yoda.core.formatter_registry")
local linter_registry = require("yoda.core.linter_registry")

describe("extras.lang.sql", function()
  local specs

  before_each(function()
    registry._reset()
    ts_registry._reset()
    formatter_registry._reset()
    linter_registry._reset()
    package.loaded["yoda.extras.lang.sql"] = nil
    specs = require("yoda.extras.lang.sql")
  end)

  after_each(function()
    registry._reset()
    ts_registry._reset()
    formatter_registry._reset()
    linter_registry._reset()
  end)

  it(
    "registers its LSP servers -- LSP only: no neotest or DAP adapter exists",
    function()
      -- Assert
      assert.same({ "sqlls" }, registry.servers())
    end
  )

  it("registers its debug adapters", function()
    -- Assert
    assert.same({}, registry.dap_adapters())
  end)

  it("contributes sql treesitter parser", function()
    -- Assert
    assert.same({ "sql" }, ts_registry.parsers())
  end)

  it("contributes sql_formatter as the sql formatter", function()
    -- Assert
    assert.same(
      { sql = { "sql_formatter" } },
      formatter_registry.formatters_by_ft()
    )
  end)

  it("contributes sqlfluff as the sql linter", function()
    -- Assert
    assert.same({ sql = { "sqlfluff" } }, linter_registry.linters_by_ft())
  end)

  it("ships no plugin specs it cannot back with a real integration", function()
    -- Assert: inventing a neotest or DAP entry here would surface a
    -- broken test runner rather than an honest absence.
    for _, spec in ipairs(specs) do
      assert.is_truthy(
        spec.optional,
        "only optional fragments belong in an LSP-only extra: "
          .. tostring(spec[1])
      )
    end
  end)
end)
