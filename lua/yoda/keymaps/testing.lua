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
    local success, err = pcall(pytest_atlas.show_status)
    if not success then
      notify.notify("Error showing pytest-atlas status: " .. tostring(err), "error")
    end
  else
    local env = vim.env.TEST_ENVIRONMENT or "qa"
    local region = vim.env.TEST_REGION or "auto"
    notify.notify(string.format("Current test environment: %s (%s)", env, region), "info")
  end
end, { desc = "Test: Show environment status" })

map("n", "<leader>tt", function()
  local ok, pytest_atlas = pcall(require, "pytest-atlas")
  if not ok then
    notify.notify("pytest-atlas not loaded: " .. tostring(pytest_atlas), "error")
    return
  end

  local success, err = pcall(pytest_atlas.run_tests)
  if not success then
    notify.notify("pytest-atlas error: " .. tostring(err), "error")
    vim.notify("Debug info:\n" .. vim.inspect({
      snacks_loaded = pcall(require, "snacks.picker"),
      cwd = vim.fn.getcwd(),
    }), vim.log.levels.DEBUG)
  end
end, { desc = "Test: Run pytest with configuration picker" })

map("n", "<leader>tD", function()
  local ok, debug = pcall(require, "yoda.pytest_atlas_debug")
  if ok then
    debug.test_integration()
  else
    notify.notify("Debug utility not available", "error")
  end
end, { desc = "Test: Debug pytest-atlas integration" })

map("n", "<leader>tL", function()
  local ok, logger = pcall(require, "pytest-atlas.logger")
  if ok then
    logger.open_log_tail(100) -- Show last 100 lines (most recent session)
  else
    notify.notify("pytest-atlas not available", "error")
  end
end, { desc = "Test: Open pytest-atlas log (tail)" })

map("n", "<leader>tLA", function()
  local ok, pytest_atlas = pcall(require, "pytest-atlas")
  if ok then
    pytest_atlas.open_log() -- Show full log (all sessions)
  else
    notify.notify("pytest-atlas not available", "error")
  end
end, { desc = "Test: Open pytest-atlas log (full)" })

map("n", "<leader>tX", function()
  local ok, pytest_atlas = pcall(require, "pytest-atlas")
  if ok then
    pytest_atlas.clear_log()
  else
    notify.notify("pytest-atlas not available", "error")
  end
end, { desc = "Test: Clear pytest-atlas log" })

-- Test vim.ui.select directly
map("n", "<leader>tS", function()
  print("\n=== Testing vim.ui.select ===")
  print("Watch for a picker UI to appear!")
  
  vim.ui.select(
    { "Apple", "Banana", "Cherry" },
    { prompt = "TEST: Select a fruit:" },
    function(choice)
      print("=== CALLBACK INVOKED ===")
      print("Selected:", tostring(choice))
      
      if choice then
        vim.notify("✅ You selected: " .. choice, vim.log.levels.INFO)
      else
        vim.notify("❌ Selection cancelled", vim.log.levels.WARN)
      end
    end
  )
  
  print("vim.ui.select called (callback is async)")
end, { desc = "Test: Test vim.ui.select directly" })
