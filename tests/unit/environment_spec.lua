-- Tests for environment.lua
local environment = require("yoda.environment")

describe("environment", function()
  -- Save originals
  local original_env_yoda = vim.env.YODA_ENV
  local original_env_dev_local = vim.env.YODA_DEV_LOCAL
  local original_config = vim.g.yoda_config
  local original_schedule = vim.schedule

  before_each(function()
    vim.env.YODA_ENV = nil
    vim.env.YODA_DEV_LOCAL = nil
    vim.g.yoda_config = nil
  end)

  after_each(function()
    vim.env.YODA_ENV = original_env_yoda
    vim.env.YODA_DEV_LOCAL = original_env_dev_local
    vim.g.yoda_config = original_config
    vim.schedule = original_schedule
    package.loaded["yoda.utils"] = nil
  end)

  describe("get_mode()", function()
    it("returns 'home' when YODA_ENV is home", function()
      vim.env.YODA_ENV = "home"
      assert.equals("home", environment.get_mode())
    end)

    it("returns 'work' when YODA_ENV is work", function()
      vim.env.YODA_ENV = "work"
      assert.equals("work", environment.get_mode())
    end)

    it("returns 'unknown' when YODA_ENV not set", function()
      vim.env.YODA_ENV = nil
      assert.equals("unknown", environment.get_mode())
    end)

    it("returns 'unknown' when YODA_ENV is empty", function()
      vim.env.YODA_ENV = ""
      assert.equals("unknown", environment.get_mode())
    end)

    it("returns 'unknown' for invalid YODA_ENV", function()
      vim.env.YODA_ENV = "invalid"
      assert.equals("unknown", environment.get_mode())
    end)

    it("is case sensitive", function()
      vim.env.YODA_ENV = "HOME" -- Uppercase
      assert.equals("unknown", environment.get_mode())
    end)
  end)

  describe("show_notification()", function()
    it("does not notify when config disabled", function()
      vim.g.yoda_config = nil -- No config
      vim.env.YODA_ENV = "home"

      local scheduled_fn = nil
      vim.schedule = function(fn)
        scheduled_fn = fn
      end

      environment.show_notification()
      assert.is_nil(scheduled_fn) -- Should not schedule anything
    end)

    it("does not notify when show_environment_notification is false", function()
      vim.g.yoda_config = {
        show_environment_notification = false,
      }
      vim.env.YODA_ENV = "home"

      local scheduled_fn = nil
      vim.schedule = function(fn)
        scheduled_fn = fn
      end

      environment.show_notification()
      assert.is_nil(scheduled_fn)
    end)

    it("notifies for home environment", function()
      vim.g.yoda_config = {
        show_environment_notification = true,
      }
      vim.env.YODA_ENV = "home"

      local notified = false
      local captured_msg = nil

      package.loaded["yoda.utils"] = {
        notify = function(msg, level, opts)
          notified = true
          captured_msg = msg
        end,
      }

      vim.schedule = function(fn)
        fn() -- Execute immediately in tests
      end

      environment.show_notification()
      assert.is_true(notified)
      assert.matches("Home", captured_msg)
      assert.matches("", captured_msg) -- Home icon
    end)

    it("notifies for work environment", function()
      vim.g.yoda_config = {
        show_environment_notification = true,
      }
      vim.env.YODA_ENV = "work"

      local captured_msg = nil

      package.loaded["yoda.utils"] = {
        notify = function(msg, level, opts)
          captured_msg = msg
        end,
      }

      vim.schedule = function(fn)
        fn()
      end

      environment.show_notification()
      assert.matches("Work", captured_msg)
      assert.matches("󰒱", captured_msg) -- Work icon
    end)

    it("passes correct options to notify", function()
      vim.g.yoda_config = {
        show_environment_notification = true,
      }
      vim.env.YODA_ENV = "home"

      local captured_opts = nil

      package.loaded["yoda.utils"] = {
        notify = function(msg, level, opts)
          captured_opts = opts
        end,
      }

      vim.schedule = function(fn)
        fn()
      end

      environment.show_notification()
      assert.equals("Yoda Environment", captured_opts.title)
      assert.equals(2000, captured_opts.timeout)
    end)

    it("uses info level for notifications", function()
      vim.g.yoda_config = {
        show_environment_notification = true,
      }
      vim.env.YODA_ENV = "home"

      local captured_level = nil

      package.loaded["yoda.utils"] = {
        notify = function(msg, level, opts)
          captured_level = level
        end,
      }

      vim.schedule = function(fn)
        fn()
      end

      environment.show_notification()
      assert.equals("info", captured_level)
    end)

    it("schedules notification asynchronously", function()
      vim.g.yoda_config = {
        show_environment_notification = true,
      }

      local scheduled = false
      vim.schedule = function(fn)
        scheduled = true
        -- Don't execute fn
      end

      environment.show_notification()
      assert.is_true(scheduled)
    end)
  end)

  describe("show_local_dev_notification()", function()
    it("does not notify when YODA_DEV_LOCAL is not set", function()
      vim.env.YODA_DEV_LOCAL = nil

      local scheduled_fn = nil
      vim.schedule = function(fn)
        scheduled_fn = fn
      end

      environment.show_local_dev_notification()
      assert.is_nil(scheduled_fn)
    end)

    it("notifies when YODA_DEV_LOCAL is set", function()
      vim.env.YODA_DEV_LOCAL = "1"

      local notified = false
      local captured_msg = nil

      package.loaded["yoda.utils"] = {
        notify = function(msg, level, opts)
          notified = true
          captured_msg = msg
        end,
      }

      vim.schedule = function(fn)
        fn()
      end

      environment.show_local_dev_notification()
      assert.is_true(notified)
      assert.matches("Local Development Mode", captured_msg)
      assert.matches("", captured_msg)
    end)

    it("passes correct options to notify", function()
      vim.env.YODA_DEV_LOCAL = "1"

      local captured_opts = nil

      package.loaded["yoda.utils"] = {
        notify = function(msg, level, opts)
          captured_opts = opts
        end,
      }

      vim.schedule = function(fn)
        fn()
      end

      environment.show_local_dev_notification()
      assert.equals("Yoda Development", captured_opts.title)
      assert.equals(2000, captured_opts.timeout)
    end)

    it("uses info level for notifications", function()
      vim.env.YODA_DEV_LOCAL = "1"

      local captured_level = nil

      package.loaded["yoda.utils"] = {
        notify = function(msg, level, opts)
          captured_level = level
        end,
      }

      vim.schedule = function(fn)
        fn()
      end

      environment.show_local_dev_notification()
      assert.equals("info", captured_level)
    end)

    it("schedules notification asynchronously", function()
      vim.env.YODA_DEV_LOCAL = "1"

      local scheduled = false
      vim.schedule = function(fn)
        scheduled = true
      end

      environment.show_local_dev_notification()
      assert.is_true(scheduled)
    end)
  end)
end)
