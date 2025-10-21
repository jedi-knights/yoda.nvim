-- lua/yoda/config/keymaps.lua
-- All keymaps in one place, organized by category
-- Simplified structure inspired by kickstart.nvim

-- ============================================================================
-- HELPER FUNCTIONS (minimal, inline where needed)
-- ============================================================================

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ============================================================================
-- HELP & DOCUMENTATION
-- ============================================================================

-- Smart K mapping: LSP hover or help fallback
map("n", "K", function()
  -- Check if LSP clients are attached
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    vim.lsp.buf.hover()
  else
    -- Fallback to help for the word under cursor
    local word = vim.fn.expand("<cword>")
    if word ~= "" then
      local success = pcall(vim.cmd, "help " .. word)
      if not success then
        vim.notify("No help found for: " .. word, vim.log.levels.WARN)
      end
    else
      vim.notify("No word under cursor", vim.log.levels.INFO)
    end
  end
end, { desc = "Help: Show hover/help for word under cursor" })

-- ============================================================================
-- EXPLORER
-- ============================================================================

-- Cache for snacks explorer window (performance optimization)
local snacks_explorer_cache = {}

-- Invalidate cache when windows are closed
vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(ev)
    local win_id = tonumber(ev.match)
    if snacks_explorer_cache.win == win_id then
      snacks_explorer_cache = {}
    end
  end,
})

-- Utility function to check if snacks explorer is open and return window info (cached)
local function get_snacks_explorer_win()
  -- Check cache first
  if snacks_explorer_cache.win and vim.api.nvim_win_is_valid(snacks_explorer_cache.win) then
    return snacks_explorer_cache.win, snacks_explorer_cache.buf
  end

  -- Cache miss or invalid - search for explorer window
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local buf_name = vim.api.nvim_buf_get_name(buf)
    -- Check for snacks explorer by filetype (snacks creates multiple windows)
    if ft:match("snacks_") or ft == "snacks" or buf_name:match("snacks") then
      -- Update cache
      snacks_explorer_cache = { win = win, buf = buf }
      return win, buf
    end
  end

  -- Not found - clear cache
  snacks_explorer_cache = {}
  return nil, nil
end

-- Open explorer only if it's closed
map("n", "<leader>eo", function()
  local win, _ = get_snacks_explorer_win()
  if win then
    vim.notify("Snacks Explorer is already open", vim.log.levels.INFO)
    return
  end
  -- Open Snacks Explorer using the API
  local success = pcall(function()
    require("snacks").explorer.open()
  end)
  if not success then
    vim.notify("Snacks Explorer could not be opened", vim.log.levels.ERROR)
  end
end, { desc = "Explorer: Open (only if closed)" })

-- Focus on explorer if it's open but not focused
map("n", "<leader>ef", function()
  local win, _ = get_snacks_explorer_win()
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.notify("Snacks Explorer is not open. Use <leader>eo to open it.", vim.log.levels.INFO)
  end
end, { desc = "Explorer: Focus (if open)" })

-- Close explorer if it's open
map("n", "<leader>ec", function()
  local win, _ = get_snacks_explorer_win()
  if win then
    -- Close all snacks windows (snacks explorer creates multiple windows)
    local snacks_wins = {}
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(w)
      local ft = vim.bo[buf].filetype
      if ft:match("snacks_") or ft == "snacks" then
        table.insert(snacks_wins, w)
      end
    end
    -- Close all snacks windows
    for _, w in ipairs(snacks_wins) do
      vim.api.nvim_win_close(w, true)
    end
  else
    vim.notify("Snacks Explorer is not open", vim.log.levels.INFO)
  end
end, { desc = "Explorer: Close (if open)" })

-- Refresh explorer if it's open
map("n", "<leader>er", function()
  local success = pcall(function()
    require("snacks").explorer.refresh()
    vim.notify("Explorer refreshed", vim.log.levels.INFO)
  end)
  if not success then
    vim.notify("Explorer not available or not open", vim.log.levels.WARN)
  end
end, { desc = "Explorer: Refresh" })

-- Show explorer help/keybindings
map("n", "<leader>e?", function()
  local help_text = {
    "Snacks Explorer Keybindings:",
    "",
    "<leader>eo - Open explorer",
    "<leader>ef - Focus explorer",
    "<leader>er - Refresh explorer",
    "<leader>ec - Close explorer",
    "",
    "In Explorer:",
    "H - Toggle hidden files",
    "I - Toggle ignored files",
    "h - Close directory",
    "l - Open directory/file",
    "",
    "Note: Hidden files are shown by default due to show_hidden=true setting",
  }

  vim.notify(table.concat(help_text, "\n"), vim.log.levels.INFO, { title = "Snacks Explorer Help" })
end, { desc = "Explorer: Show help" })

