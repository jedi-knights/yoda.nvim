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

  describe("refresh()", function()
    it("calls gitsigns.refresh when available", function()
      local refresh_called = false
      package.loaded.gitsigns = {
        refresh = function()
          refresh_called = true
        end,
      }

      gitsigns.refresh()

      -- Wait for vim.schedule
      vim.wait(100, function()
        return refresh_called
      end)

      assert.is_true(refresh_called)
    end)

    it("does nothing when gitsigns is not available", function()
      package.loaded.gitsigns = nil
      gitsigns.refresh() -- Should not error
    end)

    it("handles refresh errors gracefully", function()
      package.loaded.gitsigns = {
        refresh = function()
          error("refresh error")
        end,
      }

      gitsigns.refresh() -- Should not throw

      -- Wait for vim.schedule
      vim.wait(100)
    end)
  end)

  describe("refresh_debounced()", function()
    it("calls gitsigns.refresh with debouncing", function()
      local refresh_count = 0
      package.loaded.gitsigns = {
        refresh = function()
          refresh_count = refresh_count + 1
        end,
      }
      vim.bo.buftype = ""

      -- Call multiple times rapidly
      gitsigns.refresh_debounced()
      gitsigns.refresh_debounced()
      gitsigns.refresh_debounced()

      -- Wait for debounce delay
      vim.wait(200, function()
        return refresh_count > 0
      end)

      -- Should only refresh once due to debouncing
      assert.equals(1, refresh_count)
    end)

    it("does nothing when gitsigns is not available", function()
      package.loaded.gitsigns = nil
      vim.bo.buftype = ""
      gitsigns.refresh_debounced() -- Should not error
    end)

    it("skips refresh for special buffer types", function()
      local refresh_called = false
      package.loaded.gitsigns = {
        refresh = function()
          refresh_called = true
        end,
      }
      vim.bo.buftype = "nofile"

      gitsigns.refresh_debounced()

      -- Wait to ensure no refresh happens
      vim.wait(200)
      assert.is_false(refresh_called)
    end)

    it("cancels pending refresh when called again", function()
      local refresh_count = 0
      package.loaded.gitsigns = {
        refresh = function()
          refresh_count = refresh_count + 1
        end,
      }
      vim.bo.buftype = ""

      gitsigns.refresh_debounced()
      vim.wait(50) -- Wait less than debounce delay
      gitsigns.refresh_debounced()

      -- Wait for full debounce delay
      vim.wait(200, function()
        return refresh_count > 0
      end)

      -- Should only refresh once
      assert.equals(1, refresh_count)
    end)

    it("handles refresh errors gracefully", function()
      package.loaded.gitsigns = {
        refresh = function()
          error("refresh error")
        end,
      }
      vim.bo.buftype = ""

      gitsigns.refresh_debounced()

      -- Wait for debounce and schedule
      vim.wait(200)
      -- Should not throw error
    end)
  end)

  describe("reset_timers()", function()
    it("cancels pending refresh timers", function()
      local refresh_count = 0
      package.loaded.gitsigns = {
        refresh = function()
          refresh_count = refresh_count + 1
        end,
      }
      vim.bo.buftype = ""

      gitsigns.refresh_debounced()
      gitsigns.reset_timers()

      -- Wait to ensure no refresh happens
      vim.wait(200)
      assert.equals(0, refresh_count)
    end)

    it("can be called multiple times safely", function()
      gitsigns.reset_timers()
      gitsigns.reset_timers()
      -- Should not error
    end)

    it("handles already stopped timers gracefully", function()
      package.loaded.gitsigns = { refresh = function() end }
      vim.bo.buftype = ""

      gitsigns.refresh_debounced()
      vim.wait(200) -- Let timer complete
      gitsigns.reset_timers() -- Should not error
    end)
  end)

  describe("integration", function()
    it("works with real vim.schedule and timers", function()
      local refresh_sequence = {}
      package.loaded.gitsigns = {
        refresh = function()
          table.insert(refresh_sequence, "refresh")
        end,
      }
      vim.bo.buftype = ""

      -- Call refresh
      table.insert(refresh_sequence, "start")
      gitsigns.refresh()

      -- Wait for schedule
      vim.wait(100, function()
        return #refresh_sequence > 1
      end)

      table.insert(refresh_sequence, "end")

      assert.same({ "start", "refresh", "end" }, refresh_sequence)
    end)

    it("debounced refresh prevents flickering from rapid calls", function()
      local refresh_times = {}
      package.loaded.gitsigns = {
        refresh = function()
          table.insert(refresh_times, vim.loop.hrtime())
        end,
      }
      vim.bo.buftype = ""

      -- Simulate rapid file changes
      for i = 1, 5 do
        gitsigns.refresh_debounced()
        vim.wait(20) -- Less than debounce delay
      end

      -- Wait for debounce to complete
      vim.wait(200, function()
        return #refresh_times > 0
      end)

      -- Should only refresh once despite 5 calls
      assert.equals(1, #refresh_times)
    end)
  end)
end)
