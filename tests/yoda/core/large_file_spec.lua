-- tests/yoda/core/large_file_spec.lua
-- Pure-logic tests for lua/yoda/core/large_file.lua. No buffer or autocmd
-- setup — exercises the format_size / exceeds_threshold helpers in isolation.

local core = require("yoda.core.large_file")

describe("core.large_file", function()
  describe("format_size()", function()
    it("renders bytes < 1 KiB with a B suffix", function()
      -- Arrange
      local bytes = 512

      -- Act
      local out = core.format_size(bytes)

      -- Assert
      assert.equals("512B", out)
    end)

    it(
      "renders values in [1 KiB, 1 MiB) with one decimal + KB suffix",
      function()
        -- Arrange
        local bytes = 1536 -- 1.5 KiB

        -- Act
        local out = core.format_size(bytes)

        -- Assert
        assert.equals("1.5KB", out)
      end
    )

    it("renders values >= 1 MiB with one decimal + MB suffix", function()
      -- Arrange
      local bytes = 2 * 1024 * 1024 + 512 * 1024 -- 2.5 MiB

      -- Act
      local out = core.format_size(bytes)

      -- Assert
      assert.equals("2.5MB", out)
    end)

    it("handles the 1023 boundary as bytes", function()
      -- Arrange / Act / Assert
      assert.equals("1023B", core.format_size(1023))
    end)

    it("handles the 1024 boundary as KB", function()
      -- Arrange / Act / Assert
      assert.equals("1.0KB", core.format_size(1024))
    end)
  end)

  describe("exceeds_threshold()", function()
    it("returns true when size strictly exceeds threshold", function()
      -- Arrange / Act / Assert
      assert.is_true(core.exceeds_threshold(101, 100))
    end)

    it("returns false when size equals threshold", function()
      -- Arrange / Act / Assert
      assert.is_false(core.exceeds_threshold(100, 100))
    end)

    it("returns false when size is below threshold", function()
      -- Arrange / Act / Assert
      assert.is_false(core.exceeds_threshold(50, 100))
    end)

    it("returns false when size is nil", function()
      -- Arrange / Act / Assert
      assert.is_false(core.exceeds_threshold(nil, 100))
    end)

    it("returns false when size is a non-number", function()
      -- Arrange / Act / Assert
      assert.is_false(core.exceeds_threshold("100", 100))
    end)
  end)
end)
