local helpers = require("tests.helpers")

describe("integrations.gitsigns batching", function()
  local gitsigns
  local original_hrtime

  before_each(function()
    package.loaded["yoda.integrations.gitsigns"] = nil
    package.loaded["yoda.timer_manager"] = nil

    original_hrtime = vim.loop.hrtime

    local mock_time = 0
    vim.loop.hrtime = function()
      return mock_time
    end

    _G.mock_set_time = function(time_ms)
      mock_time = time_ms * 1000000
    end

    -- Mock gitsigns plugin
    package.loaded.gitsigns = {
      refresh = function() end,
    }

    gitsigns = require("yoda.integrations.gitsigns")
    gitsigns.reset_timers()
    gitsigns.reset_batch_stats()
  end)

  after_each(function()
    vim.loop.hrtime = original_hrtime
    _G.mock_set_time = nil
    gitsigns.reset_timers()
    gitsigns.reset_batch_stats()
    package.loaded["yoda.integrations.gitsigns"] = nil
    package.loaded["yoda.timer_manager"] = nil
    package.loaded.gitsigns = nil
  end)

  describe("refresh_batched()", function()
    it("batches multiple refresh requests", function()
      local refresh_calls = 0
      package.loaded.gitsigns.refresh = function()
        refresh_calls = refresh_calls + 1
      end

      vim.api.nvim_get_current_buf = function()
        return 1
      end

      _G.mock_set_time(0)
      gitsigns.refresh_batched()

      _G.mock_set_time(50)
      gitsigns.refresh_batched()

      _G.mock_set_time(100)
      gitsigns.refresh_batched()

      local stats = gitsigns.get_batch_stats()
      assert.is_true(stats.active, "Batch timer should be active")
      assert.is_true(stats.pending_requests > 0, "Should have pending requests")
    end)

    it("executes batched refresh after window", function()
      local refresh_calls = 0
      local refreshed_buffers = {}

      package.loaded.gitsigns.refresh = function(buf)
        refresh_calls = refresh_calls + 1
        table.insert(refreshed_buffers, buf)
      end

      vim.api.nvim_get_current_buf = function()
        return 1
      end
      vim.api.nvim_buf_is_valid = function()
        return true
      end

      _G.mock_set_time(0)
      gitsigns.refresh_batched()
      gitsigns.refresh_batched()
      gitsigns.refresh_batched()

      -- Wait for batch window to complete
      vim.wait(250)

      local stats = gitsigns.get_batch_stats()
      assert.is_false(stats.active, "Batch timer should be inactive after window")
      assert.equals(1, stats.total_batches, "Should have completed 1 batch")
    end)

    it("deduplicates buffer refresh requests", function()
      local refresh_calls = 0
      local refreshed_buffers = {}

      package.loaded.gitsigns.refresh = function(buf)
        refresh_calls = refresh_calls + 1
        table.insert(refreshed_buffers, buf)
      end

      local call_count = 0
      vim.api.nvim_get_current_buf = function()
        call_count = call_count + 1
        return 1 -- Always same buffer
      end
      vim.api.nvim_buf_is_valid = function()
        return true
      end

      _G.mock_set_time(0)
      gitsigns.refresh_batched() -- Request 1 for buffer 1
      gitsigns.refresh_batched() -- Request 2 for buffer 1
      gitsigns.refresh_batched() -- Request 3 for buffer 1

      vim.wait(250)

      -- Should only refresh buffer 1 once despite 3 requests
      assert.equals(1, refresh_calls, "Should deduplicate and refresh buffer only once")
    end)

    it("handles multiple different buffers", function()
      local refresh_calls = 0
      local refreshed_buffers = {}

      package.loaded.gitsigns.refresh = function(buf)
        refresh_calls = refresh_calls + 1
        table.insert(refreshed_buffers, buf)
      end

      local buffer_sequence = { 1, 2, 3 }
      local seq_index = 1

      vim.api.nvim_get_current_buf = function()
        local buf = buffer_sequence[seq_index]
        seq_index = seq_index + 1
        return buf
      end
      vim.api.nvim_buf_is_valid = function()
        return true
      end

      _G.mock_set_time(0)
      gitsigns.refresh_batched() -- Buffer 1
      gitsigns.refresh_batched() -- Buffer 2
      gitsigns.refresh_batched() -- Buffer 3

      vim.wait(250)

      -- Should refresh all 3 different buffers
      assert.equals(3, refresh_calls, "Should refresh all different buffers")
    end)

    it("skips invalid buffers", function()
      local refresh_calls = 0

      package.loaded.gitsigns.refresh = function()
        refresh_calls = refresh_calls + 1
      end

      vim.api.nvim_get_current_buf = function()
        return 999
      end
      vim.api.nvim_buf_is_valid = function()
        return false
      end

      _G.mock_set_time(0)
      gitsigns.refresh_batched()

      vim.wait(250)

      assert.equals(0, refresh_calls, "Should not refresh invalid buffers")
    end)
  end)

  describe("get_batch_stats()", function()
    it("returns batch statistics", function()
      vim.api.nvim_get_current_buf = function()
        return 1
      end

      _G.mock_set_time(0)
      gitsigns.refresh_batched()

      local stats = gitsigns.get_batch_stats()

      assert.is_not_nil(stats)
      assert.is_not_nil(stats.active)
      assert.is_not_nil(stats.pending_requests)
      assert.is_not_nil(stats.total_batches)
      assert.is_not_nil(stats.window_ms)
      assert.equals(200, stats.window_ms)
    end)
  end)

  describe("reset_batch_stats()", function()
    it("clears batch statistics", function()
      vim.api.nvim_get_current_buf = function()
        return 1
      end

      _G.mock_set_time(0)
      gitsigns.refresh_batched()

      vim.wait(250)

      gitsigns.reset_batch_stats()

      local stats = gitsigns.get_batch_stats()
      assert.equals(0, stats.total_batches)
      assert.equals(0, stats.pending_requests)
    end)
  end)

  describe("performance", function()
    it("reduces refresh calls with batching", function()
      local refresh_calls = 0

      package.loaded.gitsigns.refresh = function()
        refresh_calls = refresh_calls + 1
      end

      vim.api.nvim_get_current_buf = function()
        return 1
      end
      vim.api.nvim_buf_is_valid = function()
        return true
      end

      -- Simulate rapid-fire refresh requests
      _G.mock_set_time(0)
      for i = 1, 10 do
        gitsigns.refresh_batched()
        _G.mock_set_time(i * 20)
      end

      vim.wait(250)

      -- Without batching: 10 refresh calls
      -- With batching: 1 refresh call (all deduped to same buffer)
      assert.equals(1, refresh_calls, "Should batch 10 requests into 1 refresh")
    end)
  end)
end)