-- ============================================================================
-- WINDOW MANAGEMENT
-- ============================================================================

map("n", "<leader>xt", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:match("Trouble") then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end, { desc = "Window: Focus Trouble" })

-- Todo-comments integration with Trouble
map("n", "<leader>xT", function()
  local ok = pcall(vim.cmd, "TodoTrouble")
  if not ok then
    vim.notify("Todo-comments not available. Install via :Lazy sync", vim.log.levels.ERROR)
  end
end, { desc = "Trouble: Show TODOs" })

map("n", "<leader>|", ":vsplit<cr>", { desc = "Window: Vertical split" })
map("n", "<leader>-", ":split<cr>", { desc = "Window: Horizontal split" })
map("n", "<leader>ws", "<c-w>=", { desc = "Window: Equalize sizes" })

-- ============================================================================
-- FILE FINDING & NAVIGATION
-- ============================================================================

-- Snacks picker for basic file operations (consistency with snacks.nvim)
map("n", "<leader>ff", function()
  require("snacks").picker.files()
end, { desc = "Find Files (Snacks)" })

map("n", "<leader>fg", function()
  require("snacks").picker.grep()
end, { desc = "Find Text (Snacks)" })

map("n", "<leader>fr", function()
  require("snacks").picker.recent()
end, { desc = "Recent Files (Snacks)" })

map("n", "<leader>fb", function()
  require("snacks").picker.buffers()
end, { desc = "Find Buffers (Snacks)" })

