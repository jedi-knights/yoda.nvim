-- tests/yoda/plugins/snacks_spec.lua
local helpers = require("tests.helpers")

describe("plugins.snacks", function()
  local spec
  local snacks_stub

  local function dashboard_key(key)
    for _, k in ipairs(spec.config_setup_data.dashboard.preset.keys) do
      if k.key == key then
        return k
      end
    end
    return nil
  end

  before_each(function()
    package.loaded["yoda.plugins.snacks"] = nil
    spec = require("yoda.plugins.snacks")

    local setup_spy, setup_data = helpers.spy()
    snacks_stub = {
      setup = setup_spy,
      explorer = { open = function() end },
      picker = { zoxide = function() end },
      dashboard = function() end,
    }
    package.loaded.snacks = snacks_stub
    package.loaded["mini.pick"] = {
      builtin = { files = function() end, grep_live = function() end },
    }
    package.loaded["mini.extra"] = { pickers = { oldfiles = function() end } }

    spec.config()
    -- Stash the captured opts on `spec` for convenience across assertions
    -- in this file; not part of the plugin's own API.
    spec.config_setup_data = setup_data.last_call[1]
  end)

  after_each(function()
    package.loaded.snacks = nil
    package.loaded["mini.pick"] = nil
    package.loaded["mini.extra"] = nil
    pcall(vim.keymap.del, "n", "<leader>sp")
    pcall(vim.api.nvim_del_augroup_by_name, "ExplorerFileOpen")
  end)

  it("declares snacks.nvim, loaded eagerly at highest priority", function()
    -- Assert
    assert.equals("folke/snacks.nvim", spec[1])
    assert.is_false(spec.lazy)
    assert.equals(1000, spec.priority)
  end)

  it(
    "enables the dashboard, explorer, and notifier with the expected settings",
    function()
      -- Assert
      local opts = spec.config_setup_data
      assert.is_true(opts.dashboard.enabled)
      assert.is_true(opts.explorer.replace_netrw)
      assert.equals(3000, opts.notifier.timeout)
      assert.is_true(opts.picker.sources.explorer.hidden)
      assert.is_true(opts.picker.sources.explorer.ignored)
    end
  )

  describe("dashboard keys", function()
    it("'e' opens the explorer", function()
      -- Arrange
      local open_spy, open_data = helpers.spy()
      snacks_stub.explorer.open = open_spy

      -- Act
      dashboard_key("e").action()

      -- Assert
      helpers.assert_called(open_data, 1)
    end)

    it("'f' opens the mini.pick file finder", function()
      -- Arrange
      local files_spy, files_data = helpers.spy()
      package.loaded["mini.pick"].builtin.files = files_spy

      -- Act
      dashboard_key("f").action()

      -- Assert
      helpers.assert_called(files_data, 1)
    end)

    it("'g' opens the mini.pick live grep", function()
      -- Arrange
      local grep_spy, grep_data = helpers.spy()
      package.loaded["mini.pick"].builtin.grep_live = grep_spy

      -- Act
      dashboard_key("g").action()

      -- Assert
      helpers.assert_called(grep_data, 1)
    end)

    it("'r' opens the mini.extra recent-files picker", function()
      -- Arrange
      local oldfiles_spy, oldfiles_data = helpers.spy()
      package.loaded["mini.extra"].pickers.oldfiles = oldfiles_spy

      -- Act
      dashboard_key("r").action()

      -- Assert
      helpers.assert_called(oldfiles_data, 1)
    end)
  end)

  describe("<leader>sp (zoxide project picker)", function()
    local original_executable

    before_each(function()
      original_executable = vim.fn.executable
    end)

    after_each(function()
      vim.fn.executable = original_executable
    end)

    local function get_callback()
      for _, km in ipairs(vim.api.nvim_get_keymap("n")) do
        if km.desc == "[S]earch [P]rojects (zoxide)" then
          return km.callback
        end
      end
      error("keymap not registered")
    end

    it("warns when zoxide is not installed", function()
      -- Arrange
      vim.fn.executable = function()
        return 0
      end
      local zoxide_spy, zoxide_data = helpers.spy()
      snacks_stub.picker.zoxide = zoxide_spy
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      get_callback()()

      -- Assert
      assert.matches("zoxide is not installed", notify_data.last_call[1])
      helpers.assert_not_called(zoxide_data)

      restore()
    end)

    it("opens the zoxide picker when installed", function()
      -- Arrange
      vim.fn.executable = function()
        return 1
      end
      local zoxide_spy, zoxide_data = helpers.spy()
      snacks_stub.picker.zoxide = zoxide_spy

      -- Act
      get_callback()()

      -- Assert
      helpers.assert_called(zoxide_data, 1)
      assert.equals("function", type(zoxide_data.last_call[1].confirm))
    end)

    it(
      "cd's to the chosen directory and reopens the dashboard on confirm",
      function()
        -- Arrange
        vim.fn.executable = function()
          return 1
        end
        local zoxide_spy, zoxide_data = helpers.spy()
        snacks_stub.picker.zoxide = zoxide_spy
        local dashboard_spy, dashboard_data = helpers.spy()
        snacks_stub.dashboard = dashboard_spy
        local cmd_spy, cmd_data = helpers.spy()
        local original_vim_cmd = vim.cmd
        vim.cmd = cmd_spy
        local close_spy, close_data = helpers.spy()
        local picker = { close = close_spy }

        -- Act
        get_callback()()
        local confirm = zoxide_data.last_call[1].confirm
        confirm(picker, { file = "/some/project" })

        -- Assert
        helpers.assert_called(close_data, 1)
        assert.matches("^cd ", cmd_data.last_call[1])
        helpers.assert_called(dashboard_data, 1)

        vim.cmd = original_vim_cmd
      end
    )

    it("does not cd when no item was chosen", function()
      -- Arrange
      vim.fn.executable = function()
        return 1
      end
      local zoxide_spy, zoxide_data = helpers.spy()
      snacks_stub.picker.zoxide = zoxide_spy
      local cmd_spy, cmd_data = helpers.spy()
      local original_vim_cmd = vim.cmd
      vim.cmd = cmd_spy
      local close_spy, close_data = helpers.spy()

      -- Act
      get_callback()()
      local confirm = zoxide_data.last_call[1].confirm
      confirm({ close = close_spy }, nil)

      -- Assert
      helpers.assert_called(close_data, 1)
      helpers.assert_not_called(cmd_data)

      vim.cmd = original_vim_cmd
    end)
  end)

  describe("explorer file-open redirect", function()
    local explorer_buf, other_buf

    local function trigger(opened_buf)
      local callback = vim.api.nvim_get_autocmds({
        group = "ExplorerFileOpen",
        event = "BufReadPost",
      })[1].callback
      callback({ buf = opened_buf })
    end

    before_each(function()
      explorer_buf = vim.api.nvim_create_buf(false, true)
      vim.bo[explorer_buf].filetype = "snacks-explorer"
      vim.api.nvim_set_current_buf(explorer_buf)
    end)

    after_each(function()
      if vim.api.nvim_buf_is_valid(explorer_buf) then
        vim.api.nvim_buf_delete(explorer_buf, { force = true })
      end
      if other_buf and vim.api.nvim_buf_is_valid(other_buf) then
        vim.api.nvim_buf_delete(other_buf, { force = true })
      end
    end)

    it(
      "does not redirect when the current window is not the explorer",
      function()
        -- Arrange
        vim.bo[explorer_buf].filetype = "lua"
        other_buf = vim.api.nvim_create_buf(false, true)
        local current_win = vim.api.nvim_get_current_win()

        -- Act
        trigger(other_buf)

        -- Assert: current window's buffer is unchanged
        assert.equals(explorer_buf, vim.api.nvim_win_get_buf(current_win))
      end
    )

    it(
      "opens a new split when no non-explorer window exists (L184 truthy)",
      function()
        -- Arrange: only window is the explorer. When the callback fires
        -- with a regular file buffer, the for loop finds no candidate ->
        -- target_win is nil -> vsplit branch runs.
        other_buf = vim.api.nvim_create_buf(false, false)
        local cmds_seen = {}
        local original_vim_cmd = vim.cmd
        -- Preserve callable semantics but capture invocations.
        vim.cmd = setmetatable({}, {
          __call = function(_, arg)
            table.insert(cmds_seen, arg)
          end,
          __index = original_vim_cmd,
        })

        -- Act
        trigger(other_buf)

        -- Assert
        assert.is_true(
          vim.tbl_contains(cmds_seen, "rightbelow vsplit"),
          "expected vim.cmd('rightbelow vsplit') to fire"
        )

        vim.cmd = original_vim_cmd
      end
    )

    it(
      "redirects a regular file into an existing non-explorer window",
      function()
        -- Arrange: `:vsplit` clones the current (explorer) buffer into the
        -- new window rather than creating a distinct one, so give it a
        -- genuinely different buffer before switching focus back to the
        -- explorer -- otherwise every window shows "snacks-explorer" and
        -- the callback opens yet another split instead of reusing this one.
        vim.cmd("rightbelow vsplit")
        local target_win = vim.api.nvim_get_current_win()
        local placeholder_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(target_win, placeholder_buf)

        local explorer_win = vim.api.nvim_call_function("win_getid", { 1 })
        vim.api.nvim_set_current_win(explorer_win)
        vim.api.nvim_win_set_buf(explorer_win, explorer_buf)
        -- scratch=false: the callback only redirects buftype=="" buffers,
        -- and a scratch buffer's buftype defaults to "nofile".
        other_buf = vim.api.nvim_create_buf(false, false)

        -- Act
        trigger(other_buf)

        -- Assert
        assert.equals(other_buf, vim.api.nvim_win_get_buf(target_win))

        pcall(vim.api.nvim_win_close, target_win, true)
        if vim.api.nvim_buf_is_valid(placeholder_buf) then
          vim.api.nvim_buf_delete(placeholder_buf, { force = true })
        end
      end
    )
  end)
end)
