local notify = require("yoda-adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function get_snacks_explorer_win()
  local win_utils = require("yoda-window.utils")
  return win_utils.find_snacks_explorer()
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
  local win_utils = require("yoda-window.utils")

  local all_explorer_wins = win_utils.find_all_windows(function(win, buf, buf_name, ft)
    return ft == "snacks_picker_list"
      or ft == "snacks_picker_input"
      or ft == "snacks_layout_box"
      or ft == "snacks-explorer"
      or ft == "snacks_explorer"
  end)

  if #all_explorer_wins > 0 then
    local list_win = nil
    for _, win_data in ipairs(all_explorer_wins) do
      local ft = vim.bo[win_data.buf].filetype
      if ft == "snacks_picker_list" then
        list_win = win_data.win
        break
      end
    end

    if list_win then
      vim.api.nvim_set_current_win(list_win)
    end
    return
  end

  local success = pcall(function()
    require("snacks").explorer.open()
  end)
  if not success then
    notify.notify("Snacks Explorer could not be opened", "error")
  end
end, { desc = "Explorer: Focus or open" })

map("n", "<leader>ec", function()
  local win_utils = require("yoda-window.utils")
  local count = win_utils.close_windows(function(win, buf, buf_name, ft)
    return ft == "snacks_picker_list"
      or ft == "snacks_picker_input"
      or ft == "snacks_layout_box"
      or ft == "snacks-explorer"
      or ft == "snacks_explorer"
  end, true)

  if count > 0 then
    notify.notify("Closed " .. count .. " explorer window(s)", "info")
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
    "Search results:",
    "  found_win: " .. tostring(found_win),
    "  found_buf: " .. tostring(found_buf),
    "",
    "All windows:",
  }

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    local buf_name = vim.api.nvim_buf_get_name(buf)
    table.insert(debug_info, string.format("  win=%d buf=%d ft='%s' bt='%s' name='%s'", win, buf, ft, bt, buf_name))
  end

  table.insert(debug_info, "")

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
