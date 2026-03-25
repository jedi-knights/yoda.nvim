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

--- Show comprehensive LSP status for the current buffer and environment
local function lsp_status()
  local clients = vim.lsp.get_clients()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local filename = vim.api.nvim_buf_get_name(bufnr)

  print("=== LSP Status Debug ===")
  print("Current buffer:", bufnr)
  print("Current filetype:", filetype)
  print("Filename:", filename)
  print("Total active LSP clients:", #clients)
  print("")

  print("--- Running LSP Servers ---")
  if #clients == 0 then
    print("  No LSP clients are running")
  else
    for _, client in ipairs(clients) do
      local attached = vim.lsp.buf_is_attached(bufnr, client.id)
      local root_dir = client.config and client.config.root_dir or "unknown"
      print(string.format("  %s (id:%d): attached=%s, root=%s", client.name, client.id, attached, root_dir))
    end
  end
  print("")

  print("--- Available LSP Servers ---")
  local available_servers = { "gopls", "lua_ls", "ts_ls", "basedpyright", "yamlls", "jdtls", "marksman" }
  for _, server in ipairs(available_servers) do
    local cmd_available = vim.fn.executable(server) == 1
    print(string.format("  %s: %s", server, cmd_available and "✅ available" or "❌ not found"))
  end
  print("========================")
end

--- Debug Python LSP (basedpyright) configuration
local function python_lsp_debug()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "basedpyright" })

  print("=== Python LSP Debug ===")
  print("Buffer filetype:", vim.bo[bufnr].filetype)
  print("Python LSP clients:", #clients)

  if #clients > 0 then
    local client = clients[1]
    print("Client name:", client.name)
    print("Client ID:", client.id)
    print("Root dir:", client.config and client.config.root_dir or "unknown")

    if client.config and client.config.settings and client.config.settings.basedpyright then
      local settings = client.config.settings.basedpyright.analysis
      print("Python path:", settings.pythonPath or "default")
      print("Extra paths:", vim.inspect(settings.extraPaths or {}))
      print("Auto search paths:", settings.autoSearchPaths or false)
      print("Diagnostic mode:", settings.diagnosticMode or "default")
    end
  else
    print("No Python LSP clients attached!")

    if vim.fn.executable("basedpyright-langserver") == 1 then
      print("✅ basedpyright-langserver is available")
    else
      print("❌ basedpyright-langserver not found in PATH")
      print("Install with: npm install -g basedpyright")
    end

    local root = vim.fs.root(bufnr, { "pyproject.toml", "setup.py", "requirements.txt", ".git" })
    print("Detected project root:", root or "none")

    local cwd = vim.fn.getcwd()
    local possible_venvs = {
      cwd .. "/.venv/bin/python",
      cwd .. "/venv/bin/python",
      cwd .. "/env/bin/python",
    }

    print("Virtual environment check:")
    for _, path in ipairs(possible_venvs) do
      if vim.fn.executable(path) == 1 then
        print("  ✅", path)
      else
        print("  ❌", path)
      end
    end
  end
  print("========================")
end

--- Debug Groovy/Java LSP (jdtls) configuration
local function groovy_lsp_debug()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })

  print("=== Groovy/Java LSP Debug ===")
  print("Buffer filetype:", vim.bo[bufnr].filetype)
  print("JDTLS clients:", #clients)

  if #clients > 0 then
    local client = clients[1]
    print("Client name:", client.name)
    print("Client ID:", client.id)
    print("Root dir:", client.config and client.config.root_dir or "unknown")
    print("Status:", client:is_stopped() and "stopped" or "running")

    if client.config and client.config.settings and client.config.settings.java then
      print("Java settings configured: ✅")
    end

    local stats = vim.lsp.get_client_by_id(client.id)
    if stats then
      print("Client attached buffers:", #vim.lsp.get_buffers_by_client_id(client.id))
    end
  else
    print("No JDTLS clients attached!")

    if vim.fn.executable("jdtls") == 1 then
      print("✅ jdtls is available")
    else
      print("❌ jdtls not found in PATH")
      print("Install Eclipse JDT Language Server")
    end

    local root = vim.fs.root(bufnr, { "build.gradle", "build.gradle.kts", "pom.xml", "settings.gradle", "settings.gradle.kts", ".git" })
    print("Detected project root:", root or "none")

    if vim.fn.executable("java") == 1 then
      print("✅ Java runtime available")
    else
      print("❌ Java runtime not found")
    end
  end
  print("========================")
end

function M.setup()
  vim.api.nvim_create_user_command("YodaLspInfo", show_lsp_clients, { desc = "Show LSP clients for current buffer" })
  vim.api.nvim_create_user_command("YodaHelmDebug", debug_helm_setup, { desc = "Debug Helm template detection and LSP" })
  vim.api.nvim_create_user_command("LSPStatus", lsp_status, { desc = "Show comprehensive LSP status" })
  vim.api.nvim_create_user_command("LSPRestart", function()
    vim.cmd("LspRestart")
    print("LSP clients restarted")
  end, { desc = "Restart LSP clients" })
  vim.api.nvim_create_user_command("LSPInfo", function()
    vim.cmd("LspInfo")
  end, { desc = "Show LSP information" })
  vim.api.nvim_create_user_command("PythonLSPDebug", python_lsp_debug, { desc = "Debug Python LSP configuration" })
  vim.api.nvim_create_user_command("GroovyLSPDebug", groovy_lsp_debug, { desc = "Debug Groovy/Java LSP configuration" })
end

return M
