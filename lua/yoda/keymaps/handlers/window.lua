local win_utils = require("yoda.window_utils")
local M = {}

function M.open_explorer_if_closed()
	local win, _ = win_utils.find_snacks_explorer()

	if win then
		vim.notify("Snacks Explorer is already open", vim.log.levels.INFO)
		return false
	end

	local ok = pcall(function()
		require("snacks").explorer.open()
	end)

	if not ok then
		vim.notify("Snacks Explorer could not be opened", vim.log.levels.ERROR)
		return false
	end

	return true
end

function M.focus_explorer()
	local win, _ = win_utils.find_snacks_explorer()

	if not win then
		vim.notify("Snacks Explorer is not open. Use <leader>eo to open it.", vim.log.levels.INFO)
		return false
	end

	vim.api.nvim_set_current_win(win)
	return true
end

function M.close_explorer()
	local win, _ = win_utils.find_snacks_explorer()

	if not win then
		vim.notify("Snacks Explorer is not open", vim.log.levels.INFO)
		return false
	end

	local snacks_wins = {}
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(w)
		local ft = vim.bo[buf].filetype
		if ft:match("snacks_") or ft == "snacks" then
			table.insert(snacks_wins, w)
		end
	end

	for _, w in ipairs(snacks_wins) do
		pcall(vim.api.nvim_win_close, w, true)
	end

	return true
end

function M.refresh_explorer()
	local ok = pcall(function()
		require("snacks").explorer.refresh()
		vim.notify("Explorer refreshed", vim.log.levels.INFO)
	end)

	if not ok then
		vim.notify("Explorer not available or not open", vim.log.levels.WARN)
		return false
	end

	return true
end

function M.show_explorer_help()
	local help_text = {
		"Snacks Explorer Keybindings:",
		"",
		"<leader>eo - Open explorer",
		"<leader>ef - Focus explorer",
		"<leader>er - Refresh explorer",
		"<leader>ec - Close explorer",
		"",
		"In Explorer:",
		"H - Toggle hidden files",
		"I - Toggle ignored files",
		"h - Close directory",
		"l - Open directory/file",
		"",
		"Note: Hidden files are shown by default due to show_hidden=true setting",
	}

	vim.notify(table.concat(help_text, "\n"), vim.log.levels.INFO, { title = "Snacks Explorer Help" })
	return true
end

function M.focus_trouble()
	local win = win_utils.find_trouble()

	if not win then
		vim.notify("Trouble window is not open", vim.log.levels.WARN)
		return false
	end

	vim.api.nvim_set_current_win(win)
	return true
end

return M
