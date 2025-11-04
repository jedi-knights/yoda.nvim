local notify = require("yoda.adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>pr", function()
  local file = vim.fn.expand("%:p")
  local venv_ok, venv = pcall(require, "yoda.terminal.venv")
  local python_cmd = "python3"

  if venv_ok then
    local venvs = venv.find_virtual_envs()
    if #venvs > 0 then
      python_cmd = venvs[1] .. "/bin/python"
      notify.notify("Using venv: " .. venvs[1], "info")
    end
  end

  vim.cmd("!" .. python_cmd .. " " .. file)
end, { desc = "Python: Run file" })

map("n", "<leader>pi", function()
  local venv_ok, venv = pcall(require, "yoda.terminal.venv")
  local python_cmd = "python3"

  if venv_ok then
    local venvs = venv.find_virtual_envs()
    if #venvs > 0 then
      python_cmd = venvs[1] .. "/bin/python"
    end
  end

  local terminal = require("snacks.terminal")
  terminal.toggle("python", {
    cmd = { python_cmd },
    win = {
      relative = "editor",
      position = "float",
      width = 0.85,
      height = 0.85,
      border = "rounded",
      title = " Python REPL ",
      title_pos = "center",
    },
  })
end, { desc = "Python: Open REPL" })

map("n", "<leader>pt", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    notify.notify("Neotest not available. Install via :Lazy sync", "error")
    return
  end
  neotest.run.run()
end, { desc = "Python: Test nearest" })

map("n", "<leader>pT", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    notify.notify("Neotest not available. Install via :Lazy sync", "error")
    return
  end
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "Python: Test file" })

map("n", "<leader>pC", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    notify.notify("Neotest not available. Install via :Lazy sync", "error")
    return
  end
  neotest.run.run({ suite = true })
end, { desc = "Python: Test suite" })

map("n", "<leader>pd", function()
  local ok, dap_python = pcall(require, "dap-python")
  if not ok then
    notify.notify("dap-python not available. Opening standard DAP...", "warn")
    require("dap").continue()
    return
  end
  dap_python.test_method()
end, { desc = "Python: Debug test" })

map("n", "<leader>pD", function()
  local ok, dap_python = pcall(require, "dap-python")
  if not ok then
    notify.notify("dap-python not available", "error")
    return
  end
  dap_python.test_class()
end, { desc = "Python: Debug test class" })

map("n", "<leader>pv", function()
  local ok = pcall(vim.cmd, "VenvSelect")
  if not ok then
    notify.notify("venv-selector not available. Install via :Lazy sync", "error")
  end
end, { desc = "Python: Select venv" })

map("n", "<leader>po", function()
  local ok = pcall(vim.cmd, "AerialToggle")
  if not ok then
    notify.notify("Aerial not available. Install via :Lazy sync", "error")
  end
end, { desc = "Python: Toggle outline" })

map("n", "<leader>pe", function()
  local ok, trouble = pcall(require, "trouble")
  if not ok then
    vim.diagnostic.setloclist()
    return
  end
  vim.cmd("Trouble diagnostics toggle filter.buf=0")
end, { desc = "Python: Open diagnostics" })

map("n", "<leader>pm", function()
  local file = vim.fn.expand("%:p")
  vim.cmd("!mypy " .. file)
end, { desc = "Python: Run mypy" })

map("n", "<leader>pL", function()
  vim.cmd("ConfigurePythonLSP")
end, { desc = "Python: Configure LSP with venv" })

map("n", "<leader>pc", function()
  local ok = pcall(require, "coverage")
  if not ok then
    notify.notify("Coverage plugin not available", "error")
    return
  end
  require("coverage").load()
  require("coverage").show()
end, { desc = "Python: Show coverage" })
