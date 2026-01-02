-- lua/yoda/commands/lsp.lua
-- LSP utility commands

local M = {}

--- Show LSP clients attached to current buffer
local function show_lsp_clients()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No LSP clients attached to current buffer")
    return
  end

  print("LSP clients attached to current buffer:")
  for _, client in pairs(clients) do
    print("  - " .. client.name .. " (id: " .. client.id .. ")")
  end
end

--- Debug Helm template detection and LSP setup
local function debug_helm_setup()
  local filepath = vim.fn.expand("%:p")
  local current_ft = vim.bo.filetype

  print("=== Helm Debug Info ===")
  print("File path: " .. filepath)
  print("Current filetype: " .. current_ft)

  -- Check if file matches Helm patterns
  local path_lower = filepath:lower()
  local is_templates_dir = path_lower:match("/templates/[^/]*%.ya?ml$") ~= nil
  local is_charts_templates = path_lower:match("/charts/.*/templates/") ~= nil
  local is_crds = path_lower:match("/crds/[^/]*%.ya?ml$") ~= nil

  print("\nPattern matches:")
  print("  templates/ directory: " .. tostring(is_templates_dir))
  print("  charts/.../templates/: " .. tostring(is_charts_templates))
  print("  crds/ directory: " .. tostring(is_crds))

  -- Check LSP clients
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  print("\nAttached LSP clients:")
  if #clients == 0 then
    print("  None")
  else
    for _, client in pairs(clients) do
      print("  - " .. client.name)
    end
  end
end

function M.setup()
  vim.api.nvim_create_user_command("YodaLspInfo", show_lsp_clients, { desc = "Show LSP clients for current buffer" })
  vim.api.nvim_create_user_command("YodaHelmDebug", debug_helm_setup, { desc = "Debug Helm template detection and LSP" })
end

return M