-- Telescope for specialized LSP operations
map("n", "<leader>fR", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Find Rust/LSP symbols" })
map("n", "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "Find workspace symbols" })
map("n", "<leader>fD", "<cmd>Telescope diagnostics<CR>", { desc = "Find diagnostics" })
map("n", "<leader>fG", "<cmd>Telescope git_files<CR>", { desc = "Find Git files" })

-- ============================================================================
-- LSP (Deferred Loading for Startup Performance)
-- ============================================================================

-- Defer LSP-dependent keymaps to avoid loading LSP modules at startup
vim.schedule(function()
  map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP: Go to Definition" })
  map("n", "<leader>lD", vim.lsp.buf.declaration, { desc = "LSP: Go to Declaration" })
  map("n", "<leader>li", vim.lsp.buf.implementation, { desc = "LSP: Go to Implementation" })
  map("n", "<leader>lr", vim.lsp.buf.references, { desc = "LSP: Find References" })
  map("n", "<leader>lrn", vim.lsp.buf.rename, { desc = "LSP: Rename Symbol" })
  map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP: Code Action" })
  map("n", "<leader>ls", vim.lsp.buf.document_symbol, { desc = "LSP: Document Symbols" })
  map("n", "<leader>lw", vim.lsp.buf.workspace_symbol, { desc = "LSP: Workspace Symbols" })
  map("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "LSP: Format Buffer" })

  -- LSP Diagnostics
  map("n", "<leader>le", vim.diagnostic.open_float, { desc = "LSP: Show Diagnostics" })
  map("n", "<leader>lq", vim.diagnostic.setloclist, { desc = "LSP: Set Loclist" })
  map("n", "[d", vim.diagnostic.goto_prev, { desc = "LSP: Prev Diagnostic" })
  map("n", "]d", vim.diagnostic.goto_next, { desc = "LSP: Next Diagnostic" })
end)

-- ============================================================================
-- GIT
-- ============================================================================

map("n", "<leader>gp", function()
  require("gitsigns").preview_hunk()
end, { desc = "Git: Preview Hunk" })

map("n", "<leader>gt", function()
  require("gitsigns").toggle_current_line_blame()
end, { desc = "Git: Toggle Blame" })

map("n", "<leader>gg", function()
  require("neogit").open()
end, { desc = "Git: Open Neogit" })

map("n", "<leader>gB", ":G blame<CR>", { desc = "Git: Blame (Fugitive)" })

-- ============================================================================
-- TESTING
-- ============================================================================

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

-- <leader>tt functionality with fallback
map("n", "<leader>tt", function()
  local ok, pytest_atlas = pcall(require, "pytest-atlas")
  if ok and pytest_atlas.run_current_test then
    pytest_atlas.run_current_test()
  else
    -- Fallback to our custom plenary test runner
    local plenary = require("yoda.plenary")
    plenary.run_current_test()
  end
end, { desc = "Test: Run current test file" })

map("n", "<leader>tS", function()
  local ok, pytest_atlas = pcall(require, "pytest-atlas")
  if ok then
    pytest_atlas.show_status()
  else
    local env = vim.env.TEST_ENVIRONMENT or "qa"
    local region = vim.env.TEST_REGION or "auto"
    vim.notify(string.format("Current test environment: %s (%s)", env, region), vim.log.levels.INFO)
  end
end, { desc = "Test: Show environment status" })

-- ============================================================================
-- DEBUGGING (DAP)
-- ============================================================================

map("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })

map("n", "<leader>dc", function()
  require("dap").continue()
end, { desc = "Debug: Continue/Start" })

map("n", "<leader>do", function()
  require("dap").step_over()
end, { desc = "Debug: Step Over" })

map("n", "<leader>di", function()
  require("dap").step_into()
end, { desc = "Debug: Step Into" })

map("n", "<leader>dO", function()
  require("dap").step_out()
end, { desc = "Debug: Step Out" })

map("n", "<leader>dq", function()
  require("dap").terminate()
end, { desc = "Debug: Terminate" })

map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Debug: Toggle UI" })

-- ============================================================================
-- CODE COVERAGE
-- ============================================================================

map("n", "<leader>cv", function()
  require("coverage").load()
  require("coverage").show()
end, { desc = "Coverage: Show" })

map("n", "<leader>cx", function()
  require("coverage").hide()
end, { desc = "Coverage: Hide" })

-- ============================================================================
-- RUST DEVELOPMENT
-- ============================================================================

-- Cargo operations with Overseer
map("n", "<leader>rr", function()
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    vim.notify("Overseer not available. Running cargo run directly...", vim.log.levels.WARN)
    vim.cmd("!cargo run")
    return
  end
  overseer.run_template({ name = "cargo run" })
end, { desc = "Rust: Cargo run" })

map("n", "<leader>rb", function()
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    vim.notify("Overseer not available. Running cargo build directly...", vim.log.levels.WARN)
    vim.cmd("!cargo build")
    return
  end
  overseer.run_template({ name = "cargo build" })
end, { desc = "Rust: Cargo build" })

-- Testing with neotest
map("n", "<leader>rt", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  neotest.run.run()
end, { desc = "Rust: Test nearest" })

map("n", "<leader>rT", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "Rust: Test file" })

-- Debugging with rust-tools
map("n", "<leader>rd", function()
  local ok, rt = pcall(require, "rust-tools")
  if not ok then
    vim.notify("Rust-tools not available. Opening standard DAP...", vim.log.levels.WARN)
    require("dap").continue()
    return
  end
  rt.debuggables.debuggables()
end, { desc = "Rust: Start debug" })

-- Inlay hints toggle
map("n", "<leader>rh", function()
  local ok, rt = pcall(require, "rust-tools")
  if not ok then
    vim.notify("Rust-tools not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  rt.inlay_hints.toggle()
end, { desc = "Rust: Toggle inlay hints" })

-- Diagnostics (Trouble)
map("n", "<leader>re", function()
  local ok, trouble = pcall(require, "trouble")
  if not ok then
    vim.diagnostic.setloclist()
    return
  end
  vim.cmd("Trouble diagnostics toggle filter.buf=0")
end, { desc = "Rust: Open diagnostics" })

-- Outline toggle (Aerial)
map("n", "<leader>ro", function()
  local ok = pcall(vim.cmd, "AerialToggle")
  if not ok then
    vim.notify("Aerial not available. Install via :Lazy sync", vim.log.levels.ERROR)
  end
end, { desc = "Rust: Toggle outline" })

-- Additional rust-tools keymaps
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
    vim.notify("Rust-tools not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  rt.expand_macro.expand_macro()
end, { desc = "Rust: Expand macro" })

map("n", "<leader>rp", function()
  local ok, rt = pcall(require, "rust-tools")
  if not ok then
    vim.notify("Rust-tools not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  rt.parent_module.parent_module()
end, { desc = "Rust: Go to parent module" })

map("n", "<leader>rj", function()
  local ok, rt = pcall(require, "rust-tools")
  if not ok then
    vim.notify("Rust-tools not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  rt.join_lines.join_lines()
end, { desc = "Rust: Join lines" })

-- Crates.nvim keymaps are auto-configured in Cargo.toml files
-- See lua/plugins.lua crates.nvim configuration for:
-- <leader>rc - Show crate popup
-- <leader>ru - Update crate
-- <leader>rU - Update all crates
-- <leader>rV - Show versions popup
-- <leader>rF - Show features popup

-- ============================================================================
-- PYTHON DEVELOPMENT
-- ============================================================================

-- Python execution
map("n", "<leader>pr", function()
  local file = vim.fn.expand("%:p")
  local venv_ok, venv = pcall(require, "yoda.terminal.venv")
  local python_cmd = "python3"

  if venv_ok then
    local venvs = venv.find_virtual_envs()
    if #venvs > 0 then
      python_cmd = venvs[1] .. "/bin/python"
      vim.notify("Using venv: " .. venvs[1], vim.log.levels.INFO)
    end
  end

  vim.cmd("!" .. python_cmd .. " " .. file)
end, { desc = "Python: Run file" })

-- Python REPL (enhanced version of <leader>vr)
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

-- Testing with neotest
map("n", "<leader>pt", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  neotest.run.run()
end, { desc = "Python: Test nearest" })

map("n", "<leader>pT", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "Python: Test file" })

map("n", "<leader>pC", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  neotest.run.run({ suite = true })
end, { desc = "Python: Test suite" })

-- Debugging with dap-python
map("n", "<leader>pd", function()
  local ok, dap_python = pcall(require, "dap-python")
  if not ok then
    vim.notify("dap-python not available. Opening standard DAP...", vim.log.levels.WARN)
    require("dap").continue()
    return
  end
  dap_python.test_method()
end, { desc = "Python: Debug test" })

map("n", "<leader>pD", function()
  local ok, dap_python = pcall(require, "dap-python")
  if not ok then
    vim.notify("dap-python not available", vim.log.levels.ERROR)
    return
  end
  dap_python.test_class()
end, { desc = "Python: Debug test class" })

-- Virtual environment selection
map("n", "<leader>pv", function()
  local ok = pcall(vim.cmd, "VenvSelect")
  if not ok then
    vim.notify("venv-selector not available. Install via :Lazy sync", vim.log.levels.ERROR)
  end
end, { desc = "Python: Select venv" })

-- Outline toggle (Aerial - reuse from Rust)
map("n", "<leader>po", function()
  local ok = pcall(vim.cmd, "AerialToggle")
  if not ok then
    vim.notify("Aerial not available. Install via :Lazy sync", vim.log.levels.ERROR)
  end
end, { desc = "Python: Toggle outline" })

-- Diagnostics (Trouble)
map("n", "<leader>pe", function()
  local ok, trouble = pcall(require, "trouble")
  if not ok then
    vim.diagnostic.setloclist()
    return
  end
  vim.cmd("Trouble diagnostics toggle filter.buf=0")
end, { desc = "Python: Open diagnostics" })

-- Type checking (run mypy manually)
map("n", "<leader>pm", function()
  local file = vim.fn.expand("%:p")
  vim.cmd("!mypy " .. file)
end, { desc = "Python: Run mypy" })

-- Configure Python LSP with virtual environment
map("n", "<leader>pL", function()
  vim.cmd("ConfigurePythonLSP")
end, { desc = "Python: Configure LSP with venv" })

-- Coverage
map("n", "<leader>pc", function()
  local ok = pcall(require, "coverage")
  if not ok then
    vim.notify("Coverage plugin not available", vim.log.levels.ERROR)
    return
  end
  require("coverage").load()
  require("coverage").show()
end, { desc = "Python: Show coverage" })

-- It provides environment, region, and marker selection functionality

-- ============================================================================
-- JAVASCRIPT/TYPESCRIPT/NODE.JS DEVELOPMENT
-- ============================================================================

-- Node.js execution
map("n", "<leader>jr", function()
  local file = vim.fn.expand("%:p")
  vim.cmd("!node " .. file)
end, { desc = "JavaScript: Run Node.js file" })

-- Node.js REPL
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

-- Testing with neotest
map("n", "<leader>jt", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  neotest.run.run()
end, { desc = "JavaScript: Test nearest" })

map("n", "<leader>jT", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "JavaScript: Test file" })

map("n", "<leader>jC", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  neotest.run.run({ suite = true })
end, { desc = "JavaScript: Test suite" })

-- Debugging with vscode-js-debug
map("n", "<leader>jd", function()
  local ok, dap = pcall(require, "dap")
  if not ok then
    vim.notify("DAP not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  dap.continue()
end, { desc = "JavaScript: Start debugger" })

-- Outline toggle (Aerial - reuse from Rust/Python)
map("n", "<leader>jo", function()
  local ok = pcall(vim.cmd, "AerialToggle")
  if not ok then
    vim.notify("Aerial not available. Install via :Lazy sync", vim.log.levels.ERROR)
  end
end, { desc = "JavaScript: Toggle outline" })

-- Diagnostics (Trouble)
map("n", "<leader>je", function()
  local ok, trouble = pcall(require, "trouble")
  if not ok then
    vim.diagnostic.setloclist()
    return
  end
  vim.cmd("Trouble diagnostics toggle filter.buf=0")
end, { desc = "JavaScript: Open diagnostics" })

-- Organize imports (LSP)
map("n", "<leader>jI", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = {
      only = { "source.organizeImports" },
      diagnostics = {},
    },
  })
end, { desc = "JavaScript: Organize imports" })

-- Inlay hints toggle
map("n", "<leader>jh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "JavaScript: Toggle inlay hints" })

-- Console.log helper (quick insert)
map("n", "<leader>jl", function()
  local line = vim.fn.line(".")
  local var = vim.fn.expand("<cword>")
  local log = string.format('console.log("%s:", %s);', var, var)
  vim.fn.append(line, log)
end, { desc = "JavaScript: Insert console.log" })

-- Remove all console.log statements in file
map("n", "<leader>jL", function()
  vim.cmd([[%g/console\.log/d]])
  vim.notify("Removed all console.log statements", vim.log.levels.INFO)
end, { desc = "JavaScript: Remove console.logs" })

-- Package.json keymaps are auto-configured in package.json files
-- See lua/plugins.lua package-info.nvim configuration for:
-- <leader>js - Show package info
-- <leader>ju - Update package
-- <leader>jd - Delete package (note: conflicts with debug in package.json context)
-- <leader>ji - Install package (note: conflicts with organize imports)
-- <leader>jv - Change version

-- ============================================================================
-- C# / .NET DEVELOPMENT
-- ============================================================================

-- dotnet run
map("n", "<leader>cr", function()
  vim.cmd("!dotnet run")
end, { desc = "C#: dotnet run" })

-- dotnet build
map("n", "<leader>cb", function()
  vim.cmd("!dotnet build")
end, { desc = "C#: dotnet build" })

-- Testing with neotest
map("n", "<leader>ct", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  neotest.run.run()
end, { desc = "C#: Test nearest" })

map("n", "<leader>cT", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "C#: Test file" })

map("n", "<leader>cC", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  neotest.run.run({ suite = true })
end, { desc = "C#: Test suite" })

-- Debugging with netcoredbg
map("n", "<leader>cd", function()
  local ok, dap = pcall(require, "dap")
  if not ok then
    vim.notify("DAP not available. Install via :Lazy sync", vim.log.levels.ERROR)
    return
  end
  dap.continue()
end, { desc = "C#: Start debugger" })

-- Outline toggle (Aerial)
map("n", "<leader>co", function()
  local ok = pcall(vim.cmd, "AerialToggle")
  if not ok then
    vim.notify("Aerial not available. Install via :Lazy sync", vim.log.levels.ERROR)
  end
end, { desc = "C#: Toggle outline" })

-- Diagnostics (Trouble)
map("n", "<leader>ce", function()
  local ok, trouble = pcall(require, "trouble")
  if not ok then
    vim.diagnostic.setloclist()
    return
  end
  vim.cmd("Trouble diagnostics toggle filter.buf=0")
end, { desc = "C#: Open diagnostics" })

-- Inlay hints toggle
map("n", "<leader>ch", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "C#: Toggle inlay hints" })

-- dotnet new (create project/file)
map("n", "<leader>cn", function()
  local template = vim.fn.input("Template (console/classlib/web/etc): ")
  if template ~= "" then
    vim.cmd("!dotnet new " .. template)
  end
end, { desc = "C#: dotnet new" })

-- Restore packages
map("n", "<leader>cR", function()
  vim.cmd("!dotnet restore")
end, { desc = "C#: dotnet restore" })

-- Clean build
map("n", "<leader>cB", function()
  vim.cmd("!dotnet clean && dotnet build")
end, { desc = "C#: Clean and build" })

-- Add NuGet package
map("n", "<leader>cN", function()
  local package = vim.fn.input("Package name: ")
  if package ~= "" then
    vim.cmd("!dotnet add package " .. package)
  end
end, { desc = "C#: Add NuGet package" })

-- ============================================================================
-- AI & COPILOT
-- ============================================================================

-- Constants for AI features
local OPENCODE_STARTUP_DELAY_MS = 100 -- Wait for OpenCode window to initialize

-- Import window utilities for perfect encapsulation (no duplication!)
local win_utils = require("yoda.window_utils")

-- Helper function to auto-save before OpenCode operations
local function with_auto_save(operation_fn)
  return function(...)
    -- Auto-save buffers before OpenCode operations
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      opencode_integration.save_all_buffers()
    end

    -- Execute the operation
    operation_fn(...)
  end
end

-- OpenCode AI Assistant - Smart toggle with focus, insert mode, and auto-save
map(
  "n",
  "<leader>ai",
  with_auto_save(function()
    local win, _ = win_utils.find_opencode()
    if win then
      -- If OpenCode is open, focus on it and enter insert mode
      vim.api.nvim_set_current_win(win)
      vim.schedule(function()
        vim.cmd("startinsert")
      end)
    else
      -- If not open, toggle it to open
      require("opencode").toggle()
      -- Wait for window to open, then enter insert mode
      vim.defer_fn(function()
        local new_win, _ = win_utils.find_opencode()
        if new_win then
          vim.api.nvim_set_current_win(new_win)
          vim.cmd("startinsert")
        end
      end, OPENCODE_STARTUP_DELAY_MS)
    end
  end),
  { desc = "AI: Toggle/Focus OpenCode (auto-save + insert mode)" }
)

-- OpenCode: Return to previous buffer
map({ "n", "i" }, "<leader>ab", function()
  -- Exit insert mode if we're in it
  if vim.fn.mode() == "i" then
    vim.cmd("stopinsert")
  end

  -- Find the most recent non-OpenCode window
  local current_win = vim.api.nvim_get_current_win()
  local windows = vim.api.nvim_list_wins()

  for _, win in ipairs(windows) do
    if win ~= current_win then
      local buf = vim.api.nvim_win_get_buf(win)
      local buf_name = vim.api.nvim_buf_get_name(buf)
      -- Skip OpenCode windows and special buffers
      if not buf_name:match("[Oo]pen[Cc]ode") and not buf_name:match("^$") and vim.bo[buf].buftype == "" then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end

  -- Fallback: just switch to previous window
  vim.cmd("wincmd p")
end, { desc = "AI: Return to previous buffer from OpenCode" })

-- OpenCode: Enhanced Escape - exit insert mode and return to previous buffer
map("i", "<C-q>", function()
  local buf_name = vim.api.nvim_buf_get_name(0)
  if buf_name:match("[Oo]pen[Cc]ode") then
    -- In OpenCode: exit insert mode and return to previous buffer
    vim.cmd("stopinsert")
    vim.schedule(function()
      -- Find a non-OpenCode window
      local windows = vim.api.nvim_list_wins()
      for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if not name:match("[Oo]pen[Cc]ode") and vim.bo[buf].buftype == "" then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
      -- Fallback
      vim.cmd("wincmd p")
    end)
  else
    -- Normal behavior: just exit insert mode
    vim.cmd("stopinsert")
  end
end, { desc = "Smart escape: Exit insert mode (return to buffer if in OpenCode)" })

-- OpenCode: Alternative method with different key combo (works better with OpenCode)
map(
  { "n", "i" },
  "<A-q>", -- Alt+q (Option+q on Mac)
  function()
    -- Force exit insert mode first
    if vim.fn.mode() == "i" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    end

    -- Schedule the window switch
    vim.schedule(function()
      local windows = vim.api.nvim_list_wins()
      local current_win = vim.api.nvim_get_current_win()

      -- Find the first non-OpenCode window
      for _, win in ipairs(windows) do
        if win ~= current_win then
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          local buftype = vim.bo[buf].buftype

          -- Skip OpenCode and special buffers
          if not name:match("[Oo]pen[Cc]ode") and not name:match("NvimTree") and buftype == "" and name ~= "" then
            vim.api.nvim_set_current_win(win)
            vim.notify("← Returned to main buffer", vim.log.levels.INFO)
            return
          end
        end
      end

      -- Fallback to previous window
      pcall(vim.cmd, "wincmd p")
      vim.notify("← Switched to previous window", vim.log.levels.INFO)
    end)
  end,
  { desc = "Exit OpenCode and return to main buffer (Alt+q)" }
)

-- OpenCode: Command-based return (most reliable)
map({ "n", "i" }, "<leader>aq", ":OpenCodeReturn<CR>", { desc = "Return to main buffer from OpenCode (command-based)", silent = true })

map(
  { "n", "x" },
  "<leader>oa",
  with_auto_save(function()
    require("opencode").ask("@this: ", { submit = true })
  end),
  { desc = "OpenCode: Ask about this (auto-save)" }
)

map(
  { "n", "x" },
  "<leader>o+",
  with_auto_save(function()
    require("opencode").prompt("@this")
  end),
  { desc = "OpenCode: Add this to prompt (auto-save)" }
)

map(
  { "n", "x" },
  "<leader>oe",
  with_auto_save(function()
    require("opencode").prompt("Explain @this and its context", { submit = true })
  end),
  { desc = "OpenCode: Explain this (auto-save)" }
)

map(
  { "n", "x" },
  "<leader>os",
  with_auto_save(function()
    require("opencode").select()
  end),
  { desc = "OpenCode: Select prompt (auto-save)" }
)

map(
  "n",
  "<leader>ot",
  with_auto_save(function()
    require("opencode").toggle()
  end),
  { desc = "OpenCode: Toggle embedded (auto-save)" }
)

map("n", "<S-C-u>", function()
  require("opencode").command("messages_half_page_up")
end, { desc = "OpenCode: Messages half page up" })

map("n", "<S-C-d>", function()
  require("opencode").command("messages_half_page_down")
end, { desc = "OpenCode: Messages half page down" })

-- Copilot
map("n", "<leader>cop", function()
  -- Load copilot if not already loaded
  require("lazy").load({ plugins = { "copilot.lua" } })

  -- Get copilot.suggestion module
  local ok, copilot_suggestion = pcall(require, "copilot.suggestion")
  if not ok then
    vim.notify("❌ Copilot is not available", vim.log.levels.ERROR)
    return
  end

  -- Toggle: if visible, dismiss and disable; otherwise enable
  if copilot_suggestion.is_visible() then
    copilot_suggestion.dismiss()
    vim.notify("🚫 Copilot disabled", vim.log.levels.INFO)
  else
    vim.notify("✅ Copilot enabled - suggestions will appear as you type", vim.log.levels.INFO)
  end
end, { desc = "Copilot: Toggle/Dismiss" })

-- Copilot insert mode keymaps (leader-based)
-- Load when entering insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    local ok, copilot_suggestion = pcall(require, "copilot.suggestion")
    if not ok then
      return
    end

    -- Accept suggestion
    map("i", "<leader>a", function()
      copilot_suggestion.accept()
    end, { silent = true, desc = "Copilot: Accept" })

    -- Next suggestion
    map("i", "<leader>n", function()
      copilot_suggestion.next()
    end, { silent = true, desc = "Copilot: Next" })

    -- Previous suggestion
    map("i", "<leader>p", function()
      copilot_suggestion.prev()
    end, { silent = true, desc = "Copilot: Previous" })

    -- Dismiss suggestion
    map("i", "<leader>d", function()
      copilot_suggestion.dismiss()
    end, { silent = true, desc = "Copilot: Dismiss" })
  end,
})

