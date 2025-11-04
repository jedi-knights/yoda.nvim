local notify = require("yoda.adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>jr", function()
  local file = vim.fn.expand("%:p")
  vim.cmd("!node " .. file)
end, { desc = "JavaScript: Run Node.js file" })

map("n", "<leader>jn", function()
  local terminal = require("snacks.terminal")
  terminal.toggle("node", {
    cmd = { "node" },
    win = {
      relative = "editor",
      position = "float",
      width = 0.85,
      height = 0.85,
      border = "rounded",
      title = " Node.js REPL ",
      title_pos = "center",
    },
  })
end, { desc = "JavaScript: Open Node REPL" })

map("n", "<leader>jt", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    notify.notify("Neotest not available. Install via :Lazy sync", "error")
    return
  end
  neotest.run.run()
end, { desc = "JavaScript: Test nearest" })

map("n", "<leader>jT", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    notify.notify("Neotest not available. Install via :Lazy sync", "error")
    return
  end
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "JavaScript: Test file" })

map("n", "<leader>jC", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    notify.notify("Neotest not available. Install via :Lazy sync", "error")
    return
  end
  neotest.run.run({ suite = true })
end, { desc = "JavaScript: Test suite" })

map("n", "<leader>jd", function()
  local ok, dap = pcall(require, "dap")
  if not ok then
    notify.notify("DAP not available. Install via :Lazy sync", "error")
    return
  end
  dap.continue()
end, { desc = "JavaScript: Start debugger" })

map("n", "<leader>jo", function()
  local ok = pcall(vim.cmd, "AerialToggle")
  if not ok then
    notify.notify("Aerial not available. Install via :Lazy sync", "error")
  end
end, { desc = "JavaScript: Toggle outline" })

map("n", "<leader>je", function()
  local ok, trouble = pcall(require, "trouble")
  if not ok then
    vim.diagnostic.setloclist()
    return
  end
  vim.cmd("Trouble diagnostics toggle filter.buf=0")
end, { desc = "JavaScript: Open diagnostics" })

map("n", "<leader>jI", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = {
      only = { "source.organizeImports" },
      diagnostics = {},
    },
  })
end, { desc = "JavaScript: Organize imports" })

map("n", "<leader>jh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "JavaScript: Toggle inlay hints" })

map("n", "<leader>jl", function()
  local line = vim.fn.line(".")
  local var = vim.fn.expand("<cword>")
  local log = string.format('console.log("%s:", %s);', var, var)
  vim.fn.append(line, log)
end, { desc = "JavaScript: Insert console.log" })

map("n", "<leader>jL", function()
  vim.cmd([[%g/console\.log/d]])
  notify.notify("Removed all console.log statements", "info")
end, { desc = "JavaScript: Remove console.logs" })
