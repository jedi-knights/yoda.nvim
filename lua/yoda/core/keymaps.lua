-- lua/yoda/core/keymaps.lua
-- Refactored keymaps with DRY principles and reduced cyclomatic complexity

-- Helper function for DRY keymap registration with logging
local function register_keymaps(mode, mappings)
  for key, config in pairs(mappings) do
    local rhs = config[1]
    local opts = config[2] or {}
    
    -- Log the keymap for debugging purposes
    local info = debug.getinfo(2, "Sl")
    local log_record = {
      mode = mode,
      lhs = key,
      rhs = (type(rhs) == "string") and rhs or "<function>",
      desc = opts.desc or "",
      source = info.short_src .. ":" .. info.currentline,
    }
    
    -- Store in global log if available
    if _G.yoda_keymap_log then
      table.insert(_G.yoda_keymap_log, log_record)
    end
    
    vim.keymap.set(mode, key, rhs, opts)
  end
end

-- LSP keymaps using DRY pattern
local lsp_keymaps = {
  ["<leader>ld"] = { vim.lsp.buf.definition, { desc = "Go to Definition" } },
  ["<leader>lD"] = { vim.lsp.buf.declaration, { desc = "Go to Declaration" } },
  ["<leader>li"] = { vim.lsp.buf.implementation, { desc = "Go to Implementation" } },
  ["<leader>lr"] = { vim.lsp.buf.references, { desc = "Find References" } },
  ["<leader>lrn"] = { vim.lsp.buf.rename, { desc = "Rename Symbol" } },
  ["<leader>la"] = { vim.lsp.buf.code_action, { desc = "Code Action" } },
  ["<leader>ls"] = { vim.lsp.buf.document_symbol, { desc = "Document Symbols" } },
  ["<leader>lw"] = { vim.lsp.buf.workspace_symbol, { desc = "Workspace Symbols" } },
  ["<leader>lf"] = { 
    function() vim.lsp.buf.format({ async = true }) end, 
    { desc = "Format Buffer" } 
  },
}

-- LSP diagnostics keymaps
local lsp_diagnostic_keymaps = {
  ["<leader>le"] = { vim.diagnostic.open_float, { desc = "Show Diagnostics" } },
  ["<leader>lq"] = { vim.diagnostic.setloclist, { desc = "Set Loclist" } },
  ["[d"] = { vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" } },
  ["]d"] = { vim.diagnostic.goto_next, { desc = "Next Diagnostic" } },
}

-- Disable arrow keys using DRY pattern
local disabled_keys = {
  ["<up>"] = { "<nop>", { desc = "disable up arrow" } },
  ["<down>"] = { "<nop>", { desc = "disable down arrow" } },
  ["<left>"] = { "<nop>", { desc = "disable left arrow" } },
  ["<right>"] = { "<nop>", { desc = "disable right arrow" } },
  ["<pageup>"] = { "<nop>", { desc = "disable page up" } },
  ["<pagedown>"] = { "<nop>", { desc = "disable page down" } },
}

-- Window management keymaps
local window_keymaps = {
  ["<leader>|"] = { ":vsplit<cr>", { desc = "vertical split" } },
  ["<leader>-"] = { ":split<cr>", { desc = "horizontal split" } },
  ["<leader>se"] = { "<c-w>=", { desc = "equalize window sizes" } },
}

-- Test keymaps
local test_keymaps = {
  ["<leader>ta"] = { 
    function() require("neotest").run.run(vim.loop.cwd()) end, 
    { desc = "Run all tests in project" } 
  },
  ["<leader>tn"] = { 
    function() require("neotest").run.run() end, 
    { desc = "Run nearest test" } 
  },
  ["<leader>tf"] = { 
    function() require("neotest").run.run(vim.fn.expand("%")) end, 
    { desc = "Run tests in current file" } 
  },
  ["<leader>tl"] = { 
    function() require("neotest").run.run_last() end, 
    { desc = "Run last test" } 
  },
  ["<leader>ts"] = { 
    function() require("neotest").summary.toggle() end, 
    { desc = "Toggle test summary" } 
  },
  ["<leader>to"] = { 
    function() require("neotest").output_panel.toggle() end, 
    { desc = "Toggle output panel" } 
  },
  ["<leader>td"] = { 
    function() require("neotest").run.run({ strategy = "dap" }) end, 
    { desc = "Debug nearest test with DAP" } 
  },
  ["<leader>tv"] = { 
    function() require("neotest").output.open({ enter = true }) end, 
    { desc = "View test output in floating window" } 
  },
}

-- Visual mode keymaps
local visual_keymaps = {
  ["<leader>r"] = { ":s/", { desc = "Replace" } },
  ["<leader>y"] = { '"+y', { desc = "Yank to clipboard" } },
  ["<leader>d"] = { '"_d', { desc = "Delete to void register" } },
  ["<leader>p"] = { "_dP", { desc = "Delete and paste over" } },
}

-- Register all keymaps using DRY pattern
register_keymaps("n", lsp_keymaps)
register_keymaps("n", lsp_diagnostic_keymaps)
register_keymaps("n", disabled_keys)
register_keymaps("n", window_keymaps)
register_keymaps("n", test_keymaps)
register_keymaps("v", visual_keymaps)

-- Special keymaps that require custom logic
vim.keymap.set("n", "<leader>xt", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:match("Trouble") then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end, { desc = "Focus Trouble window" })

-- Reload neovim config
vim.keymap.set("n", "<leader><leader>r", function()
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
end, { desc = "Hot reload Yoda plugin config" })

-- ShowKeys toggle with state management
local showkeys_enabled = false
vim.keymap.set("n", "<leader>kk", function()
  local ok, showkeys = pcall(require, "showkeys")
  if not ok then
    require("lazy").load({ plugins = { "showkeys" } })
    ok, showkeys = pcall(require, "showkeys")
  end
  if ok and showkeys then
    showkeys.toggle()
    showkeys_enabled = not showkeys_enabled
    local status = showkeys_enabled and "✅ ShowKeys enabled" or "🚫 ShowKeys disabled"
    vim.notify(status, vim.log.levels.INFO)
  else
    vim.notify("❌ Failed to load showkeys plugin", vim.log.levels.ERROR)
  end
end, { desc = "Toggle ShowKeys" })

-- Test picker
vim.keymap.set("n", "<leader>tt", function()
  require("yoda.testpicker").run()
end, { desc = "run tests with yoda" })

-- Snacks explorer focus
vim.keymap.set("n", "<leader>e", function()
  local found = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    if ft == "snacks-explorer" then
      vim.api.nvim_set_current_win(win)
      found = true
      return
    end
  end
  -- If not found, open/toggle the Snacks Explorer
  local ok, explorer = pcall(require, "snacks.explorer")
  if ok and explorer and explorer.open then
    explorer.open()
  else
    vim.notify("Snacks Explorer could not be opened", vim.log.levels.ERROR)
  end
end, { desc = "Focus or Open Snacks Explorer window" })

-- Quit all
vim.keymap.set("n", "<leader>qq", ":qa<cr>", { desc = "quit neovim" })

-- Copilot keymaps with proper error handling
vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    vim.keymap.set("i", "<C-j>", function()
      return vim.fn["copilot#Accept"]("")
    end, { expr = true, silent = true, replace_keycodes = false, desc = "Copilot Accept" })
    
    vim.keymap.set("i", "<C-k>", 'copilot#Dismiss()', { expr = true, silent = true, desc = "Copilot Dismiss" })
    
    vim.keymap.set("i", "<C-Space>", 'copilot#Complete()', { expr = true, silent = true, desc = "Copilot Complete" })
  end,
})

