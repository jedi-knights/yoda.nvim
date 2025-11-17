-- Tests for adapters/notification.lua
local notification = require("yoda-adapters.notification")

describe("adapters.notification", function()
  -- Save originals
  local original_notify = vim.notify
  local original_print = print
  local original_yoda_backend = vim.g.yoda_notify_backend

  -- Reset before each test
  before_each(function()
    notification.reset_backend()
    vim.g.yoda_notify_backend = nil
    package.loaded["noice"] = nil
    package.loaded["snacks"] = nil
  end)

  -- Restore after each test
  after_each(function()
    vim.notify = original_notify
    print = original_print
    vim.g.yoda_notify_backend = original_yoda_backend
    notification.reset_backend()
    package.loaded["noice"] = nil
    package.loaded["snacks"] = nil
  end)

  describe("detect_backend()", function()
    it("prefers user-configured backend", function()
      vim.g.yoda_notify_backend = "native"

      local backend = notification.get_backend()
      assert.equals("native", backend)
    end)

    it("detects noice when available", function()
      package.loaded["noice"] = {
        notify = function() end,
      }

      local backend = notification.get_backend()
      assert.equals("noice", backend)
    end)

    it("falls back to snacks when noice not available", function()
      package.loaded["snacks"] = {
        notify = function() end,
      }

      local backend = notification.get_backend()
      assert.equals("snacks", backend)
    end)

    it("falls back to native when no plugins available", function()
      -- Ensure no plugins loaded
      package.loaded["noice"] = nil
      package.loaded["snacks"] = nil

      local backend = notification.get_backend()
      assert.equals("native", backend)
    end)

    it("caches backend detection (singleton)", function()
      package.loaded["noice"] = {
        notify = function() end,
      }

      local backend1 = notification.get_backend()

      -- Remove noice
      package.loaded["noice"] = nil

      -- Should still return noice (cached)
      local backend2 = notification.get_backend()
      assert.equals(backend1, backend2)
      assert.equals("noice", backend2)
    end)
  end)

  describe("set_backend()", function()
    it("sets backend to noice", function()
      notification.set_backend("noice")
      assert.equals("noice", notification.get_backend())
    end)

    it("sets backend to snacks", function()
      notification.set_backend("snacks")
      assert.equals("snacks", notification.get_backend())
    end)

    it("sets backend to native", function()
      notification.set_backend("native")
      assert.equals("native", notification.get_backend())
    end)

    it("errors on unknown backend", function()
      local ok, err = pcall(function()
        notification.set_backend("unknown")
      end)
      assert.is_false(ok)
      assert.matches("Unknown backend", err)
    end)
  end)

  describe("reset_backend()", function()
    it("clears cached backend", function()
      notification.set_backend("native")
      assert.equals("native", notification.get_backend())

      notification.reset_backend()

      -- Should detect again
      package.loaded["noice"] = {
        notify = function() end,
      }

      assert.equals("noice", notification.get_backend())
    end)
  end)

  describe("notify()", function()
    it("calls native vim.notify with correct parameters", function()
      notification.set_backend("native")

      local called = false
      local captured_msg, captured_level
      vim.notify = function(msg, level, opts)
        called = true
        captured_msg = msg
        captured_level = level
      end

      notification.notify("Test message", "info")

      assert.is_true(called)
      assert.equals("Test message", captured_msg)
      assert.equals(vim.log.levels.INFO, captured_level)
    end)

    it("calls snacks notify with string level", function()
      notification.set_backend("snacks")

      local called = false
      local captured_msg, captured_level
      package.loaded["snacks"] = {
        notify = function(msg, level, opts)
          called = true
          captured_msg = msg
          captured_level = level
        end,
      }

      notification.notify("Test message", vim.log.levels.WARN)

      assert.is_true(called)
      assert.equals("Test message", captured_msg)
      assert.equals("warn", captured_level) -- Converted to string
    end)

    it("calls noice notify with string level", function()
      notification.set_backend("noice")

      local called = false
      local captured_level
      package.loaded["noice"] = {
        notify = function(msg, level, opts)
          called = true
          captured_level = level
        end,
      }

      notification.notify("Test", vim.log.levels.ERROR)

      assert.is_true(called)
      assert.equals("error", captured_level)
    end)

    it("validates msg is a string", function()
      local original_vim_notify = vim.notify
      local notify_called = false
      vim.notify = function(msg, level)
        if type(msg) == "string" and msg:match("must be a string") then
          notify_called = true
        end
      end

      notification.notify(123, "info")

      vim.notify = original_vim_notify
      assert.is_true(notify_called)
    end)

    it("defaults level to info", function()
      notification.set_backend("native")

      local captured_level
      vim.notify = function(msg, level, opts)
        captured_level = level
      end

      notification.notify("Test") -- No level specified
      assert.equals(vim.log.levels.INFO, captured_level)
    end)

    it("defaults opts to empty table", function()
      notification.set_backend("native")

      local captured_opts
      vim.notify = function(msg, level, opts)
        captured_opts = opts
      end

      notification.notify("Test", "info") -- No opts
      assert.same({}, captured_opts)
    end)

    it("falls back to native on backend error", function()
      notification.set_backend("noice")

      package.loaded["noice"] = {
        notify = function()
          error("Noice failed")
        end,
      }

      local native_called = false
      vim.notify = function(msg, level, opts)
        native_called = true
      end

      notification.notify("Test", "info")
      assert.is_true(native_called)
    end)

    it("passes options through to backend", function()
      notification.set_backend("native")

      local captured_opts
      vim.notify = function(msg, level, opts)
        captured_opts = opts
      end

      notification.notify("Test", "info", { title = "My Title", timeout = 5000 })

      assert.equals("My Title", captured_opts.title)
      assert.equals(5000, captured_opts.timeout)
    end)

    it("converts string levels to numbers for native", function()
      notification.set_backend("native")

      local levels_tested = {}
      vim.notify = function(msg, level, opts)
        table.insert(levels_tested, level)
      end

      notification.notify("Test", "error")
      notification.notify("Test", "warn")
      notification.notify("Test", "info")
      notification.notify("Test", "debug")

      assert.equals(vim.log.levels.ERROR, levels_tested[1])
      assert.equals(vim.log.levels.WARN, levels_tested[2])
      assert.equals(vim.log.levels.INFO, levels_tested[3])
      assert.equals(vim.log.levels.DEBUG, levels_tested[4])
    end)

    it("converts numeric levels to strings for snacks", function()
      notification.set_backend("snacks")

      local levels_tested = {}
      package.loaded["snacks"] = {
        notify = function(msg, level, opts)
          table.insert(levels_tested, level)
        end,
      }

      notification.notify("Test", vim.log.levels.ERROR)
      notification.notify("Test", vim.log.levels.WARN)
      notification.notify("Test", vim.log.levels.INFO)

      assert.equals("error", levels_tested[1])
      assert.equals("warn", levels_tested[2])
      assert.equals("info", levels_tested[3])
    end)

    it("handles unknown string level gracefully", function()
      notification.set_backend("native")

      local captured_level
      vim.notify = function(msg, level, opts)
        captured_level = level
      end

      notification.notify("Test", "unknown_level")
      assert.equals(vim.log.levels.INFO, captured_level) -- Default to INFO
    end)

    it("handles case-insensitive string levels", function()
      notification.set_backend("native")

      local captured_level
      vim.notify = function(msg, level, opts)
        captured_level = level
      end

      notification.notify("Test", "ERROR") -- Uppercase
      assert.equals(vim.log.levels.ERROR, captured_level)
    end)
  end)
end)
