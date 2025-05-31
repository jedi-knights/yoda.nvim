-- lua/yoda/core/keymaps.lua

local kmap = require("yoda.utils.keymap_logger")
local job_id = 0

-- General Keymaps

-- Run tests
kmap.set("n", "<leader>tp", function()
  require("yoda.testpicker").run()
end, { desc = "Run tests with yoda" })

-- Toggle terminal at bottom
kmap.set("n", "<leader>st", function ()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 5)
  job_id = vim.opt.channel
  vim.cmd("startinsert!")  -- 👈 auto-enter insert mode after terminal opens
end, { desc = "Open bottom terminal" })

kmap.set("n", "<leader>sc", function()
  vim.fn.chansend(job_id, { "echo 'hi'\r\n" })
end, { desc = "Send Command to Terminal" })

-- Windows
-- Split
kmap.set("n", "<leader>|", vim.cmd.vs, { desc = "Vertical Split" })
kmap.set("n", "<leader>-", vim.cmd.sp, { desc = "Horizontal Split" })

-- Window navigation
kmap.set("n", "<C-h>", "<C-w>h", { desc = "Move to Left Window" })
kmap.set("n", "<C-j>", "<C-w>j", { desc = "Move to Lower Window" })
kmap.set("n", "<C-k>", "<C-w>k", { desc = "Move to Upper Window" })
kmap.set("n", "<C-l>", "<C-w>l", { desc = "Move to Right Window" })
kmap.set("n", "<C-c>", "<C-w>c", { desc = "Close Window" })

-- Tab navigation
kmap.set("n", "<C-t>", vim.cmd.tabnew, { desc = "New Tab" })
kmap.set("n", "<C-w>", vim.cmd.tabclose, { desc = "Close Tab" })
kmap.set("n", "<C-p>", vim.cmd.tabprevious, { desc = "Previous Tab" })
kmap.set("n", "<C-n>", vim.cmd.tabnext, { desc = "Next Tab" })

-- Buffer navigation
kmap.set("n", "<S-Left>", vim.cmd.bprevious, { desc = "Previous Buffer" })
kmap.set("n", "<S-Right>", vim.cmd.bnext, { desc = "Next Buffer" })
kmap.set("n", "<S-Down>", vim.cmd.buffers, { desc = "List Buffers" })
kmap.set("n", "<S-Up>", ":buffer ", { desc = "Switch to Buffer" })
kmap.set("n", "<S-Del>", vim.cmd.bdelete, { desc = "Delete Buffer" })

-- Window resizing
kmap.set("n", "<M-Left>",  ":vertical resize -2<CR>", { desc = "Shrink Window Width" })
kmap.set("n", "<M-Right>", ":vertical resize +2<CR>", { desc = "Expand Window Width" })
kmap.set("n", "<M-Up>",    ":resize -1<CR>",          { desc = "Shrink Window Height" })
kmap.set("n", "<M-Down>",  ":resize +1<CR>",          { desc = "Expand Window Height" })

-- Save/Quit
kmap.set("n", "<C-s>", ":w<CR>",   { desc = "Save File" })
kmap.set("n", "<C-q>", ":wq<CR>",  { desc = "Save and Quit" })
kmap.set("n", "<C-x>", ":bd<CR>",  { desc = "Close Buffer" })

-- Visual Mode Improvements
kmap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
kmap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })
kmap.set("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move Block Down" })
kmap.set("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move Block Up" })

-- Exit Terminal Mode
kmap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Clipboard/Yank
kmap.set("n", "<leader>y", ":%y+<CR>", { desc = "Yank buffer to system clipboard" })

-- Disable macro recording
kmap.set("n", "q", "<nop>", { desc = "Disable q" })

-- Fast mode exits
kmap.set("i", "jk", "<Esc>", { noremap = true, silent = true, desc = "Exit Insert Mode" })
kmap.set("v", "jk", "<Esc>", { noremap = true, silent = true, desc = "Exit Visual Mode" })

-- Re-indent whole file
kmap.set("n", "<leader>i", "gg=G", { desc = "Re-indent entire file" })

-- Buffer management
kmap.set("n", "<leader>bq", function()
  local api = vim.api
  local cur_buf = api.nvim_get_current_buf()
  local alt_buf = vim.fn.bufnr("#")
  if vim.bo[alt_buf].filetype ~= "neo-tree" and vim.bo[alt_buf].buflisted then
    api.nvim_set_current_buf(alt_buf)
  else
    vim.cmd("bnext")
  end
  vim.cmd("bd " .. cur_buf)
end, { desc = "Close buffer and switch" })

kmap.set("n", "<leader>bo", function()
  vim.cmd("%bd | e# | bd#")
end, { desc = "Close others" })
kmap.set("n", "<leader>bd", ":bufdo bd<CR>", { desc = "Delete all buffers" })

-- Neo-tree (grouped under <leader>e)
kmap.set("n", "<leader>nt", function()
  vim.cmd("Neotree toggle")
end, { desc = "Toggle NeoTree" })

kmap.set("n", "<leader>nc", ":Neotree close<CR>", { desc = "Close NeoTree" })

kmap.set("n", "<leader>nf", ":Neotree focus<CR>", { desc = "Focus NeoTree" })

-- Telescope mappings (grouped)
kmap.set("n", "<leader>ff", function()
  local builtin = require("telescope.builtin")
  builtin.find_files()
end, { desc = "Find Files" })

kmap.set("n", "<leader>fb", function()
  local builtin = require("telescope.builtin")
  builtin.buffers()
end, { desc = "Find Buffers" })

kmap.set("n", "<leader>fr", function()
  local builtin = require("telescope.builtin")
  builtin.registers()
end, { desc = "Find Registers" })

kmap.set("n", "<leader>sg", function()
  local builtin = require("telescope.builtin")
  builtin.live_grep()
end, { desc = "Search Grep" })

kmap.set("n", "<leader>sw", function()
  local builtin = require("telescope.builtin")
  builtin.grep_string()
end, { desc = "Search Word Under Cursor" })

kmap.set("n", "<leader>sh", function()
  local builtin = require("telescope.builtin")
  builtin.search_history()
end, { desc = "Search History" })

kmap.set("n", "<leader>hh", function()
  local builtin = require("telescope.builtin")
  builtin.help_tags()
end, { desc = "Help Tags" })

kmap.set("n", "<leader>hc", function()
  local builtin = require("telescope.builtin")
  builtin.commands()
end, { desc = "Command Palette" })

-- Quit all
kmap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit Neovim" })

