local map = vim.keymap.set

map("n", "<leader>tc", function()
	local filetype = vim.bo.filetype

	if filetype == "python" then
		local ok, neotest = pcall(require, "neotest")
		if ok then
			neotest.run.run(vim.fn.expand("%"))
		else
			vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
		end
	elseif filetype == "lua" then
		local plenary = require("yoda.plenary")
		plenary.run_current_test()
	else
		vim.notify("No test runner configured for filetype: " .. filetype, vim.log.levels.WARN)
	end
end, { desc = "Test: Run current file" })

map("n", "<leader>tr", function()
	require("neotest").run.run()
end, { desc = "Test: Run nearest" })

map("n", "<leader>ta", function()
	require("neotest").run.run(vim.fn.getcwd())
end, { desc = "Test: Run all" })

map("n", "<leader>tv", function()
	require("neotest").output.open({ enter = true })
end, { desc = "Test: View output" })

map("n", "<leader>to", function()
	require("neotest").output_panel.toggle()
end, { desc = "Test: Toggle output panel" })

map("n", "<leader>tO", function()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local bufname = vim.api.nvim_buf_get_name(buf)
		if bufname:match("Neotest Output") or vim.bo[buf].filetype == "neotest-output-panel" then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
	vim.notify("Neotest output panel not open", vim.log.levels.WARN)
end, { desc = "Test: Focus output panel" })

map("n", "<leader>ts", function()
	require("neotest").summary.toggle()
end, { desc = "Test: Toggle summary" })

map("n", "<leader>tF", function()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "neotest-summary" then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
	vim.notify("Neotest summary not open. Use <leader>ts to open it.", vim.log.levels.WARN)
end, { desc = "Test: Focus summary window" })

map("n", "<leader>tC", function()
	require("neotest").output_panel.clear()
	vim.notify("Neotest output panel cleared", vim.log.levels.INFO)
end, { desc = "Test: Clear output panel" })

map("n", "[t", function()
	require("neotest").jump.prev({ status = "failed" })
end, { desc = "Test: Jump to previous failed" })

map("n", "]t", function()
	require("neotest").jump.next({ status = "failed" })
end, { desc = "Test: Jump to next failed" })

map("n", "<leader>tw", function()
	require("neotest").watch.toggle()
end, { desc = "Test: Toggle watch mode" })

return {}
