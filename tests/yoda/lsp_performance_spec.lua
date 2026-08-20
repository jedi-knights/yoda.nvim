-- tests/yoda/lsp_performance_spec.lua
local helpers = require("tests.helpers")

describe("lsp_performance", function()
  local lsp_perf

  before_each(function()
    package.loaded["yoda.lsp_performance"] = nil
    lsp_perf = require("yoda.lsp_performance")
  end)

  --- Returns a start_time such that vim.uv.hrtime() - start_time is at least
  --- elapsed_ms milliseconds, without stubbing the clock.
  local function start_time_for(elapsed_ms)
    return vim.uv.hrtime() - (elapsed_ms * 1000000)
  end

  describe("track_lsp_attach()", function()
    it("accumulates total, count, max, and min across calls", function()
      -- Arrange / Act
      lsp_perf.track_lsp_attach("gopls", start_time_for(10))
      lsp_perf.track_lsp_attach("gopls", start_time_for(50))

      -- Assert
      local metric = lsp_perf.get_report().attach_times.gopls
      assert.equals(2, metric.count)
      assert.is_true(metric.total >= 60)
      assert.is_true(metric.max >= 50)
      assert.is_true(metric.min >= 10 and metric.min < 50)
    end)

    it("tracks separate servers independently", function()
      -- Act
      lsp_perf.track_lsp_attach("gopls", start_time_for(5))
      lsp_perf.track_lsp_attach("lua_ls", start_time_for(5))

      -- Assert
      local attach_times = lsp_perf.get_report().attach_times
      assert.equals(1, attach_times.gopls.count)
      assert.equals(1, attach_times.lua_ls.count)
    end)

    it("warns when an attach takes longer than 500ms", function()
      -- Arrange
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      lsp_perf.track_lsp_attach("gopls", start_time_for(600))

      -- Assert
      helpers.assert_called(spy_data, 1)
      assert.matches("Slow LSP attach: gopls", spy_data.last_call[1])
      assert.equals(vim.log.levels.WARN, spy_data.last_call[2])

      restore()
    end)

    it("does not warn when an attach is fast", function()
      -- Arrange
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      lsp_perf.track_lsp_attach("gopls", start_time_for(1))

      -- Assert
      helpers.assert_not_called(spy_data)

      restore()
    end)
  end)

  describe("track_venv_detection()", function()
    it("creates a new entry on first detection for a root_dir", function()
      -- Act
      lsp_perf.track_venv_detection("/proj/a", start_time_for(5), true)

      -- Assert
      local metric = lsp_perf.get_report().venv_detection["/proj/a"]
      assert.equals(1, metric.count)
      assert.equals(1, metric.found)
    end)

    it(
      "accumulates across repeated detections for the same root_dir",
      function()
        -- Act
        lsp_perf.track_venv_detection("/proj/a", start_time_for(5), true)
        lsp_perf.track_venv_detection("/proj/a", start_time_for(5), false)

        -- Assert
        local metric = lsp_perf.get_report().venv_detection["/proj/a"]
        assert.equals(2, metric.count)
        assert.equals(1, metric.found)
      end
    )

    it("evicts the oldest root_dir once past the 50-entry cap", function()
      -- Arrange: fill exactly to the cap with distinct roots
      for i = 1, 50 do
        lsp_perf.track_venv_detection("/proj/" .. i, start_time_for(1), false)
      end

      -- Act: one more distinct root pushes past the cap
      lsp_perf.track_venv_detection("/proj/51", start_time_for(1), false)

      -- Assert: the oldest (1) is gone, the newest (51) is present, and the
      -- table never exceeds the cap.
      local venv_detection = lsp_perf.get_report().venv_detection
      assert.is_nil(venv_detection["/proj/1"])
      assert.is_not_nil(venv_detection["/proj/51"])
      assert.equals(50, vim.tbl_count(venv_detection))
    end)
  end)

  describe("track_lsp_restart()", function()
    it("increments the restart count for a server", function()
      -- Act
      lsp_perf.track_lsp_restart("gopls")
      lsp_perf.track_lsp_restart("gopls")

      -- Assert
      assert.equals(2, lsp_perf.get_report().restarts.gopls)
    end)

    it("does not warn at or below 5 restarts", function()
      -- Arrange
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      for _ = 1, 5 do
        lsp_perf.track_lsp_restart("gopls")
      end

      -- Assert
      helpers.assert_not_called(spy_data)

      restore()
    end)

    it("warns once restarts exceed 5", function()
      -- Arrange
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      for _ = 1, 6 do
        lsp_perf.track_lsp_restart("gopls")
      end

      -- Assert
      helpers.assert_called(spy_data, 1)
      assert.matches("restarted 6 times", spy_data.last_call[1])

      restore()
    end)
  end)

  describe("track_config_time()", function()
    it("accumulates total, count, and max", function()
      -- Act
      lsp_perf.track_config_time("gopls", start_time_for(5))
      lsp_perf.track_config_time("gopls", start_time_for(15))

      -- Assert
      local metric = lsp_perf.get_report().config_times.gopls
      assert.equals(2, metric.count)
      assert.is_true(metric.max >= 15)
    end)
  end)

  describe("reset_metrics()", function()
    it("clears every tracked metric", function()
      -- Arrange
      lsp_perf.track_lsp_attach("gopls", start_time_for(5))
      lsp_perf.track_venv_detection("/proj/a", start_time_for(5), true)
      lsp_perf.track_lsp_restart("gopls")
      lsp_perf.track_config_time("gopls", start_time_for(5))

      -- Act
      lsp_perf.reset_metrics()

      -- Assert
      local report = lsp_perf.get_report()
      assert.equals(0, vim.tbl_count(report.attach_times))
      assert.equals(0, vim.tbl_count(report.venv_detection))
      assert.equals(0, vim.tbl_count(report.restarts))
      assert.equals(0, vim.tbl_count(report.config_times))
    end)
  end)

  describe("setup_commands()", function()
    before_each(function()
      pcall(vim.api.nvim_del_user_command, "LSPPerfReport")
      pcall(vim.api.nvim_del_user_command, "LSPPerfReset")
      lsp_perf.setup_commands()
    end)

    after_each(function()
      pcall(vim.api.nvim_del_user_command, "LSPPerfReport")
      pcall(vim.api.nvim_del_user_command, "LSPPerfReset")
    end)

    it("registers LSPPerfReport and LSPPerfReset", function()
      -- Assert
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.LSPPerfReport)
      assert.is_not_nil(commands.LSPPerfReset)
    end)

    it(
      "reports 'no data recorded' placeholders when nothing was tracked",
      function()
        -- Arrange
        local spy_fn, spy_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", spy_fn)

        -- Act
        vim.cmd("LSPPerfReport")

        -- Assert
        helpers.assert_called(spy_data, 1)
        local report_text = spy_data.last_call[1]
        assert.matches("No LSP attaches recorded", report_text)
        assert.matches("No venv detections recorded", report_text)
        assert.matches("No LSP restarts recorded", report_text)
        assert.matches("No config times recorded", report_text)

        restore()
      end
    )

    it(
      "reports formatted metrics, restart status, and venv success rate",
      function()
        -- Arrange
        lsp_perf.track_lsp_attach("gopls", start_time_for(5))
        lsp_perf.track_venv_detection("/proj/a", start_time_for(5), true)
        for _ = 1, 6 do
          lsp_perf.track_lsp_restart("gopls")
        end
        lsp_perf.track_config_time("gopls", start_time_for(5))

        local spy_fn, spy_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", spy_fn)

        -- Act
        vim.cmd("LSPPerfReport")

        -- Assert
        local report_text = spy_data.last_call[1]
        assert.matches("gopls: avg=", report_text)
        assert.matches("success=100%.0%%", report_text)
        assert.matches("%[warning%] gopls: 6 restarts", report_text)

        restore()
      end
    )

    it("LSPPerfReset clears metrics and notifies", function()
      -- Arrange
      lsp_perf.track_lsp_restart("gopls")
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("LSPPerfReset")

      -- Assert
      helpers.assert_called(spy_data, 1)
      assert.matches("metrics reset", spy_data.last_call[1])
      assert.equals(0, vim.tbl_count(lsp_perf.get_report().restarts))

      restore()
    end)
  end)
end)
