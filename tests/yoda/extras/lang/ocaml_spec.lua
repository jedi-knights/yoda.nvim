-- tests/yoda/extras/lang/ocaml_spec.lua
local registry = require("yoda.core.lsp_registry")

describe("extras.lang.ocaml", function()
  local specs

  local function by_name(plugin)
    for _, spec in ipairs(specs) do
      if spec[1] == plugin then
        return spec
      end
    end
    return nil
  end

  before_each(function()
    registry._reset()
    package.loaded["yoda.extras.lang.ocaml"] = nil
    specs = require("yoda.extras.lang.ocaml")
  end)

  after_each(function()
    registry._reset()
  end)

  it(
    "registers its LSP servers -- LSP only: no neotest or DAP adapter exists",
    function()
      -- Assert
      assert.same({ "ocamllsp" }, registry.servers())
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
