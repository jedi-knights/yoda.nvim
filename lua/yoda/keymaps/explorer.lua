local notify = require("yoda-adapters.notification")

vim.keymap.set("n", "<leader>e", function()
  local ok, win_utils = pcall(require, "yoda-window.utils")
  if not ok then
    notify.notify("yoda-window.utils not available", "error")
    return
  end

  local all_explorer_wins = win_utils.find_all_windows(function(win, buf, buf_name, ft)
    return ft == "snacks_picker_list"
      or ft == "snacks_picker_input"
      or ft == "snacks_layout_box"
      or ft == "snacks-explorer"
      or ft == "snacks_explorer"
  end)

  if #all_explorer_wins > 0 then
    win_utils.close_windows(function(win, buf, buf_name, ft)
      return ft == "snacks_picker_list"
        or ft == "snacks_picker_input"
        or ft == "snacks_layout_box"
        or ft == "snacks-explorer"
        or ft == "snacks_explorer"
    end, true)
    return
  end

  local success = pcall(function()
    require("snacks").explorer.open()
  end)
  if not success then
    notify.notify("Snacks Explorer could not be opened", "error")
  end
end, { desc = "Explorer: Toggle", nowait = true })
