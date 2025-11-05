local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

vim.schedule(function()
  map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP: Go to Definition - Jump to where symbol is defined" })
  map("n", "<leader>lD", vim.lsp.buf.declaration, { desc = "LSP: Go to Declaration - Jump to forward declaration" })
  map("n", "<leader>li", vim.lsp.buf.implementation, { desc = "LSP: Go to Implementation - Find interface implementations" })
  map("n", "<leader>lr", vim.lsp.buf.references, { desc = "LSP: Find References - Show all references to symbol" })
  map("n", "<leader>lrn", vim.lsp.buf.rename, { desc = "LSP: Rename Symbol - Rename symbol across workspace" })
  map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP: Code Action - Show available code actions (fixes, refactors)" })
  map("n", "<leader>ls", vim.lsp.buf.document_symbol, { desc = "LSP: Document Symbols - List symbols in current file" })
  map("n", "<leader>lw", vim.lsp.buf.workspace_symbol, { desc = "LSP: Workspace Symbols - Search symbols across workspace" })
  map("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "LSP: Format Buffer - Auto-format current buffer" })

  map("n", "<leader>le", vim.diagnostic.open_float, { desc = "LSP: Show Diagnostics - Show diagnostic under cursor in float" })
  map("n", "<leader>lq", vim.diagnostic.setloclist, { desc = "LSP: Set Loclist - Add diagnostics to location list" })
  map("n", "[d", vim.diagnostic.goto_prev, { desc = "LSP: Prev Diagnostic - Jump to previous diagnostic" })
  map("n", "]d", vim.diagnostic.goto_next, { desc = "LSP: Next Diagnostic - Jump to next diagnostic" })
end)
