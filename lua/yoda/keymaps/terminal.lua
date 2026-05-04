local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>.", function()
  require("yoda-terminal").open_floating()
end, { desc = "Terminal: Open floating terminal with venv detection - Auto-detect Python venv" })

map("i", "<leader>.", function()
  require("yoda-terminal").open_floating()
end, { desc = "Terminal: Open floating terminal with venv detection - Auto-detect Python venv" })

-- Navigate out of terminal mode with Ctrl+w + direction
map("t", "<C-w>h", "<C-\\><C-n><C-w>h", { desc = "Window: Move left from terminal" })
map("t", "<C-w>j", "<C-\\><C-n><C-w>j", { desc = "Window: Move down from terminal" })
map("t", "<C-w>k", "<C-\\><C-n><C-w>k", { desc = "Window: Move up from terminal" })
map("t", "<C-w>l", "<C-\\><C-n><C-w>l", { desc = "Window: Move right from terminal" })