-- Copilot toggle
vim.keymap.set("n", "<leader>cp", function()
  require("lazy").load({ plugins = { "copilot.vim" } })
  
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
end, { desc = "Toggle Copilot" })

-- Terminal keymaps
vim.keymap.set("n", "<leader>vt", function()
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
end, { desc = "Open terminal with auto-close" })

vim.keymap.set("n", "<leader>vr", function()
  local function get_python()
    local cwd = vim.loop.cwd()
    local venv = cwd .. "/.venv/bin/python3"
    if vim.fn.filereadable(venv) == 1 then
      return venv
    end
    return vim.fn.exepath("python3") or "python3"
  end

  Snacks.terminal.toggle("python", {
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
      Snacks.terminal.close("python")
    end,
  })
end, { desc = "Launch Python REPL in float" })

-- Coverage keymaps
local coverage_keymaps = {
  ["<leader>cv"] = { 
    function() 
      require("coverage").load()
      require("coverage").show()
    end, 
    { desc = "Show coverage" } 
  },
  ["<leader>cx"] = { 
    function() require("coverage").hide() end, 
    { desc = "Hide code coverage" } 
  },
}
register_keymaps("n", coverage_keymaps)

-- Cargo keymaps
local cargo_keymaps = {
  ["<leader>cb"] = { "<cmd>!cargo build<CR>", { desc = "Cargo Build" } },
  ["<leader>cr"] = { "<cmd>!cargo run<CR>", { desc = "Cargo Run" } },
  ["<leader>ct"] = { "<cmd>!cargo test<CR>", { desc = "Cargo Test" } },
}
register_keymaps("n", cargo_keymaps)

-- AI keymaps
local ai_keymaps = {
  ["<leader>aa"] = { function() vim.cmd("AvanteAsk") end, { desc = "Ask Avante AI" } },
  ["<leader>ac"] = { function() vim.cmd("AvanteChat") end, { desc = "Open Avante Chat" } },
  ["<leader>am"] = { function() vim.cmd("AvanteMCP") end, { desc = "Open MCP Hub" } },
}
register_keymaps("n", ai_keymaps)

-- Mercury keymaps (work environment only)
if vim.env.YODA_ENV == "work" then
  local mercury_keymaps = {
    ["<leader>m"] = { 
      function() 
        local ok, mercury = pcall(require, "mercury")
        if ok and mercury.open then
          mercury.open()
        else
          vim.cmd(":Mercury<CR>")
        end
      end, 
      { desc = "Open Mercury" } 
    },
    ["<leader>ma"] = { 
      function()
        local ok, mercury_ui = pcall(require, "mercury.ui")
        if ok and mercury_ui and mercury_ui.open_panel then
          mercury_ui.open_panel()
        else
          vim.notify("Mercury Agentic Panel not available", vim.log.levels.ERROR)
        end
      end, 
      { desc = "Open Mercury Agentic Panel" } 
    },
  }
  register_keymaps("n", mercury_keymaps)
end
