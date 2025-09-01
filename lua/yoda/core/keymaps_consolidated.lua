-- lua/yoda/core/keymaps_consolidated.lua
-- Consolidated keymaps to avoid conflicts and improve organization

local M = {}

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

-- LSP keymaps
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

-- Git keymaps
local git_keymaps = {
  ["<leader>gp"] = { 
    function() 
      local gs = require("gitsigns")
      gs.preview_hunk()
    end, 
    { desc = "Preview Git Hunk" } 
  },
  ["<leader>gt"] = { 
    function() 
      local gs = require("gitsigns")
      gs.toggle_current_line_blame()
    end, 
    { desc = "Toggle Git Blame" } 
  },
  ["<leader>gg"] = { 
    function() 
      local neogit = require("neogit")
      neogit.open()
    end, 
    { desc = "Open Neogit" } 
  },
  ["<leader>gB"] = { ":G blame<CR>", { desc = "Git Blame (Fugitive)" } },
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
  ["<leader>tt"] = { 
    function() require("yoda.testpicker").run() end, 
    { desc = "Run tests with yoda" } 
  },
}

-- DAP keymaps
local dap_keymaps = {
  ["<leader>db"] = { 
    function() require('dap').toggle_breakpoint() end, 
    { desc = "Toggle Breakpoint" } 
  },
  ["<leader>dc"] = { 
    function() require('dap').continue() end, 
    { desc = "Continue/Start Debugging" } 
  },
  ["<leader>do"] = { 
    function() require('dap').step_over() end, 
    { desc = "Step Over" } 
  },
  ["<leader>di"] = { 
    function() require('dap').step_into() end, 
    { desc = "Step Into" } 
  },
  ["<leader>dO"] = { 
    function() require('dap').step_out() end, 
    { desc = "Step Out" } 
  },
  ["<leader>dq"] = { 
    function() require("dap").terminate() end, 
    { desc = "Terminate Debugging" } 
  },
  ["<leader>du"] = { 
    function() 
      local dapui = require("dapui")
      dapui.toggle()
    end, 
    { desc = "Toggle DAP UI" } 
  },
}

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

-- Cargo keymaps
local cargo_keymaps = {
  ["<leader>cb"] = { "<cmd>!cargo build<CR>", { desc = "Cargo Build" } },
  ["<leader>cr"] = { "<cmd>!cargo run<CR>", { desc = "Cargo Run" } },
  ["<leader>ct"] = { "<cmd>!cargo test<CR>", { desc = "Cargo Test" } },
}

-- AI keymaps
local ai_keymaps = {
  ["<leader>aa"] = { function() vim.cmd("AvanteAsk") end, { desc = "Ask Avante AI" } },
  ["<leader>ac"] = { function() vim.cmd("AvanteChat") end, { desc = "Open Avante Chat" } },
  ["<leader>am"] = { function() vim.cmd("AvanteMCP") end, { desc = "Open MCP Hub" } },
  ["<leader>cp"] = { 
    function()
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
    end, 
    { desc = "Toggle Copilot" } 
  },
}

-- Mercury keymaps (work environment only)
local function get_mercury_keymaps()
  if vim.env.YODA_ENV == "work" then
    return {
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
  end
  return {}
end

-- Window management keymaps
local window_keymaps = {
  ["<leader>|"] = { ":vsplit<cr>", { desc = "vertical split" } },
  ["<leader>-"] = { ":split<cr>", { desc = "horizontal split" } },
  ["<leader>se"] = { "<c-w>=", { desc = "equalize window sizes" } },
}

-- Disable arrow keys
local disabled_keys = {
  ["<up>"] = { "<nop>", { desc = "disable up arrow" } },
  ["<down>"] = { "<nop>", { desc = "disable down arrow" } },
  ["<left>"] = { "<nop>", { desc = "disable left arrow" } },
  ["<right>"] = { "<nop>", { desc = "disable right arrow" } },
  ["<pageup>"] = { "<nop>", { desc = "disable page up" } },
  ["<pagedown>"] = { "<nop>", { desc = "disable page down" } },
}

-- Visual mode keymaps
local visual_keymaps = {
  ["<leader>r"] = { ":s/", { desc = "Replace" } },
  ["<leader>y"] = { '"+y', { desc = "Yank to clipboard" } },
  ["<leader>d"] = { '"_d', { desc = "Delete to void register" } },
  ["<leader>p"] = { "_dP", { desc = "Delete and paste over" } },
}

-- Insert mode keymaps
local insert_keymaps = {
  ["jk"] = { "<Esc>", { desc = "Exit to normal mode" } },
  ["<leader>jj"] = { "<Esc>", { desc = "Exit to normal mode" } },
  ["<leader>jk"] = { "<Esc>", { desc = "Exit to normal mode" } },
}

-- Terminal keymaps
local terminal_keymaps = {
  ["<leader>vt"] = { 
    function()
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
    end, 
    { desc = "Open terminal with auto-close" } 
  },
  ["<leader>vr"] = { 
    function()
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
    end, 
    { desc = "Launch Python REPL in float" } 
  },
}

-- Utility keymaps
local utility_keymaps = {
  ["<leader>qq"] = { ":qa<cr>", { desc = "quit neovim" } },
  ["<leader><leader>r"] = { 
    function()
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
    end, 
    { desc = "Hot reload Yoda plugin config" } 
  },
  ["<leader>kk"] = { 
    function()
      local showkeys_enabled = false
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
    end, 
    { desc = "Toggle ShowKeys" } 
  },
}

-- Register all keymaps
function M.setup()
  register_keymaps("n", lsp_keymaps)
  register_keymaps("n", lsp_diagnostic_keymaps)
  register_keymaps("n", git_keymaps)
  register_keymaps("n", test_keymaps)
  register_keymaps("n", dap_keymaps)
  register_keymaps("n", coverage_keymaps)
  register_keymaps("n", cargo_keymaps)
  register_keymaps("n", ai_keymaps)
  register_keymaps("n", get_mercury_keymaps())
  register_keymaps("n", window_keymaps)
  register_keymaps("n", disabled_keys)
  register_keymaps("n", terminal_keymaps)
  register_keymaps("n", utility_keymaps)
  register_keymaps("v", visual_keymaps)
  register_keymaps("i", insert_keymaps)
end

return M
