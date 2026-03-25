local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- NOTE: hunk-level operations (<leader>hp preview, <leader>tb toggle blame, etc.)
-- are registered as buffer-local keymaps inside the gitsigns on_attach callback
-- in lua/plugins/git.lua. Global duplicates have been removed.

map("n", "<leader>gg", function()
  require("neogit").open()
end, { desc = "Git: Open Neogit - Open interactive git interface" })

map("n", "<leader>gB", ":G blame<CR>", { desc = "Git: Blame (Fugitive) - Open full file blame view" })
