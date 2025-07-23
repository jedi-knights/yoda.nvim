-- lua/yoda/utils/keymap.lua
-- Keymap utilities

local M = {}

-- Standard keymap options
function M.opts(desc)
  return {
    noremap = true,
    silent = true,
    desc = desc,
  }
end

-- Create a function keymap
function M.fn(mode, lhs, fn, desc)
  vim.keymap.set(mode, lhs, fn, M.opts(desc))
end

-- Create a command keymap
function M.cmd(mode, lhs, cmd, desc)
  vim.keymap.set(mode, lhs, "<cmd>" .. cmd .. "<cr>", M.opts(desc))
end

-- Create a string keymap
function M.str(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, M.opts(desc))
end

-- Disable a keymap
function M.disable(mode, lhs, desc)
  vim.keymap.set(mode, lhs, "<nop>", M.opts(desc or "disable " .. lhs))
end

-- Create LSP keymaps
function M.lsp(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  
  M.fn("n", "<leader>ld", vim.lsp.buf.definition, "Go to Definition")
  M.fn("n", "<leader>lD", vim.lsp.buf.declaration, "Go to Declaration")
  M.fn("n", "<leader>li", vim.lsp.buf.implementation, "Go to Implementation")
  M.fn("n", "<leader>lr", vim.lsp.buf.references, "Find References")
  M.fn("n", "<leader>lrn", vim.lsp.buf.rename, "Rename Symbol")
  M.fn("n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
  M.fn("n", "<leader>ls", vim.lsp.buf.document_symbol, "Document Symbols")
  M.fn("n", "<leader>lw", vim.lsp.buf.workspace_symbol, "Workspace Symbols")
  M.fn("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, "Format Buffer")
end

-- Create diagnostic keymaps
function M.diagnostics()
  M.fn("n", "<leader>le", vim.diagnostic.open_float, "Show Diagnostics")
  M.fn("n", "<leader>lq", vim.diagnostic.setloclist, "Set Loclist")
  M.fn("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
  M.fn("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
end

-- Create window management keymaps
function M.windows()
  M.cmd("n", "<leader>|", "vsplit", "vertical split")
  M.cmd("n", "<leader>-", "split", "horizontal split")
  M.str("n", "<leader>se", "<c-w>=", "equalize window sizes")
  M.cmd("n", "<leader>sx", "close", "close current split")
  
  -- Window navigation
  M.str("n", "<c-h>", "<c-w>h", "move to left window")
  M.str("n", "<c-j>", "<c-w>j", "move to lower window")
  M.str("n", "<c-k>", "<c-w>k", "move to upper window")
  M.str("n", "<c-l>", "<c-w>l", "move to right window")
  M.str("n", "<c-c>", "<c-w>c", "close window")
end

-- Create tab management keymaps
function M.tabs()
  M.cmd("n", "<leader>tn", "tabnew", "new tab")
  M.cmd("n", "<leader>tc", "tabclose", "close tab")
  M.cmd("n", "<leader>tp", "tabprevious", "previous tab")
  M.cmd("n", "<leader>tN", "tabnext", "next tab")
end

-- Create buffer management keymaps
function M.buffers()
  M.cmd("n", "<s-left>", "bprevious", "previous buffer")
  M.cmd("n", "<s-right>", "bnext", "next buffer")
  M.cmd("n", "<s-down>", "buffers", "list buffers")
  M.str("n", "<s-up>", ":buffer ", "switch to buffer")
  M.cmd("n", "<s-del>", "bdelete", "delete buffer")
end

-- Create save/quit keymaps
function M.save_quit()
  M.cmd("n", "<c-s>", "w", "save file")
  M.cmd("n", "<c-q>", "wq", "save and quit")
  M.cmd("n", "<c-x>", "bd", "close buffer")
end

-- Disable arrow keys
function M.disable_arrows()
  M.disable("n", "<up>", "disable up arrow")
  M.disable("n", "<down>", "disable down arrow")
  M.disable("n", "<left>", "disable left arrow")
  M.disable("n", "<right>", "disable right arrow")
  M.disable("n", "<pageup>", "disable page up")
  M.disable("n", "<pagedown>", "disable page down")
end

-- Fast mode exits
function M.fast_exits()
  M.str("i", "jk", "<esc>", "exit insert mode")
  M.str("v", "jk", "<esc>", "exit visual mode")
end

return M 