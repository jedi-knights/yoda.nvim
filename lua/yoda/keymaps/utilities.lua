local notify = require("yoda-adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Buffer cycling: ]b / [b mirror the ]d / [d diagnostic convention.
-- Faster than opening the fzf buffer picker for the common case of stepping
-- through a small set of open buffers.
map("n", "]b", "<cmd>bnext<cr>", { desc = "Buffer: Next" })
map("n", "[b", "<cmd>bprev<cr>", { desc = "Buffer: Prev" })

map("n", "<leader>q", ":qa<cr>", { desc = "Util: Quit Neovim" })

-- Delete all content in the current buffer without touching the clipboard.
-- Useful for clearing a scratch buffer or starting fresh without clobbering
-- what was yanked. Uses the black-hole register so undo still works.
map("n", "<leader>D", function()
  vim.cmd('silent! normal! gg"_dG')
end, { desc = "Util: Delete buffer content" })

-- Toggle conform.nvim auto-format on save for the session.
map("n", "<leader>uf", "<cmd>ToggleFormat<cr>", { desc = "Util: Toggle format on save" })

-- <leader>H mnemonic: Home screen. <leader>d is reserved for the Debug group.
map("n", "<leader>H", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.dashboard then
    snacks.dashboard.open()
  else
    notify.notify("Failed to open dashboard - snacks not available", "error")
  end
end, { desc = "Util: Open dashboard (home)" })

-- <leader>tK lives in the Toggle group rather than Search (<leader>s) —
-- toggling a display overlay is not a search operation.
map("n", "<leader>tK", function()
  local success = pcall(vim.cmd, "ShowkeysToggle")
  if not success then
    local alt_success = pcall(vim.cmd, "Showkeys")
    if not alt_success then
      notify.notify("❌ Failed to toggle Showkeys - plugin may not be loaded", "error")
    end
  end
end, { desc = "Toggle: Show keys display" })

map("n", "<leader>nl", function()
  local ok, noice = pcall(require, "noice")
  if ok then
    noice.cmd("last")
  else
    vim.cmd("messages")
  end
end, { desc = "Util: Show last message" })

map("n", "<leader>nh", function()
  local ok, noice = pcall(require, "noice")
  if ok then
    noice.cmd("history")
  else
    vim.cmd("messages")
  end
end, { desc = "Util: Show notification history" })

map("n", "<leader>nd", function()
  local ok, noice = pcall(require, "noice")
  if ok then
    noice.cmd("dismiss")
  end
end, { desc = "Util: Dismiss all notifications" })
