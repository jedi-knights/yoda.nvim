-- Global diagnostic keymaps — work regardless of LSP attachment.
-- All other LSP keymaps (gd, gr, <leader>l*, etc.) are set buffer-locally
-- in the LspAttach handler in lua/yoda/lsp.lua.

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
