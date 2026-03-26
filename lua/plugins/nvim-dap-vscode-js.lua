-- lua/plugins/nvim-dap-vscode-js.lua

return {
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
}
