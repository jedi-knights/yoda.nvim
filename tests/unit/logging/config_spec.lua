-- Tests for logging/config.lua
describe("logging.config", function()
  local config

  before_each(function()
    -- Clear package cache
    package.loaded["yoda.logging.config"] = nil
    config = require("yoda-logging.config")
    config.reset()
  end)

  describe("LEVELS and LEVEL_NAMES", function()
    it("defines all log levels", function()
      assert.are.equal(0, config.LEVELS.TRACE)
      assert.are.equal(1, config.LEVELS.DEBUG)
      assert.are.equal(2, config.LEVELS.INFO)
      assert.are.equal(3, config.LEVELS.WARN)
      assert.are.equal(4, config.LEVELS.ERROR)
    end)

    it("defines level names", function()
      assert.are.equal("TRACE", config.LEVEL_NAMES[0])
      assert.are.equal("DEBUG", config.LEVEL_NAMES[1])
      assert.are.equal("INFO", config.LEVEL_NAMES[2])
      assert.are.equal("WARN", config.LEVEL_NAMES[3])
      assert.are.equal("ERROR", config.LEVEL_NAMES[4])
    end)
  end)

  describe("get()", function()
    it("returns default configuration", function()
      local conf = config.get()

      assert.are.equal(config.LEVELS.INFO, conf.level)
      assert.are.equal("notify", conf.strategy)
      assert.is_not_nil(conf.file)
      assert.is_not_nil(conf.format)
    end)

    it("returns table with all expected fields", function()
      local conf = config.get()

      assert.is_not_nil(conf.level)
      assert.is_not_nil(conf.strategy)
      assert.is_not_nil(conf.file.path)
      assert.is_not_nil(conf.file.max_size)
      assert.is_not_nil(conf.file.rotate_count)
      assert.is_not_nil(conf.format.include_timestamp)
    end)
  end)

  describe("update()", function()
    it("updates level", function()
      config.update({ level = config.LEVELS.DEBUG })

      local conf = config.get()
      assert.are.equal(config.LEVELS.DEBUG, conf.level)
    end)

    it("updates strategy", function()
      config.update({ strategy = "file" })

      local conf = config.get()
      assert.are.equal("file", conf.strategy)
    end)

    it("deep merges nested configuration", function()
      config.update({
        file = {
          max_size = 2048,
        },
      })

      local conf = config.get()
      assert.are.equal(2048, conf.file.max_size)
      -- Other file fields should still exist
      assert.is_not_nil(conf.file.path)
      assert.is_not_nil(conf.file.rotate_count)
    end)

    it("validates input is a table", function()
      assert.has_error(function()
        config.update("invalid")
      end, "opts must be a table")

      assert.has_error(function()
        config.update(nil)
      end, "opts must be a table")

      assert.has_error(function()
        config.update(123)
      end, "opts must be a table")
    end)
  end)

  describe("reset()", function()
    it("resets to default configuration", function()
      -- Modify config
      config.update({ level = config.LEVELS.TRACE, strategy = "console" })

      -- Reset
      config.reset()

      -- Verify defaults restored
      local conf = config.get()
      assert.are.equal(config.LEVELS.INFO, conf.level)
      assert.are.equal("notify", conf.strategy)
    end)
  end)

  describe("get_log_file()", function()
    it("returns default log file path", function()
      local path = config.get_log_file()

      assert.is_string(path)
      assert.is_true(path:match("/yoda%.log$") ~= nil)
    end)

    it("returns updated log file path", function()
      config.set_log_file("/custom/path/debug.log")

      local path = config.get_log_file()
      assert.are.equal("/custom/path/debug.log", path)
    end)
  end)

  describe("set_log_file()", function()
    it("sets log file path", function()
      config.set_log_file("/tmp/test.log")

      assert.are.equal("/tmp/test.log", config.get_log_file())
    end)

    it("validates input is a non-empty string", function()
      assert.has_error(function()
        config.set_log_file(nil)
      end, "path must be a non-empty string")

      assert.has_error(function()
        config.set_log_file("")
      end, "path must be a non-empty string")

      assert.has_error(function()
        config.set_log_file(123)
      end, "path must be a non-empty string")
    end)
  end)

  describe("get_level()", function()
    it("returns default level (INFO)", function()
      assert.are.equal(config.LEVELS.INFO, config.get_level())
    end)

    it("returns updated level", function()
      config.set_level(config.LEVELS.DEBUG)
      assert.are.equal(config.LEVELS.DEBUG, config.get_level())
    end)
  end)

  describe("set_level()", function()
    it("sets level by number", function()
      config.set_level(config.LEVELS.TRACE)
      assert.are.equal(config.LEVELS.TRACE, config.get_level())

      config.set_level(config.LEVELS.ERROR)
      assert.are.equal(config.LEVELS.ERROR, config.get_level())
    end)

    it("sets level by string name", function()
      config.set_level("debug")
      assert.are.equal(config.LEVELS.DEBUG, config.get_level())

      config.set_level("trace")
      assert.are.equal(config.LEVELS.TRACE, config.get_level())

      config.set_level("error")
      assert.are.equal(config.LEVELS.ERROR, config.get_level())
    end)

    it("is case insensitive for string names", function()
      config.set_level("DEBUG")
      assert.are.equal(config.LEVELS.DEBUG, config.get_level())

      config.set_level("WaRn")
      assert.are.equal(config.LEVELS.WARN, config.get_level())
    end)

    it("validates input and throws errors for invalid values", function()
      assert.has_error(function()
        config.set_level("invalid")
      end)

      assert.has_error(function()
        config.set_level(nil)
      end)
    end)
  end)

  describe("get_strategy()", function()
    it("returns default strategy (notify)", function()
      assert.are.equal("notify", config.get_strategy())
    end)

    it("returns updated strategy", function()
      config.set_strategy("file")
      assert.are.equal("file", config.get_strategy())
    end)
  end)

  describe("set_strategy()", function()
    it("sets valid strategies", function()
      config.set_strategy("console")
      assert.are.equal("console", config.get_strategy())

      config.set_strategy("file")
      assert.are.equal("file", config.get_strategy())

      config.set_strategy("notify")
      assert.are.equal("notify", config.get_strategy())

      config.set_strategy("multi")
      assert.are.equal("multi", config.get_strategy())
    end)

    it("validates input and throws errors for invalid strategies", function()
      assert.has_error(function()
        config.set_strategy("invalid")
      end)

      assert.has_error(function()
        config.set_strategy(nil)
      end)

      assert.has_error(function()
        config.set_strategy(123)
      end)
    end)
  end)
end)
