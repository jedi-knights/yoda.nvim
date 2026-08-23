-- tests/yoda/extras/lang/web_spec.lua
local registry = require("yoda.core.lsp_registry")

describe("extras.lang.web", function()
  local specs

  before_each(function()
    registry._reset()
    package.loaded["yoda.extras.lang.web"] = nil
    specs = require("yoda.extras.lang.web")
  end)

  after_each(function()
    registry._reset()
  end)

  it("registers html, cssls, and emmet servers together", function()
    -- Assert: paired because every real front-end file open triggers at
    -- least two of the three; splitting would force users to remember which
    -- to import for a hello-world index.html.
    assert.same(
      { "html", "cssls", "emmet_language_server" },
      registry.servers()
    )
  end)

  it("registers no debug adapters", function()
    -- Assert
    assert.same({}, registry.dap_adapters())
  end)

  it("ships no plugin specs it cannot back with a real integration", function()
    -- Assert: HTML/CSS have no neotest story; formatting is already covered
    -- by the core conform.nvim wiring for prettier.
    for _, spec in ipairs(specs) do
      assert.is_truthy(
        spec.optional,
        "only optional fragments belong in an LSP-only extra: "
          .. tostring(spec[1])
      )
    end
  end)
end)
