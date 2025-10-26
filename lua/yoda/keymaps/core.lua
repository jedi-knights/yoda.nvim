local map = vim.keymap.set
local help_handler = require("yoda.keymaps.handlers.help")
local win_handler = require("yoda.keymaps.handlers.window")

map("n", "K", help_handler.smart_help_or_hover, { desc = "Help: Show hover/help for word under cursor" })

map("n", "<leader>xt", win_handler.focus_trouble, { desc = "Window: Focus Trouble" })

map("n", "<leader>xT", function()
	local ok = pcall(vim.cmd, "TodoTrouble")
	if not ok then
		vim.notify("Todo-comments not available. Install via :Lazy sync", vim.log.levels.ERROR)
	end
end, { desc = "Trouble: Show TODOs" })

map("n", "<leader>|", ":vsplit<cr>", { desc = "Window: Vertical split" })
map("n", "<leader>-", ":split<cr>", { desc = "Window: Horizontal split" })
map("n", "<leader>ws", "<c-w>=", { desc = "Window: Equalize sizes" })

return {}
