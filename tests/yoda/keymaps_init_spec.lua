-- tests/yoda/keymaps_init_spec.lua
local helpers = require("tests.helpers")

describe("yoda.keymaps (aggregator)", function()
  local keymaps

  before_each(function()
    package.loaded["yoda.keymaps"] = nil
    keymaps = require("yoda.keymaps")
  end)

  it("loads every module and reports no failures on success", function()
    -- Act
    local failed = keymaps.apply()

    -- Assert
    assert.same({}, failed)
  end)

  it("is idempotent -- calling apply() twice does not raise", function()
    -- Act
    local ok = pcall(function()
      keymaps.apply()
      keymaps.apply()
    end)

    -- Assert
    assert.is_true(ok)
  end)

  it(
    "collects a failing module's name and warns, without aborting the rest",
    function()
      -- Arrange: force one module's require to fail as if the file were
      -- missing.
      local broken_module = "yoda.keymaps.help"
      local original_preload = package.preload[broken_module]
      local original_loaded = package.loaded[broken_module]
      package.preload[broken_module] = function()
        error("forced failure for test")
      end
      package.loaded[broken_module] = nil

      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      local failed = keymaps.apply()

      -- Assert
      assert.same({ broken_module }, failed)
      assert.matches(broken_module, notify_data.last_call[1])
      assert.equals(vim.log.levels.WARN, notify_data.last_call[2])

      restore()
      package.preload[broken_module] = original_preload
      package.loaded[broken_module] = original_loaded
    end
  )
end)
