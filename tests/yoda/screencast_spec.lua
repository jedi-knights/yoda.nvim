-- tests/yoda/screencast_spec.lua
local helpers = require("tests.helpers")

describe("yoda.screencast", function()
  local screencast
  local original_has, original_expand, original_mkdir
  local original_jobstart, original_jobstop, original_remove

  --- Records every vim.fn.jobstart call (command list + opts) so tests can
  --- distinguish the screencapture job from the later ffmpeg job and invoke
  --- either one's on_exit callback directly.
  local jobstart_calls
  local next_job_id

  local function stub_jobstart()
    jobstart_calls = {}
    next_job_id = 100
    vim.fn.jobstart = function(cmd, opts)
      table.insert(jobstart_calls, { cmd = cmd, opts = opts })
      next_job_id = next_job_id + 1
      return next_job_id
    end
  end

  before_each(function()
    package.loaded["yoda.screencast"] = nil
    screencast = require("yoda.screencast")

    original_has = vim.fn.has
    original_expand = vim.fn.expand
    original_mkdir = vim.fn.mkdir
    original_jobstart = vim.fn.jobstart
    original_jobstop = vim.fn.jobstop
    original_remove = os.remove

    -- Route the recordings dir under a scratch path instead of the real
    -- $HOME/recordings, and no-op mkdir so tests never touch the real
    -- filesystem.
    vim.fn.expand = function(arg)
      if arg == "~/recordings" then
        return "/tmp/yoda_screencast_spec"
      end
      return original_expand(arg)
    end
    vim.fn.mkdir = function() end

    stub_jobstart()
  end)

  after_each(function()
    vim.fn.has = original_has
    vim.fn.expand = original_expand
    vim.fn.mkdir = original_mkdir
    vim.fn.jobstart = original_jobstart
    vim.fn.jobstop = original_jobstop
    os.remove = original_remove
    pcall(vim.keymap.del, "n", "<leader>tv")
  end)

  describe("setup()", function()
    it("does not register a keymap on non-macOS", function()
      -- Arrange
      vim.fn.has = function()
        return 0
      end

      -- Act
      screencast.setup()

      -- Assert
      local found = false
      for _, km in ipairs(vim.api.nvim_get_keymap("n")) do
        if km.desc == "[T]oggle [V]ideo recording" then
          found = true
        end
      end
      assert.is_false(found)
    end)

    it("registers the toggle keymap on macOS", function()
      -- Arrange
      vim.fn.has = function()
        return 1
      end

      -- Act
      screencast.setup()

      -- Assert
      local found
      for _, km in ipairs(vim.api.nvim_get_keymap("n")) do
        if km.desc == "[T]oggle [V]ideo recording" then
          found = km
        end
      end
      assert.is_not_nil(found)
      assert.equals(screencast.toggle, found.callback)
    end)

    it(
      "only registers the keymap once across repeated setup() calls",
      function()
        -- Arrange
        vim.fn.has = function()
          return 1
        end
        local set_spy, set_data = helpers.spy()
        local original_set = vim.keymap.set
        vim.keymap.set = set_spy

        -- Act
        screencast.setup()
        screencast.setup()

        -- Assert
        assert.equals(1, set_data.call_count)

        vim.keymap.set = original_set
      end
    )
  end)

  describe("toggle()", function()
    it("starts a recording job when not currently recording", function()
      -- Arrange
      local notify_spy, notify_data = helpers.spy()
      local restore_notify = helpers.mock(vim, "notify", notify_spy)

      -- Act
      screencast.toggle()

      -- Assert
      assert.is_true(screencast.is_recording())
      assert.equals(1, #jobstart_calls)
      assert.equals("screencapture", jobstart_calls[1].cmd[1])
      assert.equals("-v", jobstart_calls[1].cmd[2])
      assert.matches(
        "^/tmp/yoda_screencast_spec/nvim_.*%.mov$",
        jobstart_calls[1].cmd[3]
      )
      assert.matches("^Recording started", notify_data.last_call[1])

      restore_notify()
    end)

    it("notifies an error and does not start when jobstart fails", function()
      -- Arrange
      vim.fn.jobstart = function()
        return 0
      end
      local notify_spy, notify_data = helpers.spy()
      local restore_notify = helpers.mock(vim, "notify", notify_spy)

      -- Act
      screencast.toggle()

      -- Assert
      assert.is_false(screencast.is_recording())
      assert.matches("Failed to start screencapture", notify_data.last_call[1])
      assert.equals(vim.log.levels.ERROR, notify_data.last_call[2])

      restore_notify()
    end)

    -- start()'s `output_dir == ""` guard is unreachable via the public
    -- surface: next_output_path() always joins as `dir .. "/nvim_..."`, so
    -- fnamemodify(..., ":h") can never resolve to "" regardless of what
    -- vim.fn.expand("~/recordings") returns -- not tested here.

    it("stops recording and resets state on the second toggle", function()
      -- Arrange
      screencast.toggle() -- start
      local job_id = next_job_id
      local jobstop_spy, jobstop_data = helpers.spy()
      vim.fn.jobstop = jobstop_spy

      -- Act
      screencast.toggle() -- stop

      -- Assert
      assert.is_false(screencast.is_recording())
      helpers.assert_called_with(jobstop_data, job_id)
    end)
  end)

  describe("screencapture -> ffmpeg pipeline", function()
    it("converts to gif and removes the .mov when ffmpeg succeeds", function()
      -- Arrange
      screencast.toggle() -- start: jobstart_calls[1] is screencapture
      local mov_path = jobstart_calls[1].cmd[3]
      local remove_spy, remove_data = helpers.spy()
      os.remove = remove_spy
      local notify_spy, notify_data = helpers.spy()
      local restore_notify = helpers.mock(vim, "notify", notify_spy)

      -- Act: simulate screencapture exiting, which schedules convert_to_gif
      jobstart_calls[1].opts.on_exit(next_job_id, 0)
      vim.wait(50, function()
        return #jobstart_calls == 2
      end)

      -- Assert: ffmpeg was launched against the right files
      assert.equals("ffmpeg", jobstart_calls[2].cmd[1])
      assert.equals(mov_path, jobstart_calls[2].cmd[3])
      local gif_path = mov_path:gsub("%.mov$", ".gif")
      assert.equals(gif_path, jobstart_calls[2].cmd[#jobstart_calls[2].cmd])

      -- Act: simulate ffmpeg succeeding
      jobstart_calls[2].opts.on_exit(next_job_id, 0)
      vim.wait(50, function()
        return remove_data.called
      end)

      -- Assert
      helpers.assert_called_with(remove_data, mov_path)
      assert.matches("^Screencast saved", notify_data.last_call[1])

      restore_notify()
    end)

    it("keeps the raw .mov and warns when ffmpeg fails", function()
      -- Arrange
      screencast.toggle()
      local mov_path = jobstart_calls[1].cmd[3]
      local remove_spy, remove_data = helpers.spy()
      os.remove = remove_spy
      local notify_spy, notify_data = helpers.spy()
      local restore_notify = helpers.mock(vim, "notify", notify_spy)

      -- Act
      jobstart_calls[1].opts.on_exit(next_job_id, 0)
      vim.wait(50, function()
        return #jobstart_calls == 2
      end)
      jobstart_calls[2].opts.on_exit(next_job_id, 1)
      vim.wait(50, function()
        return notify_data.call_count >= 1
      end)

      -- Assert
      helpers.assert_not_called(remove_data)
      assert.matches("ffmpeg conversion failed", notify_data.last_call[1])
      assert.matches(mov_path, notify_data.last_call[1], 1, true)
      assert.equals(vim.log.levels.WARN, notify_data.last_call[2])

      restore_notify()
    end)
  end)
end)