-- ============================================================================
-- TERMINAL
-- ============================================================================

-- Terminal keymaps (refactored to use new terminal module for better SRP)
map("n", "<leader>.", function()
  require("yoda.functions").open_floating_terminal()
end, { desc = "Terminal: Open floating terminal with venv detection" })

map("n", "<leader>vt", function()
  local terminal = require("snacks.terminal")
  terminal.open({
    id = "myterm",
    cmd = { "/bin/zsh" },
    win = {
      relative = "editor",
      position = "float",
      width = 0.85,
      height = 0.85,
      border = "rounded",
      title = " Floating Shell ",
      title_pos = "center",
    },
    on_exit = function()
      terminal.close("myterm")
    end,
  })
end, { desc = "Terminal: Floating shell" })

map("n", "<leader>vr", function()
  local function get_python()
    local cwd = vim.loop.cwd()
    local venv = cwd .. "/.venv/bin/python3"
    if vim.fn.filereadable(venv) == 1 then
      return venv
    end
    return vim.fn.exepath("python3") or "python3"
  end

  local terminal = require("snacks.terminal")
  terminal.toggle("python", {
    cmd = { get_python() },
    win = {
      relative = "editor",
      position = "float",
      width = 0.85,
      height = 0.85,
      border = "rounded",
      title = " Python REPL ",
      title_pos = "center",
    },
    on_exit = function()
      terminal.close("python")
    end,
  })
end, { desc = "Terminal: Python REPL" })

