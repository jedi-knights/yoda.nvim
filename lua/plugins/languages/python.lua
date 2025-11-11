-- lua/plugins_new/languages/python.lua
-- Python development plugins

return {
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
        local notify = require("yoda.adapters.notification")
        notify.notify("Failed to install debugpy: " .. result, "error")
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

  -- venv-selector.nvim - Virtual environment selector
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    ft = "python",
    config = function()
      require("venv-selector").setup({
        auto_refresh = true,
        search_venv_managers = true,
        search_workspace = true,
        search = true,
        dap_enabled = true, -- Auto-configure dap-python
        parents = 2,
        name = {
          "venv",
          ".venv",
          "env",
          ".env",
        },
      })
    end,
  },
}
