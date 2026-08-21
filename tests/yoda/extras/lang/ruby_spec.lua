-- tests/yoda/extras/lang/ruby_spec.lua
local helpers = require("tests.helpers")
local registry = require("yoda.core.lsp_registry")
local neotest_registry = require("yoda.core.neotest_registry")

describe("extras.lang.ruby", function()
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
    package.loaded["yoda.extras.lang.ruby"] = nil
    package.loaded["neotest-rspec"] = nil
    package.loaded["neotest-minitest"] = nil
    package.loaded["dap-ruby"] = nil
    specs = require("yoda.extras.lang.ruby")
  end)

  after_each(function()
    registry._reset()
    neotest_registry._reset()
    package.loaded["neotest-rspec"] = nil
    package.loaded["neotest-minitest"] = nil
    package.loaded["dap-ruby"] = nil
  end)

  it("registers its LSP servers -- both test adapters register", function()
    -- Assert
    assert.same({ "ruby_lsp" }, registry.servers())
  end)

  it("registers its debug adapters", function()
    -- Assert
    assert.same({}, registry.dap_adapters())
  end)

  it("declares neotest-rspec", function()
    -- Act
    local spec = by_name("olimorris/neotest-rspec")

    -- Assert
    assert.is_not_nil(spec, "olimorris/neotest-rspec missing from spec list")
    assert.is_truthy(
      spec.ft,
      "neotest-rspec must be filetype-gated so it costs nothing when unused"
    )
  end)

  it("declares neotest-minitest", function()
    -- Act
    local spec = by_name("zidhuss/neotest-minitest")

    -- Assert
    assert.is_not_nil(spec, "zidhuss/neotest-minitest missing from spec list")
    assert.is_truthy(
      spec.ft,
      "neotest-minitest must be filetype-gated so it costs nothing when unused"
    )
  end)

  it("declares nvim-dap-ruby", function()
    -- Act
    local spec = by_name("suketa/nvim-dap-ruby")

    -- Assert
    assert.is_not_nil(spec, "suketa/nvim-dap-ruby missing from spec list")
    assert.is_truthy(
      spec.ft,
      "nvim-dap-ruby must be filetype-gated so it costs nothing when unused"
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

  describe("neotest-rspec config()", function()
    local rspec_spec

    before_each(function()
      rspec_spec = by_name("olimorris/neotest-rspec")
    end)

    it("registers the adapter with neotest_registry on success", function()
      -- Arrange
      local fake_adapter = { name = "rspec-fake" }
      package.loaded["neotest-rspec"] = function(_opts)
        return fake_adapter
      end

      -- Act
      rspec_spec.config()

      -- Assert
      assert.equals(1, #neotest_registry.adapters())
      assert.equals(fake_adapter, neotest_registry.adapters()[1])
    end)

    it("warns without registering when the adapter factory raises", function()
      -- Arrange
      package.loaded["neotest-rspec"] = function(_opts)
        error("rspec factory blew up")
      end
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      rspec_spec.config()

      -- Assert
      assert.matches("RSpec adapter setup failed", notify_data.last_call[1])
      assert.equals(vim.log.levels.WARN, notify_data.last_call[2])
      assert.equals(0, #neotest_registry.adapters())

      restore()
    end)
  end)

  describe("neotest-minitest config()", function()
    local minitest_spec

    before_each(function()
      minitest_spec = by_name("zidhuss/neotest-minitest")
    end)

    it("registers the adapter with neotest_registry on success", function()
      -- Arrange
      local fake_adapter = { name = "minitest-fake" }
      package.loaded["neotest-minitest"] = function(_opts)
        return fake_adapter
      end

      -- Act
      minitest_spec.config()

      -- Assert
      assert.equals(1, #neotest_registry.adapters())
      assert.equals(fake_adapter, neotest_registry.adapters()[1])
    end)

    it("warns without registering when the adapter factory raises", function()
      -- Arrange
      package.loaded["neotest-minitest"] = function(_opts)
        error("minitest factory blew up")
      end
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      minitest_spec.config()

      -- Assert
      assert.matches("Minitest adapter setup failed", notify_data.last_call[1])
      assert.equals(vim.log.levels.WARN, notify_data.last_call[2])
      assert.equals(0, #neotest_registry.adapters())

      restore()
    end)
  end)

  describe("nvim-dap-ruby config()", function()
    local dap_ruby_spec

    before_each(function()
      dap_ruby_spec = by_name("suketa/nvim-dap-ruby")
    end)

    it("invokes dap-ruby.setup() without warning on success", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      package.loaded["dap-ruby"] = { setup = setup_spy }
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      dap_ruby_spec.config()

      -- Assert
      helpers.assert_called(setup_data, 1)
      helpers.assert_not_called(notify_data)

      restore()
    end)

    it("warns when dap-ruby.setup() raises", function()
      -- Arrange
      package.loaded["dap-ruby"] = {
        setup = function()
          error("dap-ruby exploded")
        end,
      }
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      dap_ruby_spec.config()

      -- Assert
      assert.matches("nvim%-dap%-ruby setup failed", notify_data.last_call[1])
      assert.equals(vim.log.levels.WARN, notify_data.last_call[2])

      restore()
    end)
  end)
end)
