-- lua/yoda/extras/lang/node.lua
-- Opt-in JavaScript/TypeScript stack: neotest-jest + neotest-vitest,
-- package-info.nvim for package.json, and the vscode-js-debug DAP wiring.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.node" }

return {
  {
    "nvim-neotest/neotest-jest",
    ft = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
    dependencies = { "nvim-neotest/neotest" },
    config = function()
      local ok, neotest_jest = pcall(require, "neotest-jest")
      if not ok then
        vim.notify(
          "[neotest] neotest-jest not available: " .. tostring(neotest_jest),
          vim.log.levels.WARN
        )
        return
      end

      local adapter_ok, adapter = pcall(neotest_jest, {
        jestCommand = "npm test --",
        jestConfigFile = "jest.config.js",
        env = { CI = true },
        cwd = function()
          return vim.fn.getcwd()
        end,
      })
      if adapter_ok then
        require("yoda.core.neotest_registry").register(adapter)
      else
        vim.notify(
          "[neotest] Jest adapter setup failed: " .. tostring(adapter),
          vim.log.levels.WARN
        )
      end
    end,
  },

  {
    "marilari88/neotest-vitest",
    ft = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
    dependencies = { "nvim-neotest/neotest" },
    config = function()
      local ok, neotest_vitest = pcall(require, "neotest-vitest")
      if not ok then
        vim.notify(
          "[neotest] neotest-vitest not available: " .. tostring(neotest_vitest),
          vim.log.levels.WARN
        )
        return
      end
      require("yoda.core.neotest_registry").register(neotest_vitest)
    end,
  },

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
          vim.keymap.set("n", "<leader>jf", pkg.show, {
            desc = "JS: Fetch & show package versions",
            buffer = true,
            silent = true,
          })
          vim.keymap.set(
            "n",
            "<leader>js",
            pkg.show,
            { desc = "JS: Show package info", buffer = true, silent = true }
          )
          vim.keymap.set(
            "n",
            "<leader>ju",
            pkg.update,
            { desc = "JS: Update package", buffer = true, silent = true }
          )
          vim.keymap.set(
            "n",
            "<leader>jd",
            pkg.delete,
            { desc = "JS: Delete package", buffer = true, silent = true }
          )
          vim.keymap.set(
            "n",
            "<leader>ji",
            pkg.install,
            { desc = "JS: Install package", buffer = true, silent = true }
          )
          vim.keymap.set(
            "n",
            "<leader>jv",
            pkg.change_version,
            { desc = "JS: Change version", buffer = true, silent = true }
          )

          vim.notify(
            "Package.json opened. Use <leader>jf to fetch versions",
            vim.log.levels.INFO
          )
        end,
      })
    end,
  },

  -- JS/TS debugging. Registers vscode-js-debug adapters directly against the
  -- core nvim-dap setup via yoda.core.dap_registry -- there is no wrapper
  -- plugin to hang this off. mxsdev/nvim-dap-vscode-js was abandoned in 2023;
  -- its only role was assigning dap.adapters[name] for each pwa-* type, which
  -- the configurator below does instead. The adapter binary is still managed
  -- by mason-nvim-dap (js-debug-adapter in ensure_installed).
  --
  -- This entry carries no plugin of its own; it piggybacks on nvim-dap so the
  -- registration happens whenever the node extra is imported.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      require("yoda.core.dap_registry").register(function(dap)
        local mason_ok, mason_registry = pcall(require, "mason-registry")
        if not mason_ok then
          return
        end
        local pkg_ok, pkg =
          pcall(mason_registry.get_package, "js-debug-adapter")
        if not (pkg_ok and pkg and pkg:is_installed()) then
          return
        end

        local debugger_path = pkg:get_install_path()
          .. "/js-debug/src/dapDebugServer.js"
        for _, adapter in ipairs({
          "pwa-node",
          "pwa-chrome",
          "pwa-msedge",
          "node-terminal",
          "pwa-extensionHost",
        }) do
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

        for _, language in ipairs({
          "typescript",
          "javascript",
          "typescriptreact",
          "javascriptreact",
        }) do
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
      end)
    end,
  },
}
