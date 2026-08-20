-- tests/yoda/extras/lang/csharp_spec.lua
local registry = require("yoda.core.lsp_registry")

describe("extras.lang.csharp", function()
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
    package.loaded["yoda.extras.lang.csharp"] = nil
    specs = require("yoda.extras.lang.csharp")
  end)

  after_each(function()
    registry._reset()
  end)

  it("registers its LSP servers -- omnisharp serves cs and vb", function()
    -- Assert
    assert.same({ "omnisharp" }, registry.servers())
  end)

  it("registers its debug adapters", function()
    -- Assert
    assert.same({ "netcoredbg" }, registry.dap_adapters())
  end)

  it("declares neotest-dotnet", function()
    -- Act
    local spec = by_name("Issafalcon/neotest-dotnet")

    -- Assert
    assert.is_not_nil(spec, "Issafalcon/neotest-dotnet missing from spec list")
  end)

  it("survives its plugins being absent", function()
    -- Arrange: under test none of these plugins are installed, so
    -- config() exercises the require-failed branch.
    -- Act / Assert
    for _, spec in ipairs(specs) do
      if type(spec.config) == "function" then
        local ok = pcall(spec.config)
        assert.is_true(ok, tostring(spec[1]))
      end
    end
  end)
end)
