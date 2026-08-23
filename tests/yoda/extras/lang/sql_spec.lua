-- tests/yoda/extras/lang/sql_spec.lua
local registry = require("yoda.core.lsp_registry")

describe("extras.lang.sql", function()
  local specs

  before_each(function()
    registry._reset()
    package.loaded["yoda.extras.lang.sql"] = nil
    specs = require("yoda.extras.lang.sql")
  end)

  after_each(function()
    registry._reset()
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
