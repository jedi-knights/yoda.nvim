-- lua/yoda/core/keymaps.lua


local kmap = require("yoda.utils.keymap_logger")

-- General Keymaps

kmap.set("n", "<leader>tp", function()
  require("yoda.testpicker").run()
end, { desc = "Run tests with yoda" })

-- Start a small terminal at the bottom of the screen
--
local job_id = 0
kmap.set("n", "<leader>st", function ()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 5)

  job_id = vim.opt.channel
end)

kmap.set("n", "<leader>sc", function()
  vim.fn.chansend(job_id, { "echo 'hi'\r\n" })
end, { desc = "Send Command to Terminal" })

-- Toggle relative numbersq
kmap.set("n", "<leader>r", ":set relativenumber!<CR>", { desc = "Toggle Relative Line Numbers" })

-- Toggle neo-tree
kmap.set("n", "<leader>te", function()
  local neotree_open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == "neo-tree" then
      neotree_open = true
      break
    end
  end

  if neotree_open then
    vim.cmd("Neotree close")
  else
    vim.cmd("Neotree toggle")
  end
end, { desc = "Toggle NeoTree" })

-- Close Neo-tree
kmap.set("n", "<leader>tc", ":Neotree close<CR>", { desc = "Close NeoTree" })

-- Focus on neo-tree
kmap.set("n", "<leader>to", ":Neotree focus<CR>", { desc = "Focus NeoTree" })

kmap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find Files" })

kmap.set("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Live Grep" })

kmap.set("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "Find Buffers" })

kmap.set("n", "<leader>fh", function()
  require("telescope.builtin").help_tags()
end, { desc = "Find Help Tags" })

kmap.set("n", "<leader>fw", function()
  require("telescope.builtin").grep_string()
end, { desc = "Grep String" })

kmap.set("n", "<leader>fd", function()
  require("telescope.builtin").diagnostics()
end, { desc = "Find Diagnostics" })

kmap.set("n", "<leader>fp", function()
  require("telescope.builtin").pickers()
end, { desc = "Find Pickers" })

kmap.set("n", "<leader>fs", function()
  require("telescope.builtin").search_history()
end, { desc = "Search History" })

kmap.set("n", "<leader>ft", function()
  require("telescope.builtin").tags()
end, { desc = "Find Tags" })

kmap.set("n", "<leader>fc", function()
  require("telescope.builtin").commands()
end, { desc = "Find Commands" })

kmap.set("n", "<leader>fr", function()
  require("telescope.builtin").registers()
end, { desc = "Find Registers" })

kmap.set("n", "<leader>fC", function()
  require("telescope.builtin").command_history()
end, { desc = "Find Command History" })



kmap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit Neovim" })
kmap.set("n", "<C-s>", ":w<CR>", { desc = "Save File" })

-- Better Window Navigation
kmap.set("n", "<C-h>", "<C-w>h", { desc = "Move to Left Window" })
kmap.set("n", "<C-j>", "<C-w>j", { desc = "Move to Lower Window" })
kmap.set("n", "<C-k>", "<C-w>k", { desc = "Move to Upper Window" })
kmap.set("n", "<C-l>", "<C-w>l", { desc = "Move to Right Window" })
kmap.set("n", "<C-c>", "<C-w>c", { desc = "Close window" })

-- Visual Mode Improvements
kmap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
kmap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })

-- Visual Block Mode Improvements
kmap.set("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move Block Down" })
kmap.set("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move Block Up" })

-- Terminal Mode
kmap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Yank the entire buffer to the system clipboard
kmap.set("n", "<leader>y", ":%y+<CR>", { desc = "Yank entire buffer to system clipboard" })

-- Prevent accedental macro recording
kmap.set("n", "q", "<nop>", { desc = "Disable q" })

-- Add any additional keymaps here
kmap.set("i", "jk", "<Esc>", { noremap = true, silent = true, desc = "Exit Insert Mode" })
kmap.set("v", "jk", "<Esc>", { noremap = true, silent = true, desc = "Exit Visual Mode" })

-- Indent entire file
kmap.set("n", "<leader>i", "gg=G", { desc = "Re-indent entire file" })

-- Close current buffer and switch cleanly
kmap.set("n", "<leader>bq", function()
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

-- Close all buffers other than the current one
kmap.set("n", "<leader>bd", function()
  vim.cmd("%bd | e# | bd#")
end, { desc = "Delete all buffers except current" })

