-- tests/yoda/extras/lang/kotlin_spec.lua
local helpers = require("tests.helpers")
local registry = require("yoda.core.lsp_registry")
local dap_registry = require("yoda.core.dap_registry")

describe("extras.lang.kotlin", function()
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
    package.loaded["yoda.extras.lang.kotlin"] = nil
    specs = require("yoda.extras.lang.kotlin")
  end)

  after_each(function()
    registry._reset()
    dap_registry._reset()
  end)

  it("registers kotlin_language_server", function()
    -- Assert
    assert.same({ "kotlin_language_server" }, registry.servers())
  end)

  it("registers kotlin-debug-adapter for Mason install", function()
    -- Assert
    assert.same({ "kotlin-debug-adapter" }, registry.dap_adapters())
  end)

  it(
    "ships only DAP wiring beyond the LSP -- no maintained neotest adapter",
    function()
      -- Assert: neotest-kotest is unmaintained; refusing to register an
      -- adapter is more honest than shipping one that surfaces stale errors.
      for _, spec in ipairs(specs) do
        assert.is_truthy(
          spec.optional,
          "only optional fragments belong here without an active adapter: "
            .. tostring(spec[1])
        )
      end
    end
  )

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

    it("no-ops when kotlin-debug-adapter is not installed", function()
      -- Arrange
      local restore = helpers.mock(vim.fn, "executable", function()
        return 0
      end)
      dap_spec.init()
      local fake_dap = { adapters = {}, configurations = {} }

      -- Act
      dap_registry.apply(fake_dap)

      -- Assert
      assert.is_nil(fake_dap.adapters.kotlin)
      assert.is_nil(fake_dap.configurations.kotlin)

      restore()
    end)

    it("wires kotlin adapter and configuration when installed", function()
      -- Arrange
      local restore = helpers.mock(vim.fn, "executable", function()
        return 1
      end)
      dap_spec.init()
      local fake_dap = { adapters = {}, configurations = {} }

      -- Act
      dap_registry.apply(fake_dap)

      -- Assert
      assert.equals("executable", fake_dap.adapters.kotlin.type)
      assert.matches(
        "kotlin%-debug%-adapter$",
        fake_dap.adapters.kotlin.command
      )
      assert.equals(1, #fake_dap.configurations.kotlin)
      local cfg = fake_dap.configurations.kotlin[1]
      assert.equals("kotlin", cfg.type)
      assert.equals("launch", cfg.request)
      assert.equals("${workspaceFolder}", cfg.projectRoot)

      restore()
    end)
  end)
end)
