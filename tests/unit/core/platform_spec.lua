-- Tests for core/platform.lua
local platform = require("yoda-core.platform")
local helpers = require("tests.helpers")

describe("core.platform", function()
  -- Save original vim.fn.has
  local original_has = vim.fn.has

  -- Helper to mock vim.fn.has for different platforms
  local function mock_platform(platform_type)
    vim.fn.has = function(feature)
      if platform_type == "windows" then
        if feature == "win32" or feature == "win64" then
          return 1
        end
      elseif platform_type == "macos" then
        if feature == "mac" or feature == "macunix" then
          return 1
        end
        if feature == "unix" then
          return 1
        end
      elseif platform_type == "linux" then
        if feature == "unix" then
          return 1
        end
        if feature == "mac" or feature == "macunix" then
          return 0
        end
      end
      return 0
    end
  end

  -- Restore original after each test
  after_each(function()
    vim.fn.has = original_has
    -- Clear module cache to reset platform detection
    package.loaded["yoda.core.platform"] = nil
  end)

  describe("is_windows()", function()
    it("returns true on Windows (win32)", function()
      mock_platform("windows")
      local plat = require("yoda-core.platform")
      assert.is_true(plat.is_windows())
    end)

    it("returns false on macOS", function()
      mock_platform("macos")
      local plat = require("yoda-core.platform")
      assert.is_false(plat.is_windows())
    end)

    it("returns false on Linux", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.is_false(plat.is_windows())
    end)
  end)

  describe("is_macos()", function()
    it("returns true on macOS", function()
      mock_platform("macos")
      local plat = require("yoda-core.platform")
      assert.is_true(plat.is_macos())
    end)

    it("returns false on Windows", function()
      mock_platform("windows")
      local plat = require("yoda-core.platform")
      assert.is_false(plat.is_macos())
    end)

    it("returns false on Linux", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.is_false(plat.is_macos())
    end)
  end)

  describe("is_linux()", function()
    it("returns true on Linux", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.is_true(plat.is_linux())
    end)

    it("returns false on Windows", function()
      mock_platform("windows")
      local plat = require("yoda-core.platform")
      assert.is_false(plat.is_linux())
    end)

    it("returns false on macOS", function()
      mock_platform("macos")
      local plat = require("yoda-core.platform")
      assert.is_false(plat.is_linux())
    end)

    it("distinguishes Linux from macOS (both Unix)", function()
      -- macOS has unix=1 but also mac=1
      mock_platform("macos")
      local plat = require("yoda-core.platform")
      assert.is_false(plat.is_linux())
      assert.is_true(plat.is_macos())
    end)
  end)

  describe("get_platform()", function()
    it("returns 'windows' on Windows", function()
      mock_platform("windows")
      local plat = require("yoda-core.platform")
      assert.equals("windows", plat.get_platform())
    end)

    it("returns 'macos' on macOS", function()
      mock_platform("macos")
      local plat = require("yoda-core.platform")
      assert.equals("macos", plat.get_platform())
    end)

    it("returns 'linux' on Linux", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("linux", plat.get_platform())
    end)

    it("returns 'unknown' on unrecognized platform", function()
      vim.fn.has = function()
        return 0
      end
      local plat = require("yoda-core.platform")
      assert.equals("unknown", plat.get_platform())
    end)
  end)

  describe("get_path_sep()", function()
    it("returns backslash on Windows", function()
      mock_platform("windows")
      local plat = require("yoda-core.platform")
      assert.equals("\\", plat.get_path_sep())
    end)

    it("returns forward slash on macOS", function()
      mock_platform("macos")
      local plat = require("yoda-core.platform")
      assert.equals("/", plat.get_path_sep())
    end)

    it("returns forward slash on Linux", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("/", plat.get_path_sep())
    end)
  end)

  describe("join_path()", function()
    it("joins paths with backslash on Windows", function()
      mock_platform("windows")
      local plat = require("yoda-core.platform")
      assert.equals("C:\\Users\\test", plat.join_path("C:", "Users", "test"))
    end)

    it("joins paths with forward slash on Unix", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("/home/test", plat.join_path("/home", "test"))
    end)

    it("handles single path component", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("/home", plat.join_path("/home"))
    end)

    it("handles many path components", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("a/b/c/d/e", plat.join_path("a", "b", "c", "d", "e"))
    end)

    it("handles empty strings in path", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("a//c", plat.join_path("a", "", "c"))
    end)

    it("works on macOS", function()
      mock_platform("macos")
      local plat = require("yoda-core.platform")
      assert.equals("/Users/test/file.txt", plat.join_path("/Users", "test", "file.txt"))
    end)
  end)

  describe("normalize_path()", function()
    it("converts forward slashes to backslashes on Windows", function()
      mock_platform("windows")
      local plat = require("yoda-core.platform")
      assert.equals("C:\\Users\\test", plat.normalize_path("C:/Users/test"))
    end)

    it("converts backslashes to forward slashes on Linux", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("/home/test", plat.normalize_path("\\home\\test"))
    end)

    it("converts backslashes to forward slashes on macOS", function()
      mock_platform("macos")
      local plat = require("yoda-core.platform")
      assert.equals("/Users/test", plat.normalize_path("\\Users\\test"))
    end)

    it("handles mixed separators on Windows", function()
      mock_platform("windows")
      local plat = require("yoda-core.platform")
      assert.equals("C:\\Users\\test\\file", plat.normalize_path("C:/Users\\test/file"))
    end)

    it("handles mixed separators on Unix", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("/home/test/file", plat.normalize_path("\\home/test\\file"))
    end)

    it("handles already normalized paths", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("/home/test", plat.normalize_path("/home/test"))
    end)

    it("handles empty path", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("", plat.normalize_path(""))
    end)

    it("preserves UNC paths on Windows", function()
      mock_platform("windows")
      local plat = require("yoda-core.platform")
      assert.equals("\\\\server\\share", plat.normalize_path("//server/share"))
    end)

    it("handles paths with spaces", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("/path/with spaces/file", plat.normalize_path("\\path\\with spaces\\file"))
    end)

    it("handles relative paths", function()
      mock_platform("linux")
      local plat = require("yoda-core.platform")
      assert.equals("./test/file", plat.normalize_path(".\\test\\file"))
    end)
  end)
end)
