describe("session", function()
  local session

  before_each(function()
    package.loaded["yoda.session"] = nil
    pcall(vim.api.nvim_del_augroup_by_name, "YodaSessionCleanup")
    session = require("yoda.session")
  end)

  after_each(function()
    package.loaded["yoda.session"] = nil
    pcall(vim.api.nvim_del_augroup_by_name, "YodaSessionCleanup")
  end)

  describe("setup", function()
    -- Uses nvim_get_autocmds as the observable rather than monkeypatching
    -- nvim_create_autocmd — tests behavior, not mock wiring.
    it(
      "registers a VimLeavePre autocmd in the YodaSessionCleanup group",
      function()
        session.setup()

        local autocmds = vim.api.nvim_get_autocmds({
          group = "YodaSessionCleanup",
          event = "VimLeavePre",
        })

        assert.equals(1, #autocmds)
      end
    )

    it("calls wshada! when VimLeavePre fires", function()
      session.setup()

      local autocmds = vim.api.nvim_get_autocmds({
        group = "YodaSessionCleanup",
        event = "VimLeavePre",
      })

      local wshada_called = false
      local original_cmd = vim.cmd

      vim.cmd = function(cmd)
        if cmd == "wshada!" then
          wshada_called = true
          return
        end
        return original_cmd(cmd)
      end

      -- VimLeavePre cannot be fired in headless mode; invoke the callback
      -- directly
      autocmds[1].callback()

      vim.cmd = original_cmd

      assert.is_true(wshada_called)
    end)

    it(
      "is idempotent — calling setup twice does not double-register the autocmd",
      function()
        session.setup()
        session.setup()

        local autocmds = vim.api.nvim_get_autocmds({
          group = "YodaSessionCleanup",
          event = "VimLeavePre",
        })

        assert.equals(1, #autocmds)
      end
    )

    it(
      "emits WARN and does not propagate when wshada! raises an error",
      function()
        session.setup()

        local autocmds = vim.api.nvim_get_autocmds({
          group = "YodaSessionCleanup",
          event = "VimLeavePre",
        })

        local notified_level
        local original_cmd = vim.cmd
        local original_notify = vim.notify

        vim.cmd = function(cmd)
          if cmd == "wshada!" then
            error("permission denied")
          end
          return original_cmd(cmd)
        end

        vim.notify = function(_, level)
          notified_level = level
        end

        local ok = pcall(autocmds[1].callback)

        vim.cmd = original_cmd
        vim.notify = original_notify

        assert.is_true(ok)
        assert.equals(vim.log.levels.WARN, notified_level)
      end
    )
  end)

  describe("VimEnter stale ShaDa tmp cleanup", function()
    -- Every prior test exercises VimLeavePre only. The VimEnter callback
    -- (cleanup_stale_shada_tmp) was completely untested, leaving three
    -- zero-arm gaps: the loop iteration (L25), the stale-file predicate
    -- (L27), and the os.remove failure path (L29).

    local original_glob
    local original_fs_stat
    local original_remove
    local original_time
    local original_notify

    local function get_vim_enter_callback()
      session.setup()
      local acs = vim.api.nvim_get_autocmds({
        group = "YodaSessionCleanup",
        event = "VimEnter",
      })
      assert.equals(1, #acs, "VimEnter autocmd not registered")
      return acs[1].callback
    end

    before_each(function()
      original_glob = vim.fn.glob
      original_fs_stat = vim.loop.fs_stat
      original_remove = os.remove
      original_time = os.time
      original_notify = vim.notify
    end)

    after_each(function()
      vim.fn.glob = original_glob
      vim.loop.fs_stat = original_fs_stat
      os.remove = original_remove
      os.time = original_time
      vim.notify = original_notify
    end)

    it(
      "registers a VimEnter autocmd on the YodaSessionCleanup group",
      function()
        -- Act
        session.setup()

        -- Assert
        local acs = vim.api.nvim_get_autocmds({
          group = "YodaSessionCleanup",
          event = "VimEnter",
        })
        assert.equals(1, #acs)
        assert.matches("stale", acs[1].desc)
      end
    )

    it("removes stale tmp files (age > STALE_AFTER_SECONDS)", function()
      -- Arrange: file mtime is 400 seconds old, threshold is 300s -> stale.
      os.time = function()
        return 1000000
      end
      vim.fn.glob = function(_pattern, _nosuf, _list)
        return { "/state/shada/main.shada.tmp.X" }
      end
      vim.loop.fs_stat = function(path)
        if path == "/state/shada/main.shada.tmp.X" then
          return { mtime = { sec = 1000000 - 400 } }
        end
        return nil
      end
      local removed = {}
      os.remove = function(path)
        table.insert(removed, path)
        return true
      end

      -- Act
      get_vim_enter_callback()()

      -- Assert
      assert.same({ "/state/shada/main.shada.tmp.X" }, removed)
    end)

    it("keeps recent tmp files (age <= STALE_AFTER_SECONDS)", function()
      -- Arrange: file is 100 seconds old, well under 300s threshold.
      os.time = function()
        return 1000000
      end
      vim.fn.glob = function()
        return { "/state/shada/fresh.shada.tmp.X" }
      end
      vim.loop.fs_stat = function()
        return { mtime = { sec = 1000000 - 100 } }
      end
      local removed = {}
      os.remove = function(path)
        table.insert(removed, path)
        return true
      end

      -- Act
      get_vim_enter_callback()()

      -- Assert
      assert.equals(0, #removed)
    end)

    it("warns when os.remove raises on a stale tmp file", function()
      -- Arrange
      os.time = function()
        return 1000000
      end
      vim.fn.glob = function()
        return { "/state/shada/locked.shada.tmp.X" }
      end
      vim.loop.fs_stat = function()
        return { mtime = { sec = 1000000 - 500 } }
      end
      os.remove = function()
        error("permission denied")
      end
      local warn_msg
      local warn_level
      vim.notify = function(msg, level)
        warn_msg = msg
        warn_level = level
      end

      -- Act
      get_vim_enter_callback()()

      -- Assert
      assert.is_not_nil(warn_msg, "expected a warn notification")
      assert.matches("failed to remove stale ShaDa temp file", warn_msg)
      assert.equals(vim.log.levels.WARN, warn_level)
    end)

    it("no-ops when glob returns no matching files", function()
      -- Arrange
      vim.fn.glob = function()
        return {}
      end
      local removed = {}
      os.remove = function(path)
        table.insert(removed, path)
        return true
      end

      -- Act
      get_vim_enter_callback()()

      -- Assert
      assert.equals(0, #removed)
    end)

    it("skips paths whose fs_stat returns nil (raced deletion)", function()
      -- Arrange: glob reported a path but fs_stat comes back nil (someone
      -- else deleted it between glob and stat). The `if stat and ...` guard
      -- exists for this race; make sure it holds.
      vim.fn.glob = function()
        return { "/state/shada/gone.shada.tmp.X" }
      end
      vim.loop.fs_stat = function()
        return nil
      end
      local removed = {}
      os.remove = function(path)
        table.insert(removed, path)
        return true
      end

      -- Act
      get_vim_enter_callback()()

      -- Assert
      assert.equals(0, #removed)
    end)
  end)
end)
