-- Tests for logging/strategies/notify.lua
describe("logging.strategies.notify", function()
  local notify_strategy
  local config
  local original_notify
  local original_pcall

  before_each(function()
    -- Clear package cache
    package.loaded["yoda.logging.strategies.notify"] = nil
    package.loaded["yoda.logging.config"] = nil

    config = require("yoda-logging.config")
    config.reset()

    -- Mock vim.notify
    original_notify = vim.notify
    _G.notify_calls = {}
    vim.notify = function(msg, level, opts)
      table.insert(_G.notify_calls, { msg = msg, level = level, opts = opts })
    end

    -- Mock pcall to fail adapter loading (test fallback)
    original_pcall = _G.pcall
    _G.adapter_loaded = false

    _G.pcall = function(fn, ...)
      if type(fn) == "function" then
        return fn(...)
      end

      local mod = ...
      if mod == "yoda.adapters.notification" then
        if _G.adapter_loaded then
          return true, { notify = vim.notify }
        else
          return false, "Mock adapter not loaded"
        end
      end

      return original_pcall(fn, ...)
    end

    notify_strategy = require("yoda-logging.strategies.notify")
  end)

  after_each(function()
    -- Restore mocks
    vim.notify = original_notify
    _G.pcall = original_pcall
    _G.notify_calls = nil
    _G.adapter_loaded = nil
  end)

  describe("write()", function()
    it("writes via vim.notify fallback when adapter not loaded", function()
      _G.adapter_loaded = false

      notify_strategy.write("Test message", config.LEVELS.INFO)

      assert.are.equal(1, #_G.notify_calls)
      assert.are.equal("Test message", _G.notify_calls[1].msg)
      assert.are.equal(vim.log.levels.INFO, _G.notify_calls[1].level)
      assert.are.equal("Yoda", _G.notify_calls[1].opts.title)
    end)

    it("converts log levels to vim.log.levels", function()
      _G.adapter_loaded = false

      local level_tests = {
        { log_level = config.LEVELS.ERROR, vim_level = vim.log.levels.ERROR },
        { log_level = config.LEVELS.WARN, vim_level = vim.log.levels.WARN },
        { log_level = config.LEVELS.INFO, vim_level = vim.log.levels.INFO },
        { log_level = config.LEVELS.DEBUG, vim_level = vim.log.levels.DEBUG },
        { log_level = config.LEVELS.TRACE, vim_level = vim.log.levels.TRACE },
      }

      for _, test in ipairs(level_tests) do
        _G.notify_calls = {}
        notify_strategy.write("Test", test.log_level)

        assert.are.equal(1, #_G.notify_calls)
        assert.are.equal(test.vim_level, _G.notify_calls[1].level)
      end
    end)

    it("ignores non-string messages", function()
      notify_strategy.write(nil, config.LEVELS.INFO)
      notify_strategy.write(123, config.LEVELS.INFO)

      assert.are.equal(0, #_G.notify_calls)
    end)

    it("handles message with special characters", function()
      notify_strategy.write("[INFO] Test | key=value", config.LEVELS.INFO)

      assert.are.equal(1, #_G.notify_calls)
      assert.are.equal("[INFO] Test | key=value", _G.notify_calls[1].msg)
    end)
  end)

  describe("flush()", function()
    it("is callable (no-op for notifications)", function()
      notify_strategy.flush()
      -- Should not error
    end)
  end)
end)
