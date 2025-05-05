-- lua/yoda/core/keymaps.lua

-- General Keymaps

-- Toggle relative numbers
vim.keymap.set("n", "<leader>r", ":set relativenumber!<CR>", { desc = "Toggle Relative Line Numbers" })

-- Toggle neo-tree
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle NeoTree" })

-- Focus on neo-tree
vim.keymap.set("n", "<leader>o", ":Neotree focus<CR>", { desc = "Focus NeoTree" })

vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find Files" })

vim.keymap.set("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Live Grep" })

vim.keymap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit Neovim" })
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save File" })

-- Better Window Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to Left Window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to Lower Window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to Upper Window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to Right Window" })
vim.keymap.set("n", "<C-c>", "<C-w>c", { desc = "Close window" })

-- Visual Mode Improvements
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })

-- Visual Block Mode Improvements
vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move Block Down" })
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move Block Up" })

-- Terminal Mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Yank the entire buffer to the system clipboard
vim.keymap.set("n", "<leader>y", ":%y+<CR>", { desc = "Yank entire buffer to system clipboard" })

-- Prevent accedental macro recording
vim.keymap.set("n", "q", "<nop>", { desc = "Disable q" })

-- Add any additional keymaps here
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true, silent = true, desc = "Exit Insert Mode" })
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true, silent = true, desc = "Exit Insert Mode" })

