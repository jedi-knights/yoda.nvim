-- tests/yoda/commands/dev_setup/rust_spec.lua
local helpers = require("tests.helpers")

describe("commands.dev_setup.rust", function()
  local dev_rust
  local notify_spy_fn, notify_spy_data
  local original_vim_cmd

  before_each(function()
    package.loaded["yoda.commands.dev_setup.rust"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }

    pcall(vim.api.nvim_del_user_command, "YodaRustSetup")
    dev_rust = require("yoda.commands.dev_setup.rust")
    dev_rust.setup()

    original_vim_cmd = vim.cmd
  end)

  after_each(function()
    vim.cmd = original_vim_cmd
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded.mason = nil
    pcall(vim.api.nvim_del_user_command, "YodaRustSetup")
  end)

  it("notifies an error when Mason is unavailable", function()
    -- Act
    vim.cmd("YodaRustSetup")

    -- Assert
    helpers.assert_called_with(
      notify_spy_data,
      "❌ Mason not available. Install via :Lazy sync first",
      "error"
    )
  end)

  it("installs rust-analyzer and codelldb via Mason when available", function()
    -- Arrange
    package.loaded.mason = {}
    local cmd_spy_fn, cmd_spy_data = helpers.spy()
    vim.cmd = cmd_spy_fn

    -- Act
    vim.api.nvim_exec2("YodaRustSetup", {})

    -- Assert
    assert.equals(2, cmd_spy_data.call_count)
    assert.equals("MasonInstall rust-analyzer", cmd_spy_data.calls[1][1])
    assert.equals("MasonInstall codelldb", cmd_spy_data.calls[2][1])
    assert.matches(
      "Rust tools installation started",
      notify_spy_data.last_call[1]
    )
  end)
end)
