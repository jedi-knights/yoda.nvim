-- tests/yoda/extras/lang/web_spec.lua
local registry = require("yoda.core.lsp_registry")
local ts_registry = require("yoda.core.treesitter_registry")
local formatter_registry = require("yoda.core.formatter_registry")

describe("extras.lang.web", function()
  local specs

  before_each(function()
    registry._reset()
    ts_registry._reset()
    formatter_registry._reset()
    package.loaded["yoda.extras.lang.web"] = nil
    specs = require("yoda.extras.lang.web")
  end)

  after_each(function()
    registry._reset()
    ts_registry._reset()
    formatter_registry._reset()
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

  it("contributes html + css + scss treesitter parsers", function()
    -- Assert
    assert.same({ "html", "css", "scss" }, ts_registry.parsers())
  end)

  it("contributes prettier for css and scss", function()
    -- Assert: html -> prettier is core; css/scss are the new additions.
    assert.same({
      css = { "prettier" },
      scss = { "prettier" },
    }, formatter_registry.formatters_by_ft())
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
