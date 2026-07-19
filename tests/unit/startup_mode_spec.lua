-- tests/unit/startup_mode_spec.lua
-- Validates the `nvim claude` startup mode: argv detection (mode_from_argv)
-- and the layout builder (start_claude_layout) that opens the Snacks explorer,
-- launches Claude Code, and grows Claude into the space right of the explorer
-- via yoda-window.nvim's reclaim_width.

describe("yoda.startup_mode", function()
  local startup_mode

  before_each(function()
    package.loaded["yoda.startup_mode"] = nil
    pcall(vim.api.nvim_del_augroup_by_name, "YodaStartupMode")
    startup_mode = require("yoda.startup_mode")
  end)

  after_each(function()
    package.loaded["yoda.startup_mode"] = nil
    pcall(vim.api.nvim_del_augroup_by_name, "YodaStartupMode")
  end)

  describe("mode_from_argv", function()
    local original_filereadable = vim.fn.filereadable
    local original_isdirectory = vim.fn.isdirectory

    before_each(function()
      -- Default: nothing named "claude" exists on disk.
      vim.fn.filereadable = function()
        return 0
      end
      vim.fn.isdirectory = function()
        return 0
      end
    end)

    after_each(function()
      vim.fn.filereadable = original_filereadable
      vim.fn.isdirectory = original_isdirectory
    end)

    it("returns 'claude' for a lone 'claude' argument", function()
      -- Arrange
      local argv = { "claude" }

      -- Act
      local mode = startup_mode.mode_from_argv(argv)

      -- Assert
      assert.equals("claude", mode)
    end)

    it("returns 'claude' for the short 'c' alias", function()
      -- Arrange
      local argv = { "c" }

      -- Act
      local mode = startup_mode.mode_from_argv(argv)

      -- Assert
      assert.equals("claude", mode)
    end)

    it("returns nil when a readable file named 'c' exists", function()
      -- Arrange
      vim.fn.filereadable = function(name)
        return name == "c" and 1 or 0
      end

      -- Act / Assert
      assert.is_nil(startup_mode.mode_from_argv({ "c" }))
    end)

    it("returns nil when there are no arguments", function()
      -- Arrange
      local argv = {}

      -- Act / Assert
      assert.is_nil(startup_mode.mode_from_argv(argv))
    end)

    it("returns nil when 'claude' is not the only argument", function()
      -- Arrange
      local argv = { "claude", "extra.lua" }

      -- Act / Assert
      assert.is_nil(startup_mode.mode_from_argv(argv))
    end)

    it("returns nil for an unrelated argument", function()
      -- Arrange
      local argv = { "init.lua" }

      -- Act / Assert
      assert.is_nil(startup_mode.mode_from_argv(argv))
    end)

    it("returns nil when a readable file named 'claude' exists", function()
      -- Arrange
      vim.fn.filereadable = function(name)
        return name == "claude" and 1 or 0
      end

      -- Act / Assert
      assert.is_nil(startup_mode.mode_from_argv({ "claude" }))
    end)

    it("returns nil when a directory named 'claude' exists", function()
      -- Arrange
      vim.fn.isdirectory = function(name)
        return name == "claude" and 1 or 0
      end

      -- Act / Assert
      assert.is_nil(startup_mode.mode_from_argv({ "claude" }))
    end)
  end)

  describe("start_claude_layout", function()
    local originals = {}

    before_each(function()
      package.loaded["snacks"] = nil
      package.loaded["yoda-window.utils"] = nil
      package.loaded["claudecode.terminal"] = nil

      originals.cmd = vim.cmd
      originals.schedule = vim.schedule
      originals.bufwinid = vim.fn.bufwinid
      originals.get_current_win = vim.api.nvim_get_current_win
      originals.get_current_buf = vim.api.nvim_get_current_buf
      originals.win_is_valid = vim.api.nvim_win_is_valid
      originals.buf_is_valid = vim.api.nvim_buf_is_valid
      originals.buf_delete = vim.api.nvim_buf_delete
      originals.set_current_win = vim.api.nvim_set_current_win

      -- Run scheduled work synchronously so assertions don't need an event tick.
      vim.schedule = function(fn)
        fn()
      end
      -- The phantom startup window/buffer that `nvim claude` opens.
      vim.api.nvim_get_current_win = function()
        return 100
      end
      vim.api.nvim_get_current_buf = function()
        return 200
      end
      vim.api.nvim_win_is_valid = function()
        return true
      end
      vim.api.nvim_buf_is_valid = function()
        return true
      end
    end)

    after_each(function()
      vim.cmd = originals.cmd
      vim.schedule = originals.schedule
      vim.fn.bufwinid = originals.bufwinid
      vim.api.nvim_get_current_win = originals.get_current_win
      vim.api.nvim_get_current_buf = originals.get_current_buf
      vim.api.nvim_win_is_valid = originals.win_is_valid
      vim.api.nvim_buf_is_valid = originals.buf_is_valid
      vim.api.nvim_buf_delete = originals.buf_delete
      vim.api.nvim_set_current_win = originals.set_current_win
      package.loaded["snacks"] = nil
      package.loaded["yoda-window.utils"] = nil
      package.loaded["claudecode.terminal"] = nil
    end)

    it(
      "opens the explorer, runs ClaudeCode, and reclaims width for Claude",
      function()
        -- Arrange
        local explorer_opened = false
        package.loaded["snacks"] = {
          explorer = {
            open = function()
              explorer_opened = true
            end,
          },
        }
        local cmds = {}
        vim.cmd = function(c)
          table.insert(cmds, c)
        end
        package.loaded["claudecode.terminal"] = {
          get_active_terminal_bufnr = function()
            return 42
          end,
        }
        vim.fn.bufwinid = function(buf)
          return buf == 42 and 7 or -1
        end
        local reclaimed, focused, deleted
        package.loaded["yoda-window.utils"] = {
          reclaim_width = function(close_win, target_win)
            reclaimed = { close_win = close_win, target_win = target_win }
          end,
        }
        vim.api.nvim_set_current_win = function(win)
          focused = win
        end
        vim.api.nvim_buf_delete = function(buf)
          deleted = buf
        end

        -- Act
        startup_mode.start_claude_layout()

        -- Assert
        assert.is_true(explorer_opened)
        assert.is_true(vim.tbl_contains(cmds, "ClaudeCode"))
        assert.same({ close_win = 100, target_win = 7 }, reclaimed)
        assert.equals(200, deleted)
        assert.equals(7, focused)
      end
    )

    it("degrades to a plain ClaudeCode when yoda-window is absent", function()
      -- Arrange
      package.loaded["snacks"] = {
        explorer = { open = function() end },
      }
      local cmds = {}
      vim.cmd = function(c)
        table.insert(cmds, c)
      end
      package.loaded["claudecode.terminal"] = {
        get_active_terminal_bufnr = function()
          return 42
        end,
      }
      vim.fn.bufwinid = function()
        return 7
      end
      -- yoda-window.utils intentionally left unstubbed (require fails).

      -- Act — must not raise even without the resize helper.
      local ok = pcall(startup_mode.start_claude_layout)

      -- Assert
      assert.is_true(ok)
      assert.is_true(vim.tbl_contains(cmds, "ClaudeCode"))
    end)

    it("does not resize when Claude's window can't be found", function()
      -- Arrange
      package.loaded["snacks"] = {
        explorer = { open = function() end },
      }
      vim.cmd = function() end
      package.loaded["claudecode.terminal"] = {
        get_active_terminal_bufnr = function()
          return nil
        end,
      }
      package.loaded["yoda-window.utils"] = {
        reclaim_width = function()
          error("reclaim_width should not be called without a Claude window")
        end,
      }

      -- Act
      local ok = pcall(startup_mode.start_claude_layout)

      -- Assert
      assert.is_true(ok)
    end)
  end)

  describe("setup", function()
    it(
      "registers a single VimEnter autocmd in the YodaStartupMode group",
      function()
        -- Arrange / Act
        startup_mode.setup()

        -- Assert
        local autocmds = vim.api.nvim_get_autocmds({
          group = "YodaStartupMode",
          event = "VimEnter",
        })
        assert.equals(1, #autocmds)
      end
    )

    it("does not build the layout when argv is not claude mode", function()
      -- Arrange
      local original_argv = vim.fn.argv
      vim.fn.argv = function()
        return {}
      end
      local built = false
      -- The autocmd dispatches through the module table so it is overridable.
      startup_mode.start_claude_layout = function()
        built = true
      end
      startup_mode.setup()
      local autocmds = vim.api.nvim_get_autocmds({
        group = "YodaStartupMode",
        event = "VimEnter",
      })

      -- Act
      autocmds[1].callback()

      -- Assert
      assert.is_false(built)
      vim.fn.argv = original_argv
    end)

    it("builds the layout when argv selects claude mode", function()
      -- Arrange
      local original_argv = vim.fn.argv
      local original_filereadable = vim.fn.filereadable
      local original_isdirectory = vim.fn.isdirectory
      vim.fn.argv = function()
        return { "claude" }
      end
      vim.fn.filereadable = function()
        return 0
      end
      vim.fn.isdirectory = function()
        return 0
      end
      local built = false
      startup_mode.start_claude_layout = function()
        built = true
      end
      startup_mode.setup()
      local autocmds = vim.api.nvim_get_autocmds({
        group = "YodaStartupMode",
        event = "VimEnter",
      })

      -- Act
      autocmds[1].callback()

      -- Assert
      assert.is_true(built)
      vim.fn.argv = original_argv
      vim.fn.filereadable = original_filereadable
      vim.fn.isdirectory = original_isdirectory
    end)
  end)
end)
