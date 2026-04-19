local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<C-h>", "<C-w>h", { desc = "Window: Move left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window: Move down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window: Move up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window: Move right" })

map("n", "<leader>|", ":vsplit<cr>", { desc = "Window: Vertical split - Split window vertically" })
map("n", "<leader>-", ":split<cr>", { desc = "Window: Horizontal split - Split window horizontally" })
map("n", "<leader>ws", "<c-w>=", { desc = "Window: Equalize sizes - Make all splits equal size" })