-- ============================================================================
-- UTILITIES
-- ============================================================================

map("n", "<leader>qq", ":qa<cr>", { desc = "Util: Quit Neovim" })

map("n", "<leader>d", function()
  local ok, alpha = pcall(require, "alpha")
  if ok and alpha and alpha.start then
    alpha.start()
    vim.notify("Dashboard opened", vim.log.levels.INFO)
  else
    vim.notify("Failed to open dashboard - alpha plugin not available", vim.log.levels.ERROR)
  end
end, { desc = "Util: Open dashboard" })

map("n", "<leader><leader>r", function()
  -- Unload yoda modules and plugins so they can be re-required
  for name, _ in pairs(package.loaded) do
    if name:match("^yoda") or name:match("^plugins") then
      package.loaded[name] = nil
    end
  end

  -- Reload core config files
  dofile(vim.fn.stdpath("config") .. "/lua/options.lua")
  dofile(vim.fn.stdpath("config") .. "/lua/keymaps.lua")
  dofile(vim.fn.stdpath("config") .. "/lua/autocmds.lua")

  -- Defer notify so that `vim.notify` has a chance to be overridden again
  vim.defer_fn(function()
    vim.notify("✅ Reloaded Yoda config", vim.log.levels.INFO)
  end, 100)
end, { desc = "Util: Hot reload Yoda config" })

