-- lua/yoda/lsp/servers/eslint.lua

return {
  settings = {
    format = { enable = true },
  },
  on_attach = function(client, bufnr)
    -- Disable formatting in favor of eslint/linting
    client.server_capabilities.documentFormattingProvider = true
    -- Optional: format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
}

