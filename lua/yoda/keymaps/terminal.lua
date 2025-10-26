local map = vim.keymap.set

map("n", "<leader>`", function()
	require("snacks").terminal()
end, { desc = "Terminal: Toggle" })

map("n", "<leader>~", function()
	require("snacks").terminal(nil, { position = "float" })
end, { desc = "Terminal: Float" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: Exit terminal mode" })

return {}
