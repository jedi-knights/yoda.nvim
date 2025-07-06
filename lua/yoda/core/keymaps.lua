-- lua/yoda/keymaps.lua

local kmap = require("yoda.utils.keymap_logger")
local job_id = 0

-- general keymaps

-- LSP keymaps
kmap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Go to Definition" })
kmap.set("n", "<leader>lD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
kmap.set("n", "<leader>li", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
kmap.set("n", "<leader>lr", vim.lsp.buf.references, { desc = "Find References" })
kmap.set("n", "<leader>lrn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
kmap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code Action" })
kmap.set("n", "<leader>ls", vim.lsp.buf.document_symbol, { desc = "Document Symbols" })
kmap.set("n", "<leader>lw", vim.lsp.buf.workspace_symbol, { desc = "Workspace Symbols" })
kmap.set("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format Buffer" })

-- LSP diagnostics
kmap.set("n", "<leader>le", vim.diagnostic.open_float, { desc = "Show Diagnostics" })
kmap.set("n", "<leader>lq", vim.diagnostic.setloclist, { desc = "Set Loclist" })
kmap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
kmap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })


-- DISABLE arrow keys
kmap.set("n", "<up>", "<nop>", { desc = "disable up arrow" })
kmap.set("n", "<down>", "<nop>", { desc = "disable down arrow" })
kmap.set("n", "<left>", "<nop>", { desc = "disable left arrow" })
kmap.set("n", "<right>", "<nop>", { desc = "disable right arrow" })
kmap.set("n", "<pageup>", "<nop>", { desc = "disable page up" })
kmap.set("n", "<pagedown>", "<nop>", { desc = "disable page down" })

-- Trouble custom keymaps
kmap.set("n", "<leader>xt", function()
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
kmap.set("n", "<leader><leader>r", function()
  -- Unload your plugin/config namespace so it can be re-required
  for name, _ in pairs(package.loaded) do
    if name:match("^yoda") then -- or your namespace prefix
      package.loaded[name] = nil
    end
  end

  -- Reload your plugin spec file (if using `import = "yoda.plugins.spec"`)
  require("yoda")

  -- Defer notify so that `vim.notify` has a chance to be overridden again
  vim.defer_fn(function()
    vim.notify("✅ Reloaded yoda plugin config", vim.log.levels.INFO)
  end, 100)
end, { desc = "Hot reload Yoda plugin config" })

local showkeys_enabled = false

-- Toggle ShowKeys plugin
kmap.set("n", "<leader>kk", function()
  local ok, showkeys = pcall(require, "showkeys")
  if not ok then
    require("lazy").load({ plugins = { "showkeys" } })
    ok, showkeys = pcall(require, "showkeys")
  end
  if ok and showkeys then
    showkeys.toggle()
    showkeys_enabled = not showkeys_enabled

    if showkeys_enabled then
      vim.notify("✅ ShowKeys enabled", vim.log.levels.INFO)
    else
      vim.notify("🚫 ShowKeys disabled", vim.log.levels.INFO)
    end
  else
    vim.notify("❌ Failed to load showkeys plugin", vim.log.levels.ERROR)
  end
end, { desc = "Toggle ShowKeys" })

-- run tests
kmap.set("n", "<leader>tp", function()
  require("yoda.testpicker").run()
end, { desc = "run tests with yoda" })


-- windows
-- split
kmap.set("n", "<leader>|", ":vsplit<cr>", { desc = "vertical split" })
kmap.set("n", "<leader>-", ":split<cr>", { desc = "horizontal split" })
kmap.set("n", "<leader>se", "<c-w>=", { desc = "equalize window sizes" })
kmap.set("n", "<leader>sx", ":close<cr>", { desc = "close current split" })

-- window navigation
kmap.set("n", "<c-h>", "<c-w>h", { desc = "move to left window" })
kmap.set("n", "<c-j>", "<c-w>j", { desc = "move to lower window" })
kmap.set("n", "<c-k>", "<c-w>k", { desc = "move to upper window" })
kmap.set("n", "<c-l>", "<c-w>l", { desc = "move to right window" })
kmap.set("n", "<c-c>", "<c-w>c", { desc = "close window" })

-- tab navigation
kmap.set("n", "<leader>tn", vim.cmd.tabnew, { desc = "new tab" })
kmap.set("n", "<leader>tc", vim.cmd.tabclose, { desc = "close tab" })
kmap.set("n", "<leader>tp", vim.cmd.tabprevious, { desc = "previous tab" })
kmap.set("n", "<leader>tN", vim.cmd.tabnext, { desc = "next tab" })

-- buffer navigation
kmap.set("n", "<s-left>", vim.cmd.bprevious, { desc = "previous buffer" })
kmap.set("n", "<s-right>", vim.cmd.bnext, { desc = "next buffer" })
kmap.set("n", "<s-down>", vim.cmd.buffers, { desc = "list buffers" })
kmap.set("n", "<s-up>", ":buffer ", { desc = "switch to buffer" })
kmap.set("n", "<s-del>", vim.cmd.bdelete, { desc = "delete buffer" })

-- window resizing
kmap.set("n", "<m-left>", ":vertical resize -2<cr>", { desc = "shrink window width" })
kmap.set("n", "<m-right>", ":vertical resize +2<cr>", { desc = "expand window width" })
kmap.set("n", "<m-up>", ":resize -1<cr>", { desc = "shrink window height" })
kmap.set("n", "<m-down>", ":resize +1<cr>", { desc = "expand window height" })

-- save/quit
kmap.set("n", "<c-s>", ":w<cr>", { desc = "save file" })
kmap.set("n", "<c-q>", ":wq<cr>", { desc = "save and quit" })
kmap.set("n", "<c-x>", ":bd<cr>", { desc = "close buffer" })

-- visual mode improvements
-- kmap.set("v", "j", ":m '>+1<cr>gv=gv", { desc = "move selection down" })
-- kmap.set("v", "k", ":m '<-2<cr>gv=gv", { desc = "move selection up" })
-- kmap.set("x", "j", ":move '>+1<cr>gv-gv", { desc = "move block down" })
-- kmap.set("x", "k", ":move '<-2<cr>gv-gv", { desc = "move block up" })

-- exit terminal mode
-- kmap.set("t", "<esc>", "<c-\\><c-n>", { desc = "exit terminal mode" })

-- clipboard/yank
kmap.set("n", "<leader>y", ":%y+<cr>", { desc = "yank buffer to system clipboard" })

-- disable macro recording
kmap.set("n", "q", "<nop>", { desc = "disable q" })

-- fast mode exits
kmap.set("i", "jk", "<esc>", { noremap = true, silent = true, desc = "exit insert mode" })
kmap.set("v", "jk", "<esc>", { noremap = true, silent = true, desc = "exit visual mode" })

-- Enhanced navigation
kmap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "move down" })
kmap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "move up" })

