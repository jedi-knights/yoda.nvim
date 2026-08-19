-- tests/yoda/init_spec.lua
-- Black-box tests for require("yoda").setup(opts) -- the public API entry
-- point consumers call from their lazy.nvim spec's `config` callback (see
-- ARCHITECTURE.md "Bootstrap flow").

local yoda = require("yoda")
local config = require("yoda.config")

describe("yoda.setup()", function()
  before_each(function()
    config._reset()
  end)

  it("resolves defaults when called with no opts", function()
    -- Arrange / Act
    local resolved = yoda.setup()

    -- Assert
    assert.same(config.defaults(), resolved)
  end)

  it("resolves defaults when called with nil", function()
    -- Arrange / Act
    local resolved = yoda.setup(nil)

    -- Assert
    assert.same(config.defaults(), resolved)
  end)

  it("deep-merges user opts over defaults", function()
    -- Arrange / Act
    local resolved = yoda.setup({ ui = { verbose_startup = true } })

    -- Assert: override applied
    assert.is_true(resolved.ui.verbose_startup)
    -- Assert: untouched sibling default preserved
    assert.equals(2, resolved.yaml.env_indent)
  end)

  it("raises on non-table opts", function()
    -- Arrange / Act / Assert
    assert.has_error(function()
      yoda.setup("not a table")
    end)
  end)

  it("makes the resolved config retrievable via yoda.config.get()", function()
    -- Arrange
    yoda.setup({ startup_mode = { enable = false } })

    -- Act
    local resolved = config.get()

    -- Assert
    assert.is_false(resolved.startup_mode.enable)
  end)

  it("is safe to call more than once", function()
    -- Arrange / Act
    local ok = pcall(function()
      yoda.setup({ large_file = { enable = false } })
      yoda.setup({ large_file = { enable = false } })
    end)

    -- Assert
    assert.is_true(ok)
  end)
end)
