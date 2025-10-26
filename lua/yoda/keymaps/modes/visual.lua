local map = vim.keymap.set

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Visual: Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Visual: Move line up" })
map("v", "<", "<gv", { desc = "Visual: Indent left" })
map("v", ">", ">gv", { desc = "Visual: Indent right" })

return {}
