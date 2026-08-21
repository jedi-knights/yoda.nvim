-- tests/yoda/extras/lang/perl_spec.lua
local helpers = require("tests.helpers")
local registry = require("yoda.core.lsp_registry")
local dap_registry = require("yoda.core.dap_registry")

describe("extras.lang.perl", function()
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
    package.loaded["yoda.extras.lang.perl"] = nil
    specs = require("yoda.extras.lang.perl")
  end)

  after_each(function()
    registry._reset()
    dap_registry._reset()
  end)

  it(
    "registers its LSP servers -- no neotest adapter exists for Perl",
    function()
      -- Assert
      assert.same({ "perlnavigator" }, registry.servers())
    end
  )

  it("registers its debug adapters", function()
    -- Assert
    assert.same({ "perl-debug-adapter" }, registry.dap_adapters())
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

    it("no-ops when perl-debug-adapter is not installed", function()
      -- Arrange
      local restore = helpers.mock(vim.fn, "executable", function()
        return 0
      end)
      dap_spec.init()
      local fake_dap = { adapters = {}, configurations = {} }

      -- Act
      dap_registry.apply(fake_dap)

      -- Assert
      assert.is_nil(fake_dap.adapters.perlsplit)
      assert.is_nil(fake_dap.configurations.perl)

      restore()
    end)

    it(
      "wires perlsplit adapter and perl configuration when installed",
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
        assert.equals("executable", fake_dap.adapters.perlsplit.type)
        assert.matches(
          "perl%-debug%-adapter$",
          fake_dap.adapters.perlsplit.command
        )
        assert.equals(1, #fake_dap.configurations.perl)
        local cfg = fake_dap.configurations.perl[1]
        assert.equals("perlsplit", cfg.type)
        assert.equals("launch", cfg.request)
        assert.equals("${file}", cfg.program)
        assert.equals("${workspaceFolder}", cfg.cwd)
        assert.is_false(cfg.stopOnEntry)

        restore()
      end
    )
  end)
end)
