-- tests/yoda/extras/lang/java_spec.lua
local helpers = require("tests.helpers")
local registry = require("yoda.core.lsp_registry")
local neotest_registry = require("yoda.core.neotest_registry")

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
    neotest_registry._reset()
    package.loaded["yoda.extras.lang.java"] = nil
    package.loaded["neotest-java"] = nil
    specs = require("yoda.extras.lang.java")
  end)

  after_each(function()
    registry._reset()
    neotest_registry._reset()
    package.loaded["neotest-java"] = nil
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
    assert.is_true(
      vim.tbl_contains(spec.dependencies or {}, "mfussenegger/nvim-dap"),
      "nvim-jdtls must depend on nvim-dap so :JdtlsDebugTest resolves"
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

  describe("neotest-java config()", function()
    local neotest_spec

    before_each(function()
      neotest_spec = by_name("rcasia/neotest-java")
    end)

    it(
      "registers the adapter with neotest_registry when neotest-java loads",
      function()
        -- Arrange
        local fake_adapter = { name = "neotest-java-fake" }
        package.loaded["neotest-java"] = function(_opts)
          return fake_adapter
        end

        -- Act
        neotest_spec.config()

        -- Assert
        assert.equals(1, #neotest_registry.adapters())
        assert.equals(fake_adapter, neotest_registry.adapters()[1])
      end
    )

    it("warns without registering when the adapter factory raises", function()
      -- Arrange
      package.loaded["neotest-java"] = function(_opts)
        error("java factory blew up")
      end
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      neotest_spec.config()

      -- Assert
      assert.matches("Java adapter setup failed", notify_data.last_call[1])
      assert.equals(vim.log.levels.WARN, notify_data.last_call[2])
      assert.equals(0, #neotest_registry.adapters())

      restore()
    end)
  end)
end)