-- Better search
kmap.set("n", "n", "nzzzv", { desc = "next search result" })
kmap.set("n", "N", "Nzzzv", { desc = "prev search result" })

-- Keep cursor in place when joining lines
kmap.set("n", "J", "mzJ`z", { desc = "join lines" })

-- Paste without overwriting register
kmap.set("x", "<leader>p", "\"_dP", { desc = "paste without overwriting register" })

-- Quick save
kmap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "save file" })

-- Better window management
kmap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "split vertically" })
kmap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "split horizontally" })

-- Quick buffer operations
kmap.set("n", "<leader>bn", "<cmd>bn<cr>", { desc = "next buffer" })
kmap.set("n", "<leader>bp", "<cmd>bp<cr>", { desc = "prev buffer" })
kmap.set("n", "<leader>bd", "<cmd>bd<cr>", { desc = "delete buffer" })

-- Utility function keymaps
local utils = require("yoda.core.functions")
kmap.set("n", "<leader>ur", utils.toggle_relative_line_numbers, { desc = "toggle relative line numbers" })
kmap.set("n", "<leader>us", utils.toggle_spell, { desc = "toggle spell checking" })
kmap.set("n", "<leader>uc", utils.toggle_cursor_line, { desc = "toggle cursor line" })
kmap.set("n", "<leader>ul", utils.toggle_list, { desc = "toggle whitespace display" })
kmap.set("n", "<leader>uw", utils.toggle_wrap, { desc = "toggle word wrap" })
kmap.set("n", "<leader>uf", utils.format_buffer, { desc = "format buffer" })
kmap.set("n", "<leader>ud", utils.toggle_diagnostics, { desc = "toggle diagnostics" })
kmap.set("n", "<leader>uh", utils.clear_search_highlights, { desc = "clear search highlights" })
kmap.set("n", "<leader>ui", utils.get_file_info, { desc = "show file info" })
kmap.set("n", "<leader>ut", utils.toggle_terminal, { desc = "toggle terminal" })
kmap.set("n", "<leader>up", utils.copy_file_path, { desc = "copy file path" })
kmap.set("n", "<leader>un", utils.copy_file_name, { desc = "copy file name" })

-- re-indent whole file
kmap.set("n", "<leader>i", "gg=g", { desc = "re-indent entire file" })

-- buffer management
kmap.set("n", "<leader>bq", function()
  local api = vim.api
  local cur_buf = api.nvim_get_current_buf()
  local alt_buf = vim.fn.bufnr("#")
  if vim.bo[alt_buf].filetype ~= "neo-tree" and vim.bo[alt_buf].buflisted then
    api.nvim_set_current_buf(alt_buf)
  else
    vim.cmd("bnext")
  end
  vim.cmd("bd " .. cur_buf)
end, { desc = "close buffer and switch" })

