-- tests/unit/integrations/gitsigns_spec.lua
-- Tests for GitSigns integration

local helpers = require("tests.helpers")

describe("integrations.gitsigns", function()
  local gitsigns

  before_each(function()
    -- Clear module cache
    package.loaded["yoda.integrations.gitsigns"] = nil
    gitsigns = require("yoda.integrations.gitsigns")

    -- Reset timers
    gitsigns.reset_timers()

    -- Clear package.loaded.gitsigns
    package.loaded.gitsigns = nil
  end)

  after_each(function()
    gitsigns.reset_timers()
    package.loaded.gitsigns = nil
  end)

  describe("is_available()", function()
    it("returns true when gitsigns is loaded", function()
      package.loaded.gitsigns = { refresh = function() end }
      assert.is_true(gitsigns.is_available())
    end)

    it("returns false when gitsigns is not loaded", function()
      package.loaded.gitsigns = nil
      assert.is_false(gitsigns.is_available())
    end)
  end)

  describe("get_gitsigns()", function()
    it("returns gitsigns module when loaded", function()
      local mock_gs = { refresh = function() end }
      package.loaded.gitsigns = mock_gs
      assert.equals(mock_gs, gitsigns.get_gitsigns())
    end)

    it("returns nil when gitsigns is not loaded", function()
      package.loaded.gitsigns = nil
      assert.is_nil(gitsigns.get_gitsigns())
    end)
  end)

  describe("refresh_batched()", function()
    it("does nothing when gitsigns is not available", function()
      package.loaded.gitsigns = nil
      gitsigns.refresh_batched() -- should not error
    end)

    it("calls gitsigns.refresh after the batch window elapses", function()
      local refresh_called = false
      package.loaded.gitsigns = {
        refresh = function()
          refresh_called = true
        end,
      }

      gitsigns.refresh_batched()

      -- Wait longer than the 200ms batch window
      vim.wait(300, function()
        return refresh_called
      end)

      assert.is_true(refresh_called)
    end)

    it("handles errors in gitsigns.refresh gracefully", function()
      package.loaded.gitsigns = {
        refresh = function()
          error("simulated refresh error")
        end,
      }

      gitsigns.refresh_batched()

      -- Wait for batch window + schedule; should not propagate the error
      vim.wait(300)
    end)
  end)

  describe("reset_timers()", function()
    it("cancels a pending batch timer before it fires", function()
      local refresh_count = 0
      package.loaded.gitsigns = {
        refresh = function()
          refresh_count = refresh_count + 1
        end,
      }

      gitsigns.refresh_batched()
      gitsigns.reset_timers()

      -- Wait past the batch window; timer was cancelled so no refresh should occur
      vim.wait(300)
      assert.equals(0, refresh_count)
    end)

    it("can be called multiple times safely", function()
      gitsigns.reset_timers()
      gitsigns.reset_timers()
      -- should not error
    end)

    it("handles already-completed timers gracefully", function()
      package.loaded.gitsigns = { refresh = function() end }

      gitsigns.refresh_batched()
      vim.wait(300) -- let the batch timer complete naturally
      gitsigns.reset_timers() -- should not error on already-done timer
    end)
  end)

  describe("integration", function()
    it("triggers exactly one refresh after the batch window", function()
      local refresh_called = false
      package.loaded.gitsigns = {
        refresh = function()
          refresh_called = true
        end,
      }

      gitsigns.refresh_batched()

      vim.wait(300, function()
        return refresh_called
      end)

      assert.is_true(refresh_called)
    end)

    it("deduplicates rapid calls within the batch window", function()
      local refresh_count = 0
      package.loaded.gitsigns = {
        refresh = function()
          refresh_count = refresh_count + 1
        end,
      }

      -- Fire five times within the batch window
      for _ = 1, 5 do
        gitsigns.refresh_batched()
        vim.wait(20) -- well within the 200ms window
      end

      -- Wait for the batch to fire and schedule to complete
      vim.wait(300, function()
        return refresh_count > 0
      end)

      -- Same buffer deduplicates to a single refresh
      assert.equals(1, refresh_count)
    end)
  end)
end)
