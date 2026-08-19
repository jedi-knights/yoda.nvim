-- lua/plugins/nvim-dap.lua
-- DAP core: nvim-dap + dap-ui + virtual text + shared keymaps + launch.json
-- loading + dapui autolisteners. Per-language adapters live in sibling files:
--   - plugins/nvim-dap-python.lua
--   - plugins/nvim-dap-go.lua
-- JS/TS adapter+configuration wiring stays here for now; it has no dedicated
-- language plugin spec to hang off and moves to `extras/lang/node.lua` in
-- Phase 2 of the v1.0.0 restructure.

return {
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

      -- Load .vscode/launch.json if present in the project root.
      -- type_to_filetypes maps DAP adapter names to filetype(s) so launch.json
      -- entries (keyed by adapter type) resolve to Neovim ft configurations.
      -- Mappings for every language yoda supports live here; language spec
      -- files don't need to edit this table — adding a new language just
      -- means adding one line here (yagni over a full registry for 3–5 pins).
      local vscode = require("dap.ext.vscode")
      local type_to_filetypes = {
        delve = { "go" },
        python = { "python" },
        ["pwa-node"] = {
          "typescript",
          "javascript",
          "typescriptreact",
          "javascriptreact",
        },
        ["pwa-chrome"] = {
          "typescript",
          "javascript",
          "typescriptreact",
          "javascriptreact",
        },
      }

      local function load_vscode_launch()
        local launch = vim.fn.getcwd() .. "/.vscode/launch.json"
        if vim.fn.filereadable(launch) == 1 then
          -- load_launchjs parses JSON; wrap in pcall so a malformed file
          -- surfaces as a notification rather than a raw Lua stack trace.
          local ok, err = pcall(vscode.load_launchjs, launch, type_to_filetypes)
          if not ok then
            vim.notify(
              "[dap] Failed to load launch.json: " .. tostring(err),
              vim.log.levels.WARN
            )
          end
        end
      end

      load_vscode_launch()

      -- Reload when switching projects so per-repo launch configs are picked
      -- up.
      -- pattern = "global" limits to :cd (session-wide) changes; ignores
      -- :lcd/:tcd
      -- so the callback doesn't fire multiple times for a single directory
      -- change.
      vim.api.nvim_create_autocmd("DirChanged", {
        group = vim.api.nvim_create_augroup(
          "dap_vscode_launch",
          { clear = true }
        ),
        pattern = { "global" },
        callback = load_vscode_launch,
        desc = "Reload .vscode/launch.json when cwd changes",
      })

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
      -- by mason-nvim-dap (js-debug-adapter in ensure_installed). Moves to
      -- extras/lang/node.lua in Phase 2 of the v1.0.0 restructure.
      local mason_ok, mason_registry = pcall(require, "mason-registry")
      if mason_ok then
        local pkg_ok, pkg =
          pcall(mason_registry.get_package, "js-debug-adapter")
        if pkg_ok and pkg and pkg:is_installed() then
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
        end
      end
    end,
  },
}
