local map = vim.keymap.set
local actions = require("yoda.keymaps.handlers.explorer_actions")

map("n", "<leader>ai", actions.with_auto_save(actions.toggle_opencode_with_insert), {
	desc = "AI: Toggle/Focus OpenCode (auto-save + insert mode)",
})

map({ "n", "i" }, "<leader>ab", actions.return_from_opencode, {
	desc = "AI: Return to previous buffer from OpenCode",
})

map("i", "<C-q>", actions.smart_escape_opencode, {
	desc = "Smart escape: Exit insert mode (return to buffer if in OpenCode)",
})

map("n", "<leader>ao", function()
	require("opencode").open()
end, { desc = "AI: Open OpenCode" })

map("n", "<leader>ac", function()
	require("opencode").close()
end, { desc = "AI: Close OpenCode" })

map("n", "<leader>at", function()
	require("opencode").toggle()
end, { desc = "AI: Toggle OpenCode" })

map("n", "<leader>as", function()
	local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
	if ok then
		opencode_integration.save_all_buffers()
		vim.notify("All buffers saved for OpenCode", vim.log.levels.INFO)
	end
end, { desc = "AI: Save all buffers" })

map({ "n", "v" }, "<leader>ce", function()
	local ok = pcall(vim.cmd, "CopilotChatExplain")
	if not ok then
		vim.notify("CopilotChat not available", vim.log.levels.ERROR)
	end
end, { desc = "Copilot: Explain" })

map({ "n", "v" }, "<leader>ct", function()
	local ok = pcall(vim.cmd, "CopilotChatTests")
	if not ok then
		vim.notify("CopilotChat not available", vim.log.levels.ERROR)
	end
end, { desc = "Copilot: Generate tests" })

map({ "n", "v" }, "<leader>cr", function()
	local ok = pcall(vim.cmd, "CopilotChatReview")
	if not ok then
		vim.notify("CopilotChat not available", vim.log.levels.ERROR)
	end
end, { desc = "Copilot: Review code" })

map({ "n", "v" }, "<leader>cf", function()
	local ok = pcall(vim.cmd, "CopilotChatFix")
	if not ok then
		vim.notify("CopilotChat not available", vim.log.levels.ERROR)
	end
end, { desc = "Copilot: Fix code" })

map({ "n", "v" }, "<leader>co", function()
	local ok = pcall(vim.cmd, "CopilotChatOptimize")
	if not ok then
		vim.notify("CopilotChat not available", vim.log.levels.ERROR)
	end
end, { desc = "Copilot: Optimize code" })

return {}
