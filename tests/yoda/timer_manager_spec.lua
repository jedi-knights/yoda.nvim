local helpers = require("tests.helpers")

describe("timer_manager", function()
  local timer_manager
  local original_loop_new_timer
  local original_timer_start

  before_each(function()
    package.loaded["yoda.timer_manager"] = nil

    original_loop_new_timer = vim.uv.new_timer
    original_timer_start = vim.fn.timer_start

    timer_manager = require("yoda.timer_manager")
    timer_manager.reset()
  end)

  after_each(function()
    timer_manager.reset()
    vim.uv.new_timer = original_loop_new_timer
    vim.fn.timer_start = original_timer_start
    package.loaded["yoda.timer_manager"] = nil
  end)

  describe("create_timer", function()
    it("creates a vim.loop timer", function()
      local callback_called = false
      local timer, timer_id = timer_manager.create_timer(function()
        callback_called = true
      end, 100, 0)

      assert.is_not_nil(timer)
      assert.is_not_nil(timer_id)
      assert.is_true(timer_manager.is_timer_active(timer_id))
    end)

    it("wraps callback in pcall for error handling", function()
      local error_callback = function()
        error("Test error")
      end

      local timer, timer_id = timer_manager.create_timer(error_callback, 100, 0)

      assert.is_not_nil(timer)
      assert.is_not_nil(timer_id)
    end)

    it("accepts custom timer ID", function()
      local custom_id = "my_custom_timer"
      local timer, timer_id = timer_manager.create_timer(
        function() end,
        100,
        0,
        custom_id
      )

      assert.equals(custom_id, timer_id)
      assert.is_true(timer_manager.is_timer_active(custom_id))
    end)
  end)

  describe("stop_timer", function()
    it("stops and cleans up timer", function()
      local timer, timer_id = timer_manager.create_timer(function() end, 100, 0)

      assert.is_true(timer_manager.is_timer_active(timer_id))

      timer_manager.stop_timer(timer_id)

      assert.is_false(timer_manager.is_timer_active(timer_id))
    end)

    it("handles stopping non-existent timer gracefully", function()
      local ok = pcall(timer_manager.stop_timer, "non_existent_timer")
      assert.is_true(ok)
    end)
  end)

  describe("create_vim_timer", function()
    it("creates a vim.fn.timer_start timer", function()
      local callback_called = false
      local timer_handle, timer_id = timer_manager.create_vim_timer(function()
        callback_called = true
      end, 100)

      assert.is_not_nil(timer_handle)
      assert.is_not_nil(timer_id)
      assert.is_true(timer_manager.is_vim_timer_active(timer_id))
    end)

    it("accepts custom timer ID", function()
      local custom_id = "my_vim_timer"
      local timer_handle, timer_id = timer_manager.create_vim_timer(
        function() end,
        100,
        custom_id
      )

      assert.equals(custom_id, timer_id)
      assert.is_true(timer_manager.is_vim_timer_active(custom_id))
    end)

    it("wraps callback in pcall for error handling", function()
      local error_callback = function()
        error("Test error")
      end

      local timer_handle, timer_id =
        timer_manager.create_vim_timer(error_callback, 100)

      assert.is_not_nil(timer_handle)
      assert.is_not_nil(timer_id)
    end)
  end)

  describe("stop_vim_timer", function()
    it("stops vim timer", function()
      local timer_handle, timer_id = timer_manager.create_vim_timer(
        function() end,
        100
      )

      assert.is_true(timer_manager.is_vim_timer_active(timer_id))

      timer_manager.stop_vim_timer(timer_id)

      assert.is_false(timer_manager.is_vim_timer_active(timer_id))
    end)

    it("handles stopping non-existent timer gracefully", function()
      local ok = pcall(timer_manager.stop_vim_timer, "non_existent")
      assert.is_true(ok)
    end)
  end)

  describe("stop_all_timers", function()
    it("stops all active timers", function()
      local timer1, id1 = timer_manager.create_timer(function() end, 100, 0)
      local timer2, id2 = timer_manager.create_vim_timer(function() end, 100)

      assert.is_true(timer_manager.is_timer_active(id1))
      assert.is_true(timer_manager.is_vim_timer_active(id2))

      timer_manager.stop_all_timers()

      assert.is_false(timer_manager.is_timer_active(id1))
      assert.is_false(timer_manager.is_vim_timer_active(id2))
    end)

    it("handles empty timer list", function()
      local ok = pcall(timer_manager.stop_all_timers)
      assert.is_true(ok)
    end)
  end)

  describe("get_timer_count", function()
    it("returns correct count of active timers", function()
      local loop_count, vim_count = timer_manager.get_timer_count()
      assert.equals(0, loop_count)
      assert.equals(0, vim_count)

      timer_manager.create_timer(function() end, 100, 0)
      timer_manager.create_vim_timer(function() end, 100)

      loop_count, vim_count = timer_manager.get_timer_count()
      assert.equals(1, loop_count)
      assert.equals(1, vim_count)
    end)
  end)

  describe("get_stats", function()
    it("returns timer statistics", function()
      timer_manager.create_timer(function() end, 100, 0, "timer1")
      timer_manager.create_vim_timer(function() end, 100, "vim_timer1")

      local stats = timer_manager.get_stats()

      assert.is_not_nil(stats)
      assert.is_not_nil(stats.loop_timers)
      assert.is_not_nil(stats.vim_timers)
      assert.is_not_nil(stats.total_created)
      assert.equals(2, stats.total_created)
      assert.equals(1, #stats.loop_timers)
      assert.equals(1, #stats.vim_timers)
    end)
  end)

  describe("setup_cleanup", function()
    it("creates VimLeavePre autocmd", function()
      local autocmd_created = false
      local original_create_autocmd = vim.api.nvim_create_autocmd

      vim.api.nvim_create_autocmd = function(event, opts)
        if event == "VimLeavePre" then
          autocmd_created = true
        end
        return original_create_autocmd(event, opts)
      end

      timer_manager.setup_cleanup()

      vim.api.nvim_create_autocmd = original_create_autocmd

      assert.is_true(autocmd_created)
    end)
  end)

  describe("memory leak prevention", function()
    it("prevents timer leaks by cleaning up on exit", function()
      timer_manager.setup_cleanup()

      timer_manager.create_timer(function() end, 100, 100, "leak_test_1")
      timer_manager.create_vim_timer(function() end, 100, "leak_test_2")

      local loop_count, vim_count = timer_manager.get_timer_count()
      assert.equals(1, loop_count)
      assert.equals(1, vim_count)

      timer_manager.stop_all_timers()

      loop_count, vim_count = timer_manager.get_timer_count()
      assert.equals(0, loop_count)
      assert.equals(0, vim_count)
    end)
  end)

  describe("edge cases exposed by branch instrumentation", function()
    it(
      "wrap_callback notifies with ERROR when the callback raises (L33 truthy)",
      function()
        -- Arrange: create a real timer with a raising callback and wait
        -- long enough for the wrapped pcall to catch it.
        local notify_spy, notify_data = helpers.spy()
        local restore_notify = helpers.mock(vim, "notify", notify_spy)

        -- Act
        local _timer, timer_id = timer_manager.create_timer(function()
          error("simulated timer callback failure")
        end, 10, 0)
        vim.wait(200, function()
          for _, call in ipairs(notify_data.calls) do
            if call[1] and call[1]:find("Timer callback error", 1, true) then
              return true
            end
          end
          return false
        end)

        -- Assert
        local found = false
        for _, call in ipairs(notify_data.calls) do
          if call[1] and call[1]:find("Timer callback error", 1, true) then
            found = true
            assert.is_true(call[1]:find(timer_id, 1, true) ~= nil)
            assert.equals(vim.log.levels.ERROR, call[2])
            break
          end
        end
        assert.is_true(found, "expected 'Timer callback error' notify")

        restore_notify()
      end
    )

    it(
      "create_timer returns nil and notifies when vim.uv.new_timer returns nil (L58 truthy)",
      function()
        -- Arrange
        vim.uv.new_timer = function()
          return nil
        end
        local notify_spy, notify_data = helpers.spy()
        local restore_notify = helpers.mock(vim, "notify", notify_spy)

        -- Act
        local timer, timer_id = timer_manager.create_timer(
          function() end,
          100,
          0,
          "no_timer_test"
        )

        -- Assert
        assert.is_nil(timer)
        assert.is_nil(timer_id)
        local found = false
        for _, call in ipairs(notify_data.calls) do
          if call[1] and call[1]:find("Failed to create timer", 1, true) then
            found = true
            assert.equals(vim.log.levels.ERROR, call[2])
          end
        end
        assert.is_true(found, "expected 'Failed to create timer' notify")

        restore_notify()
      end
    )

    it(
      "create_vim_timer returns nil and notifies when vim.fn.timer_start returns -1 (L123 truthy)",
      function()
        -- Arrange
        vim.fn.timer_start = function()
          return -1
        end
        local notify_spy, notify_data = helpers.spy()
        local restore_notify = helpers.mock(vim, "notify", notify_spy)

        -- Act
        local handle, timer_id = timer_manager.create_vim_timer(
          function() end,
          100,
          "no_vim_timer_test"
        )

        -- Assert
        assert.is_nil(handle)
        assert.is_nil(timer_id)
        local found = false
        for _, call in ipairs(notify_data.calls) do
          if
            call[1] and call[1]:find("Failed to create vim timer", 1, true)
          then
            found = true
            assert.equals(vim.log.levels.ERROR, call[2])
          end
        end
        assert.is_true(found, "expected 'Failed to create vim timer' notify")

        restore_notify()
      end
    )

    it(
      "setup_cleanup's VimLeavePre callback stops every active timer",
      function()
        -- Arrange: register the cleanup autocmd, then create two timers so
        -- there's actually something to stop.
        timer_manager.setup_cleanup()
        timer_manager.create_timer(function() end, 100, 0, "cleanup_test_loop")
        timer_manager.create_vim_timer(function() end, 100, "cleanup_test_vim")
        local loop_before, vim_before = timer_manager.get_timer_count()
        assert.equals(1, loop_before)
        assert.equals(1, vim_before)

        local acs = vim.api.nvim_get_autocmds({
          group = "YodaTimerCleanup",
          event = "VimLeavePre",
        })
        assert.equals(1, #acs, "VimLeavePre autocmd not registered")

        -- Act: invoke the callback directly (VimLeavePre can't be fired in
        -- headless test mode).
        acs[1].callback({})

        -- Assert
        local loop_after, vim_after = timer_manager.get_timer_count()
        assert.equals(0, loop_after)
        assert.equals(0, vim_after)
      end
    )
  end)
end)
