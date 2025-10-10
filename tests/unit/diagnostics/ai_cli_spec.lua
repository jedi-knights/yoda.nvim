-- Tests for diagnostics/ai_cli.lua
local ai_cli = require("yoda.diagnostics.ai_cli")

describe("diagnostics.ai_cli", function()
  -- Save originals
  local original_exepath = vim.fn.exepath
  local original_executable = vim.fn.executable
  local original_expand = vim.fn.expand
  local original_system = vim.fn.system

  -- Restore after each test
  after_each(function()
    vim.fn.exepath = original_exepath
    vim.fn.executable = original_executable
    vim.fn.expand = original_expand
    vim.fn.system = original_system
  end)

  describe("get_claude_path()", function()
    it("finds claude in PATH", function()
      vim.fn.exepath = function(cmd)
        return cmd == "claude" and "/usr/bin/claude" or ""
      end
      vim.fn.executable = function(path)
        return path == "/usr/bin/claude" and 1 or 0
      end

      local path = ai_cli.get_claude_path()
      assert.equals("/usr/bin/claude", path)
    end)

    it("finds claude in ~/.local/bin", function()
      vim.fn.exepath = function()
        return ""
      end
      vim.fn.expand = function(path)
        if path == "~/.local/bin/claude" then
          return "/home/user/.local/bin/claude"
        end
        return path
      end
      vim.fn.executable = function(path)
        return path == "/home/user/.local/bin/claude" and 1 or 0
      end

      local path = ai_cli.get_claude_path()
      assert.equals("/home/user/.local/bin/claude", path)
    end)

    it("finds claude in homebrew path (macOS)", function()
      vim.fn.exepath = function()
        return ""
      end
      vim.fn.expand = function(path)
        return path -- No expansion needed
      end
      vim.fn.executable = function(path)
        return path == "/opt/homebrew/bin/claude" and 1 or 0
      end

      local path = ai_cli.get_claude_path()
      assert.equals("/opt/homebrew/bin/claude", path)
    end)

    it("returns nil when claude not found", function()
      vim.fn.exepath = function()
        return ""
      end
      vim.fn.expand = function(path)
        return path
      end
      vim.fn.executable = function()
        return 0
      end

      local path = ai_cli.get_claude_path()
      assert.is_nil(path)
    end)

    it("prefers PATH over other locations", function()
      vim.fn.exepath = function(cmd)
        return cmd == "claude" and "/usr/bin/claude" or ""
      end
      vim.fn.executable = function()
        return 1 -- All paths executable
      end

      local path = ai_cli.get_claude_path()
      assert.equals("/usr/bin/claude", path) -- Should be from PATH
    end)

    it("handles expand errors gracefully", function()
      vim.fn.exepath = function()
        return ""
      end
      vim.fn.expand = function()
        error("Expand failed")
      end
      vim.fn.executable = function()
        return 0
      end

      local path = ai_cli.get_claude_path()
      assert.is_nil(path) -- Should not crash
    end)
  end)

  describe("is_claude_available()", function()
    it("returns true when claude found", function()
      vim.fn.exepath = function(cmd)
        return cmd == "claude" and "/usr/bin/claude" or ""
      end
      vim.fn.executable = function()
        return 1
      end

      assert.is_true(ai_cli.is_claude_available())
    end)

    it("returns false when claude not found", function()
      vim.fn.exepath = function()
        return ""
      end
      vim.fn.executable = function()
        return 0
      end

      assert.is_false(ai_cli.is_claude_available())
    end)
  end)

  describe("get_claude_version()", function()
    it("returns version when claude available", function()
      vim.fn.exepath = function(cmd)
        return cmd == "claude" and "/usr/bin/claude" or ""
      end
      vim.fn.executable = function()
        return 1
      end
      vim.fn.system = function(cmd)
        if cmd[1]:match("claude") and cmd[2] == "--version" then
          return "  claude version 1.2.3  \n"
        end
        return ""
      end

      local version, err = ai_cli.get_claude_version()
      assert.equals("claude version 1.2.3", version)
      assert.is_nil(err)
    end)

    it("returns error when claude not found", function()
      vim.fn.exepath = function()
        return ""
      end
      vim.fn.executable = function()
        return 0
      end

      local version, err = ai_cli.get_claude_version()
      assert.is_nil(version)
      assert.matches("not found", err)
    end)

    it("trims whitespace from version output", function()
      vim.fn.exepath = function()
        return "/usr/bin/claude"
      end
      vim.fn.executable = function()
        return 1
      end
      vim.fn.system = function()
        return "\n\n  1.0.0  \n\n"
      end

      local version = ai_cli.get_claude_version()
      assert.equals("1.0.0", version)
    end)

    it("handles system command errors", function()
      vim.fn.exepath = function()
        return "/usr/bin/claude"
      end
      vim.fn.executable = function()
        return 1
      end
      vim.fn.system = function()
        error("Command failed")
      end

      local version, err = ai_cli.get_claude_version()
      assert.is_nil(version)
      assert.matches("Failed to get version", err)
    end)
  end)
end)

