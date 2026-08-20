-- tests/yoda/core/lsp_registry_spec.lua
-- Covers the contribution point opt-in language extras use to add LSP servers
-- and debug adapters without re-declaring the core mason spec.

local registry = require("yoda.core.lsp_registry")

describe("core.lsp_registry", function()
  before_each(function()
    registry._reset()
  end)

  after_each(function()
    registry._reset()
  end)

  it("starts empty", function()
    -- Assert
    assert.same({}, registry.servers())
    assert.same({}, registry.dap_adapters())
  end)

  it("collects servers and adapters separately", function()
    -- Act
    registry.register({
      servers = { "ruby_lsp" },
      dap_adapters = { "netcoredbg" },
    })

    -- Assert: the two lists feed different plugins (mason-lspconfig vs
    -- mason-nvim-dap) and must not be conflated.
    assert.same({ "ruby_lsp" }, registry.servers())
    assert.same({ "netcoredbg" }, registry.dap_adapters())
  end)

  it("de-duplicates a server registered by two extras", function()
    -- Arrange: omnisharp serves both cs and vb, so lang.csharp and lang.vbnet
    -- both register it. Listing it twice would ask Mason to install it twice.
    registry.register({ servers = { "omnisharp" } })

    -- Act
    registry.register({ servers = { "omnisharp" } })

    -- Assert
    assert.same({ "omnisharp" }, registry.servers())
  end)

  it("de-duplicates debug adapters the same way", function()
    -- Arrange
    registry.register({ dap_adapters = { "netcoredbg" } })

    -- Act
    registry.register({ dap_adapters = { "netcoredbg" } })

    -- Assert
    assert.same({ "netcoredbg" }, registry.dap_adapters())
  end)

  it("accepts a registration carrying only one of the two lists", function()
    -- Act: LSP-only languages register no adapters at all.
    registry.register({ servers = { "ocamllsp" } })

    -- Assert
    assert.same({ "ocamllsp" }, registry.servers())
    assert.same({}, registry.dap_adapters())
  end)

  it("returns copies so callers cannot mutate registry state", function()
    -- Arrange
    registry.register({ servers = { "cobol_ls" } })

    -- Act
    local servers = registry.servers()
    table.insert(servers, "injected")

    -- Assert
    assert.same({ "cobol_ls" }, registry.servers())
  end)

  it("rejects a non-table registration", function()
    -- Act / Assert
    assert.has_error(function()
      registry.register("ruby_lsp")
    end)
  end)
end)
