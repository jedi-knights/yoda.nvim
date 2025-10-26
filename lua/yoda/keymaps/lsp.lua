local map = vim.keymap.set

vim.schedule(function()
	map("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to definition" })
	map("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Go to declaration" })
	map("n", "gr", vim.lsp.buf.references, { desc = "LSP: References" })
	map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP: Go to implementation" })
	map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code actions" })
	map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename symbol" })
	map("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "LSP: Type definition" })
	map("n", "[d", vim.diagnostic.goto_prev, { desc = "LSP: Previous diagnostic" })
	map("n", "]d", vim.diagnostic.goto_next, { desc = "LSP: Next diagnostic" })
end)

return {}
