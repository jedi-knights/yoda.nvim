-- Tests for logging/strategies/console.lua
describe("logging.strategies.console", function()
  local console_strategy
  local original_print

  before_each(function()
    -- Clear package cache
    package.loaded["yoda.logging.strategies.console"] = nil

    -- Mock print
    original_print = print
    _G.print_calls = {}
    _G.print = function(...)
      table.insert(_G.print_calls, { ... })
    end

    console_strategy = require("yoda-logging.strategies.console")
  end)

  after_each(function()
    -- Restore print
    _G.print = original_print
    _G.print_calls = nil
  end)

  describe("write()", function()
    it("writes message to console via print", function()
      console_strategy.write("Test message", 2)

      assert.are.equal(1, #_G.print_calls)
      assert.are.equal("Test message", _G.print_calls[1][1])
    end)

    it("writes multiple messages", function()
      console_strategy.write("Message 1", 2)
      console_strategy.write("Message 2", 3)
      console_strategy.write("Message 3", 4)

      assert.are.equal(3, #_G.print_calls)
      assert.are.equal("Message 1", _G.print_calls[1][1])
      assert.are.equal("Message 2", _G.print_calls[2][1])
      assert.are.equal("Message 3", _G.print_calls[3][1])
    end)

    it("ignores non-string messages", function()
      console_strategy.write(nil, 2)
      console_strategy.write(123, 2)
      console_strategy.write({}, 2)

      assert.are.equal(0, #_G.print_calls)
    end)

    it("writes formatted messages with special characters", function()
      console_strategy.write("[INFO] Test | key=value", 2)

      assert.are.equal(1, #_G.print_calls)
      assert.are.equal("[INFO] Test | key=value", _G.print_calls[1][1])
    end)
  end)

  describe("flush()", function()
    it("is callable (no-op for console)", function()
      -- Should not error
      console_strategy.flush()
    end)
  end)
end)
