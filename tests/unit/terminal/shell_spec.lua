-- Tests for terminal/shell.lua
local shell = require("yoda-terminal.shell")

describe("terminal.shell", function()
  -- Save originals
  local original_getenv = os.getenv
  local original_shell_opt = vim.o.shell
  local original_cmd = vim.cmd

  after_each(function()
    os.getenv = original_getenv
    vim.o.shell = original_shell_opt
    vim.cmd = original_cmd
    package.loaded["snacks"] = nil
    package.loaded["yoda.utils"] = nil
    package.loaded["yoda.terminal.config"] = nil
  end)

  describe("get_type()", function()
    it("detects bash shell", function()
      assert.equals("bash", shell.get_type("/bin/bash"))
      assert.equals("bash", shell.get_type("/usr/bin/bash"))
      assert.equals("bash", shell.get_type("/usr/local/bin/bash"))
    end)

    it("detects zsh shell", function()
      assert.equals("zsh", shell.get_type("/bin/zsh"))
      assert.equals("zsh", shell.get_type("/usr/bin/zsh"))
      assert.equals("zsh", shell.get_type("/opt/homebrew/bin/zsh"))
    end)

    it("returns nil for unknown shell", function()
      assert.is_nil(shell.get_type("/bin/fish"))
      assert.is_nil(shell.get_type("/bin/tcsh"))
      assert.is_nil(shell.get_type("/bin/ksh"))
    end)

    it("matches shell name anywhere in path", function()
      assert.equals("bash", shell.get_type("some/path/with/bash/in/it"))
      assert.equals("zsh", shell.get_type("another/zsh/path"))
    end)
  end)

  describe("get_default()", function()
    it("returns SHELL environment variable if set", function()
      os.getenv = function(var)
        return var == "SHELL" and "/bin/zsh" or nil
      end

      assert.equals("/bin/zsh", shell.get_default())
    end)

    it("falls back to vim.o.shell if SHELL not set", function()
      os.getenv = function()
        return nil
      end
      vim.o.shell = "/bin/bash"

      assert.equals("/bin/bash", shell.get_default())
    end)

    it("prefers SHELL over vim.o.shell", function()
      os.getenv = function(var)
        return var == "SHELL" and "/usr/bin/zsh" or nil
      end
      vim.o.shell = "/bin/bash"

      assert.equals("/usr/bin/zsh", shell.get_default())
    end)
  end)

  describe("open_simple()", function()
    it("opens terminal with snacks when available", function()
      local opened = false
      local captured_cmd = nil

      package.loaded["snacks"] = {
        terminal = {
          open = function(cmd, cfg)
            opened = true
            captured_cmd = cmd
          end,
        },
      }

      package.loaded["yoda.terminal.config"] = {
        make_win_opts = function(title, overrides)
          return { title = title }
        end,
      }

      os.getenv = function()
        return "/bin/sh"
      end

      shell.open_simple()
      assert.is_true(opened)
    end)

    it("falls back to native terminal when snacks not available", function()
      package.loaded["snacks"] = nil

      local cmd_executed = false
      vim.cmd = function(cmd)
        if cmd:match("^terminal") then
          cmd_executed = true
        end
      end

      package.loaded["yoda.utils"] = {
        notify = function() end,
      }

      package.loaded["yoda.terminal.config"] = {
        make_win_opts = function(title, overrides)
          return { title = title }
        end,
      }

      os.getenv = function()
        return "/bin/sh"
      end

      shell.open_simple()
      assert.is_true(cmd_executed)
    end)

    it("uses custom cmd when provided", function()
      local captured_cmd = nil

      package.loaded["snacks"] = {
        terminal = {
          open = function(cmd, opts)
            captured_cmd = cmd
          end,
        },
      }

      package.loaded["yoda.terminal.config"] = {
        make_win_opts = function(title, overrides)
          return { title = title }
        end,
      }

      shell.open_simple({ cmd = { "python", "-i" } })
      assert.same({ "python", "-i" }, captured_cmd)
    end)

    it("uses custom title when provided", function()
      local captured_title = nil

      package.loaded["snacks"] = {
        terminal = {
          open = function(cmd, cfg) end,
        },
      }

      package.loaded["yoda.terminal.config"] = {
        make_win_opts = function(title, overrides)
          captured_title = title
          return { title = title }
        end,
      }

      shell.open_simple({ title = "Python Shell" })
      assert.equals("Python Shell", captured_title)
    end)

    it("defaults to ' Terminal ' title", function()
      local captured_title = nil

      package.loaded["snacks"] = {
        terminal = {
          open = function(cmd, cfg) end,
        },
      }

      package.loaded["yoda.terminal.config"] = {
        make_win_opts = function(title, overrides)
          captured_title = title
          return { title = title }
        end,
      }

      shell.open_simple()
      assert.equals(" Terminal ", captured_title)
    end)

    it("notifies when using native terminal fallback", function()
      package.loaded["snacks"] = nil

      local notified = false
      package.loaded["yoda.utils"] = {
        notify = function(msg, level)
          if msg:match("native terminal") then
            notified = true
          end
        end,
      }

      package.loaded["yoda.terminal.config"] = {
        make_win_opts = function(title, overrides)
          return { title = title }
        end,
      }

      vim.cmd = function() end
      os.getenv = function()
        return "/bin/sh"
      end

      shell.open_simple()
      assert.is_true(notified)
    end)
  end)
end)
