-- lua/plugins_new/debugging.lua
-- Debug Adapter Protocol (DAP) plugins

return {
  -- DAP - Debug Adapter Protocol
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
    -- existing muscle memory transfers. leader-d prefix for breakpoint/ui ops.
    keys = {
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
    end,
  },

  -- Mason-nvim-dap - Auto-install DAP adapters via Mason
  {
    "jay-babu/mason-nvim-dap.nvim",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "debugpy", "js-debug-adapter" },
        automatic_installation = true,
        handlers = {},
      })
    end,
  },

  -- nvim-dap-python - Python debugging with debugpy
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    -- Use a more reliable build command
    build = function()
      -- Install debugpy asynchronously so the UI is not blocked
      vim.fn.jobstart({ "python", "-m", "pip", "install", "debugpy" }, {
        on_exit = function(_, code)
          if code ~= 0 then
            vim.notify("Failed to install debugpy (exit " .. code .. ")", vim.log.levels.ERROR)
          end
        end,
      })
    end,
    config = function()
      -- Try to find debugpy in virtual environment first
      local debugpy_path = vim.fn.exepath("python")

      -- Check for venv
      local venv_ok, venv = pcall(require, "yoda.terminal.venv")
      if venv_ok then
        local venvs = venv.find_virtual_envs() or {}
        if #venvs > 0 then
          debugpy_path = venvs[1] .. "/bin/python"
        end
      end

      require("dap-python").setup(debugpy_path)

      -- Configure test runner
      require("dap-python").test_runner = "pytest"

      -- Add configurations for common scenarios
      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch file with arguments",
        program = "${file}",
        args = function()
          local args_string = vim.fn.input("Arguments: ")
          return vim.split(args_string, " +")
        end,
      })
    end,
  },

  -- nvim-dap-vscode-js - VSCode JavaScript debugger
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    lazy = true,
    config = function()
      -- Get vscode-js-debug path from Mason with safety checks
      local ok, mason_registry = pcall(require, "mason-registry")
      if not ok then
        vim.notify("Mason not available for JavaScript debugging", vim.log.levels.WARN)
        return
      end

      -- Try to get the js-debug-adapter package
      local pkg_ok, pkg = pcall(mason_registry.get_package, "js-debug-adapter")
      if not pkg_ok or not pkg then
        vim.notify("js-debug-adapter not installed. Run :MasonInstall js-debug-adapter", vim.log.levels.WARN)
        return
      end

      -- Get install path
      local install_ok, debugger_path = pcall(function()
        return pkg:get_install_path() .. "/js-debug/src/dapDebugServer.js"
      end)

      if not install_ok or not debugger_path then
        vim.notify(
          "js-debug-adapter installation path not found. Try :MasonUninstall js-debug-adapter then :MasonInstall js-debug-adapter",
          vim.log.levels.WARN
        )
        return
      end

      require("dap-vscode-js").setup({
        debugger_path = debugger_path,
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
      })

      -- Configure for various JavaScript scenarios
      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        require("dap").configurations[language] = {
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
        }
      end
    end,
  },
}
