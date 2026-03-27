local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>|", ":vsplit<cr>", { desc = "Window: Vertical split - Split window vertically" })
map("n", "<leader>-", ":split<cr>", { desc = "Window: Horizontal split - Split window horizontally" })
map("n", "<leader>ws", "<c-w>=", { desc = "Window: Equalize sizes - Make all splits equal size" })
