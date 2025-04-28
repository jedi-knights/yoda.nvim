-- lua/yoda/core/keymaps.lua

-- General Keymaps

-- Toggle relative numbers
vim.keymap.set("n", "<leader>r", ":set relativenumber!<CR>", { desc = "Toggle Relative Line Numbers" })

vim.keymap.set("n", "<leader>e", function()
  local api = require("nvim-tree.api")
  local view = require("nvim-tree.view")

  if view.is_visible() then
    -- If you're already in the tree window → go right
    local current_win = vim.api.nvim_get_current_win()
    if current_win == view.get_winnr() then
      api.tree.close() -- Close the tree if already focused
      --vim.cmd("wincmd l") -- move to the right window (your buffer)
    else
      api.tree.focus() -- focus the tree
    end
  else
    api.tree.open() -- Tree isn't open? Open it
  end
end, { desc = "Toggle focus between NvimTree and buffer" })


local function smart_buffer_close()
  local api = require("nvim-tree.api")

  local curr_buf = vim.api.nvim_get_current_buf()

  -- Try to close the buffer safely
  vim.cmd("bdelete")

  -- Get the new current buffer and window AFTER buffer deleted
  local new_win = vim.api.nvim_get_current_win()
  local new_buf = vim.api.nvim_win_get_buf(new_win)
  local new_buf_name = vim.api.nvim_buf_get_name(new_buf)

  -- If the new buffer is NvimTree, switch to next buffer
  if new_buf_name:match("NvimTree_") then
    vim.cmd("bnext")
  end
end

-- Map <leader>q to close the current buffer
vim.keymap.set("n", "<leader>q", smart_buffer_close, { desc = "Close Buffer (via Bufferline)" })


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

-- Toggle whether or not dotfiles are visible in the tree
vim.keymap.set("n", "<leader>.", function()
  require("nvim-tree.api").tree.toggle_filter("dotfiles")
end, { desc = "Toggle dotfiles in NvimTree" })

