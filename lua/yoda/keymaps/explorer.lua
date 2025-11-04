local notify = require("yoda.adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

local snacks_explorer_cache = {}

vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(ev)
    local win_id = tonumber(ev.match)
    if snacks_explorer_cache.win == win_id then
      snacks_explorer_cache = {}
    end
  end,
})

local function get_snacks_explorer_win()
  if snacks_explorer_cache.win and vim.api.nvim_win_is_valid(snacks_explorer_cache.win) then
    return snacks_explorer_cache.win, snacks_explorer_cache.buf
  end

  local win_utils = require("yoda.window_utils")
  local win, buf = win_utils.find_snacks_explorer()

  if win then
    snacks_explorer_cache = { win = win, buf = buf }
    return win, buf
  end

  snacks_explorer_cache = {}
  return nil, nil
end

map("n", "<leader>eo", function()
  local win, _ = get_snacks_explorer_win()
  if win then
    notify.notify("Snacks Explorer is already open", "info")
    return
  end
  local success = pcall(function()
    require("snacks").explorer.open()
  end)
  if not success then
    notify.notify("Snacks Explorer could not be opened", "error")
  end
end, { desc = "Explorer: Open (only if closed)" })

map("n", "<leader>ef", function()
  local win, _ = get_snacks_explorer_win()
  if win then
    vim.api.nvim_set_current_win(win)
  else
    notify.notify("Snacks Explorer is not open. Use <leader>eo to open it.", "info")
  end
end, { desc = "Explorer: Focus (if open)" })

map("n", "<leader>ec", function()
  local win, _ = get_snacks_explorer_win()
  if win then
    local win_utils = require("yoda.window_utils")
    local count = win_utils.close_windows(function(win, buf, buf_name, ft)
      return ft:match("snacks_") or ft == "snacks"
    end, true)
  else
    notify.notify("Snacks Explorer is not open", "info")
  end
end, { desc = "Explorer: Close (if open)" })

map("n", "<leader>er", function()
  local success = pcall(function()
    require("snacks").explorer.refresh()
    notify.notify("Explorer refreshed", "info")
  end)
  if not success then
    notify.notify("Explorer not available or not open", "warn")
  end
end, { desc = "Explorer: Refresh" })

map("n", "<leader>e?", function()
  local help_text = {
    "Snacks Explorer Keybindings:",
    "",
    "<leader>eo - Open explorer",
    "<leader>ef - Focus explorer",
    "<leader>er - Refresh explorer",
    "<leader>ec - Close explorer",
    "",
    "In Explorer:",
    "H - Toggle hidden files",
    "I - Toggle ignored files",
    "h - Close directory",
    "l - Open directory/file",
    "",
    "Note: Hidden files are shown by default due to show_hidden=true setting",
  }

  notify.notify(table.concat(help_text, "\n"), "info", { title = "Snacks Explorer Help" })
end, { desc = "Explorer: Show help" })
