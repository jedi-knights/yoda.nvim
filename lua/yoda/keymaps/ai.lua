local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude Code" })
