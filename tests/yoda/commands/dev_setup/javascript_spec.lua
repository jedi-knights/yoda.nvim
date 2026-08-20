-- tests/yoda/commands/dev_setup/javascript_spec.lua
local helpers = require("tests.helpers")

describe("commands.dev_setup.javascript", function()
  local dev_js
  local notify_spy_fn, notify_spy_data
  local original_vim_cmd, original_popen

  local ALL_COMMANDS =
    { "YodaJavaScriptSetup", "YodaNodeVersion", "YodaNpmOutdated" }

  local function clear_commands()
    for _, name in ipairs(ALL_COMMANDS) do
      pcall(vim.api.nvim_del_user_command, name)
    end
  end

  before_each(function()
    package.loaded["yoda.commands.dev_setup.javascript"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }

    clear_commands()
    dev_js = require("yoda.commands.dev_setup.javascript")
    dev_js.setup()

    original_vim_cmd = vim.cmd
    original_popen = io.popen
  end)

  after_each(function()
    vim.cmd = original_vim_cmd
    io.popen = original_popen
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded.mason = nil
    clear_commands()
  end)

  describe("YodaJavaScriptSetup", function()
    it("notifies an error when Mason is unavailable", function()
      -- Act
      vim.cmd("YodaJavaScriptSetup")

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "❌ Mason not available. Install via :Lazy sync first",
        "error"
      )
    end)

    it(
      "installs ts_ls, js-debug-adapter, and biome via Mason when available",
      function()
        -- Arrange
        package.loaded.mason = {}
        local cmd_spy_fn, cmd_spy_data = helpers.spy()
        vim.cmd = cmd_spy_fn

        -- Act
        vim.api.nvim_exec2("YodaJavaScriptSetup", {})

        -- Assert
        assert.equals(3, cmd_spy_data.call_count)
        assert.equals(
          "MasonInstall typescript-language-server",
          cmd_spy_data.calls[1][1]
        )
        assert.equals("MasonInstall js-debug-adapter", cmd_spy_data.calls[2][1])
        assert.equals("MasonInstall biome", cmd_spy_data.calls[3][1])
        assert.matches(
          "JavaScript tools installation started",
          notify_spy_data.last_call[1]
        )
      end
    )
  end)

  describe("YodaNodeVersion", function()
    it("reports the node version when node is available", function()
      -- Arrange
      io.popen = function()
        return {
          read = function()
            return "v20.11.0\n"
          end,
          close = function() end,
        }
      end

      -- Act
      vim.cmd("YodaNodeVersion")

      -- Assert
      assert.matches("v20%.11%.0", notify_spy_data.last_call[1])
      assert.equals("info", notify_spy_data.last_call[2])
    end)

    it("notifies an error when node is not found", function()
      -- Arrange
      io.popen = function()
        return nil
      end

      -- Act
      vim.cmd("YodaNodeVersion")

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "❌ Node.js not found",
        "error"
      )
    end)
  end)

  it("YodaNpmOutdated shells out to npm outdated", function()
    -- Arrange
    local cmd_spy_fn, cmd_spy_data = helpers.spy()
    vim.cmd = cmd_spy_fn

    -- Act
    vim.api.nvim_exec2("YodaNpmOutdated", {})

    -- Assert
    assert.equals("!npm outdated", cmd_spy_data.last_call[1])
  end)
end)
