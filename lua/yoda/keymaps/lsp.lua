local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

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

  map("n", "<leader>le", vim.diagnostic.open_float, { desc = "LSP: Show Diagnostics" })
  map("n", "<leader>lq", vim.diagnostic.setloclist, { desc = "LSP: Set Loclist" })
  map("n", "[d", vim.diagnostic.goto_prev, { desc = "LSP: Prev Diagnostic" })
  map("n", "]d", vim.diagnostic.goto_next, { desc = "LSP: Next Diagnostic" })
end)
