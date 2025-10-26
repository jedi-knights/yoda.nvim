local map = vim.keymap.set

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function(ev)
		local opts = { buffer = ev.buf }

		map("n", "<leader>rr", function()
			vim.cmd("RustLsp run")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Run" }))

		map("n", "<leader>rt", function()
			vim.cmd("RustLsp testables")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Test" }))

		map("n", "<leader>rd", function()
			vim.cmd("RustLsp debuggables")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Debug" }))

		map("n", "<leader>re", function()
			vim.cmd("RustLsp explainError")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Explain error" }))

		map("n", "<leader>rc", function()
			vim.cmd("RustLsp openCargo")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Open Cargo.toml" }))

		map("n", "<leader>rp", function()
			vim.cmd("RustLsp parentModule")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Parent module" }))

		map("n", "<leader>rm", function()
			vim.cmd("RustLsp expandMacro")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Expand macro" }))

		map("n", "<leader>rh", function()
			vim.cmd("RustLsp hover actions")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Hover actions" }))

		map("n", "<leader>ra", function()
			vim.cmd("RustLsp codeAction")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Code action" }))

		map("n", "<leader>rk", function()
			vim.cmd("RustLsp moveItem up")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Move item up" }))

		map("n", "<leader>rj", function()
			vim.cmd("RustLsp moveItem down")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Move item down" }))

		map("n", "<leader>rC", function()
			vim.cmd("RustLsp openDocs")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Open docs" }))

		map("n", "<leader>rR", function()
			vim.cmd("RustLsp runnables")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Runnables" }))

		map("n", "<leader>rD", function()
			vim.cmd("RustLsp renderDiagnostic")
		end, vim.tbl_extend("force", opts, { desc = "Rust: Render diagnostic" }))

		map("n", "<leader>ro", function()
			local ok = pcall(vim.cmd, "AerialToggle")
			if not ok then
				vim.notify("Aerial not available. Install via :Lazy sync", vim.log.levels.ERROR)
			end
		end, vim.tbl_extend("force", opts, { desc = "Rust: Toggle outline" }))
	end,
})

return {}
