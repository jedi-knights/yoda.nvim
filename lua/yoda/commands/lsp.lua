-- lua/yoda/commands/lsp.lua
-- LSP utility commands

local M = {}

--- Show LSP clients attached to current buffer
local function show_lsp_clients()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP clients attached to current buffer", vim.log.levels.INFO)
    return
  end

  local lines = { "LSP clients attached to current buffer:" }
  for _, client in pairs(clients) do
    table.insert(lines, "  - " .. client.name .. " (id: " .. client.id .. ")")
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

--- Debug Helm template detection and LSP setup
local function debug_helm_setup()
  local filepath = vim.fn.expand("%:p")
  local current_ft = vim.bo.filetype

  local lines = {
    "=== Helm Debug Info ===",
    "File path: " .. filepath,
    "Current filetype: " .. current_ft,
  }

  -- Check if file matches Helm patterns
  local path_lower = filepath:lower()
  local is_templates_dir = path_lower:match("/templates/[^/]*%.ya?ml$") ~= nil
  local is_charts_templates = path_lower:match("/charts/.*/templates/") ~= nil
  local is_crds = path_lower:match("/crds/[^/]*%.ya?ml$") ~= nil

  table.insert(lines, "\nPattern matches:")
  table.insert(lines, "  templates/ directory: " .. tostring(is_templates_dir))
  table.insert(lines, "  charts/.../templates/: " .. tostring(is_charts_templates))
  table.insert(lines, "  crds/ directory: " .. tostring(is_crds))

  -- Check LSP clients
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  table.insert(lines, "\nAttached LSP clients:")
  if #clients == 0 then
    table.insert(lines, "  None")
  else
    for _, client in pairs(clients) do
      table.insert(lines, "  - " .. client.name)
    end
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

--- Show comprehensive LSP status for the current buffer and environment
local function lsp_status()
  local clients = vim.lsp.get_clients()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local filename = vim.api.nvim_buf_get_name(bufnr)

  local lines = {
    "=== LSP Status Debug ===",
    "Current buffer: " .. bufnr,
    "Current filetype: " .. filetype,
    "Filename: " .. filename,
    "Total active LSP clients: " .. #clients,
    "",
    "--- Running LSP Servers ---",
  }

  if #clients == 0 then
    table.insert(lines, "  No LSP clients are running")
  else
    for _, client in ipairs(clients) do
      local attached = client.attached_buffers[bufnr] ~= nil
      local root_dir = client.config and client.config.root_dir or "unknown"
      table.insert(lines, string.format("  %s (id:%d): attached=%s, root=%s", client.name, client.id, attached, root_dir))
    end
  end
  table.insert(lines, "")

  table.insert(lines, "--- Available LSP Servers ---")
  -- Map server names to their actual executable names for availability checks.
  -- Most executables match the server name, but some differ.
  local available_servers = {
    { name = "gopls", cmd = "gopls" },
    { name = "lua_ls", cmd = "lua-language-server" },
    { name = "ts_ls", cmd = "typescript-language-server" },
    { name = "basedpyright", cmd = "basedpyright-langserver" },
    { name = "yamlls", cmd = "yaml-language-server" },
    { name = "jdtls", cmd = "jdtls" },
    { name = "marksman", cmd = "marksman" },
    { name = "autotools_ls", cmd = "autotools-language-server" },
    { name = "rust_analyzer", cmd = "rust-analyzer" },
  }
  for _, server in ipairs(available_servers) do
    local cmd_available = vim.fn.executable(server.cmd) == 1
    table.insert(lines, string.format("  %s: %s", server.name, cmd_available and "available" or "not found"))
  end
  table.insert(lines, "========================")

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

