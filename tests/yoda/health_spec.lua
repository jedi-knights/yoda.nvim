-- tests/yoda/health_spec.lua
-- Covers the legacy-global reporting. As of v1.0.0 nothing reads
-- vim.g.yoda_*, so a leftover global is a warning, not an informational note.

describe("yoda.health", function()
  local health = require("yoda.health")
  local original_health = vim.health
  local original_config = vim.g.yoda_config

  local calls

  before_each(function()
    calls = { ok = {}, info = {}, warn = {}, error = {} }
    vim.health = {
      start = function() end,
      ok = function(m)
        table.insert(calls.ok, m)
      end,
      info = function(m)
        table.insert(calls.info, m)
      end,
      warn = function(m)
        table.insert(calls.warn, m)
      end,
      error = function(m)
        table.insert(calls.error, m)
      end,
    }
    vim.g.yoda_config = nil
  end)

  after_each(function()
    vim.health = original_health
    vim.g.yoda_config = original_config
  end)

  --- Any reported message containing `needle`, or nil.
  local function find(bucket, needle)
    for _, m in ipairs(bucket) do
      if m:find(needle, 1, true) then
        return m
      end
    end
    return nil
  end

  it("reports ok when no legacy global is set", function()
    -- Act
    health.check()

    -- Assert
    assert.is_not_nil(find(calls.ok, "No legacy vim.g.yoda_* globals set"))
    assert.is_nil(find(calls.warn, "IGNORED"))
  end)

  it("warns that a leftover legacy global is ignored", function()
    -- Arrange
    vim.g.yoda_config = { verbose_startup = true }

    -- Act
    health.check()

    -- Assert: warn, not info -- a global that silently does nothing is
    -- exactly what a health check exists to surface.
    local msg = find(calls.warn, "IGNORED")
    assert.is_not_nil(msg, "expected a warning about the ignored global")
    assert.is_truthy(msg:find("vim.g.yoda_config", 1, true))
    assert.is_nil(find(calls.info, "Legacy globals"))
  end)

  describe("edge cases exposed by branch instrumentation", function()
    it("reports an error when Neovim is older than 0.11 (L34 arm 1)", function()
      -- Arrange: mock vim.fn.has to report 0.11 as unavailable.
      local original_has = vim.fn.has
      vim.fn.has = function(feature)
        if feature == "nvim-0.11" then
          return 0
        end
        return original_has(feature)
      end

      -- Act
      health.check()

      -- Assert
      assert.is_not_nil(find(calls.error, "Neovim 0.11+ required"))

      vim.fn.has = original_has
    end)

    it(
      "reports an error and returns early when yoda.config fails to load (L44)",
      function()
        -- Arrange: force require("yoda.config") to raise.
        local original_loaded = package.loaded["yoda.config"]
        local original_preload = package.preload["yoda.config"]
        package.loaded["yoda.config"] = nil
        package.preload["yoda.config"] = function()
          error("simulated config failure")
        end

        -- Act
        health.check()

        -- Assert
        assert.is_not_nil(
          find(calls.error, "yoda.config module failed to load")
        )
        -- Legacy globals check never runs because we returned early.
        assert.is_nil(find(calls.ok, "No legacy vim.g.yoda_* globals set"))

        package.preload["yoda.config"] = original_preload
        package.loaded["yoda.config"] = original_loaded
      end
    )

    it(
      "reports ok when setup(opts) has been called and config.get() returns truthy (L49 arm 0)",
      function()
        -- Arrange: stub yoda.config so config.get() returns a table.
        local original_loaded = package.loaded["yoda.config"]
        package.loaded["yoda.config"] = {
          get = function()
            return { any_key = true }
          end,
        }

        -- Act
        health.check()

        -- Assert
        assert.is_not_nil(
          find(calls.ok, "using resolved config"),
          "expected the 'using resolved config' ok message"
        )
        assert.is_nil(find(calls.info, "has not been called yet"))

        package.loaded["yoda.config"] = original_loaded
      end
    )

    it("warns when a sibling plugin is not installed (L81 arm 1)", function()
      -- Arrange: force one specific sibling module to fail while leaving
      -- the others alone. Every sibling is preloaded in minimal_init.lua,
      -- so the "not installed" arm never fires unless we simulate it.
      local original_loaded = package.loaded["yoda-terminal"]
      local original_preload = package.preload["yoda-terminal"]
      package.loaded["yoda-terminal"] = nil
      package.preload["yoda-terminal"] = function()
        error("simulated missing sibling")
      end

      -- Act
      health.check()

      -- Assert
      assert.is_not_nil(
        find(calls.warn, "yoda-terminal not installed (optional)"),
        "expected 'yoda-terminal not installed' warn"
      )

      package.preload["yoda-terminal"] = original_preload
      package.loaded["yoda-terminal"] = original_loaded
    end)
  end)
end)
