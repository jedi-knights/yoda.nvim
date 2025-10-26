local map = vim.keymap.set

map("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle breakpoint" })

map("n", "<leader>dc", function()
	require("dap").continue()
end, { desc = "Debug: Continue" })

map("n", "<leader>di", function()
	require("dap").step_into()
end, { desc = "Debug: Step into" })

map("n", "<leader>do", function()
	require("dap").step_over()
end, { desc = "Debug: Step over" })

map("n", "<leader>dO", function()
	require("dap").step_out()
end, { desc = "Debug: Step out" })

map("n", "<leader>dr", function()
	require("dap").repl.toggle()
end, { desc = "Debug: Toggle REPL" })

map("n", "<leader>dl", function()
	require("dap").run_last()
end, { desc = "Debug: Run last" })

map("n", "<leader>du", function()
	require("dapui").toggle()
end, { desc = "Debug: Toggle UI" })

map("n", "<leader>dt", function()
	require("dap").terminate()
end, { desc = "Debug: Terminate" })

return {}
