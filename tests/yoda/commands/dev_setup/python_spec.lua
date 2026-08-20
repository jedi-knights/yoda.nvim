-- tests/yoda/commands/dev_setup/python_spec.lua
local helpers = require("tests.helpers")

describe("commands.dev_setup.python", function()
  local dev_python
  local notify_spy_fn, notify_spy_data
  local cmd_spy_fn, cmd_spy_data
  local original_vim_cmd

  local ALL_COMMANDS =
    { "YodaPythonSetup", "StopPyright", "UninstallPyright", "YodaPythonVenv" }

  local function clear_commands()
    for _, name in ipairs(ALL_COMMANDS) do
      pcall(vim.api.nvim_del_user_command, name)
    end
  end

  before_each(function()
    package.loaded["yoda.commands.dev_setup.python"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }

    clear_commands()
    dev_python = require("yoda.commands.dev_setup.python")
    dev_python.setup()

    cmd_spy_fn, cmd_spy_data = helpers.spy()
    original_vim_cmd = vim.cmd
  end)

  after_each(function()
    vim.cmd = original_vim_cmd
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded.mason = nil
    clear_commands()
  end)

  describe("YodaPythonSetup", function()
    it("notifies an error when Mason is unavailable", function()
      -- Act
      vim.cmd("YodaPythonSetup")

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "❌ Mason not available. Install via :Lazy sync first",
        "error"
      )
    end)

    it(
      "installs basedpyright, debugpy, and ruff via Mason when available",
      function()
        -- Arrange
        package.loaded.mason = {}
        vim.cmd = cmd_spy_fn

        -- Act: nvim_exec2 dispatches through the Ex-command layer,
        -- independent of the now-stubbed Lua-level vim.cmd, so the
        -- registered callback still runs and its own vim.cmd(...) calls
        -- hit the stub.
        vim.api.nvim_exec2("YodaPythonSetup", {})

        -- Assert
        assert.equals(3, cmd_spy_data.call_count)
        assert.equals("MasonInstall basedpyright", cmd_spy_data.calls[1][1])
        assert.equals("MasonInstall debugpy", cmd_spy_data.calls[2][1])
        assert.equals("MasonInstall ruff", cmd_spy_data.calls[3][1])
        assert.matches(
          "Python tools installation started",
          notify_spy_data.last_call[1]
        )
      end
    )
  end)

  describe("StopPyright", function()
    it("notifies when no pyright clients are running", function()
      -- Arrange
      local original_get_clients = vim.lsp.get_clients
      vim.lsp.get_clients = function()
        return {}
      end

      -- Act
      vim.cmd("StopPyright")

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "No pyright clients running",
        "info"
      )

      vim.lsp.get_clients = original_get_clients
    end)

    it("stops every running pyright client", function()
      -- Arrange
      local stop_spy, stop_data = helpers.spy()
      local original_get_clients = vim.lsp.get_clients
      vim.lsp.get_clients = function()
        return { { id = 7, stop = stop_spy } }
      end

      -- Act
      vim.cmd("StopPyright")

      -- Assert
      helpers.assert_called(stop_data, 1)
      assert.matches(
        "Stopped pyright client %(id:7%)",
        notify_spy_data.last_call[1]
      )

      vim.lsp.get_clients = original_get_clients
    end)
  end)

  it("UninstallPyright removes pyright via Mason and notifies", function()
    -- Arrange
    vim.cmd = cmd_spy_fn

    -- Act
    vim.api.nvim_exec2("UninstallPyright", {})

    -- Assert
    assert.equals("MasonUninstall pyright", cmd_spy_data.last_call[1])
    assert.matches("Pyright uninstalled", notify_spy_data.last_call[1])
  end)

  describe("YodaPythonVenv", function()
    after_each(function()
      pcall(vim.api.nvim_del_user_command, "VenvSelect")
    end)

    it("notifies when venv-selector is unavailable", function()
      -- Act
      vim.cmd("YodaPythonVenv")

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "❌ venv-selector not available. Install via :Lazy sync",
        "error"
      )
    end)

    it("does not notify when VenvSelect exists", function()
      -- Arrange
      vim.api.nvim_create_user_command("VenvSelect", function() end, {})

      -- Act
      vim.cmd("YodaPythonVenv")

      -- Assert
      helpers.assert_not_called(notify_spy_data)
    end)
  end)
end)
