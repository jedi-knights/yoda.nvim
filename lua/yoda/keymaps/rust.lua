local notify = require("yoda-adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>rr", function()
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    notify.notify("Overseer not available. Running cargo run directly...", "warn")
    vim.cmd("!cargo run")
    return
  end
  overseer.run_template({ name = "cargo run" })
end, { desc = "Rust: Cargo run" })

map("n", "<leader>rb", function()
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    notify.notify("Overseer not available. Running cargo build directly...", "warn")
    vim.cmd("!cargo build")
    return
  end
  overseer.run_template({ name = "cargo build" })
end, { desc = "Rust: Cargo build" })

map("n", "<leader>rt", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    notify.notify("Neotest not available. Install via :Lazy sync", "error")
    return
  end
  neotest.run.run()
end, { desc = "Rust: Test nearest" })

map("n", "<leader>rT", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    notify.notify("Neotest not available. Install via :Lazy sync", "error")
    return
  end
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "Rust: Test file" })

-- rustaceanvim provides :RustLsp debuggables which integrates with DAP
map("n", "<leader>rd", function()
  vim.cmd.RustLsp("debuggables")
end, { desc = "Rust: Start debug" })

-- Native Neovim 0.10+ inlay hint toggle (no plugin dependency)
map("n", "<leader>rh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Rust: Toggle inlay hints" })

map("n", "<leader>re", function()
  local ok, trouble = pcall(require, "trouble")
  if not ok then
    vim.diagnostic.setloclist()
    return
  end
  vim.cmd("Trouble diagnostics toggle filter.buf=0")
end, { desc = "Rust: Open diagnostics" })

map("n", "<leader>ro", function()
  local ok = pcall(vim.cmd, "AerialToggle")
  if not ok then
    notify.notify("Aerial not available. Install via :Lazy sync", "error")
  end
end, { desc = "Rust: Toggle outline" })

-- rustaceanvim grouped code actions
map("n", "<leader>ra", function()
  vim.cmd.RustLsp("codeAction")
end, { desc = "Rust: Code actions" })

map("n", "<leader>rm", function()
  vim.cmd.RustLsp("expandMacro")
end, { desc = "Rust: Expand macro" })

map("n", "<leader>rp", function()
  vim.cmd.RustLsp("parentModule")
end, { desc = "Rust: Go to parent module" })

map("n", "<leader>rj", function()
  vim.cmd.RustLsp("joinLines")
end, { desc = "Rust: Join lines" })
