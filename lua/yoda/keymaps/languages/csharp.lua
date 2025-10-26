local map = vim.keymap.set

vim.api.nvim_create_autocmd("FileType", {
	pattern = "cs",
	callback = function(ev)
		local opts = { buffer = ev.buf }

		map("n", "<leader>cr", function()
			vim.cmd("!dotnet run")
		end, vim.tbl_extend("force", opts, { desc = "C#: Run project" }))

		map("n", "<leader>cb", function()
			vim.cmd("!dotnet build")
		end, vim.tbl_extend("force", opts, { desc = "C#: Build project" }))

		map("n", "<leader>ct", function()
			vim.cmd("!dotnet test")
		end, vim.tbl_extend("force", opts, { desc = "C#: Run tests" }))

		map("n", "<leader>cd", function()
			local ok, dap = pcall(require, "dap")
			if not ok then
				vim.notify("DAP not available", vim.log.levels.ERROR)
				return
			end
			dap.continue()
		end, vim.tbl_extend("force", opts, { desc = "C#: Start debugger" }))

		map("n", "<leader>co", function()
			local ok = pcall(vim.cmd, "AerialToggle")
			if not ok then
				vim.notify("Aerial not available", vim.log.levels.ERROR)
			end
		end, vim.tbl_extend("force", opts, { desc = "C#: Toggle outline" }))

		map("n", "<leader>ce", function()
			local ok, trouble = pcall(require, "trouble")
			if not ok then
				vim.diagnostic.setloclist()
				return
			end
			vim.cmd("Trouble diagnostics toggle filter.buf=0")
		end, vim.tbl_extend("force", opts, { desc = "C#: Open diagnostics" }))

		map("n", "<leader>cu", function()
			vim.lsp.buf.code_action({
				apply = true,
				context = {
					only = { "source.addMissingImports" },
					diagnostics = {},
				},
			})
		end, vim.tbl_extend("force", opts, { desc = "C#: Add using statements" }))

		map("n", "<leader>cU", function()
			vim.lsp.buf.code_action({
				apply = true,
				context = {
					only = { "source.removeUnusedImports" },
					diagnostics = {},
				},
			})
		end, vim.tbl_extend("force", opts, { desc = "C#: Remove unused usings" }))
	end,
})

return {}
