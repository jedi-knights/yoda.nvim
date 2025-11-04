local notify = require("yoda.adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>ta", function()
  require("neotest").run.run(vim.loop.cwd())
end, { desc = "Test: Run all tests" })

map("n", "<leader>tn", function()
  require("neotest").run.run()
end, { desc = "Test: Run nearest test" })

map("n", "<leader>tf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Test: Run file tests" })

map("n", "<leader>tl", function()
  require("neotest").run.run_last()
end, { desc = "Test: Run last test" })

map("n", "<leader>ts", function()
  require("neotest").summary.toggle()
end, { desc = "Test: Toggle summary" })

map("n", "<leader>to", function()
  require("neotest").output_panel.toggle()
end, { desc = "Test: Toggle output panel" })

map("n", "<leader>td", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "Test: Debug nearest test" })

map("n", "<leader>tv", function()
  require("neotest").output.open({ enter = true })
end, { desc = "Test: View test output" })

map("n", "<leader>tO", function()
  local win_utils = require("yoda.window_utils")
  local found = win_utils.focus_window(function(win, buf, buf_name, ft)
    return buf_name:match("Neotest Output Panel") or ft == "neotest-output-panel"
  end)
  if not found then
    notify.notify("Neotest output panel not open", "warn")
  end
end, { desc = "Test: Focus output panel" })

map("n", "<leader>tF", function()
  local win_utils = require("yoda.window_utils")
  local found = win_utils.focus_window(function(win, buf, buf_name, ft)
    return ft == "neotest-summary"
  end)
  if not found then
    notify.notify("Neotest summary not open. Use <leader>ts to open it.", "warn")
  end
end, { desc = "Test: Focus summary window" })

map("n", "<leader>tC", function()
  require("neotest").output_panel.clear()
  notify.notify("Neotest output panel cleared", "info")
end, { desc = "Test: Clear output panel" })

map("n", "<leader>tc", function()
  local filetype = vim.bo.filetype

  if filetype == "python" then
    local ok, neotest = pcall(require, "neotest")
    if ok then
      neotest.run.run(vim.fn.expand("%"))
    else
      notify.notify("Neotest not available. Install via :Lazy sync", "error")
    end
  elseif filetype == "lua" then
    local plenary = require("yoda.plenary")
    plenary.run_current_test()
  else
    notify.notify("No test runner configured for filetype: " .. filetype, "warn")
  end
end, { desc = "Test: Run current file" })

map("n", "<leader>tS", function()
  local ok, pytest_atlas = pcall(require, "pytest-atlas")
  if ok then
    pytest_atlas.show_status()
  else
    local env = vim.env.TEST_ENVIRONMENT or "qa"
    local region = vim.env.TEST_REGION or "auto"
    notify.notify(string.format("Current test environment: %s (%s)", env, region), "info")
  end
end, { desc = "Test: Show environment status" })
