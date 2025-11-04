-- lua/plugins_new/languages/javascript.lua
-- JavaScript/TypeScript/Node.js development plugins

return {
  -- nvim-dap-vscode-js - VSCode JavaScript debugger
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    lazy = true,
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
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
          -- Jest debugging
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/jest/bin/jest.js",
              "--runInBand",
            },
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
    end,
  },

  -- Neotest Jest adapter
  {
    "nvim-neotest/neotest-jest",
    dependencies = { "nvim-neotest/neotest" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  },

  -- Neotest Vitest adapter
  {
    "marilari88/neotest-vitest",
    dependencies = { "nvim-neotest/neotest" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  },

  -- Package-info.nvim - Show package versions in package.json
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = { "BufRead package.json" },
    config = function()
      require("package-info").setup({
        highlights = {
          up_to_date = { fg = "#3C4048" },
          outdated = { fg = "#d19a66" },
        },
        icons = {
          enable = true,
          style = {
            up_to_date = "|  ",
            outdated = "|  ",
          },
        },
        autostart = false, -- Don't auto-fetch on file open (prevents spam)
        hide_up_to_date = false,
        hide_unstable_versions = false,
        package_manager = "npm",
      })

      -- Package.json specific keymaps (set in autocmd)
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "package.json",
        callback = function(args)
          -- Only setup once per buffer
          if vim.b[args.buf].package_info_setup then
            return
          end
          vim.b[args.buf].package_info_setup = true

          local pkg = require("package-info")
          vim.keymap.set("n", "<leader>jf", pkg.show, { desc = "JS: Fetch & show package versions", buffer = true, silent = true })
          vim.keymap.set("n", "<leader>js", pkg.show, { desc = "JS: Show package info", buffer = true, silent = true })
          vim.keymap.set("n", "<leader>ju", pkg.update, { desc = "JS: Update package", buffer = true, silent = true })
          vim.keymap.set("n", "<leader>jd", pkg.delete, { desc = "JS: Delete package", buffer = true, silent = true })
          vim.keymap.set("n", "<leader>ji", pkg.install, { desc = "JS: Install package", buffer = true, silent = true })
          vim.keymap.set("n", "<leader>jv", pkg.change_version, { desc = "JS: Change version", buffer = true, silent = true })

          -- Show helpful message only once
          vim.notify("Package.json opened. Use <leader>jf to fetch versions", vim.log.levels.INFO)
        end,
      })
    end,
  },
}
