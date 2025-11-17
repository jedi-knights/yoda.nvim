-- Tests for logging/logger.lua
describe("logging.logger", function()
  local logger
  local config

  -- Mock strategies
  local mock_strategy

  before_each(function()
    -- Clear package cache
    package.loaded["yoda.logging.logger"] = nil
    package.loaded["yoda.logging.config"] = nil
    package.loaded["yoda.logging.strategies.console"] = nil
    package.loaded["yoda.logging.strategies.file"] = nil
    package.loaded["yoda.logging.strategies.notify"] = nil
    package.loaded["yoda.logging.strategies.multi"] = nil

    -- Create mock strategy
    mock_strategy = {
      write = function(msg, level) end,
      flush = function() end,
      clear = function() end,
      calls = {},
    }

    -- Track calls
    local original_write = mock_strategy.write
    mock_strategy.write = function(msg, level)
      table.insert(mock_strategy.calls, { msg = msg, level = level })
      original_write(msg, level)
    end

    -- Mock require for strategies
    local original_require = require
    _G.require = function(mod)
      if mod:match("^yoda%.logging%.strategies%.") then
        return mock_strategy
      end
      return original_require(mod)
    end

    logger = original_require("yoda-logging.logger")
    config = original_require("yoda-logging.config")
    config.reset()
  end)

  after_each(function()
    -- Restore original require
    _G.require = require
  end)

  describe("LEVELS", function()
    it("exports log levels", function()
      assert.is_not_nil(logger.LEVELS)
      assert.are.equal(config.LEVELS.INFO, logger.LEVELS.INFO)
      assert.are.equal(config.LEVELS.DEBUG, logger.LEVELS.DEBUG)
    end)
  end)

  describe("log()", function()
    it("logs message at specified level", function()
      logger.log(logger.LEVELS.INFO, "Test message")

      assert.are.equal(1, #mock_strategy.calls)
      assert.is_true(mock_strategy.calls[1].msg:match("Test message") ~= nil)
    end)

    it("respects level filtering", function()
      config.set_level(logger.LEVELS.WARN)

      -- Should be filtered out
      logger.log(logger.LEVELS.INFO, "Info message")
      logger.log(logger.LEVELS.DEBUG, "Debug message")

      -- Should be logged
      logger.log(logger.LEVELS.WARN, "Warn message")
      logger.log(logger.LEVELS.ERROR, "Error message")

      assert.are.equal(2, #mock_strategy.calls)
      assert.is_true(mock_strategy.calls[1].msg:match("Warn message") ~= nil)
      assert.is_true(mock_strategy.calls[2].msg:match("Error message") ~= nil)
    end)

    it("supports lazy evaluation with function messages", function()
      local expensive_called = false

      logger.log(logger.LEVELS.INFO, function()
        expensive_called = true
        return "Expensive computation"
      end)

      assert.is_true(expensive_called)
      assert.are.equal(1, #mock_strategy.calls)
      assert.is_true(mock_strategy.calls[1].msg:match("Expensive computation") ~= nil)
    end)

    it("skips lazy evaluation when filtered by level", function()
      local expensive_called = false

      config.set_level(logger.LEVELS.ERROR)

      logger.log(logger.LEVELS.DEBUG, function()
        expensive_called = true
        return "Should not be called"
      end)

      -- Function should not be called since DEBUG < ERROR
      assert.is_false(expensive_called)
      assert.are.equal(0, #mock_strategy.calls)
    end)

    it("includes context data", function()
      logger.log(logger.LEVELS.INFO, "Test", { key = "value", num = 42 })

      assert.are.equal(1, #mock_strategy.calls)
      local msg = mock_strategy.calls[1].msg
      assert.is_true(msg:match("key=value") ~= nil)
      assert.is_true(msg:match("num=42") ~= nil)
    end)
  end)

  describe("convenience methods", function()
    it("trace() logs at TRACE level", function()
      config.set_level(logger.LEVELS.TRACE)

      logger.trace("Trace message")

      assert.are.equal(1, #mock_strategy.calls)
      assert.are.equal(logger.LEVELS.TRACE, mock_strategy.calls[1].level)
    end)

    it("debug() logs at DEBUG level", function()
      config.set_level(logger.LEVELS.DEBUG)

      logger.debug("Debug message")

      assert.are.equal(1, #mock_strategy.calls)
      assert.are.equal(logger.LEVELS.DEBUG, mock_strategy.calls[1].level)
    end)

    it("info() logs at INFO level", function()
      logger.info("Info message")

      assert.are.equal(1, #mock_strategy.calls)
      assert.are.equal(logger.LEVELS.INFO, mock_strategy.calls[1].level)
    end)

    it("warn() logs at WARN level", function()
      logger.warn("Warn message")

      assert.are.equal(1, #mock_strategy.calls)
      assert.are.equal(logger.LEVELS.WARN, mock_strategy.calls[1].level)
    end)

    it("error() logs at ERROR level", function()
      logger.error("Error message")

      assert.are.equal(1, #mock_strategy.calls)
      assert.are.equal(logger.LEVELS.ERROR, mock_strategy.calls[1].level)
    end)

    it("all methods support context", function()
      config.set_level(logger.LEVELS.TRACE)

      logger.trace("Trace", { ctx = "trace" })
      logger.debug("Debug", { ctx = "debug" })
      logger.info("Info", { ctx = "info" })
      logger.warn("Warn", { ctx = "warn" })
      logger.error("Error", { ctx = "error" })

      assert.are.equal(5, #mock_strategy.calls)

      for i, call in ipairs(mock_strategy.calls) do
        assert.is_true(call.msg:match("ctx=") ~= nil)
      end
    end)
  end)

  describe("configuration methods", function()
    it("set_strategy() updates strategy", function()
      logger.set_strategy("file")
      assert.are.equal("file", config.get_strategy())
    end)

    it("set_level() updates level", function()
      logger.set_level("debug")
      assert.are.equal(config.LEVELS.DEBUG, config.get_level())
    end)

    it("set_file_path() updates file path", function()
      logger.set_file_path("/custom/log.txt")
      assert.are.equal("/custom/log.txt", config.get_log_file())
    end)

    it("setup() updates full configuration", function()
      logger.setup({
        level = logger.LEVELS.DEBUG,
        strategy = "file",
        file = {
          path = "/tmp/custom.log",
        },
      })

      assert.are.equal(logger.LEVELS.DEBUG, config.get_level())
      assert.are.equal("file", config.get_strategy())
      assert.are.equal("/tmp/custom.log", config.get_log_file())
    end)
  end)

  describe("reset()", function()
    it("resets configuration to defaults", function()
      logger.setup({
        level = logger.LEVELS.TRACE,
        strategy = "console",
      })

      logger.reset()

      assert.are.equal(logger.LEVELS.INFO, config.get_level())
      assert.are.equal("notify", config.get_strategy())
    end)
  end)
end)
