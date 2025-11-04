local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>ff", function()
  require("snacks").picker.files()
end, { desc = "Find Files (Snacks)" })

map("n", "<leader>fg", function()
  require("snacks").picker.grep()
end, { desc = "Find Text (Snacks)" })

map("n", "<leader>fr", function()
  require("snacks").picker.recent()
end, { desc = "Recent Files (Snacks)" })

map("n", "<leader>fb", function()
  require("snacks").picker.buffers()
end, { desc = "Find Buffers (Snacks)" })

map("n", "<leader>fR", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Find Rust/LSP symbols" })
map("n", "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "Find workspace symbols" })
map("n", "<leader>fD", "<cmd>Telescope diagnostics<CR>", { desc = "Find diagnostics" })
map("n", "<leader>fG", "<cmd>Telescope git_files<CR>", { desc = "Find Git files" })
