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

map("n", "<leader>rd", function()
  local ok, rt = pcall(require, "rust-tools")
  if not ok then
    notify.notify("Rust-tools not available. Opening standard DAP...", "warn")
    require("dap").continue()
    return
  end
  rt.debuggables.debuggables()
end, { desc = "Rust: Start debug" })

map("n", "<leader>rh", function()
  local ok, rt = pcall(require, "rust-tools")
  if not ok then
    notify.notify("Rust-tools not available. Install via :Lazy sync", "error")
    return
  end
  rt.inlay_hints.toggle()
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

map("n", "<leader>ra", function()
  local ok, rt = pcall(require, "rust-tools")
  if not ok then
    vim.lsp.buf.code_action()
    return
  end
  rt.code_action_group.code_action_group()
end, { desc = "Rust: Code actions" })

map("n", "<leader>rm", function()
  local ok, rt = pcall(require, "rust-tools")
  if not ok then
    notify.notify("Rust-tools not available. Install via :Lazy sync", "error")
    return
  end
  rt.expand_macro.expand_macro()
end, { desc = "Rust: Expand macro" })

map("n", "<leader>rp", function()
  local ok, rt = pcall(require, "rust-tools")
  if not ok then
    notify.notify("Rust-tools not available. Install via :Lazy sync", "error")
    return
  end
  rt.parent_module.parent_module()
end, { desc = "Rust: Go to parent module" })

map("n", "<leader>rj", function()
  local ok, rt = pcall(require, "rust-tools")
  if not ok then
    notify.notify("Rust-tools not available. Install via :Lazy sync", "error")
    return
  end
  rt.join_lines.join_lines()
end, { desc = "Rust: Join lines" })
