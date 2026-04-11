local M = {}

function M.show()
  local output = vim.api.nvim_exec2("messages", { output = true }).output
  if not output or output == "" then
    vim.notify("No messages", vim.log.levels.INFO)
    return
  end

  local lines = vim.split(output, "\n")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "messages"

  local width = math.min(120, vim.o.columns - 4)
  local height = math.min(#lines + 1, vim.o.lines - 4)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    border = "rounded",
    title = " Messages ",
    title_pos = "center",
  })

  vim.wo[win].wrap = true
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close messages" })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, desc = "Close messages" })
end

return M
