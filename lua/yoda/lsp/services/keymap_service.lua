-- lua/yoda/lsp/services/keymap_service.lua
-- LSP keymap management service

local M = {}

--- @class LSPKeymapService
--- @field private _logger table
--- @field private _skip_filetypes table<string, boolean>
local LSPKeymapService = {}
LSPKeymapService.__index = LSPKeymapService

--- Create new keymap service
--- @param logger table Logger service
--- @param skip_filetypes table List of filetypes to skip
--- @return LSPKeymapService
function M.new(logger, skip_filetypes)
  local self = setmetatable({}, LSPKeymapService)
  self._logger = logger

  -- Convert skip filetypes array to lookup table for O(1) performance
  self._skip_filetypes = {}
  for _, ft in ipairs(skip_filetypes or {}) do
    self._skip_filetypes[ft] = true
  end

  return self
end

--- Setup LSP keymaps for a buffer
--- @param client table LSP client
--- @param bufnr number Buffer number
function LSPKeymapService:setup_keymaps(client, bufnr)
  if type(bufnr) ~= "number" or bufnr < 0 then
    self._logger.error("Invalid buffer number")
    return false
  end

  local filetype = vim.bo[bufnr].filetype

  -- Skip keymaps for excluded filetypes
  if self._skip_filetypes[filetype] then
    self._logger.debug("Skipping LSP keymaps for excluded filetype", {
      filetype = filetype,
      buffer = bufnr,
    })
    return false
  end

  -- Performance optimization: Disable semantic tokens
  if client and client.server_capabilities.semanticTokensProvider then
    client.server_capabilities.semanticTokensProvider = nil
  end

  self:_apply_keymaps(bufnr)
  self._logger.debug("Applied LSP keymaps", { buffer = bufnr, filetype = filetype })
  return true
end

--- Apply standard LSP keymaps to buffer
--- @param bufnr number Buffer number
--- @private
function LSPKeymapService:_apply_keymaps(bufnr)
  local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- Navigation keymaps
  map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
  map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
  map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
  map("n", "gr", vim.lsp.buf.references, { desc = "Show references" })
  map("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

  -- Information keymaps
  map("n", "K", vim.lsp.buf.hover, { desc = "Show hover" })
  map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help" })

  -- Workspace keymaps
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
  map("n", "<leader>wl", function()
    self._logger.info("Workspace folders", { folders = vim.lsp.buf.list_workspace_folders() })
  end, { desc = "List workspace folders" })

  -- Action keymaps
  map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
  map("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format" })
end

--- Check if filetype should be skipped
--- @param filetype string
--- @return boolean
function LSPKeymapService:should_skip_filetype(filetype)
  return self._skip_filetypes[filetype] or false
end

--- Get list of skipped filetypes
--- @return table<string>
function LSPKeymapService:get_skip_filetypes()
  local result = {}
  for ft, _ in pairs(self._skip_filetypes) do
    table.insert(result, ft)
  end
  table.sort(result)
  return result
end

return M
