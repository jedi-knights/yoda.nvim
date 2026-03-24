local notify = require("yoda-adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Standard window navigation. Using C-w C-h etc. requires two steps;
-- these single-chord mappings match the muscle memory most editors use.
map("n", "<C-h>", "<C-w><C-h>", { desc = "Window: Move to left split" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Window: Move to lower split" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Window: Move to upper split" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Window: Move to right split" })

map("n", "<leader>xt", function()
  local ok, win_utils = pcall(require, "yoda-window.utils")
  if not ok then
    notify.notify("yoda-window.utils not available", "error")
    return
  end

  win_utils.focus_window(function(win, buf, buf_name, ft)
    return buf_name:match("Trouble")
  end)
end, { desc = "Window: Focus Trouble - Switch to Trouble diagnostics window" })

map("n", "<leader>xT", function()
  local ok = pcall(vim.cmd, "TodoTrouble")
  if not ok then
    notify.notify("Todo-comments not available. Install via :Lazy sync", "error")
  end
end, { desc = "Trouble: Show TODOs - Display all TODO comments in Trouble" })

map("n", "<leader>|", ":vsplit<cr>", { desc = "Window: Vertical split - Split window vertically" })
map("n", "<leader>-", ":split<cr>", { desc = "Window: Horizontal split - Split window horizontally" })
map("n", "<leader>ws", "<c-w>=", { desc = "Window: Equalize sizes - Make all splits equal size" })
