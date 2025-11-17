-- Tests for logging/formatter.lua
describe("logging.formatter", function()
  local formatter
  local config

  before_each(function()
    -- Clear package cache
    package.loaded["yoda.logging.formatter"] = nil
    package.loaded["yoda.logging.config"] = nil

    formatter = require("yoda-logging.formatter")
    config = require("yoda-logging.config")
  end)

  describe("format()", function()
    it("formats basic message with timestamp and level", function()
      local result = formatter.format(config.LEVELS.INFO, "Test message")

      assert.is_string(result)
      assert.is_true(result:match("%[INFO%]") ~= nil)
      assert.is_true(result:match("Test message") ~= nil)
      -- Should have timestamp
      assert.is_true(result:match("%d%d%d%d%-%d%d%-%d%d") ~= nil)
    end)

    it("formats message with context", function()
      local result = formatter.format(config.LEVELS.DEBUG, "Loading plugin", {
        plugin = "telescope",
        event = "VeryLazy",
      })

      assert.is_true(result:match("%[DEBUG%]") ~= nil)
      assert.is_true(result:match("Loading plugin") ~= nil)
      assert.is_true(result:match("plugin=telescope") ~= nil)
      assert.is_true(result:match("event=VeryLazy") ~= nil)
    end)

    it("handles different log levels", function()
      local levels = {
        { level = config.LEVELS.TRACE, name = "TRACE" },
        { level = config.LEVELS.DEBUG, name = "DEBUG" },
        { level = config.LEVELS.INFO, name = "INFO" },
        { level = config.LEVELS.WARN, name = "WARN" },
        { level = config.LEVELS.ERROR, name = "ERROR" },
      }

      for _, test in ipairs(levels) do
        local result = formatter.format(test.level, "Message")
        assert.is_true(result:match("%[" .. test.name .. "%]") ~= nil, "Should include " .. test.name)
      end
    end)

    it("formats context with table values", function()
      local result = formatter.format(config.LEVELS.INFO, "Test", {
        data = { key = "value" },
      })

      -- Should include inspected table
      assert.is_true(result:match("data=") ~= nil)
    end)

    it("handles nil context", function()
      local result = formatter.format(config.LEVELS.INFO, "Test", nil)

      assert.is_string(result)
      assert.is_true(result:match("Test") ~= nil)
    end)

    it("handles empty context", function()
      local result = formatter.format(config.LEVELS.INFO, "Test", {})

      assert.is_string(result)
      assert.is_true(result:match("Test") ~= nil)
    end)

    it("respects formatting options", function()
      local opts = {
        include_timestamp = false,
        include_level = true,
        include_context = true,
      }

      local result = formatter.format(config.LEVELS.INFO, "Test", { key = "value" }, opts)

      -- Should not have timestamp
      assert.is_false(result:match("%d%d%d%d%-%d%d%-%d%d") ~= nil)
      -- Should have level
      assert.is_true(result:match("%[INFO%]") ~= nil)
      -- Should have context
      assert.is_true(result:match("key=value") ~= nil)
    end)
  end)

  describe("format_simple()", function()
    it("formats message with level only", function()
      local result = formatter.format_simple(config.LEVELS.INFO, "Simple message")

      assert.are.equal("[INFO] Simple message", result)
    end)

    it("handles all levels", function()
      assert.are.equal("[DEBUG] Test", formatter.format_simple(config.LEVELS.DEBUG, "Test"))
      assert.are.equal("[WARN] Test", formatter.format_simple(config.LEVELS.WARN, "Test"))
      assert.are.equal("[ERROR] Test", formatter.format_simple(config.LEVELS.ERROR, "Test"))
    end)

    it("no timestamp or context", function()
      local result = formatter.format_simple(config.LEVELS.INFO, "Test")

      -- Should not have timestamp
      assert.is_false(result:match("%d%d%d%d%-%d%d%-%d%d") ~= nil)
      -- Should not have context marker
      assert.is_false(result:match("|") ~= nil)
    end)
  end)
end)
