-- lua/plugins/nvim-dap-python.lua

return {
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
}
