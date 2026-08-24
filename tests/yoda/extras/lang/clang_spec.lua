-- tests/yoda/extras/lang/clang_spec.lua
local helpers = require("tests.helpers")
local registry = require("yoda.core.lsp_registry")
local dap_registry = require("yoda.core.dap_registry")
local ts_registry = require("yoda.core.treesitter_registry")
local formatter_registry = require("yoda.core.formatter_registry")
local linter_registry = require("yoda.core.linter_registry")

describe("extras.lang.clang", function()
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
    ts_registry._reset()
    formatter_registry._reset()
    linter_registry._reset()
    package.loaded["yoda.extras.lang.clang"] = nil
    specs = require("yoda.extras.lang.clang")
  end)

  after_each(function()
    registry._reset()
    dap_registry._reset()
    ts_registry._reset()
    formatter_registry._reset()
    linter_registry._reset()
  end)

  it("registers clangd as the shared C/C++ LSP", function()
    -- Assert
    assert.same({ "clangd" }, registry.servers())
  end)

  it(
    "does NOT re-register codelldb -- already in core mason-nvim-dap",
    function()
      -- Assert: registering it again would just duplicate the ensure_installed
      -- entry, so the extra intentionally omits it.
      assert.same({}, registry.dap_adapters())
    end
  )

  it("contributes c + cpp treesitter parsers", function()
    -- Assert
    assert.same({ "c", "cpp" }, ts_registry.parsers())
  end)

  it("contributes clang-format for both c and cpp filetypes", function()
    -- Assert
    assert.same({
      c = { "clang-format" },
      cpp = { "clang-format" },
    }, formatter_registry.formatters_by_ft())
  end)

  it("contributes clangtidy as the c/cpp linter", function()
    -- Assert
    assert.same({
      c = { "clangtidy" },
      cpp = { "clangtidy" },
    }, linter_registry.linters_by_ft())
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

    it("no-ops when codelldb is not installed", function()
      -- Arrange
      local restore = helpers.mock(vim.fn, "executable", function()
        return 0
      end)
      dap_spec.init()
      local fake_dap = { adapters = {}, configurations = {} }

      -- Act
      dap_registry.apply(fake_dap)

      -- Assert
      assert.is_nil(fake_dap.adapters.codelldb)
      assert.is_nil(fake_dap.configurations.c)
      assert.is_nil(fake_dap.configurations.cpp)

      restore()
    end)

    it(
      "wires codelldb adapter and c/cpp configurations when installed",
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
        assert.equals("server", fake_dap.adapters.codelldb.type)
        assert.matches(
          "codelldb$",
          fake_dap.adapters.codelldb.executable.command
        )
        assert.equals(1, #fake_dap.configurations.c)
        assert.equals(1, #fake_dap.configurations.cpp)
        local cfg = fake_dap.configurations.c[1]
        assert.equals("codelldb", cfg.type)
        assert.equals("launch", cfg.request)
        assert.equals("${workspaceFolder}", cfg.cwd)
        assert.is_false(cfg.stopOnEntry)

        restore()
      end
    )
  end)
end)
