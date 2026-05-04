local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<C-h>", "<C-w>h", { desc = "Window: Move left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window: Move down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window: Move up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window: Move right" })

-- Splits live under <leader>w so they appear in the Window which-key group
-- alongside <leader>ws (equalize). The bare <leader>| and <leader>- forms
-- were moved here because they had no group home and clashed visually.
map("n", "<leader>w|", ":vsplit<cr>", { desc = "Window: Vertical split" })
map("n", "<leader>w-", ":split<cr>", { desc = "Window: Horizontal split" })
map("n", "<leader>ws", "<c-w>=", { desc = "Window: Equalize sizes" })
