-- lua/yoda/lsp/init.lua

-- This file configures LSP behavior after servers are installed

local M = {}

-- optional: pass in cmp capabilities if needed
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
M.capabilities = function()
  local base = vim.lsp.protocol.make_client_capabilities()
  if ok then
    return cmp_nvim_lsp.default_capabilities(base)
  end
  return base
end

-- Define a general on_attach function
function M.on_attach(client, bufnr)
  local keymap = vim.keymap.set
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- LSP keymaps
  keymap("n", "gd", vim.lsp.buf.definition, opts)
  keymap("n", "gD", vim.lsp.buf.declaration, opts)
  keymap("n", "gi", vim.lsp.buf.implementation, opts)
  keymap("n", "gr", vim.lsp.buf.references, opts)
  keymap("n", "K", vim.lsp.buf.hover, opts)
  keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
  keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  keymap("n", "<leader>ds", vim.lsp.buf.document_symbol, opts)
  keymap("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
  keymap("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)
end

-- Define LSP capabilities (extend if needed for autocompletion later)
function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- If using nvim-cmp (completion), extend capabilities
  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

return M

