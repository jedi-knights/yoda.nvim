local notify = require("yoda-adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>qq", ":qa<cr>", { desc = "Util: Quit Neovim" })

map("n", "<leader>d", function()
  local ok, alpha = pcall(require, "alpha")
  if ok and alpha and alpha.start then
    alpha.start()
    notify.notify("Dashboard opened", "info")
  else
    notify.notify("Failed to open dashboard - alpha plugin not available", "error")
  end
end, { desc = "Util: Open dashboard" })

map("n", "<leader><leader>r", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^yoda") or name:match("^plugins") then
      package.loaded[name] = nil
    end
  end

  dofile(vim.fn.stdpath("config") .. "/lua/options.lua")
  dofile(vim.fn.stdpath("config") .. "/lua/keymaps.lua")
  dofile(vim.fn.stdpath("config") .. "/lua/autocmds.lua")

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
  local success = pcall(vim.cmd, "Noice")
  if not success then
    notify.notify("❌ Noice is not available - using :messages instead", "warn")
    vim.cmd("messages")
  end
end, { desc = "Util: Show message history" })

map("n", "<leader>nl", function()
  local success = pcall(vim.cmd, "Noice last")
  if not success then
    notify.notify("❌ Noice is not available", "warn")
  end
end, { desc = "Util: Show last message" })

map("n", "<leader>nh", function()
  local success = pcall(vim.cmd, "Noice history")
  if not success then
    notify.notify("❌ Noice is not available", "warn")
  end
end, { desc = "Util: Show notification history" })

map("n", "<leader>nd", function()
  local success = pcall(vim.cmd, "Noice dismiss")
  if not success then
    notify.notify("❌ Noice is not available", "warn")
  end
end, { desc = "Util: Dismiss all notifications" })
