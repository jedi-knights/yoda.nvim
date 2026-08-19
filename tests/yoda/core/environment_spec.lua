-- tests/yoda/core/environment_spec.lua
-- Pure-logic tests for lua/yoda/core/environment.lua. Exercises YODA_ENV
-- classification directly, without loading the notification stack.

local core = require("yoda.core.environment")

describe("core.environment", function()
  local original_env

  before_each(function()
    original_env = vim.env.YODA_ENV
    vim.env.YODA_ENV = nil
  end)

  after_each(function()
    vim.env.YODA_ENV = original_env
  end)

  describe("get_mode()", function()
    it("returns 'home' when YODA_ENV=home", function()
      -- Arrange
      vim.env.YODA_ENV = "home"

      -- Act
      local mode = core.get_mode()

      -- Assert
      assert.equals("home", mode)
    end)

    it("returns 'work' when YODA_ENV=work", function()
      -- Arrange
      vim.env.YODA_ENV = "work"

      -- Act
      local mode = core.get_mode()

      -- Assert
      assert.equals("work", mode)
    end)

    it("returns 'unknown' when YODA_ENV is unset", function()
      -- Arrange
      vim.env.YODA_ENV = nil

      -- Act
      local mode = core.get_mode()

      -- Assert
      assert.equals("unknown", mode)
    end)

    it("returns 'unknown' when YODA_ENV is empty", function()
      -- Arrange
      vim.env.YODA_ENV = ""

      -- Act
      local mode = core.get_mode()

      -- Assert
      assert.equals("unknown", mode)
    end)

    it("returns 'unknown' for any other value", function()
      -- Arrange
      vim.env.YODA_ENV = "staging"

      -- Act
      local mode = core.get_mode()

      -- Assert
      assert.equals("unknown", mode)
    end)

    it("is case-sensitive", function()
      -- Arrange
      vim.env.YODA_ENV = "HOME"

      -- Act
      local mode = core.get_mode()

      -- Assert
      assert.equals("unknown", mode)
    end)
  end)
end)
