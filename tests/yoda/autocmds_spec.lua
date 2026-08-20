-- tests/yoda/autocmds_spec.lua
local helpers = require("tests.helpers")

describe("yoda.autocmds", function()
  local autocmds
  local timer_manager = require("yoda.timer_manager")

  --- Stubs a `vim.cmd.<name>` sub-command directly (vim.cmd's __newindex
  --- falls through to a plain rawset) without disturbing vim.cmd() itself.
  local function stub_cmd_field(name, fn)
    vim.cmd[name] = fn
    return function()
      vim.cmd[name] = nil
    end
  end

  --- Forces `require(modname)` to fail (as if the module were absent),
  --- exercising the pcall-guarded failure branch for real first-party
  --- modules that would otherwise load successfully from disk.
  local function force_require_failure(modname)
    local original_preload = package.preload[modname]
    local original_loaded = package.loaded[modname]
    package.loaded[modname] = nil
    package.preload[modname] = function()
      error("forced failure for test")
    end
    return function()
      package.loaded[modname] = original_loaded
      package.preload[modname] = original_preload
    end
  end

  local function get_autocmd(group, event)
    local acs = vim.api.nvim_get_autocmds({ group = group, event = event })
    return acs[1]
  end

  before_each(function()
    package.loaded["yoda.autocmds"] = nil
    autocmds = require("yoda.autocmds")
  end)

  after_each(function()
    timer_manager.reset()
  end)

  it("does not raise and is idempotent", function()
    -- Act
    local ok1 = pcall(autocmds.apply)
    local ok2 = pcall(autocmds.apply)

    -- Assert
    assert.is_true(ok1)
    assert.is_true(ok2)
  end)

  it("registers every expected augroup", function()
    -- Act
    autocmds.apply()

    -- Assert
    local groups = {
      "YodaToggleLineNumbers",
      "YodaChecktime",
      "YodaHighlightYank",
      "YodaTrimWhitespace",
      "ColorColumnPersistent",
      "YodaCloseWithQ",
      "YodaRestoreCursor",
      "YodaResizeSplits",
      "YodaFileTypes",
    }
    for _, group in ipairs(groups) do
      assert.is_true(
        #vim.api.nvim_get_autocmds({ group = group }) > 0,
        group .. " should have at least one autocmd"
      )
    end
  end)

  describe("relative line number toggling", function()
    local win

    before_each(function()
      autocmds.apply()
      win = vim.api.nvim_get_current_win()
    end)

    it("enables relative numbers in normal mode when nu is set", function()
      -- Arrange
      vim.wo[win].number = true
      vim.wo[win].relativenumber = false
      local callback = get_autocmd("YodaToggleLineNumbers", "BufEnter").callback

      -- Act
      callback({ event = "BufEnter" })

      -- Assert
      assert.is_true(vim.wo[win].relativenumber)
    end)

    it("does not enable relative numbers when nu is unset", function()
      -- Arrange
      vim.wo[win].number = false
      vim.wo[win].relativenumber = false
      local callback = get_autocmd("YodaToggleLineNumbers", "BufEnter").callback

      -- Act
      callback({ event = "BufEnter" })

      -- Assert
      assert.is_false(vim.wo[win].relativenumber)
    end)

    it("does not enable relative numbers while in insert mode", function()
      -- Arrange
      vim.wo[win].number = true
      vim.wo[win].relativenumber = false
      local original_get_mode = vim.api.nvim_get_mode
      vim.api.nvim_get_mode = function()
        return { mode = "i" }
      end
      local callback = get_autocmd("YodaToggleLineNumbers", "BufEnter").callback

      -- Act
      callback({ event = "BufEnter" })

      -- Assert
      assert.is_false(vim.wo[win].relativenumber)

      vim.api.nvim_get_mode = original_get_mode
    end)

    it("disables relative numbers on BufLeave when both are set", function()
      -- Arrange
      vim.wo[win].number = true
      vim.wo[win].relativenumber = true
      local callback = get_autocmd("YodaToggleLineNumbers", "BufLeave").callback

      -- Act
      callback({ event = "BufLeave" })

      -- Assert
      assert.is_false(vim.wo[win].relativenumber)
    end)

    it(
      "redraws on CmdlineEnter when v:event.cmdtype is not excluded",
      function()
        -- Arrange: outside a real command-line context v:event is empty, so
        -- cmdtype is nil -- not in the {"@", "-"} exclusion set.
        local redraw_spy, redraw_data = helpers.spy()
        local restore = stub_cmd_field("redraw", redraw_spy)
        local callback =
          get_autocmd("YodaToggleLineNumbers", "BufLeave").callback

        -- Act
        callback({ event = "CmdlineEnter" })

        -- Assert
        helpers.assert_called(redraw_data, 1)

        restore()
      end
    )

    it("does not redraw for non-CmdlineEnter events", function()
      -- Arrange
      local redraw_spy, redraw_data = helpers.spy()
      local restore = stub_cmd_field("redraw", redraw_spy)
      local callback = get_autocmd("YodaToggleLineNumbers", "BufLeave").callback

      -- Act
      callback({ event = "BufLeave" })

      -- Assert
      helpers.assert_not_called(redraw_data)

      restore()
    end)
  end)

  describe("checktime on file change", function()
    before_each(function()
      autocmds.apply()
    end)

    it("runs checktime outside the command-line window", function()
      -- Arrange
      local original_getcmdwintype = vim.fn.getcmdwintype
      vim.fn.getcmdwintype = function()
        return ""
      end
      local checktime_spy, checktime_data = helpers.spy()
      local restore = stub_cmd_field("checktime", checktime_spy)
      local callback = get_autocmd("YodaChecktime", "BufEnter").callback

      -- Act
      callback()

      -- Assert
      helpers.assert_called(checktime_data, 1)

      restore()
      vim.fn.getcmdwintype = original_getcmdwintype
    end)

    it("skips checktime inside the command-line window", function()
      -- Arrange
      local original_getcmdwintype = vim.fn.getcmdwintype
      vim.fn.getcmdwintype = function()
        return "@"
      end
      local checktime_spy, checktime_data = helpers.spy()
      local restore = stub_cmd_field("checktime", checktime_spy)
      local callback = get_autocmd("YodaChecktime", "BufEnter").callback

      -- Act
      callback()

      -- Assert
      helpers.assert_not_called(checktime_data)

      restore()
      vim.fn.getcmdwintype = original_getcmdwintype
    end)
  end)

  describe("yank highlight", function()
    before_each(function()
      autocmds.apply()
    end)

    it("highlights the yank for small buffers", function()
      -- Arrange
      local on_yank_spy, on_yank_data = helpers.spy()
      local original_on_yank = vim.hl.on_yank
      vim.hl.on_yank = on_yank_spy
      local callback = get_autocmd("YodaHighlightYank", "TextYankPost").callback

      -- Act
      callback()

      -- Assert
      helpers.assert_called(on_yank_data, 1)

      vim.hl.on_yank = original_on_yank
    end)

    it("skips highlighting for buffers with 1000+ lines", function()
      -- Arrange
      local on_yank_spy, on_yank_data = helpers.spy()
      local original_on_yank = vim.hl.on_yank
      vim.hl.on_yank = on_yank_spy
      local original_line_count = vim.api.nvim_buf_line_count
      vim.api.nvim_buf_line_count = function()
        return 5000
      end
      local callback = get_autocmd("YodaHighlightYank", "TextYankPost").callback

      -- Act
      callback()

      -- Assert
      helpers.assert_not_called(on_yank_data)

      vim.hl.on_yank = original_on_yank
      vim.api.nvim_buf_line_count = original_line_count
    end)
  end)

  describe("trim trailing whitespace on save", function()
    local buf

    before_each(function()
      autocmds.apply()
      buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
    end)

    after_each(function()
      package.loaded.conform = nil
      if buf and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)

    local function trigger()
      local callback = get_autocmd("YodaTrimWhitespace", "BufWritePre").callback
      callback()
    end

    it("trims trailing whitespace when present", function()
      -- Arrange
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "foo   ", "bar" })

      -- Act
      trigger()

      -- Assert
      assert.same(
        { "foo", "bar" },
        vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      )
    end)

    it(
      "does not touch buffer content when there is no trailing whitespace",
      function()
        -- Arrange
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "foo", "bar" })

        -- Act
        trigger()

        -- Assert
        assert.same(
          { "foo", "bar" },
          vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        )
      end
    )

    it("preserves the last-search register", function()
      -- Arrange
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "foo   " })
      vim.fn.setreg("/", "myPreviousSearch")

      -- Act
      trigger()

      -- Assert
      assert.equals("myPreviousSearch", vim.fn.getreg("/"))
    end)

    it("skips entirely when the buffer is not modifiable", function()
      -- Arrange
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "foo   " })
      vim.bo[buf].modifiable = false

      -- Act
      local ok = pcall(trigger)

      -- Assert
      assert.is_true(ok)
      assert.same({ "foo   " }, vim.api.nvim_buf_get_lines(buf, 0, -1, false))

      vim.bo[buf].modifiable = true
    end)

    it("skips when a conform formatter is registered for the buffer", function()
      -- Arrange
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "foo   " })
      package.loaded.conform = {
        list_formatters = function()
          return { {} }
        end,
      }

      -- Act
      trigger()

      -- Assert
      assert.same({ "foo   " }, vim.api.nvim_buf_get_lines(buf, 0, -1, false))
    end)

    it(
      "still trims when conform is loaded but has no formatters for the buffer",
      function()
        -- Arrange
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "foo   " })
        package.loaded.conform = {
          list_formatters = function()
            return {}
          end,
        }

        -- Act
        trigger()

        -- Assert
        assert.same({ "foo" }, vim.api.nvim_buf_get_lines(buf, 0, -1, false))
      end
    )
  end)

  it(
    "re-applies the ColorColumn highlight after a colorscheme change",
    function()
      -- Arrange
      autocmds.apply()
      local set_hl_spy, set_hl_data = helpers.spy()
      local original_set_hl = vim.api.nvim_set_hl
      vim.api.nvim_set_hl = set_hl_spy
      local callback =
        get_autocmd("ColorColumnPersistent", "ColorScheme").callback

      -- Act
      callback()
      vim.wait(50)

      -- Assert
      helpers.assert_called_with(
        set_hl_data,
        0,
        "ColorColumn",
        { bg = "#2a2a37" }
      )

      vim.api.nvim_set_hl = original_set_hl
    end
  )

  describe("close ephemeral buffers with q", function()
    local buf

    before_each(function()
      autocmds.apply()
      buf = vim.api.nvim_create_buf(false, true)
    end)

    after_each(function()
      if buf and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)

    local function has_q_keymap()
      for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
        if km.lhs == "q" then
          return true
        end
      end
      return false
    end

    it("binds q for non-help ephemeral filetypes", function()
      -- Arrange
      local callback = get_autocmd("YodaCloseWithQ", "FileType").callback

      -- Act
      callback({ buf = buf, match = "qf" })

      -- Assert
      assert.is_true(has_q_keymap())
    end)

    it("binds q for a non-modifiable help buffer", function()
      -- Arrange
      vim.bo[buf].modifiable = false
      local callback = get_autocmd("YodaCloseWithQ", "FileType").callback

      -- Act
      callback({ buf = buf, match = "help" })

      -- Assert
      assert.is_true(has_q_keymap())
    end)

    it("does not bind q for a modifiable help buffer", function()
      -- Arrange
      vim.bo[buf].modifiable = true
      local callback = get_autocmd("YodaCloseWithQ", "FileType").callback

      -- Act
      callback({ buf = buf, match = "help" })

      -- Assert
      assert.is_false(has_q_keymap())
    end)
  end)

  describe("restore cursor position", function()
    local buf, win

    before_each(function()
      autocmds.apply()
      -- scratch = false: a scratch buffer's buftype defaults to "nofile",
      -- which the restore-cursor callback deliberately skips (see the
      -- "skips buffers with a non-empty buftype" test below).
      buf = vim.api.nvim_create_buf(false, false)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "1", "2", "3", "4", "5" })
      win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(win, buf)
    end)

    after_each(function()
      if buf and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)

    it("restores the cursor to a valid last-edit mark", function()
      -- Arrange
      vim.api.nvim_buf_set_mark(buf, '"', 3, 0, {})
      vim.api.nvim_win_set_cursor(win, { 1, 0 })
      local callback = get_autocmd("YodaRestoreCursor", "BufReadPost").callback

      -- Act
      callback()

      -- Assert
      assert.equals(3, vim.api.nvim_win_get_cursor(win)[1])
    end)

    it("does not move the cursor when the mark is out of range", function()
      -- Arrange: mark beyond the buffer's line count
      vim.api.nvim_buf_set_mark(buf, '"', 5, 0, {})
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "1" })
      vim.api.nvim_win_set_cursor(win, { 1, 0 })
      local callback = get_autocmd("YodaRestoreCursor", "BufReadPost").callback

      -- Act
      callback()

      -- Assert
      assert.equals(1, vim.api.nvim_win_get_cursor(win)[1])
    end)

    it("skips buffers with a non-empty buftype", function()
      -- Arrange
      vim.bo[buf].buftype = "nofile"
      vim.api.nvim_buf_set_mark(buf, '"', 3, 0, {})
      vim.api.nvim_win_set_cursor(win, { 1, 0 })
      local callback = get_autocmd("YodaRestoreCursor", "BufReadPost").callback

      -- Act
      callback()

      -- Assert
      assert.equals(1, vim.api.nvim_win_get_cursor(win)[1])
    end)
  end)

  describe("debounced resize", function()
    before_each(function()
      autocmds.apply()
    end)

    it("resizes splits once after the debounce window", function()
      -- Arrange
      local cmd_spy, cmd_data = helpers.spy()
      local original_vim_cmd = vim.cmd
      vim.cmd = cmd_spy
      local callback = get_autocmd("YodaResizeSplits", "VimResized").callback

      -- Act
      callback()
      vim.wait(400, function()
        return cmd_data.call_count >= 1
      end)

      -- Assert
      helpers.assert_called_with(cmd_data, "wincmd =")

      vim.cmd = original_vim_cmd
    end)

    it("collapses rapid repeated resizes into a single call", function()
      -- Arrange
      local cmd_spy, cmd_data = helpers.spy()
      local original_vim_cmd = vim.cmd
      vim.cmd = cmd_spy
      local callback = get_autocmd("YodaResizeSplits", "VimResized").callback

      -- Act
      callback()
      callback()
      callback()
      vim.wait(400, function()
        return cmd_data.call_count >= 1
      end)

      -- Assert
      assert.equals(1, cmd_data.call_count)

      vim.cmd = original_vim_cmd
    end)
  end)

  it("applies filetype-specific settings on FileType", function()
    -- Arrange
    local apply_spy, apply_data = helpers.spy()
    package.loaded["yoda.filetype.settings"] = { apply = apply_spy }
    autocmds.apply()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = "go"
    local callback = get_autocmd("YodaFileTypes", "FileType").callback

    -- Act
    callback()

    -- Assert
    helpers.assert_called_with(apply_data, "go")

    package.loaded["yoda.filetype.settings"] = nil
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  describe("module delegation", function()
    after_each(function()
      package.loaded["yoda.filetype.detection"] = nil
      package.loaded["yoda.git_refresh"] = nil
      package.loaded["yoda.timer_manager"] = nil
      package.loaded["yoda.session"] = nil
    end)

    it(
      "delegates to filetype_detection.setup_all with the real autocmd/augroup fns",
      function()
        -- Arrange
        local setup_all_spy, setup_all_data = helpers.spy()
        package.loaded["yoda.filetype.detection"] =
          { setup_all = setup_all_spy }

        -- Act
        autocmds.apply()

        -- Assert
        helpers.assert_called(setup_all_data, 1)
        assert.equals(vim.api.nvim_create_autocmd, setup_all_data.last_call[1])
        assert.equals(vim.api.nvim_create_augroup, setup_all_data.last_call[2])
      end
    )

    it("delegates to git_refresh.setup_autocmds", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      package.loaded["yoda.git_refresh"] = { setup_autocmds = setup_spy }

      -- Act
      autocmds.apply()

      -- Assert
      helpers.assert_called(setup_data, 1)
    end)

    it("delegates to timer_manager.setup_cleanup", function()
      -- Arrange
      local cleanup_spy, cleanup_data = helpers.spy()
      package.loaded["yoda.timer_manager"] =
        { setup_cleanup = cleanup_spy, reset = function() end }

      -- Act
      autocmds.apply()

      -- Assert
      helpers.assert_called(cleanup_data, 1)
    end)

    it("delegates to session.setup", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      package.loaded["yoda.session"] = { setup = setup_spy }

      -- Act
      autocmds.apply()

      -- Assert
      helpers.assert_called(setup_data, 1)
    end)

    it(
      "warns and continues when yoda.filetype.settings fails to load",
      function()
        -- Arrange
        local restore_require = force_require_failure("yoda.filetype.settings")
        local notify_spy, notify_data = helpers.spy()
        local restore_notify = helpers.mock(vim, "notify", notify_spy)

        -- Act
        local ok = pcall(autocmds.apply)

        -- Assert
        assert.is_true(ok)
        assert.is_true(#notify_data.calls > 0)
        local found = false
        for _, call in ipairs(notify_data.calls) do
          if call[1]:find("yoda.filetype.settings", 1, true) then
            found = true
          end
        end
        assert.is_true(
          found,
          "expected a warning mentioning yoda.filetype.settings"
        )

        restore_notify()
        restore_require()
      end
    )

    it(
      "warns and continues when yoda.filetype.detection fails to load",
      function()
        -- Arrange
        local restore_require = force_require_failure("yoda.filetype.detection")
        local notify_spy, notify_data = helpers.spy()
        local restore_notify = helpers.mock(vim, "notify", notify_spy)

        -- Act
        local ok = pcall(autocmds.apply)

        -- Assert
        assert.is_true(ok)
        local found = false
        for _, call in ipairs(notify_data.calls) do
          if call[1]:find("yoda.filetype.detection", 1, true) then
            found = true
          end
        end
        assert.is_true(found)

        restore_notify()
        restore_require()
      end
    )

    it("warns and continues when yoda.git_refresh fails to load", function()
      -- Arrange
      local restore_require = force_require_failure("yoda.git_refresh")
      local notify_spy, notify_data = helpers.spy()
      local restore_notify = helpers.mock(vim, "notify", notify_spy)

      -- Act
      local ok = pcall(autocmds.apply)

      -- Assert
      assert.is_true(ok)
      local found = false
      for _, call in ipairs(notify_data.calls) do
        if call[1]:find("yoda.git_refresh", 1, true) then
          found = true
        end
      end
      assert.is_true(found)

      restore_notify()
      restore_require()
    end)

    it("warns and continues when yoda.timer_manager fails to load", function()
      -- Arrange
      local restore_require = force_require_failure("yoda.timer_manager")
      local notify_spy, notify_data = helpers.spy()
      local restore_notify = helpers.mock(vim, "notify", notify_spy)

      -- Act
      local ok = pcall(autocmds.apply)

      -- Assert
      assert.is_true(ok)
      local found = false
      for _, call in ipairs(notify_data.calls) do
        if call[1]:find("yoda.timer_manager", 1, true) then
          found = true
        end
      end
      assert.is_true(found)

      restore_notify()
      restore_require()
    end)

    it("warns and continues when yoda.session fails to load", function()
      -- Arrange
      local restore_require = force_require_failure("yoda.session")
      local notify_spy, notify_data = helpers.spy()
      local restore_notify = helpers.mock(vim, "notify", notify_spy)

      -- Act
      local ok = pcall(autocmds.apply)

      -- Assert
      assert.is_true(ok)
      local found = false
      for _, call in ipairs(notify_data.calls) do
        if call[1]:find("yoda.session", 1, true) then
          found = true
        end
      end
      assert.is_true(found)

      restore_notify()
      restore_require()
    end)
  end)
end)
