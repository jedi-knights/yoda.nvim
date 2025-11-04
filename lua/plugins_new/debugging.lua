-- lua/plugins_new/debugging.lua
-- Debug Adapter Protocol (DAP) plugins

return {
  -- DAP - Debug Adapter Protocol
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    cmd = { "DapToggleBreakpoint", "DapContinue", "DapStepOver", "DapStepInto", "DapStepOut", "DapTerminate" },
    dependencies = {
      "rcarriga/nvim-dap-ui",
    },
  },

  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()
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
        ensure_installed = { "codelldb", "debugpy", "js-debug-adapter", "netcoredbg" },
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
      -- Install debugpy using the system python
      local result = vim.fn.system("python -m pip install debugpy")
      if vim.v.shell_error ~= 0 then
        vim.notify("Failed to install debugpy: " .. result, vim.log.levels.ERROR)
      end
    end,
    config = function()
      -- Try to find debugpy in virtual environment first
      local debugpy_path = vim.fn.exepath("python")

      -- Check for venv
      local venv_ok, venv = pcall(require, "yoda.terminal.venv")
      if venv_ok then
        local venvs = venv.find_virtual_envs()
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
