local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- NOTE: hunk-level operations (<leader>hp preview, <leader>tb toggle blame, etc.)
-- are registered as buffer-local keymaps inside the gitsigns on_attach callback
-- in lua/plugins/git.lua. Global duplicates have been removed.

map("n", "<leader>Gg", function()
  require("neogit").open()
end, { desc = "Git: Open Neogit" })
