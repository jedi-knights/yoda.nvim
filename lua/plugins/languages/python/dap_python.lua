-- lua/plugins/languages/python/dap_python.lua
-- nvim-dap-python - Python debugging with debugpy

return {
  "mfussenegger/nvim-dap-python",
  ft = "python",
  dependencies = {
    "mfussenegger/nvim-dap",
    "rcarriga/nvim-dap-ui",
  },
  build = function()
    local result = vim.fn.system("python -m pip install debugpy")
    if vim.v.shell_error ~= 0 then
      vim.notify("Failed to install debugpy: " .. result, vim.log.levels.ERROR)
    end
  end,
  config = function()
    local debugpy_path = vim.fn.exepath("python")

    local venv_ok, venv = pcall(require, "yoda.terminal.venv")
    if venv_ok then
      local venvs = venv.find_virtual_envs()
      if #venvs > 0 then
        debugpy_path = venvs[1] .. "/bin/python"
      end
    end

    require("dap-python").setup(debugpy_path)
    require("dap-python").test_runner = "pytest"

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
}
