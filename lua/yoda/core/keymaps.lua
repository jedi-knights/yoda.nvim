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

vim.keymap.set("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "Find Buffers" })

vim.keymap.set("n", "<leader>fh", function()
  require("telescope.builtin").help_tags()
end, { desc = "Find Help Tags" })

vim.keymap.set("n", "<leader>fw", function()
  require("telescope.builtin").grep_string()
end, { desc = "Grep String" })

vim.keymap.set("n", "<leader>fd", function()
  require("telescope.builtin").diagnostics()
end, { desc = "Find Diagnostics" })

vim.keymap.set("n", "<leader>fp", function()
  require("telescope.builtin").pickers()
end, { desc = "Find Pickers" })

vim.keymap.set("n", "<leader>fs", function()
  require("telescope.builtin").search_history()
end, { desc = "Search History" })

vim.keymap.set("n", "<leader>ft", function()
  require("telescope.builtin").tags()
end, { desc = "Find Tags" })

vim.keymap.set("n", "<leader>fc", function()
  require("telescope.builtin").commands()
end, { desc = "Find Commands" })

vim.keymap.set("n", "<leader>fr", function()
  require("telescope.builtin").registers()
end, { desc = "Find Registers" })

vim.keymap.set("n", "<leader>fC", function()
  require("telescope.builtin").command_history()
end, { desc = "Find Command History" })



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
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true, silent = true, desc = "Exit Insert Mode" })
vim.api.nvim_set_keymap("v", "jk", "<Esc>", { noremap = true, silent = true, desc = "Exit Visual Mode" })

-- Indent entire file
vim.keymap.set("n", "<leader>i", "gg=G", { desc = "Re-indent entire file" })

-- Close current buffer and switch cleanly
vim.keymap.set("n", "<leader>q", function()
  local api = vim.api
  local cur_buf = api.nvim_get_current_buf()
  local alt_buf = vim.fn.bufnr("#")

  -- Do not switch to Neo-tree or non-listed buffers
  if vim.bo[alt_buf].filetype ~= "neo-tree" and vim.bo[alt_buf].buflisted then
    api.nvim_set_current_buf(alt_buf)
  else
    vim.cmd("bnext")
  end

  vim.cmd("bd " .. cur_buf)
end, { desc = "Close current buffer and switch cleanly" })

-- Plenary test runner keymaps (global dev tools)
local plenary_test_tools_ok, test_tools = pcall(require, "plenary_test_tools")
if plenary_test_tools_ok then
  local wk = require("which-key")

  -- Set keymaps
  vim.keymap.set("n", "<leader>tt", test_tools.test_current_file, { desc = "Run Plenary: Current test file" })
  vim.keymap.set("n", "<leader>ta", test_tools.test_project, { desc = "Run Plenary: All tests in project" })

  -- Optional: register with which-key
  wk.register({
    t = {
      name = "+tests",
      t = "Run Current Test File",
      a = "Run All Tests in Project",
    },
  }, { prefix = "<leader>" })
end

