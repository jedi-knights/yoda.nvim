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

map("n", "<leader>qq", ":qa<cr>", { desc = "Util: Quit Neovim" })

-- Delete all content in the current buffer without touching the clipboard.
-- Useful for clearing a scratch buffer or starting fresh without clobbering
-- what was yanked. Uses the black-hole register so undo still works.
map("n", "<leader>D", function()
  vim.cmd('silent! normal! gg"_dG')
end, { desc = "Util: Delete buffer content" })

-- Toggle conform.nvim auto-format on save for the session.
map("n", "<leader>tu", "<cmd>ToggleFormat<cr>", { desc = "Util: Toggle format on save" })

map("n", "<leader>d", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.dashboard then
    snacks.dashboard.open()
  else
    notify.notify("Failed to open dashboard - snacks not available", "error")
  end
end, { desc = "Util: Open dashboard" })

map("n", "<leader><leader>r", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^yoda") or name:match("^plugins") then
      package.loaded[name] = nil
    end
  end

  local config = vim.fn.stdpath("config")
  for _, f in ipairs({ "/lua/options.lua", "/lua/yoda/keymaps/init.lua", "/lua/autocmds.lua" }) do
    local ok, err = pcall(dofile, config .. f)
    if not ok then
      notify.notify("❌ Failed to reload " .. f .. ": " .. tostring(err), "error")
    end
  end

  vim.defer_fn(function()
    notify.notify("✅ Reloaded Yoda config", "info")
  end, 100)
end, { desc = "Util: Hot reload Yoda config" })

map("n", "<leader>kk", function()
  local keymaps = {}

  local leader = vim.g.mapleader or " "
  local mode = "n"

  local success, result = pcall(function()
    return vim.api.nvim_get_keymap(mode)
  end)

  if success then
    for _, keymap in ipairs(result) do
      if keymap.lhs and keymap.lhs:sub(1, #leader) == leader then
        local desc = keymap.desc or keymap.rhs or "No description"
        table.insert(keymaps, keymap.lhs .. " → " .. desc)
      end
    end

    if #keymaps > 0 then
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, keymaps)
      vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = 60,
        height = math.min(#keymaps + 2, 20),
        col = 10,
        row = 5,
        border = "single",
        title = "Leader Keymaps (Normal Mode)",
        title_pos = "center",
      })

      vim.api.nvim_create_autocmd("BufLeave", {
        buffer = buf,
        callback = function()
          vim.api.nvim_buf_delete(buf, { force = true })
        end,
      })
    else
      notify.notify("No leader keymaps found in normal mode", "info")
    end
  else
    notify.notify("❌ Failed to get keymaps", "error")
  end
end, { desc = "Util: Show leader keymaps in normal mode" })

map("n", "<leader>sk", function()
  local success = pcall(vim.cmd, "ShowkeysToggle")
  if not success then
    local alt_success = pcall(vim.cmd, "Showkeys")
    if not alt_success then
      notify.notify("❌ Failed to toggle Showkeys - plugin may not be loaded", "error")
    end
  end
end, { desc = "Util: Toggle showkeys display" })

map("n", "<leader>nm", function()
  vim.cmd("messages")
end, { desc = "Util: Show message history" })
