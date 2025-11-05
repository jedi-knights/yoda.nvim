local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>gp", function()
  require("gitsigns").preview_hunk()
end, { desc = "Git: Preview Hunk - Show diff preview of current hunk" })

map("n", "<leader>gt", function()
  require("gitsigns").toggle_current_line_blame()
end, { desc = "Git: Toggle Blame - Show/hide git blame for current line" })

map("n", "<leader>gg", function()
  require("neogit").open()
end, { desc = "Git: Open Neogit - Open interactive git interface" })

map("n", "<leader>gB", ":G blame<CR>", { desc = "Git: Blame (Fugitive) - Open full file blame view" })
