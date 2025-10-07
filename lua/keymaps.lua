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
-- EXPLORER
-- ============================================================================

-- Smart explorer focus: focuses if open, opens if not found
map("n", "<leader>e", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    if ft == "snacks-explorer" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  -- If not found, open the Snacks Explorer
  local ok, explorer = pcall(require, "snacks.explorer")
  if ok and explorer and explorer.open then
    explorer.open()
  else
    vim.notify("Snacks Explorer could not be opened", vim.log.levels.ERROR)
  end
end, { desc = "Explorer: Focus or Open" })

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

map("n", "<leader>|", ":vsplit<cr>", { desc = "Window: Vertical split" })
map("n", "<leader>-", ":split<cr>", { desc = "Window: Horizontal split" })
map("n", "<leader>ws", "<c-w>=", { desc = "Window: Equalize sizes" })

-- ============================================================================
-- FILE FINDING & NAVIGATION
-- ============================================================================

map("n", "<leader>ff", function()
  vim.cmd("Telescope find_files")
end, { desc = "Find Files" })

map("n", "<leader>fg", function()
  vim.cmd("Telescope live_grep")
end, { desc = "Find Text" })

map("n", "<leader>fr", function()
  vim.cmd("Telescope oldfiles")
end, { desc = "Recent Files" })

-- ============================================================================
-- LSP
-- ============================================================================

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

map("n", "<leader>tt", function()
  require("yoda.testpicker").run()
end, { desc = "Test: Run with yoda picker" })

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
-- RUST/CARGO
-- ============================================================================

map("n", "<leader>cb", "<cmd>!cargo build<CR>", { desc = "Cargo: Build" })
map("n", "<leader>cr", "<cmd>!cargo run<CR>", { desc = "Cargo: Run" })
map("n", "<leader>ct", "<cmd>!cargo test<CR>", { desc = "Cargo: Test" })

-- ============================================================================
-- AI & COPILOT
-- ============================================================================

-- Avante AI
map("n", "<leader>aa", "<cmd>AvanteAsk<cr>", { desc = "AI: Ask Avante" })
map("n", "<leader>ac", "<cmd>AvanteChat<cr>", { desc = "AI: Open Avante Chat" })
map("n", "<leader>am", "<cmd>AvanteMCP<cr>", { desc = "AI: Open MCP Hub" })

-- Copilot
map("n", "<leader>cp", function()
  require("lazy").load({ plugins = { "copilot.lua" } })
  
  local status_ok, is_enabled = pcall(vim.fn["copilot#IsEnabled"])
  if not status_ok then
    vim.notify("❌ Copilot is not available", vim.log.levels.ERROR)
    return
  end

  if is_enabled == 1 then
    vim.cmd("Copilot disable")
    vim.notify("🚫 Copilot disabled", vim.log.levels.INFO)
  else
    vim.cmd("Copilot enable")
    vim.notify("✅ Copilot enabled", vim.log.levels.INFO)
  end
end, { desc = "AI: Toggle Copilot" })

-- Copilot insert mode keymaps (lazy-loaded)
vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    map("i", "<C-j>", function()
      return vim.fn["copilot#Accept"]("")
    end, { expr = true, silent = true, replace_keycodes = false, desc = "Copilot: Accept" })
    
    map("i", "<C-k>", 'copilot#Dismiss()', { expr = true, silent = true, desc = "Copilot: Dismiss" })
    map("i", "<C-Space>", 'copilot#Complete()', { expr = true, silent = true, desc = "Copilot: Complete" })
  end,
})


-- ============================================================================
-- TERMINAL
-- ============================================================================

map("n", "<leader>.", function()
  local ok, functions = pcall(require, "yoda.functions")
  if ok and functions.open_floating_terminal then
    functions.open_floating_terminal()
  else
    vim.notify("Floating terminal function not available", vim.log.levels.ERROR)
  end
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

map("n", "<leader><leader>r", function()
  -- Unload plugin/config namespace so it can be re-required
  for name, _ in pairs(package.loaded) do
    if name:match("^yoda") then
      package.loaded[name] = nil
    end
  end

  -- Reload plugin spec file
  require("yoda")

  -- Defer notify so that `vim.notify` has a chance to be overridden again
  vim.defer_fn(function()
    vim.notify("✅ Reloaded yoda plugin config", vim.log.levels.INFO)
  end, 100)
end, { desc = "Util: Hot reload Yoda config" })

map("n", "<leader>k", function()
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

-- Toggle real-time keystroke display (Keys.nvim)
map("n", "<leader>d", function()
  local success = pcall(vim.cmd, "KeysToggle")
  if not success then
    -- Try alternative command
    local alt_success = pcall(vim.cmd, "Keys toggle")
    if not alt_success then
      vim.notify("❌ Failed to toggle Keys.nvim - plugin may not be loaded", vim.log.levels.ERROR)
    end
  end
end, { desc = "Util: Toggle real-time keystroke display (Keys.nvim)" })

-- Toggle screenkey display
map("n", "<leader>s", function()
  local success = pcall(vim.cmd, "Screenkey toggle")
  if not success then
    -- Try alternative command
    local alt_success = pcall(vim.cmd, "ScreenkeyToggle")
    if not alt_success then
      vim.notify("❌ Failed to toggle Screenkey - plugin may not be loaded", vim.log.levels.ERROR)
    end
  end
end, { desc = "Util: Toggle screenkey display" })

-- Toggle showkeys display
map("n", "<leader>h", function()
  local success = pcall(vim.cmd, "Showkeys toggle")
  if not success then
    -- Try alternative command
    local alt_success = pcall(vim.cmd, "ShowkeysToggle")
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
    table.insert(lines, string.format(
      "%s %s → %s [%s] (%s)",
      map.mode, map.lhs, map.rhs, map.desc or "", map.source
    ))
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