--- Debug Python LSP (basedpyright) configuration
local function python_lsp_debug()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "basedpyright" })

  local lines = {
    "=== Python LSP Debug ===",
    "Buffer filetype: " .. vim.bo[bufnr].filetype,
    "Python LSP clients: " .. #clients,
  }

  if #clients > 0 then
    local client = clients[1]
    table.insert(lines, "Client name: " .. client.name)
    table.insert(lines, "Client ID: " .. client.id)
    table.insert(lines, "Root dir: " .. (client.config and client.config.root_dir or "unknown"))

    if client.config and client.config.settings and client.config.settings.basedpyright then
      local settings = client.config.settings.basedpyright.analysis
      table.insert(lines, "Python path: " .. (settings.pythonPath or "default"))
      table.insert(lines, "Extra paths: " .. vim.inspect(settings.extraPaths or {}))
      table.insert(lines, "Auto search paths: " .. tostring(settings.autoSearchPaths or false))
      table.insert(lines, "Diagnostic mode: " .. (settings.diagnosticMode or "default"))
    end
  else
    table.insert(lines, "No Python LSP clients attached!")

    if vim.fn.executable("basedpyright-langserver") == 1 then
      table.insert(lines, "basedpyright-langserver is available")
    else
      table.insert(lines, "basedpyright-langserver not found in PATH")
      table.insert(lines, "Install with: npm install -g basedpyright")
    end

    local root = vim.fs.root(bufnr, { "pyproject.toml", "setup.py", "requirements.txt", ".git" })
    table.insert(lines, "Detected project root: " .. (root or "none"))

    local cwd = vim.fn.getcwd()
    local possible_venvs = {
      cwd .. "/.venv/bin/python",
      cwd .. "/venv/bin/python",
      cwd .. "/env/bin/python",
    }

    table.insert(lines, "Virtual environment check:")
    for _, path in ipairs(possible_venvs) do
      if vim.fn.executable(path) == 1 then
        table.insert(lines, "  found: " .. path)
      else
        table.insert(lines, "  missing: " .. path)
      end
    end
  end
  table.insert(lines, "========================")

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

--- Debug Groovy/Java LSP (jdtls) configuration
local function groovy_lsp_debug()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })

  local lines = {
    "=== Groovy/Java LSP Debug ===",
    "Buffer filetype: " .. vim.bo[bufnr].filetype,
    "JDTLS clients: " .. #clients,
  }

  if #clients > 0 then
    local client = clients[1]
    table.insert(lines, "Client name: " .. client.name)
    table.insert(lines, "Client ID: " .. client.id)
    table.insert(lines, "Root dir: " .. (client.config and client.config.root_dir or "unknown"))
    table.insert(lines, "Status: " .. (client:is_stopped() and "stopped" or "running"))

    if client.config and client.config.settings and client.config.settings.java then
      table.insert(lines, "Java settings configured: yes")
    end

    table.insert(lines, "Client attached buffers: " .. vim.tbl_count(client.attached_buffers))
  else
    table.insert(lines, "No JDTLS clients attached!")

    if vim.fn.executable("jdtls") == 1 then
      table.insert(lines, "jdtls is available")
    else
      table.insert(lines, "jdtls not found in PATH")
      table.insert(lines, "Install Eclipse JDT Language Server")
    end

    local root = vim.fs.root(bufnr, { "build.gradle", "build.gradle.kts", "pom.xml", "settings.gradle", "settings.gradle.kts", ".git" })
    table.insert(lines, "Detected project root: " .. (root or "none"))

    if vim.fn.executable("java") == 1 then
      table.insert(lines, "Java runtime available")
    else
      table.insert(lines, "Java runtime not found")
    end
  end
  table.insert(lines, "========================")

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

function M.setup()
  vim.api.nvim_create_user_command("YodaLspInfo", show_lsp_clients, { desc = "Show LSP clients for current buffer" })
  vim.api.nvim_create_user_command("YodaHelmDebug", debug_helm_setup, { desc = "Debug Helm template detection and LSP" })
  vim.api.nvim_create_user_command("LSPStatus", lsp_status, { desc = "Show comprehensive LSP status" })
  vim.api.nvim_create_user_command("LSPRestart", function()
    vim.cmd("lsp restart *")
    vim.notify("LSP clients restarted", vim.log.levels.INFO)
  end, { desc = "Restart LSP clients" })
  vim.api.nvim_create_user_command("LSPInfo", function()
    vim.cmd("lsp")
  end, { desc = "Show LSP information" })
  vim.api.nvim_create_user_command("PythonLSPDebug", python_lsp_debug, { desc = "Debug Python LSP configuration" })
  vim.api.nvim_create_user_command("GroovyLSPDebug", groovy_lsp_debug, { desc = "Debug Groovy/Java LSP configuration" })

  -- jdtls commands — registered once here rather than in LspAttach to avoid
  -- errors from re-creating global commands on every buffer attach.
  local notify = require("yoda-adapters.notification")
  vim.api.nvim_create_user_command("JdtlsQuiet", function()
    vim.lsp.codelens.run()
    notify.notify("JDTLS quiet mode toggled", "info")
  end, { desc = "Toggle JDTLS quiet mode" })

  vim.api.nvim_create_user_command("JdtlsBuild", function()
    vim.lsp.buf.execute_command({
      command = "java.project.buildWorkspace",
      arguments = { true },
    })
    notify.notify("JDTLS build initiated", "info")
  end, { desc = "Force JDTLS build" })
end

return M
