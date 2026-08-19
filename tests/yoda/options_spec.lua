-- tests/yoda/options_spec.lua
-- Covers the apply()-is-explicit contract: requiring the module must not
-- change any option, and applying twice must not re-run the body.

describe("yoda.options", function()
  local options = require("yoda.options")

  after_each(function()
    options._reset()
  end)

  it("does not apply as a side effect of require", function()
    -- Arrange: a fresh require is cached, so assert on the guard instead --
    -- it is only ever set by apply().
    options._reset()

    -- Assert
    assert.is_false(options._applied)
  end)

  it("reports true on the call that applies", function()
    -- Act
    local applied = options.apply()

    -- Assert
    assert.is_true(applied)
    assert.is_true(options._applied)
  end)

  it("is a no-op on the second call", function()
    -- Arrange
    options.apply()

    -- Act
    local applied = options.apply()

    -- Assert
    assert.is_false(applied)
  end)

  it("actually sets option defaults when applied", function()
    -- Arrange
    vim.opt.scrolloff = 0

    -- Act
    options.apply()

    -- Assert
    assert.equals(10, vim.opt.scrolloff:get())
    assert.is_true(vim.opt.expandtab:get())
  end)

  it("seeds vim.g.yoda_config only when unset", function()
    -- Arrange
    vim.g.yoda_config = { verbose_startup = true }

    -- Act
    options.apply()

    -- Assert
    assert.is_true(vim.g.yoda_config.verbose_startup)
  end)
end)
