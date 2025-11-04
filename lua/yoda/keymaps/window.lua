local notify = require("yoda.adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>xt", function()
  local win_utils = require("yoda.window_utils")
  win_utils.focus_window(function(win, buf, buf_name, ft)
    return buf_name:match("Trouble")
  end)
end, { desc = "Window: Focus Trouble" })

map("n", "<leader>xT", function()
  local ok = pcall(vim.cmd, "TodoTrouble")
  if not ok then
    notify.notify("Todo-comments not available. Install via :Lazy sync", "error")
  end
end, { desc = "Trouble: Show TODOs" })

map("n", "<leader>|", ":vsplit<cr>", { desc = "Window: Vertical split" })
map("n", "<leader>-", ":split<cr>", { desc = "Window: Horizontal split" })
map("n", "<leader>ws", "<c-w>=", { desc = "Window: Equalize sizes" })
