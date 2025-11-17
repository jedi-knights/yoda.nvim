local notify = require("yoda-adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>cr", function()
  vim.cmd("!dotnet run")
end, { desc = "C#: dotnet run" })

map("n", "<leader>cb", function()
  vim.cmd("!dotnet build")
end, { desc = "C#: dotnet build" })

map("n", "<leader>ct", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    notify.notify("Neotest not available. Install via :Lazy sync", "error")
    return
  end
  neotest.run.run()
end, { desc = "C#: Test nearest" })

map("n", "<leader>cT", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    notify.notify("Neotest not available. Install via :Lazy sync", "error")
    return
  end
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "C#: Test file" })

map("n", "<leader>cC", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    notify.notify("Neotest not available. Install via :Lazy sync", "error")
    return
  end
  neotest.run.run({ suite = true })
end, { desc = "C#: Test suite" })

map("n", "<leader>cd", function()
  local ok, dap = pcall(require, "dap")
  if not ok then
    notify.notify("DAP not available. Install via :Lazy sync", "error")
    return
  end
  dap.continue()
end, { desc = "C#: Start debugger" })

map("n", "<leader>co", function()
  local ok = pcall(vim.cmd, "AerialToggle")
  if not ok then
    notify.notify("Aerial not available. Install via :Lazy sync", "error")
  end
end, { desc = "C#: Toggle outline" })

map("n", "<leader>ce", function()
  local ok, trouble = pcall(require, "trouble")
  if not ok then
    vim.diagnostic.setloclist()
    return
  end
  vim.cmd("Trouble diagnostics toggle filter.buf=0")
end, { desc = "C#: Open diagnostics" })

map("n", "<leader>ch", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "C#: Toggle inlay hints" })

map("n", "<leader>cn", function()
  local template = vim.fn.input("Template (console/classlib/web/etc): ")
  if template ~= "" then
    vim.cmd("!dotnet new " .. template)
  end
end, { desc = "C#: dotnet new" })

map("n", "<leader>cR", function()
  vim.cmd("!dotnet restore")
end, { desc = "C#: dotnet restore" })

map("n", "<leader>cB", function()
  vim.cmd("!dotnet clean && dotnet build")
end, { desc = "C#: Clean and build" })

map("n", "<leader>cN", function()
  local package = vim.fn.input("Package name: ")
  if package ~= "" then
    vim.cmd("!dotnet add package " .. package)
  end
end, { desc = "C#: Add NuGet package" })
