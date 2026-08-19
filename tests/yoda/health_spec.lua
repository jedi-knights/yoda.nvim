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
end)
