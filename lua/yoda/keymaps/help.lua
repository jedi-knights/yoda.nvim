local notify = require("yoda-adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "K", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    vim.lsp.buf.hover()
  else
    local word = vim.fn.expand("<cword>")
    if word ~= "" then
      local success = pcall(vim.cmd, "help " .. word)
      if not success then
        notify.notify("No help found for: " .. word, "warn")
      end
    else
      notify.notify("No word under cursor", "info")
    end
  end
end, { desc = "Help: Show hover/help for word under cursor" })
