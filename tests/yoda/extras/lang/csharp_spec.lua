-- tests/yoda/extras/lang/csharp_spec.lua
local helpers = require("tests.helpers")
local registry = require("yoda.core.lsp_registry")
local dap_registry = require("yoda.core.dap_registry")
local neotest_registry = require("yoda.core.neotest_registry")

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
    dap_registry._reset()
    neotest_registry._reset()
    package.loaded["yoda.extras.lang.csharp"] = nil
    package.loaded["neotest-dotnet"] = nil
    specs = require("yoda.extras.lang.csharp")
  end)

  after_each(function()
    registry._reset()
    dap_registry._reset()
    neotest_registry._reset()
    package.loaded["neotest-dotnet"] = nil
  end)

  it("registers its LSP servers -- omnisharp serves cs and vb", function()
    -- Assert
    assert.same({ "omnisharp" }, registry.servers())
  end)

  it("registers its debug adapters", function()
    -- Assert
    assert.same({ "netcoredbg" }, registry.dap_adapters())
  end)

  it("declares neotest-dotnet gated to cs and vb", function()
    -- Act
    local spec = by_name("Issafalcon/neotest-dotnet")

    -- Assert
    assert.is_not_nil(spec, "Issafalcon/neotest-dotnet missing from spec list")
    assert.same({ "cs", "vb" }, spec.ft)
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

  describe("neotest-dotnet config()", function()
    local neotest_spec

    before_each(function()
      neotest_spec = by_name("Issafalcon/neotest-dotnet")
    end)

    it(
      "registers the adapter with neotest_registry when neotest-dotnet loads",
      function()
        -- Arrange
        local fake_adapter = { name = "neotest-dotnet-fake" }
        package.loaded["neotest-dotnet"] = function(_opts)
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
      package.loaded["neotest-dotnet"] = function(_opts)
        error("dotnet factory blew up")
      end
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      neotest_spec.config()

      -- Assert
      assert.matches("%.NET adapter setup failed", notify_data.last_call[1])
      assert.equals(vim.log.levels.WARN, notify_data.last_call[2])
      assert.equals(0, #neotest_registry.adapters())

      restore()
    end)
  end)

  describe("nvim-dap init()", function()
    local dap_spec

    before_each(function()
      dap_spec = by_name("mfussenegger/nvim-dap")
    end)

    it("registers a dap configurator", function()
      -- Act
      dap_spec.init()

      -- Assert
      assert.equals(1, #dap_registry.configurators())
    end)

    it("no-ops when netcoredbg is not installed", function()
      -- Arrange
      local restore = helpers.mock(vim.fn, "executable", function()
        return 0
      end)
      dap_spec.init()
      local fake_dap = { adapters = {}, configurations = {} }

      -- Act
      dap_registry.apply(fake_dap)

      -- Assert
      assert.is_nil(fake_dap.adapters.coreclr)
      assert.is_nil(fake_dap.configurations.cs)
      assert.is_nil(fake_dap.configurations.vb)

      restore()
    end)

    it(
      "wires coreclr adapter and both cs/vb configurations when installed",
      function()
        -- Arrange
        local restore = helpers.mock(vim.fn, "executable", function()
          return 1
        end)
        dap_spec.init()
        local fake_dap = { adapters = {}, configurations = {} }

        -- Act
        dap_registry.apply(fake_dap)

        -- Assert
        assert.equals("executable", fake_dap.adapters.coreclr.type)
        assert.matches("netcoredbg$", fake_dap.adapters.coreclr.command)
        assert.same({ "--interpreter=vscode" }, fake_dap.adapters.coreclr.args)

        for _, ft in ipairs({ "cs", "vb" }) do
          local cfg = fake_dap.configurations[ft]
          assert.is_not_nil(cfg, "missing configuration for " .. ft)
          assert.equals(1, #cfg)
          assert.equals("coreclr", cfg[1].type)
          assert.equals("launch", cfg[1].request)
          assert.equals("Launch - netcoredbg", cfg[1].name)
        end

        restore()
      end
    )
  end)
end)
