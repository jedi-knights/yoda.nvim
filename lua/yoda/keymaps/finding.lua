local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>ff", function()
  require("snacks").picker.files()
end, { desc = "Find Files (Snacks) - Fuzzy find files in current directory" })

map("n", "<leader>fg", function()
  require("snacks").picker.grep()
end, { desc = "Find Text (Snacks) - Live grep search across files" })

map("n", "<leader>fr", function()
  require("snacks").picker.recent()
end, { desc = "Recent Files (Snacks) - Browse recently opened files" })

map("n", "<leader>fb", function()
  require("snacks").picker.buffers()
end, { desc = "Find Buffers (Snacks) - Switch between open buffers" })

map("n", "<leader>fR", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Find Rust/LSP symbols - Search symbols in current document" })
map("n", "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "Find workspace symbols - Search symbols across workspace" })
map("n", "<leader>fD", "<cmd>Telescope diagnostics<CR>", { desc = "Find diagnostics - Browse all diagnostics in workspace" })
map("n", "<leader>fG", "<cmd>Telescope git_files<CR>", { desc = "Find Git files - Search files tracked by git" })
