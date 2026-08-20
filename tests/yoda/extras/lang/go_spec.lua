-- tests/yoda/extras/lang/go_spec.lua
local helpers = require("tests.helpers")

describe("extras.lang.go", function()
  local specs
  local neotest_registry = require("yoda.core.neotest_registry")

  local function by_name(name)
    for _, spec in ipairs(specs) do
      if spec[1] == name then
        return spec
      end
    end
    return nil
  end

  before_each(function()
    package.loaded["yoda.extras.lang.go"] = nil
    specs = require("yoda.extras.lang.go")
    neotest_registry._reset()
  end)

  after_each(function()
    package.loaded["neotest-golang"] = nil
    neotest_registry._reset()
  end)

  it("declares neotest-golang and nvim-dap-go, both scoped to *.go", function()
    -- Assert
    local neotest_spec = by_name("fredrikaverpil/neotest-golang")
    local dap_spec = by_name("leoluz/nvim-dap-go")
    assert.is_not_nil(neotest_spec)
    assert.equals("go", neotest_spec.ft)
    assert.is_not_nil(dap_spec)
    assert.equals("go", dap_spec.ft)
  end)

  describe("neotest-golang config()", function()
    local neotest_spec

    before_each(function()
      neotest_spec = by_name("fredrikaverpil/neotest-golang")
    end)

    it("warns when neotest-golang is unavailable", function()
      -- Arrange
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      neotest_spec.config()

      -- Assert
      assert.matches("neotest%-golang not available", notify_data.last_call[1])
      assert.equals(0, #neotest_registry.adapters())

      restore()
    end)

    it("registers the adapter when neotest-golang is available", function()
      -- Arrange
      package.loaded["neotest-golang"] = function(opts)
        return { built_with = opts }
      end

      -- Act
      neotest_spec.config()

      -- Assert
      assert.equals(1, #neotest_registry.adapters())
    end)

    it("warns when the adapter constructor raises", function()
      -- Arrange
      package.loaded["neotest-golang"] = function()
        error("boom")
      end
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      neotest_spec.config()

      -- Assert
      assert.matches("Go adapter setup failed", notify_data.last_call[1])
      assert.equals(0, #neotest_registry.adapters())

      restore()
    end)
  end)

  describe("nvim-dap-go keys", function()
    local dap_spec

    before_each(function()
      dap_spec = by_name("leoluz/nvim-dap-go")
    end)

    after_each(function()
      package.loaded["dap-go"] = nil
    end)

    it("<leader>dt debugs the nearest test", function()
      -- Arrange
      local debug_test_spy, debug_test_data = helpers.spy()
      package.loaded["dap-go"] = { debug_test = debug_test_spy }

      -- Act
      dap_spec.keys[1][2]()

      -- Assert
      helpers.assert_called(debug_test_data, 1)
    end)

    it("<leader>dT debugs the last test", function()
      -- Arrange
      local debug_last_spy, debug_last_data = helpers.spy()
      package.loaded["dap-go"] = { debug_last_test = debug_last_spy }

      -- Act
      dap_spec.keys[2][2]()

      -- Assert
      helpers.assert_called(debug_last_data, 1)
    end)
  end)
end)
