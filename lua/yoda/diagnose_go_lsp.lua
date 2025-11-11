-- lua/yoda/diagnose_go_lsp.lua
-- Diagnostic script specifically for Go LSP issues

local M = {}

function M.diagnose()
  print("=== GO LSP DIAGNOSTIC ===")
  print("")

  -- Get current buffer info
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local filename = vim.api.nvim_buf_get_name(bufnr)

  print("Current File Info:")
  print(string.format("  Buffer: %d", bufnr))
  print(string.format("  Filetype: %s", filetype))
  print(string.format("  Filename: %s", filename))
  print("")

  -- Check if this is a Go file
  if filetype ~= "go" then
    print("⚠️  WARNING: Current buffer is not a Go file (filetype: " .. filetype .. ")")
    if filename:match("%.go$") then
      print("   File has .go extension but filetype is not 'go' - this may be the issue!")
    end
  else
    print("✅ Current buffer is a Go file")
  end
  print("")

  -- Check for gopls executable
  print("1. gopls Availability:")
  if vim.fn.executable("gopls") == 1 then
    print("   ✅ gopls is available in PATH")

    -- Get version
    local handle = io.popen("gopls version 2>/dev/null")
    if handle then
      local version = handle:read("*a")
      handle:close()
      print("   Version: " .. (version:gsub("%s+", " "):match("^%s*(.-)%s*$") or "unknown"))
    end
  else
    print("   ❌ gopls not found in PATH")
    print("   Install with: go install golang.org/x/tools/gopls@latest")
  end
  print("")

  -- Check LSP clients
  print("2. LSP Clients:")
  local clients = vim.lsp.get_clients()
  local gopls_clients = vim.lsp.get_clients({ name = "gopls" })
  local buffer_clients = vim.lsp.get_clients({ bufnr = bufnr })

  print(string.format("   Total LSP clients: %d", #clients))
  print(string.format("   gopls clients: %d", #gopls_clients))
  print(string.format("   Clients attached to current buffer: %d", #buffer_clients))
  print("")

  if #gopls_clients > 0 then
    print("   gopls Details:")
    for _, client in ipairs(gopls_clients) do
      local is_attached = vim.lsp.buf_is_attached(bufnr, client.id)
      print(string.format("     Client ID: %d", client.id))
      print(string.format("     Attached to current buffer: %s", tostring(is_attached)))
      print(string.format("     Root dir: %s", client.config.root_dir or "unknown"))
      print(string.format("     Status: %s", client.is_stopped() and "stopped" or "running"))

      if client.server_capabilities then
        print("     Capabilities:")
        print(string.format("       - completionProvider: %s", tostring(client.server_capabilities.completionProvider ~= nil)))
        print(string.format("       - definitionProvider: %s", tostring(client.server_capabilities.definitionProvider ~= nil)))
        print(string.format("       - hoverProvider: %s", tostring(client.server_capabilities.hoverProvider ~= nil)))
        print(string.format("       - semanticTokensProvider: %s", tostring(client.server_capabilities.semanticTokensProvider ~= nil)))
      end
    end
  else
    print("   ❌ No gopls clients found")
  end
  print("")

  -- Check project root detection
  print("3. Project Root Detection:")
  local root_patterns = { "go.work", "go.mod", ".git" }
  for _, pattern in ipairs(root_patterns) do
    local root = vim.fs.root(filename, { pattern })
    print(string.format("   %s: %s", pattern, root or "not found"))
    if root then
      -- Check if the detected root contains Go files
      local go_files = vim.fn.glob(root .. "/*.go", false, true)
      print(string.format("     Go files in root: %d", #go_files))
    end
  end
  print("")

  -- Check autocmds that might affect LSP
  print("4. LSP-related Autocmds:")
  local lsp_autocmds = vim.api.nvim_get_autocmds({
    group = "YodaLspConfig",
  })
  print(string.format("   YodaLspConfig autocmds: %d", #lsp_autocmds))

  local lsp_attach_autocmds = vim.api.nvim_get_autocmds({
    event = "LspAttach",
  })
  print(string.format("   LspAttach autocmds: %d", #lsp_attach_autocmds))
  print("")

  -- Check for conflicting language servers
  print("5. Potential Conflicts:")
  local all_client_names = {}
  for _, client in ipairs(clients) do
    table.insert(all_client_names, client.name)
  end

  if #all_client_names > 0 then
    print("   All running LSP servers: " .. table.concat(all_client_names, ", "))
  end

  -- Check for multiple Go servers
  local go_servers = {}
  for _, client in ipairs(clients) do
    if client.name:match("go") or (client.config.filetypes and vim.tbl_contains(client.config.filetypes, "go")) then
      table.insert(go_servers, client.name)
    end
  end

  if #go_servers > 1 then
    print("   🔥 CRITICAL: Multiple Go language servers detected!")
    print("   Servers: " .. table.concat(go_servers, ", "))
    print("   This can cause flickering and conflicts!")
  elseif #go_servers == 1 then
    print("   ✅ Single Go language server: " .. go_servers[1])
  else
    print("   ❌ No Go language servers detected")
  end
  print("")

  -- Check for common flickering causes
  print("6. Flickering Analysis:")

  -- Check updatetime
  print(string.format("   updatetime: %dms", vim.o.updatetime))
  if vim.o.updatetime < 300 then
    print("     ⚠️  Low updatetime may cause frequent updates")
  end

  -- Check buffer autocmds
  local buf_autocmds = vim.api.nvim_get_autocmds({ buffer = bufnr })
  local high_frequency_events = { "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI" }
  local high_freq_count = 0

  for _, au in ipairs(buf_autocmds) do
    if vim.tbl_contains(high_frequency_events, au.event) then
      high_freq_count = high_freq_count + 1
    end
  end

  print(string.format("   High-frequency autocmds: %d", high_freq_count))
  if high_freq_count > 5 then
    print("     ⚠️  Many high-frequency autocmds may cause flickering")
  end
  print("")

  -- Recommendations
  print("7. Recommendations:")

  if filetype ~= "go" and filename:match("%.go$") then
    print("   - File has .go extension but wrong filetype. Run: :set filetype=go")
  end

  if #gopls_clients == 0 and vim.fn.executable("gopls") == 1 then
    print("   - gopls is available but not running. Try: :LspStart gopls")
  end

  if #gopls_clients == 0 and vim.fn.executable("gopls") == 0 then
    print("   - Install gopls: go install golang.org/x/tools/gopls@latest")
  end

  if #gopls_clients > 0 and #buffer_clients == 0 then
    print("   - gopls is running but not attached to this buffer")
    print("   - Check if the file is in a Go project (has go.mod or go.work)")
    print("   - Try: :LspRestart")
  end

  if #go_servers > 1 then
    print("   - Stop conflicting Go language servers")
  end

  print("")
  print("=== END GO LSP DIAGNOSTIC ===")
end

-- Create user command
vim.api.nvim_create_user_command("DiagnoseGoLSP", function()
  M.diagnose()
end, { desc = "Diagnose Go LSP attachment issues" })

return M
