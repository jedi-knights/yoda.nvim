-- tests/unit/plugins/claudecode_spec.lua
-- Validates the claudecode.nvim plugin spec and the <leader>ai dashboard
-- expand behavior: closing the dashboard and growing Claude's window into
-- the space it freed via yoda-window.nvim's reclaim_width.

describe("claudecode plugin spec", function()
  local specpath = vim.fn.getcwd() .. "/lua/plugins/claudecode.lua"

  local function find_key(spec, lhs)
    for _, key in ipairs(spec.keys) do
      if key[1] == lhs then
        return key
      end
    end
    return nil
  end

  it("declares claudecode.nvim with a ClaudeCode cmd trigger", function()
    local spec = dofile(specpath)
    assert.equals("coder/claudecode.nvim", spec[1])
    assert.equals("ClaudeCode", spec.cmd)
  end)

  it("wires <leader>ai to a function, not a plain cmd string", function()
    local spec = dofile(specpath)
    local key = find_key(spec, "<leader>ai")
    assert.is_not_nil(key, "<leader>ai should be mapped")
    assert.equals("function", type(key[2]))
  end)

  describe("<leader>ai callback", function()
    local original_cmd = vim.cmd
    local original_schedule = vim.schedule
    local original_bufwinid = vim.fn.bufwinid

    before_each(function()
      package.loaded["yoda-window.utils"] = nil
      package.loaded["claudecode.terminal"] = nil
      -- Run scheduled work synchronously so assertions don't need to wait
      -- an event loop tick.
      vim.schedule = function(fn)
        fn()
      end
    end)

    after_each(function()
      vim.cmd = original_cmd
      vim.schedule = original_schedule
      vim.fn.bufwinid = original_bufwinid
      package.loaded["yoda-window.utils"] = nil
      package.loaded["claudecode.terminal"] = nil
    end)

    it("always toggles Claude Code", function()
      package.loaded["yoda-window.utils"] = {
        find_by_filetype = function()
          return nil
        end,
      }
      local cmds = {}
      vim.cmd = function(c)
        table.insert(cmds, c)
      end

      local spec = dofile(specpath)
      find_key(spec, "<leader>ai")[2]()

      assert.same({ "ClaudeCode" }, cmds)
    end)

    it("does not touch window layout when no dashboard is on screen", function()
      package.loaded["yoda-window.utils"] = {
        find_by_filetype = function()
          return nil
        end,
        reclaim_width = function()
          error("reclaim_width should not be called without a dashboard")
        end,
      }
      vim.cmd = function() end

      local spec = dofile(specpath)
      find_key(spec, "<leader>ai")[2]()
    end)

    it("reclaims the dashboard's width for Claude's window when the dashboard was open", function()
      local reclaimed
      package.loaded["yoda-window.utils"] = {
        find_by_filetype = function(ft)
          if ft == "snacks_dashboard" then
            return 1
          end
          return nil
        end,
        reclaim_width = function(close_win, target_win)
          reclaimed = { close_win = close_win, target_win = target_win }
        end,
      }
      package.loaded["claudecode.terminal"] = {
        get_active_terminal_bufnr = function()
          return 42
        end,
      }
      vim.cmd = function() end
      vim.fn.bufwinid = function(buf)
        assert.equals(42, buf)
        return 7
      end

      local spec = dofile(specpath)
      find_key(spec, "<leader>ai")[2]()

      assert.same({ close_win = 1, target_win = 7 }, reclaimed)
    end)

    it("does not resize when Claude's terminal window can't be found", function()
      package.loaded["yoda-window.utils"] = {
        find_by_filetype = function()
          return 1
        end,
        reclaim_width = function()
          error("reclaim_width should not be called without a Claude window")
        end,
      }
      package.loaded["claudecode.terminal"] = {
        get_active_terminal_bufnr = function()
          return nil
        end,
      }
      vim.cmd = function() end

      local spec = dofile(specpath)
      find_key(spec, "<leader>ai")[2]()
    end)
  end)
end)
