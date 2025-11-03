-- scripts/diagnose_flickering.lua
-- Diagnostic script to identify flickering causes

local M = {}

function M.diagnose()
  print("=== FLICKERING DIAGNOSTIC ===")
  print("")

  -- Check LSP clients
  print("1. LSP Clients:")
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    print("   ❌ No LSP clients attached")
  else
    local python_lsp_count = 0
    for _, client in ipairs(clients) do
      print(string.format("   ✅ %s (id:%d)", client.name, client.id))

      -- Count Python LSP servers
      if client.name == "basedpyright" or client.name == "pyright" or client.name == "pylsp" then
        python_lsp_count = python_lsp_count + 1
      end

      if client.name == "basedpyright" then
        local settings = client.config.settings
        if settings and settings.basedpyright and settings.basedpyright.analysis then
          local analysis = settings.basedpyright.analysis
          print(string.format("      - diagnosticMode: %s", analysis.diagnosticMode or "unknown"))
          print(string.format("      - typeCheckingMode: %s", analysis.typeCheckingMode or "unknown"))
        end

        -- Check capabilities
        if client.server_capabilities then
          print("      - semanticTokens: " .. tostring(client.server_capabilities.semanticTokensProvider ~= nil))
          print("      - documentHighlight: " .. tostring(client.server_capabilities.documentHighlightProvider ~= nil))
        end
      end

      if client.name == "pyright" then
        print("      ⚠️  WARNING: pyright should not be running (we use basedpyright)")
      end
    end

    -- Warn about multiple Python LSP servers
    if python_lsp_count > 1 then
      print(string.format("   🔥 CRITICAL: %d Python LSP servers running (should be 1) - THIS CAUSES FLICKERING!", python_lsp_count))
    end
  end
  print("")

  -- Check updatetime
  print("2. Update Time:")
  print(string.format("   updatetime = %dms", vim.o.updatetime))
  if vim.o.updatetime < 300 then
    print("   ⚠️  Low updatetime may cause frequent updates")
  end
  print("")

  -- Check autocmds
  print("3. Buffer Autocmds:")
  local autocmds = vim.api.nvim_get_autocmds({ buffer = 0 })
  local event_counts = {}
  for _, au in ipairs(autocmds) do
    event_counts[au.event] = (event_counts[au.event] or 0) + 1
  end

  for event, count in pairs(event_counts) do
    print(string.format("   %s: %d handlers", event, count))
    if count > 5 then
      print(string.format("      ⚠️  High handler count for %s", event))
    end
  end
  print("")

  -- Check diagnostics
  print("4. Diagnostic Config:")
  local diag_config = vim.diagnostic.config()
  print(string.format("   update_in_insert: %s", tostring(diag_config.update_in_insert)))
  print(string.format("   virtual_text: %s", tostring(diag_config.virtual_text ~= false)))
  print("")

  -- Check buffer options
  print("5. Buffer Options:")
  print(string.format("   filetype: %s", vim.bo.filetype))
  print(string.format("   buftype: %s", vim.bo.buftype))
  print(string.format("   syntax: %s", vim.bo.syntax))
  print("")

  -- Check treesitter
  print("6. Treesitter:")
  local ts_status, _ = pcall(require, "nvim-treesitter.configs")
  if ts_status then
    print("   ✅ Treesitter available")
    -- Check if treesitter is active for current buffer
    local has_ts, _ = pcall(vim.treesitter.get_parser, 0, "python")
    print(string.format("   Active for buffer: %s", tostring(has_ts)))
  else
    print("   ❌ Treesitter not available")
  end
  print("")

  -- Check for common performance issues
  print("7. Performance Checks:")
  local file_size = vim.fn.getfsize(vim.fn.expand("%"))
  print(string.format("   File size: %d bytes", file_size))
  if file_size > 1000000 then
    print("   ⚠️  Large file detected (>1MB)")
  end

  local line_count = vim.api.nvim_buf_line_count(0)
  print(string.format("   Line count: %d", line_count))
  if line_count > 10000 then
    print("   ⚠️  Many lines (>10k)")
  end
  print("")

  -- Recommendations
  print("8. Recommendations:")
  if vim.o.updatetime < 300 then
    print("   - Increase updatetime: :set updatetime=300")
  end

  local basedpyright_found = false
  for _, client in ipairs(clients) do
    if client.name == "basedpyright" then
      basedpyright_found = true
      local settings = client.config.settings
      if settings and settings.basedpyright and settings.basedpyright.analysis then
        if settings.basedpyright.analysis.diagnosticMode == "workspace" then
          print("   - Change diagnosticMode to openFilesOnly")
        end
      end
    end
  end

  if not basedpyright_found then
    print("   - No issues detected, but basedpyright not attached")
  end

  print("")
  print("=== END DIAGNOSTIC ===")
end

-- Create user command
vim.api.nvim_create_user_command("DiagnoseFlickering", function()
  M.diagnose()
end, { desc = "Diagnose flickering issues" })

return M
