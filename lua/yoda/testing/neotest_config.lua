-- lua/yoda/testing/neotest_config.lua
-- Neotest configuration with dynamic adapter loading

local M = {}

function M.setup()
  local adapters = {}

  local python_ok, neotest_python = pcall(require, "neotest-python")
  if python_ok then
    table.insert(
      adapters,
      neotest_python({
        dap = {
          justMyCode = false,
          console = "integratedTerminal",
        },
        args = { "-vv" },
        runner = "pytest",
        python = function()
          local venv_ok, venv = pcall(require, "yoda.terminal.venv")
          if venv_ok then
            local venvs = venv.find_virtual_envs()
            if #venvs > 0 then
              return venvs[1] .. "/bin/python"
            end
          end
          return vim.fn.exepath("python3") or "python"
        end,
      })
    )
  end

  local rust_ok, neotest_rust = pcall(require, "neotest-rust")
  if rust_ok then
    table.insert(
      adapters,
      neotest_rust({
        args = { "--no-capture" },
        dap_adapter = "codelldb",
      })
    )
  end

  local jest_ok, neotest_jest = pcall(require, "neotest-jest")
  if jest_ok then
    table.insert(
      adapters,
      neotest_jest({
        jestCommand = "npm test --",
        jestConfigFile = "jest.config.js",
        env = { CI = true },
        cwd = function()
          return vim.fn.getcwd()
        end,
      })
    )
  end

  local vitest_ok, neotest_vitest = pcall(require, "neotest-vitest")
  if vitest_ok then
    table.insert(adapters, neotest_vitest)
  end

  local dotnet_ok, neotest_dotnet = pcall(require, "neotest-dotnet")
  if dotnet_ok then
    table.insert(
      adapters,
      neotest_dotnet({
        dap = {
          adapter_name = "coreclr",
          args = { justMyCode = false },
        },
      })
    )
  end

  require("neotest").setup({
    adapters = adapters,
    output = {
      enabled = true,
      open_on_run = "short",
    },
    output_panel = {
      enabled = true,
      open = "botright split | resize 15",
    },
    summary = {
      enabled = true,
      expand_errors = true,
      follow = true,
    },
    icons = {
      running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
      passed = "✓",
      failed = "✗",
      running = "⟳",
      skipped = "↓",
      unknown = "?",
    },
    floating = {
      border = "rounded",
      max_height = 0.8,
      max_width = 0.9,
    },
    status = {
      enabled = true,
      virtual_text = true,
      signs = true,
    },
  })
end

return M
