-- tests/yoda/extras/lang/php_spec.lua
local helpers = require("tests.helpers")
local registry = require("yoda.core.lsp_registry")
local neotest_registry = require("yoda.core.neotest_registry")
local dap_registry = require("yoda.core.dap_registry")
local ts_registry = require("yoda.core.treesitter_registry")
local formatter_registry = require("yoda.core.formatter_registry")
local linter_registry = require("yoda.core.linter_registry")

describe("extras.lang.php", function()
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
    dap_registry._reset()
    ts_registry._reset()
    formatter_registry._reset()
    linter_registry._reset()
    package.loaded["yoda.extras.lang.php"] = nil
    package.loaded["neotest-phpunit"] = nil
    specs = require("yoda.extras.lang.php")
  end)

  after_each(function()
    registry._reset()
    neotest_registry._reset()
    dap_registry._reset()
    ts_registry._reset()
    formatter_registry._reset()
    linter_registry._reset()
    package.loaded["neotest-phpunit"] = nil
  end)

  it("registers intelephense as the LSP", function()
    -- Assert
    assert.same({ "intelephense" }, registry.servers())
  end)

  it("registers php-debug-adapter for Mason install", function()
    -- Assert
    assert.same({ "php-debug-adapter" }, registry.dap_adapters())
  end)

  it("contributes php + phpdoc treesitter parsers", function()
    -- Assert
    assert.same({ "php", "phpdoc" }, ts_registry.parsers())
  end)

  it("contributes php_cs_fixer as the php formatter", function()
    -- Assert
    assert.same(
      { php = { "php_cs_fixer" } },
      formatter_registry.formatters_by_ft()
    )
  end)

  it("contributes phpcs as the php linter", function()
    -- Assert
    assert.same({ php = { "phpcs" } }, linter_registry.linters_by_ft())
  end)

  it("declares neotest-phpunit, filetype-gated to *.php", function()
    -- Act
    local spec = by_name("olimorris/neotest-phpunit")

    -- Assert
    assert.is_not_nil(spec, "olimorris/neotest-phpunit missing from spec list")
    assert.equals("php", spec.ft)
  end)

  it("survives its plugins being absent", function()
    -- Arrange: none of these plugins are installed under test, so config()
    -- exercises the require-failed branch.
    -- Act / Assert
    for _, spec in ipairs(specs) do
      if type(spec.config) == "function" then
        local ok = pcall(spec.config)
        assert.is_true(ok, tostring(spec[1]))
      end
    end
  end)

  describe("neotest-phpunit config()", function()
    local phpunit_spec

    before_each(function()
      phpunit_spec = by_name("olimorris/neotest-phpunit")
    end)

    it("registers the adapter with neotest_registry on success", function()
      -- Arrange
      local fake_adapter = { name = "phpunit-fake" }
      package.loaded["neotest-phpunit"] = function(_opts)
        return fake_adapter
      end

      -- Act
      phpunit_spec.config()

      -- Assert
      assert.equals(1, #neotest_registry.adapters())
      assert.equals(fake_adapter, neotest_registry.adapters()[1])
    end)

    it("warns without registering when the adapter factory raises", function()
      -- Arrange
      package.loaded["neotest-phpunit"] = function(_opts)
        error("phpunit factory blew up")
      end
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      phpunit_spec.config()

      -- Assert
      assert.matches("PHPUnit adapter setup failed", notify_data.last_call[1])
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

    it("no-ops when php-debug-adapter is not installed", function()
      -- Arrange
      local restore = helpers.mock(vim.fn, "executable", function()
        return 0
      end)
      dap_spec.init()
      local fake_dap = { adapters = {}, configurations = {} }

      -- Act
      dap_registry.apply(fake_dap)

      -- Assert
      assert.is_nil(fake_dap.adapters.php)
      assert.is_nil(fake_dap.configurations.php)

      restore()
    end)

    it("wires php adapter and configuration when installed", function()
      -- Arrange
      local restore = helpers.mock(vim.fn, "executable", function()
        return 1
      end)
      dap_spec.init()
      local fake_dap = { adapters = {}, configurations = {} }

      -- Act
      dap_registry.apply(fake_dap)

      -- Assert
      assert.equals("executable", fake_dap.adapters.php.type)
      assert.matches("php%-debug%-adapter$", fake_dap.adapters.php.command)
      assert.equals(1, #fake_dap.configurations.php)
      local cfg = fake_dap.configurations.php[1]
      assert.equals("php", cfg.type)
      assert.equals("launch", cfg.request)
      assert.equals(9003, cfg.port)

      restore()
    end)
  end)
end)
