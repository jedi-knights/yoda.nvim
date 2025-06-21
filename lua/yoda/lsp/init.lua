-- lua/yoda/lsp/init.lua

local M = {}

-- Extend LSP client capabilities (e.g., for nvim-cmp)
function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

-- Attach LSP with minimal built-in behavior
function M.on_attach(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Basic hover functionality only
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
end

return M
