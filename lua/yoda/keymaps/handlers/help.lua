local M = {}

function M.smart_help_or_hover()
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  if #clients > 0 then
    vim.lsp.buf.hover()
    return
  end

  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify("No word under cursor", vim.log.levels.INFO)
    return
  end

  local success = pcall(vim.cmd, "help " .. word)
  if not success then
    vim.notify("No help found for: " .. word, vim.log.levels.WARN)
  end
end

return M
