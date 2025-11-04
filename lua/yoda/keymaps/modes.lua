local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("v", "<leader>r", ":s/", { desc = "Visual: Replace" })
map("v", "<leader>y", '"+y', { desc = "Visual: Yank to clipboard" })
map("v", "<leader>d", '"_d', { desc = "Visual: Delete to void register" })
map("v", "<leader>p", "_dP", { desc = "Visual: Delete and paste over" })

map("i", "jk", "<Esc>", { desc = "Insert: Exit to normal mode" })

map("n", "<up>", "<nop>", { desc = "Disabled: Use k" })
map("n", "<down>", "<nop>", { desc = "Disabled: Use j" })
map("n", "<left>", "<nop>", { desc = "Disabled: Use h" })
map("n", "<right>", "<nop>", { desc = "Disabled: Use l" })
map("n", "<pageup>", "<nop>", { desc = "Disabled: Use <C-u>" })
map("n", "<pagedown>", "<nop>", { desc = "Disabled: Use <C-d>" })
