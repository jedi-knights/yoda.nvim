local map = vim.keymap.set

map("n", "<leader>gg", function()
	require("snacks").lazygit()
end, { desc = "Git: Open LazyGit" })

map("n", "<leader>gl", function()
	require("snacks").lazygit.log()
end, { desc = "Git: Log" })

map("n", "<leader>gf", function()
	require("snacks").lazygit.log_file()
end, { desc = "Git: Log (current file)" })

map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Git: Blame line" })
map("n", "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "Git: Toggle line blame" })

return {}
