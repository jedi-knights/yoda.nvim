-- tests/yoda/keymaps/utilities_spec.lua
local helpers = require("tests.helpers")

describe("keymaps.utilities", function()
  local notify_spy_fn, notify_spy_data

  local function get_keymap(desc)
    for _, km in ipairs(vim.api.nvim_get_keymap("n")) do
      if km.desc == desc then
        return km
      end
    end
    error("no keymap registered with desc: " .. desc)
  end

  before_each(function()
    package.loaded["yoda.keymaps.utilities"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }
    require("yoda.keymaps.utilities")
  end)

  after_each(function()
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded.snacks = nil
    pcall(vim.api.nvim_del_user_command, "ShowkeysToggle")
    pcall(vim.api.nvim_del_user_command, "Showkeys")
  end)

  it("registers the plain-string buffer/quit/format keymaps", function()
    -- Assert: Neovim normalizes special-key casing on registration
    -- (<cmd> -> <Cmd>, <cr> -> <CR>).
    assert.equals("<Cmd>bnext<CR>", get_keymap("Buffer: Next").rhs)
    assert.equals("<Cmd>bprev<CR>", get_keymap("Buffer: Prev").rhs)
    assert.equals(":qa<CR>", get_keymap("Util: Quit Neovim").rhs)
    assert.equals(
      "<Cmd>ToggleFormat<CR>",
      get_keymap("Util: Toggle format on save").rhs
    )
  end)

  it(
    "<leader>D deletes buffer content without touching the clipboard",
    function()
      -- Arrange
      local buf = vim.api.nvim_create_buf(false, false)
      vim.api.nvim_set_current_buf(buf)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "line one", "line two" })
      local yank_before = vim.fn.getreg('"')

      -- Act
      get_keymap("Util: Delete buffer content").callback()

      -- Assert
      assert.same({ "" }, vim.api.nvim_buf_get_lines(buf, 0, -1, false))
      assert.equals(yank_before, vim.fn.getreg('"'))

      vim.api.nvim_buf_delete(buf, { force = true })
    end
  )

  describe("<leader>H (open dashboard)", function()
    it("opens the snacks dashboard when available", function()
      -- Arrange
      local open_spy, open_data = helpers.spy()
      package.loaded.snacks = { dashboard = { open = open_spy } }

      -- Act
      get_keymap("Util: Open dashboard (home)").callback()

      -- Assert
      helpers.assert_called(open_data, 1)
      helpers.assert_not_called(notify_spy_data)
    end)

    it("notifies when snacks is unavailable", function()
      -- Act
      get_keymap("Util: Open dashboard (home)").callback()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Failed to open dashboard - snacks not available",
        "error"
      )
    end)
  end)

  describe("<leader>tK (toggle showkeys)", function()
    it("uses ShowkeysToggle when it exists", function()
      -- Arrange
      vim.api.nvim_create_user_command("ShowkeysToggle", function() end, {})

      -- Act
      get_keymap("Toggle: Show keys display").callback()

      -- Assert
      helpers.assert_not_called(notify_spy_data)
    end)

    it("falls back to Showkeys when ShowkeysToggle doesn't exist", function()
      -- Arrange
      vim.api.nvim_create_user_command("Showkeys", function() end, {})

      -- Act
      get_keymap("Toggle: Show keys display").callback()

      -- Assert
      helpers.assert_not_called(notify_spy_data)
    end)

    it("notifies when neither command exists", function()
      -- Act
      get_keymap("Toggle: Show keys display").callback()

      -- Assert
      assert.matches("Failed to toggle Showkeys", notify_spy_data.last_call[1])
    end)
  end)

  describe("show_notification_history (<leader>nl / <leader>nh)", function()
    it("shows the snacks notification history when available", function()
      -- Arrange
      local show_history_spy, show_history_data = helpers.spy()
      package.loaded.snacks = {
        notifier = { show_history = show_history_spy },
      }

      -- Act
      get_keymap("Util: Show last message").callback()
      get_keymap("Util: Show notification history").callback()

      -- Assert
      assert.equals(2, show_history_data.call_count)
    end)

    it("falls back to :messages when snacks.notifier is unavailable", function()
      -- Arrange
      local original_messages = vim.cmd.messages
      local messages_spy, messages_data = helpers.spy()
      vim.cmd.messages = messages_spy

      -- Act
      get_keymap("Util: Show last message").callback()

      -- Assert
      helpers.assert_called(messages_data, 1)

      vim.cmd.messages = original_messages
    end)
  end)

  describe("<leader>nd (dismiss notifications)", function()
    it("hides snacks notifications when available", function()
      -- Arrange
      local hide_spy, hide_data = helpers.spy()
      package.loaded.snacks = { notifier = { hide = hide_spy } }

      -- Act
      get_keymap("Util: Dismiss all notifications").callback()

      -- Assert
      helpers.assert_called(hide_data, 1)
    end)

    it("warns via vim.notify when snacks.notifier is unavailable", function()
      -- Arrange
      local vim_notify_spy, vim_notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", vim_notify_spy)

      -- Act
      get_keymap("Util: Dismiss all notifications").callback()

      -- Assert
      helpers.assert_called_with(
        vim_notify_data,
        "snacks.notifier not available",
        vim.log.levels.WARN
      )

      restore()
    end)
  end)
end)