map("n", "<leader>kk", function()
  -- Show keymaps in a temporary buffer
  local keymaps = {}

  -- Get all normal mode keymaps that start with leader
  local leader = vim.g.mapleader or " "
  local mode = "n"

  -- Try to get keymaps using vim.api
  local success, result = pcall(function()
    return vim.api.nvim_get_keymap(mode)
  end)

  if success then
    for _, keymap in ipairs(result) do
      if keymap.lhs and keymap.lhs:sub(1, #leader) == leader then
        local desc = keymap.desc or keymap.rhs or "No description"
        table.insert(keymaps, keymap.lhs .. " → " .. desc)
      end
    end

    if #keymaps > 0 then
      -- Create a temporary buffer to show keymaps
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, keymaps)
      vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = 60,
        height = math.min(#keymaps + 2, 20),
        col = 10,
        row = 5,
        border = "single",
        title = "Leader Keymaps (Normal Mode)",
        title_pos = "center",
      })

      -- Close buffer when leaving window
      vim.api.nvim_create_autocmd("BufLeave", {
        buffer = buf,
        callback = function()
          vim.api.nvim_buf_delete(buf, { force = true })
        end,
      })
    else
      vim.notify("No leader keymaps found in normal mode", vim.log.levels.INFO)
    end
  else
    vim.notify("❌ Failed to get keymaps", vim.log.levels.ERROR)
  end
