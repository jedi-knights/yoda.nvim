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
    it("registers a VimLeavePre autocmd in the YodaSessionCleanup group", function()
      session.setup()

      local autocmds = vim.api.nvim_get_autocmds({
        group = "YodaSessionCleanup",
        event = "VimLeavePre",
      })

      assert.equals(1, #autocmds)
    end)

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

      -- VimLeavePre cannot be fired in headless mode; invoke the callback directly
      autocmds[1].callback()

      vim.cmd = original_cmd

      assert.is_true(wshada_called)
    end)

    it("is idempotent — calling setup twice does not double-register the autocmd", function()
      session.setup()
      session.setup()

      local autocmds = vim.api.nvim_get_autocmds({
        group = "YodaSessionCleanup",
        event = "VimLeavePre",
      })

      assert.equals(1, #autocmds)
    end)

    it("emits WARN and does not propagate when wshada! raises an error", function()
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
    end)
  end)
end)
