-- lua/yoda/core/keymaps.lua

local map = require("yoda.utils.keymap_tracker").track


-- General Keymaps
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer"})
map("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find Files" })
map("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live Grep" })
map("n", "<leader>qq", ":qa<CR>", { desc = "Quit Neovim"}) 
map("n", "<C-s>", ":w<CR>", { desc = "Save File" })

-- Better Window Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to Right Window" })

-- Visual Mode Improvements
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })

-- Visual Block Mode Improvements
map("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move Block Down" })
map("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move Block Up" })

-- Terminal Mode (optional early setup)
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })


