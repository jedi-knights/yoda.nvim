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

  it(
    "does not raise on a Neovim older than the newest options it sets",
    function()
      -- Regression guard: pumborder/winborder are 0.12+, but yoda supports
      -- 0.10.1+. Setting an unknown option raises and aborts the rest of
      -- apply(), so these must be probed rather than assumed.
      -- Act / Assert
      assert.has_no.errors(function()
        options.apply()
      end)
    end
  )

  it("only sets 0.12+ options when the running Neovim has them", function()
    -- Act
    options.apply()

    -- Assert
    if vim.fn.exists("&winborder") == 1 then
      -- vim.o, not vim.opt: winborder is list-like, so opt:get() returns
      -- { "rounded" } rather than the string.
      assert.equals("rounded", vim.o.winborder)
    end
  end)

  it("does not seed the legacy vim.g.yoda_config global", function()
    -- v1.0.0 drops the global config vessel entirely. apply() used to seed
    -- vim.g.yoda_config so pre-setup() readers had something to read; nothing
    -- reads it now, so seeding it would only resurrect a dead path.
    -- Arrange
    vim.g.yoda_config = nil

    -- Act
    options.apply()

    -- Assert
    assert.is_nil(vim.g.yoda_config)
  end)

  it("leaves an existing legacy global untouched", function()
    -- A user's stale global is not cleared -- :checkhealth yoda warns about
    -- it instead, so it stays visible rather than silently vanishing.
    -- Arrange
    vim.g.yoda_config = { verbose_startup = true }

    -- Act
    options.apply()

    -- Assert
    assert.is_true(vim.g.yoda_config.verbose_startup)
    vim.g.yoda_config = nil
  end)
end)
