-- tests/yoda/commands/formatting_spec.lua
local helpers = require("tests.helpers")

describe("commands.formatting", function()
  local original_autoformat
  local original_notify

  local function clear_commands()
    pcall(vim.api.nvim_del_user_command, "FormatFeature")
    pcall(vim.api.nvim_del_user_command, "ToggleFormat")
  end

  before_each(function()
    original_autoformat = vim.g.autoformat
    original_notify = vim.notify
    clear_commands()
    package.loaded["yoda.commands.formatting"] = nil
    require("yoda.commands.formatting").setup()
  end)

  after_each(function()
    clear_commands()
    vim.g.autoformat = original_autoformat
    vim.notify = original_notify
    package.loaded["yoda.commands.formatting"] = nil
  end)

  describe(":ToggleFormat", function()
    it("flips vim.g.autoformat and notifies the new state", function()
      -- Arrange
      vim.g.autoformat = true
      local notify_spy, notify_data = helpers.spy()
      vim.notify = notify_spy

      -- Act
      vim.api.nvim_exec2("ToggleFormat", {})

      -- Assert
      assert.is_false(vim.g.autoformat)
      helpers.assert_called(notify_data)
      assert.matches("Disabled formatting on save", notify_data.last_call[1])
      assert.equals(vim.log.levels.INFO, notify_data.last_call[2])
    end)

    it("toggles from false back to true on a second invocation", function()
      -- Arrange
      vim.g.autoformat = false
      local notify_spy, notify_data = helpers.spy()
      vim.notify = notify_spy

      -- Act
      vim.api.nvim_exec2("ToggleFormat", {})

      -- Assert
      assert.is_true(vim.g.autoformat)
      assert.matches("Enabled formatting on save", notify_data.last_call[1])
    end)
  end)
end)