kmap.set("n", "<leader>bo", function()
  vim.cmd("%bd | e# | bd#")
end, { desc = "close others" })
kmap.set("n", "<leader>bd", ":bufdo bd<cr>", { desc = "delete all buffers" })

-- Toggle explorer
local explorer_open = false


kmap.set("n", "<leader>et", function()
  local explorer = require("snacks.explorer")

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "snacks-explorer" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end

  explorer.open()
end, { desc = "Toggle Snacks Explorer" })

-- Focus explorer (if in split mode)
kmap.set("n", "<leader>ef", function()
  local candidates = { "snacks_picker_list", "snacks_picker_input", "snacks_layout_box" }

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    for _, match in ipairs(candidates) do
      if ft == match then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end

  vim.notify("Snacks Explorer is not open", vim.log.levels.WARN)
end, { desc = "Focus Snacks Explorer window" })

-- quit all
kmap.set("n", "<leader>qq", ":qa<cr>", { desc = "quit neovim" })

-- copilot keymaps
vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    local kmap = require("yoda.utils.keymap_logger")

    kmap.set("i", "<C-j>", function()
      return vim.fn["copilot#Accept"]("")
    end, {
      expr = true,
      silent = true,
      replace_keycodes = false,
      desc = "Copilot Accept",
    })

    --kmap.set("i", "<C-j>", 'copilot#Accept("<CR>")', {
    --  expr = true,
    --  silent = true,
    --  desc = "Copilot Accept",
    -- })

    kmap.set("i", "<C-k>", 'copilot#Dismiss()', {
      expr = true,
      silent = true,
      desc = "Copilot Dismiss",
    })

    kmap.set("i", "<C-Space>", 'copilot#Complete()', {
      expr = true,
      silent = true,
      desc = "Copilot Complete",
    })
  end,
})

kmap.set("n", "<leader>cp", function()
  -- Ensure the plugin is loaded (if lazy-loaded)
  require("lazy").load({ plugins = { "copilot.vim" } })

  -- Now it's safe to call VimL functions
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

-- Avante AI keymaps
kmap.set("n", "<leader>aa", function()
  vim.cmd("AvanteAsk")
end, { desc = "Ask Avante AI" })

kmap.set("n", "<leader>ac", function()
  vim.cmd("AvanteChat")
end, { desc = "Open Avante Chat" })

kmap.set("n", "<leader>ah", function()
  vim.cmd("MCPHub")
end, { desc = "Open MCP Hub" })


-- snacks terminal keymaps
kmap.set("n", "<leader>vt", function()
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

kmap.set("n", "<leader>vr", function()
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

-- neotest keymaps
kmap.set("n", "<leader>ta", function()
  require("neotest").run.run(vim.loop.cwd())
end, { desc = "Run all tests in project" })

kmap.set("n", "<leader>tn", function()
  require("neotest").run.run()
end, { desc = "Run nearest test" })

kmap.set("n", "<leader>tf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run tests in current file" })

kmap.set("n", "<leader>tl", function()
  require("neotest").run.run_last()
end, { desc = "Run last test" })

kmap.set("n", "<leader>ts", function()
  require("neotest").summary.toggle()
end, { desc = "Toggle test summary" })

kmap.set("n", "<leader>to", function()
  require("neotest").output_panel.toggle()
end, { desc = "Toggle output panel" })

kmap.set("n", "<leader>td", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "Debug nearest test with DAP" })

kmap.set("n", "<leader>tv", function()
  require("neotest").output.open({ enter = true })
end, { desc = "View test output in floating window" })


-- coverage keymaps
kmap.set("n", "<leader>cv", function()
  require("coverage").load()
  require("coverage").show()
end, { desc = "Show coverage" })

kmap.set("n", "<leader>cx", function()
  require("coverage").hide()
end, { desc = "Hide code coverage" })

vim.keymap.set("n", "<leader>cb", "<cmd>!cargo build<CR>", { desc = "Cargo Build" })
vim.keymap.set("n", "<leader>cr", "<cmd>!cargo run<CR>", { desc = "Cargo Run" })
vim.keymap.set("n", "<leader>ct", "<cmd>!cargo test<CR>", { desc = "Cargo Test" })


-- VISUAL MODE
-- Replace
kmap.set('v', '<leader>r', ':s/')

-- Yank selection to the clipboard
kmap.set('v', '<leader>y', '"+y')

-- Delete selection to void register
kmap.set('v', '<leader>d', '"_d')

-- Delete selection into the void register and then paste over it
kmap.set('v', '<leader>p', '_dP')