end, { desc = "Util: Show leader keymaps in normal mode" })

-- Toggle showkeys display
map("n", "<leader>sk", function()
  local success = pcall(vim.cmd, "ShowkeysToggle")
  if not success then
    -- Try alternative command
    local alt_success = pcall(vim.cmd, "Showkeys")
    if not alt_success then
      vim.notify("❌ Failed to toggle Showkeys - plugin may not be loaded", vim.log.levels.ERROR)
    end
  end
end, { desc = "Util: Toggle showkeys display" })

-- ============================================================================
-- VISUAL MODE
-- ============================================================================

map("v", "<leader>r", ":s/", { desc = "Visual: Replace" })
map("v", "<leader>y", '"+y', { desc = "Visual: Yank to clipboard" })
map("v", "<leader>d", '"_d', { desc = "Visual: Delete to void register" })
map("v", "<leader>p", "_dP", { desc = "Visual: Delete and paste over" })

-- ============================================================================
-- INSERT MODE
-- ============================================================================

map("i", "jk", "<Esc>", { desc = "Insert: Exit to normal mode" })

-- ============================================================================
-- DISABLED KEYS (for vim muscle memory)
-- ============================================================================

map("n", "<up>", "<nop>", { desc = "Disabled: Use k" })
map("n", "<down>", "<nop>", { desc = "Disabled: Use j" })
map("n", "<left>", "<nop>", { desc = "Disabled: Use h" })
map("n", "<right>", "<nop>", { desc = "Disabled: Use l" })
map("n", "<pageup>", "<nop>", { desc = "Disabled: Use <C-u>" })
map("n", "<pagedown>", "<nop>", { desc = "Disabled: Use <C-d>" })

