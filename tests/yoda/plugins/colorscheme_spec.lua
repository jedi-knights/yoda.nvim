-- tests/yoda/plugins/colorscheme_spec.lua
local helpers = require("tests.helpers")

describe("plugins.colorscheme", function()
  local spec

  before_each(function()
    package.loaded["yoda.plugins.colorscheme"] = nil
    spec = require("yoda.plugins.colorscheme")
  end)

  it("declares tokyonight, loaded eagerly at highest priority", function()
    -- Assert
    assert.equals("folke/tokyonight.nvim", spec[1])
    assert.is_false(spec.lazy)
    assert.equals(1000, spec.priority)
  end)

  it("notifies an error when the colorscheme cannot be applied", function()
    -- Arrange: tokyonight is not on the test runtimepath, so the real
    -- `:colorscheme tokyonight` genuinely fails here -- no stubbing needed.
    local notify_spy, notify_data = helpers.spy()
    local restore = helpers.mock(vim, "notify", notify_spy)

    -- Act
    spec.config()
    vim.wait(50, function()
      return notify_data.called
    end)

    -- Assert
    helpers.assert_called_with(
      notify_data,
      "Colorscheme 'tokyonight' not found!",
      vim.log.levels.ERROR
    )

    restore()
  end)

  it("does not notify when the colorscheme applies successfully", function()
    -- Arrange
    local cmd_spy = helpers.spy()
    local original_vim_cmd = vim.cmd
    vim.cmd = cmd_spy
    local notify_spy, notify_data = helpers.spy()
    local restore_notify = helpers.mock(vim, "notify", notify_spy)

    -- Act
    spec.config()
    vim.wait(50)

    -- Assert
    helpers.assert_not_called(notify_data)

    restore_notify()
    vim.cmd = original_vim_cmd
  end)
end)
