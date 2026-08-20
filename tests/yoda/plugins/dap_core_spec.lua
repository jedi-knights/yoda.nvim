-- tests/yoda/plugins/dap_core_spec.lua
local helpers = require("tests.helpers")

describe("plugins.dap-core", function()
  local spec
  local dap_registry = require("yoda.core.dap_registry")

  local function fresh_dap_stub()
    return {
      listeners = {
        after = { event_initialized = {} },
        before = { event_terminated = {}, event_exited = {} },
      },
      configurations = { python = {} },
      continue = function() end,
      step_over = function() end,
      step_into = function() end,
      step_out = function() end,
      toggle_breakpoint = function() end,
      set_breakpoint = function() end,
      terminate = function() end,
      run_last = function() end,
      repl = { open = function() end },
    }
  end

  before_each(function()
    package.loaded["yoda.plugins.dap-core"] = nil
    spec = require("yoda.plugins.dap-core")[1]
    dap_registry._reset()

    package.loaded["nvim-dap-virtual-text"] = { setup = function() end }
    package.loaded["dap.ext.vscode"] = { load_launchjs = function() end }
  end)

  after_each(function()
    package.loaded.dap = nil
    package.loaded.dapui = nil
    package.loaded["nvim-dap-virtual-text"] = nil
    package.loaded["dap.ext.vscode"] = nil
    dap_registry._reset()
    pcall(vim.api.nvim_del_augroup_by_name, "dap_vscode_launch")
  end)

  it("declares nvim-dap with dapui and virtual-text as dependencies", function()
    -- Assert
    assert.equals("mfussenegger/nvim-dap", spec[1])
    local dep_names = {}
    for _, dep in ipairs(spec.dependencies) do
      dep_names[type(dep) == "table" and dep[1] or dep] = true
    end
    assert.is_true(dep_names["rcarriga/nvim-dap-ui"])
    assert.is_true(dep_names["theHamsta/nvim-dap-virtual-text"])
  end)

  describe("keymaps", function()
    local function by_lhs(lhs)
      for _, k in ipairs(spec.keys) do
        if k[1] == lhs then
          return k
        end
      end
      return nil
    end

    for _, case in ipairs({
      { lhs = "<F5>", target = "dap", method = "continue" },
      { lhs = "<F10>", target = "dap", method = "step_over" },
      { lhs = "<F11>", target = "dap", method = "step_into" },
      { lhs = "<F12>", target = "dap", method = "step_out" },
      { lhs = "<leader>dc", target = "dap", method = "continue" },
      { lhs = "<leader>db", target = "dap", method = "toggle_breakpoint" },
      { lhs = "<leader>do", target = "dap", method = "step_over" },
      { lhs = "<leader>di", target = "dap", method = "step_into" },
      { lhs = "<leader>dO", target = "dap", method = "step_out" },
      { lhs = "<leader>dq", target = "dap", method = "terminate" },
      { lhs = "<leader>du", target = "dapui", method = "toggle" },
      { lhs = "<leader>dl", target = "dap", method = "run_last" },
    }) do
      it(
        case.lhs .. " calls " .. case.target .. "." .. case.method .. "()",
        function()
          -- Arrange
          local spy_fn, spy_data = helpers.spy()
          package.loaded[case.target] = { [case.method] = spy_fn }

          -- Act
          by_lhs(case.lhs)[2]()

          -- Assert
          helpers.assert_called(spy_data, 1)

          package.loaded[case.target] = nil
        end
      )
    end

    it("<leader>dB sets a conditional breakpoint from user input", function()
      -- Arrange
      local set_breakpoint_spy, set_breakpoint_data = helpers.spy()
      package.loaded.dap = { set_breakpoint = set_breakpoint_spy }
      local original_input = vim.fn.input
      vim.fn.input = function()
        return "x == 1"
      end

      -- Act
      by_lhs("<leader>dB")[2]()

      -- Assert
      helpers.assert_called_with(set_breakpoint_data, "x == 1")

      vim.fn.input = original_input
      package.loaded.dap = nil
    end)

    it("<leader>dr opens the REPL", function()
      -- Arrange
      local open_spy, open_data = helpers.spy()
      package.loaded.dap = { repl = { open = open_spy } }

      -- Act
      by_lhs("<leader>dr")[2]()

      -- Assert
      helpers.assert_called(open_data, 1)

      package.loaded.dap = nil
    end)
  end)

  describe("config()", function()
    it("sets up dapui and nvim-dap-virtual-text", function()
      -- Arrange
      local dapui_setup_spy, dapui_setup_data = helpers.spy()
      package.loaded.dap = fresh_dap_stub()
      package.loaded.dapui = { setup = dapui_setup_spy }

      -- Act
      spec.config()

      -- Assert
      helpers.assert_called(dapui_setup_data, 1)
    end)

    it(
      "does not load launch.json when .vscode/launch.json is absent",
      function()
        -- Arrange
        package.loaded.dap = fresh_dap_stub()
        package.loaded.dapui = { setup = function() end }
        local load_spy, load_data = helpers.spy()
        package.loaded["dap.ext.vscode"] = { load_launchjs = load_spy }
        local original_filereadable = vim.fn.filereadable
        vim.fn.filereadable = function()
          return 0
        end

        -- Act
        spec.config()

        -- Assert
        helpers.assert_not_called(load_data)

        vim.fn.filereadable = original_filereadable
      end
    )

    it("loads launch.json when present", function()
      -- Arrange
      package.loaded.dap = fresh_dap_stub()
      package.loaded.dapui = { setup = function() end }
      local load_spy, load_data = helpers.spy()
      package.loaded["dap.ext.vscode"] = { load_launchjs = load_spy }
      local original_filereadable = vim.fn.filereadable
      vim.fn.filereadable = function()
        return 1
      end

      -- Act
      spec.config()

      -- Assert
      helpers.assert_called(load_data, 1)
      assert.matches("%.vscode/launch%.json$", load_data.last_call[1])
      assert.same({ "go" }, load_data.last_call[2].delve)

      vim.fn.filereadable = original_filereadable
    end)

    it("warns instead of raising when launch.json is malformed", function()
      -- Arrange
      package.loaded.dap = fresh_dap_stub()
      package.loaded.dapui = { setup = function() end }
      package.loaded["dap.ext.vscode"] = {
        load_launchjs = function()
          error("bad json")
        end,
      }
      local original_filereadable = vim.fn.filereadable
      vim.fn.filereadable = function()
        return 1
      end
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      local ok = pcall(spec.config)

      -- Assert
      assert.is_true(ok)
      assert.matches("Failed to load launch%.json", notify_data.last_call[1])

      restore()
      vim.fn.filereadable = original_filereadable
    end)

    it("reloads launch.json on DirChanged", function()
      -- Arrange: `local vscode = require("dap.ext.vscode")` is captured
      -- once inside config()'s closure, so the spy must be installed
      -- before config() runs -- swapping package.loaded afterwards would
      -- not reach the already-bound `vscode` local.
      package.loaded.dap = fresh_dap_stub()
      package.loaded.dapui = { setup = function() end }
      local load_spy, load_data = helpers.spy()
      package.loaded["dap.ext.vscode"] = { load_launchjs = load_spy }
      local original_filereadable = vim.fn.filereadable
      vim.fn.filereadable = function()
        return 0
      end
      spec.config()
      vim.fn.filereadable = function()
        return 1
      end
      local callback = vim.api.nvim_get_autocmds({
        group = "dap_vscode_launch",
        event = "DirChanged",
      })[1].callback

      -- Act
      callback()

      -- Assert
      helpers.assert_called(load_data, 1)

      vim.fn.filereadable = original_filereadable
    end)

    it("opens dapui when a debug session initializes", function()
      -- Arrange
      local dap = fresh_dap_stub()
      package.loaded.dap = dap
      local open_spy, open_data = helpers.spy()
      package.loaded.dapui = { setup = function() end, open = open_spy }

      -- Act
      spec.config()
      dap.listeners.after.event_initialized["dapui_config"]()

      -- Assert
      helpers.assert_called(open_data, 1)
    end)

    it("closes dapui when a debug session terminates or exits", function()
      -- Arrange
      local dap = fresh_dap_stub()
      package.loaded.dap = dap
      local close_spy, close_data = helpers.spy()
      package.loaded.dapui = { setup = function() end, close = close_spy }

      -- Act
      spec.config()
      dap.listeners.before.event_terminated["dapui_config"]()
      dap.listeners.before.event_exited["dapui_config"]()

      -- Assert
      assert.equals(2, close_data.call_count)
    end)

    it(
      "drains the dap_registry configurators registered by language extras",
      function()
        -- Arrange
        local dap = fresh_dap_stub()
        package.loaded.dap = dap
        package.loaded.dapui = { setup = function() end }
        local configurator_spy, configurator_data = helpers.spy()
        dap_registry.register(configurator_spy)

        -- Act
        spec.config()

        -- Assert
        helpers.assert_called_with(configurator_data, dap)
      end
    )
  end)
end)
