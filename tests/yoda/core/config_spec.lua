-- tests/yoda/core/config_spec.lua
-- Tests the schema + merge + resolved-state holder for yoda.config.

local config = require("yoda.config")

describe("yoda.config", function()
  before_each(function()
    config._reset()
  end)

  describe("defaults()", function()
    it("returns a fresh copy each call (mutation-safe)", function()
      -- Arrange
      local first = config.defaults()

      -- Act
      first.large_file.size_threshold = 999

      -- Assert
      assert.equals(100 * 1024, config.defaults().large_file.size_threshold)
    end)

    it("includes every documented top-level key", function()
      -- Arrange / Act
      local d = config.defaults()

      -- Assert
      for _, key in ipairs({
        "extras",
        "ui",
        "profiling",
        "adapters",
        "large_file",
        "yaml",
        "testing",
        "startup_mode",
        "defaults",
      }) do
        assert.is_not_nil(d[key], "missing default key: " .. key)
      end
    end)
  end)

  describe("get()", function()
    it("returns nil before resolve() is called", function()
      -- Arrange / Act / Assert
      assert.is_nil(config.get())
    end)

    it("returns the merged config after resolve()", function()
      -- Arrange
      config.resolve({ large_file = { size_threshold = 500 * 1024 } })

      -- Act
      local resolved = config.get()

      -- Assert
      assert.equals(500 * 1024, resolved.large_file.size_threshold)
    end)
  end)

  describe("resolve()", function()
    it("deep-merges user opts over defaults", function()
      -- Arrange
      local resolved = config.resolve({
        large_file = { size_threshold = 200 },
      })

      -- Assert: user override wins for the touched key
      assert.equals(200, resolved.large_file.size_threshold)
      -- Assert: defaults preserved for untouched keys inside the same sub-table
      assert.is_true(resolved.large_file.show_notification)
      assert.is_true(resolved.large_file.disable.treesitter)
    end)

    it("preserves default sub-tables when opts omit them", function()
      -- Arrange
      local resolved = config.resolve({ ui = { verbose_startup = true } })

      -- Assert
      assert.is_true(resolved.ui.verbose_startup)
      assert.is_not_nil(resolved.yaml)
      assert.equals(2, resolved.yaml.env_indent)
    end)

    it("treats nil opts as {}", function()
      -- Arrange / Act
      local resolved = config.resolve(nil)

      -- Assert
      assert.same(config.defaults(), resolved)
    end)

    it("returns the same value that get() returns", function()
      -- Arrange
      local from_resolve = config.resolve({ startup_mode = { enable = false } })

      -- Act
      local from_get = config.get()

      -- Assert
      assert.equals(from_resolve, from_get)
    end)

    it("raises on non-table opts", function()
      -- Arrange / Act / Assert
      assert.has_error(function()
        config.resolve("not a table")
      end)
    end)
  end)

  describe("dual-read pattern (nil-safe get())", function()
    it("callers can safely index without setup() being called", function()
      -- Arrange
      config._reset()

      -- Act: mirror the pattern used by consumers
      local resolved = config.get()
      local ui_flag = resolved and resolved.ui and resolved.ui.verbose_startup

      -- Assert
      assert.is_nil(ui_flag)
    end)
  end)
end)
