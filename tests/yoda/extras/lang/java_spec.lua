-- tests/yoda/extras/lang/java_spec.lua
local registry = require("yoda.core.lsp_registry")

describe("extras.lang.java", function()
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
    package.loaded["yoda.extras.lang.java"] = nil
    specs = require("yoda.extras.lang.java")
  end)

  after_each(function()
    registry._reset()
  end)

  it(
    "registers its LSP servers -- jdtls is installed out of band, so no server is registered",
    function()
      -- Assert
      assert.same({}, registry.servers())
    end
  )

  it("registers its debug adapters", function()
    -- Assert
    assert.same({ "java-debug-adapter" }, registry.dap_adapters())
  end)

  it("declares nvim-jdtls", function()
    -- Act
    local spec = by_name("mfussenegger/nvim-jdtls")

    -- Assert
    assert.is_not_nil(spec, "mfussenegger/nvim-jdtls missing from spec list")
    assert.is_truthy(
      spec.ft,
      "nvim-jdtls must be filetype-gated so it costs nothing when unused"
    )
  end)

  it("declares neotest-java", function()
    -- Act
    local spec = by_name("rcasia/neotest-java")

    -- Assert
    assert.is_not_nil(spec, "rcasia/neotest-java missing from spec list")
    assert.is_truthy(
      spec.ft,
      "neotest-java must be filetype-gated so it costs nothing when unused"
    )
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
