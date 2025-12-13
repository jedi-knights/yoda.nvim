local notify = require("yoda-adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

local snacks_explorer_cache = {}

local function invalidate_cache()
  snacks_explorer_cache = {}
end

vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(ev)
    local win_id = tonumber(ev.match)
    if snacks_explorer_cache.win == win_id then
      invalidate_cache()
    end
  end,
})

vim.api.nvim_create_autocmd("BufWinLeave", {
  callback = function(ev)
    if snacks_explorer_cache.buf and ev.buf == snacks_explorer_cache.buf then
      invalidate_cache()
    end
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(ev)
    if snacks_explorer_cache.buf and ev.buf == snacks_explorer_cache.buf then
      invalidate_cache()
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function(ev)
    if snacks_explorer_cache.win and vim.api.nvim_win_is_valid(snacks_explorer_cache.win) then
      local current_buf = vim.api.nvim_win_get_buf(snacks_explorer_cache.win)
      if current_buf ~= snacks_explorer_cache.buf then
        local ft = vim.bo[current_buf].filetype
        if ft ~= "snacks-explorer" then
          invalidate_cache()
        else
          snacks_explorer_cache.buf = current_buf
        end
      end
    end
  end,
})

local function get_snacks_explorer_win()
  if snacks_explorer_cache.win and vim.api.nvim_win_is_valid(snacks_explorer_cache.win) then
    local buf = vim.api.nvim_win_get_buf(snacks_explorer_cache.win)
    if vim.api.nvim_buf_is_valid(buf) then
      local ft = vim.bo[buf].filetype
      if ft == "snacks-explorer" and snacks_explorer_cache.buf == buf then
        return snacks_explorer_cache.win, buf
      else
        invalidate_cache()
      end
    else
      invalidate_cache()
    end
  end

  local win_utils = require("yoda-window.utils")
  local win, buf = win_utils.find_snacks_explorer()

  if win and vim.api.nvim_buf_is_valid(buf) then
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
    local win_utils = require("yoda-window.utils")
    local count = win_utils.close_windows(function(win, buf, buf_name, ft)
      return ft == "snacks-explorer"
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
    "<leader>ed - Debug explorer state",
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

map("n", "<leader>ed", function()
  local win_utils = require("yoda-window.utils")
  local found_win, found_buf = win_utils.find_snacks_explorer()
  
  local debug_info = {
    "Explorer Debug Info:",
    "",
    "Cached state:",
    "  win: " .. tostring(snacks_explorer_cache.win),
    "  buf: " .. tostring(snacks_explorer_cache.buf),
    "",
    "Search results:",
    "  found_win: " .. tostring(found_win),
    "  found_buf: " .. tostring(found_buf),
    "",
  }
  
  if found_win then
    local buf = vim.api.nvim_win_get_buf(found_win)
    local ft = vim.bo[buf].filetype
    local buf_name = vim.api.nvim_buf_get_name(buf)
    table.insert(debug_info, "Found window details:")
    table.insert(debug_info, "  buffer: " .. buf)
    table.insert(debug_info, "  filetype: " .. ft)
    table.insert(debug_info, "  buf_name: " .. buf_name)
  else
    table.insert(debug_info, "No explorer window found")
  end
  
  notify.notify(table.concat(debug_info, "\n"), "info", { title = "Explorer Debug" })
end, { desc = "Explorer: Debug state" })
