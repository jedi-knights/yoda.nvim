-- Tests for logging/strategies/multi.lua
describe("logging.strategies.multi", function()
  local multi_strategy

  -- Mocks for console and file strategies
  local mock_console
  local mock_file

  before_each(function()
    -- Clear package cache
    package.loaded["yoda.logging.strategies.multi"] = nil
    package.loaded["yoda.logging.strategies.console"] = nil
    package.loaded["yoda.logging.strategies.file"] = nil

    -- Create mock strategies
    mock_console = {
      write_calls = {},
      flush_called = false,
    }

    mock_file = {
      write_calls = {},
      flush_called = false,
      clear_called = false,
    }

    -- Mock console strategy
    package.loaded["yoda.logging.strategies.console"] = {
      write = function(msg, level)
        table.insert(mock_console.write_calls, { msg = msg, level = level })
      end,
      flush = function()
        mock_console.flush_called = true
      end,
    }

    -- Mock file strategy
    package.loaded["yoda.logging.strategies.file"] = {
      write = function(msg, level)
        table.insert(mock_file.write_calls, { msg = msg, level = level })
      end,
      flush = function()
        mock_file.flush_called = true
      end,
      clear = function()
        mock_file.clear_called = true
      end,
    }

    multi_strategy = require("yoda-logging.strategies.multi")
  end)

  describe("write()", function()
    it("writes to both console and file strategies", function()
      multi_strategy.write("Test message", 2)

      assert.are.equal(1, #mock_console.write_calls)
      assert.are.equal(1, #mock_file.write_calls)

      assert.are.equal("Test message", mock_console.write_calls[1].msg)
      assert.are.equal("Test message", mock_file.write_calls[1].msg)
      assert.are.equal(2, mock_console.write_calls[1].level)
      assert.are.equal(2, mock_file.write_calls[1].level)
    end)

    it("writes multiple messages to both strategies", function()
      multi_strategy.write("Message 1", 2)
      multi_strategy.write("Message 2", 3)

      assert.are.equal(2, #mock_console.write_calls)
      assert.are.equal(2, #mock_file.write_calls)
    end)

    it("ignores non-string messages", function()
      multi_strategy.write(nil, 2)
      multi_strategy.write(123, 2)

      assert.are.equal(0, #mock_console.write_calls)
      assert.are.equal(0, #mock_file.write_calls)
    end)
  end)

  describe("flush()", function()
    it("flushes both console and file strategies", function()
      multi_strategy.flush()

      assert.is_true(mock_console.flush_called)
      assert.is_true(mock_file.flush_called)
    end)
  end)

  describe("clear()", function()
    it("clears file strategy", function()
      multi_strategy.clear()

      assert.is_true(mock_file.clear_called)
    end)
  end)
end)
