-- lua/plugins/nvim-dap.lua
-- DAP core + language adapters. Adapters are lazy-loaded by filetype and
-- wired into dap.configurations in their own config callbacks.

return {
  -- Python DAP adapter. Installs debugpy via uv and resolves the project
  -- venv at session-start time so multi-project sessions get the right python.
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    -- Install debugpy as a uv global tool so it is available across all projects.
    build = function()
      vim.fn.jobstart({ "uv", "tool", "install", "debugpy" }, {
        on_exit = function(_, code)
          if code ~= 0 then
            vim.notify("[yoda] Failed to install debugpy via uv (exit " .. code .. ")", vim.log.levels.ERROR)
          end
        end,
      })
    end,
    config = function()
      local dap = require("dap")
      local dap_python = require("dap-python")

      -- Resolves the project venv at call time, not at plugin-load time.
      -- nvim-dap calls function values in configurations when a session starts,
      -- so getcwd() returns the correct project root even across multiple
      -- Python projects open in the same Neovim session.
      local function get_python_path()
        local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
        return vim.uv.fs_stat(venv_python) and venv_python or vim.fn.exepath("python")
      end

      -- setup() configures the adapter and registers default launch configs.
      -- We pass the current project's python for the initial adapter setup.
      dap_python.setup(get_python_path())
      dap_python.test_runner = "pytest"

      -- Patch all registered configurations to use the dynamic resolver so
      -- subsequent projects in the same session get the right venv too.
      for _, config in ipairs(dap.configurations.python) do
        config.pythonPath = get_python_path
      end

      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch file with arguments",
        program = "${file}",
        pythonPath = get_python_path,
        args = function()
          local args_string = vim.fn.input("Arguments: ")
          return vim.split(args_string, " +")
        end,
      })
    end,
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      -- Shows variable values inline at the current breakpoint line.
      -- Without this, you must hover or open the dapui variables panel to
      -- inspect state; virtual text puts the values right in the buffer.
      "theHamsta/nvim-dap-virtual-text",
    },
    -- F-key bindings match standard IDE conventions (VS Code, IntelliJ) so
    -- existing muscle memory transfers. <leader>d prefix for leader-accessible
    -- alternatives and operations without F-key equivalents.
    keys = {
      -- F-keys (IDE convention)
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "Debug: Continue",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: Step Over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: Step Into",
      },
      {
        "<F12>",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: Step Out",
      },
      -- <leader>d prefix (home-row alternatives + extras)
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Debug: Continue/Start",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Condition: "))
        end,
        desc = "Debug: Conditional Breakpoint",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: Step Over",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: Step Into",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: Step Out",
      },
      {
        "<leader>dq",
        function()
          require("dap").terminate()
        end,
        desc = "Debug: Terminate",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug: Toggle UI",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "Debug: REPL",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Debug: Run Last",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      -- Auto-open dapui when a debug session starts and close it when the
      -- session ends. This avoids having to manually toggle the UI each time.
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- JS/TS: register vscode-js-debug adapters directly (no wrapper plugin).
      -- mxsdev/nvim-dap-vscode-js was abandoned in 2023; its only role was
      -- calling dap.adapters[name] = { type = "server", ... } for each pwa-*
      -- type, which we do here instead. The adapter binary is still managed
      -- by mason-nvim-dap (js-debug-adapter in ensure_installed).
      local mason_ok, mason_registry = pcall(require, "mason-registry")
      if mason_ok then
        local pkg_ok, pkg = pcall(mason_registry.get_package, "js-debug-adapter")
        if pkg_ok and pkg and pkg:is_installed() then
          local debugger_path = pkg:get_install_path() .. "/js-debug/src/dapDebugServer.js"
          for _, adapter in ipairs({ "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }) do
            dap.adapters[adapter] = {
              type = "server",
              host = "localhost",
              port = "${port}",
              executable = {
                command = "node",
                args = { debugger_path, "${port}" },
              },
            }
          end

          for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
            dap.configurations[language] = {
              -- Node.js debugging
              {
                type = "pwa-node",
                request = "launch",
                name = "Launch file",
                program = "${file}",
                cwd = "${workspaceFolder}",
              },
              {
                type = "pwa-node",
                request = "attach",
                name = "Attach",
                processId = require("dap.utils").pick_process,
                cwd = "${workspaceFolder}",
              },
              -- Jest debugging
              {
                type = "pwa-node",
                request = "launch",
                name = "Debug Jest Tests",
                runtimeExecutable = "node",
                runtimeArgs = { "./node_modules/jest/bin/jest.js", "--runInBand" },
                rootPath = "${workspaceFolder}",
                cwd = "${workspaceFolder}",
                console = "integratedTerminal",
                internalConsoleOptions = "neverOpen",
              },
              -- Chrome debugging
              {
                type = "pwa-chrome",
                request = "launch",
                name = "Launch Chrome",
                url = "http://localhost:3000",
                webRoot = "${workspaceFolder}",
              },
            }
          end
        end
      end
    end,
  },
}