-- ============================================================================
-- DEVELOPMENT TOOLS
-- ============================================================================

-- Initialize global keymap log if it doesn't exist
if not _G.yoda_keymap_log then
  _G.yoda_keymap_log = {}
end

-- Dump all tracked keymaps from vim.keymap.set()
map("n", "<leader>kd", function()
  local log = vim.deepcopy(_G.yoda_keymap_log or {})

  -- Alphabetically sort by mode then lhs
  table.sort(log, function(a, b)
    return a.lhs == b.lhs and a.mode < b.mode or a.lhs < b.lhs
  end)

  local lines = {}
  for _, map in ipairs(log) do
    table.insert(lines, string.format("%s %s → %s [%s] (%s)", map.mode, map.lhs, map.rhs, map.desc or "", map.source))
  end

  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "keymap-dump"
end, { desc = "DevTools: Dump Keymaps" })

-- Detect conflicts in tracked keymaps from vim.keymap.set()
map("n", "<leader>kc", function()
  local seen = {}
  local conflicts = {}
  local log = _G.yoda_keymap_log or {}

  for _, map in ipairs(log) do
    local key = map.mode .. ":" .. map.lhs
    if seen[key] then
      table.insert(conflicts, string.format("❌ Conflict: %s (%s)", map.lhs, map.mode))
    else
      seen[key] = true
    end
  end

  if #conflicts == 0 then
    vim.notify("✅ No keymap conflicts detected!", vim.log.levels.INFO)
  else
    vim.cmd("new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, conflicts)
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false
    vim.bo.filetype = "keymap-conflicts"
  end
end, { desc = "DevTools: Find Keymap Conflicts" })
