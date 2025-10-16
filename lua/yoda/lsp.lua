-- lua/yoda/lsp.lua
-- Modern LSP setup using vim.lsp.config (Neovim 0.11+)

local M = {}

--- Setup LSP servers using vim.lsp.config
function M.setup()
  -- Setup completion capabilities
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Add nvim-cmp capabilities if available
  local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if cmp_ok then
    capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
  end

  -- Helper function to safely setup LSP servers using vim.lsp.config
  local function safe_setup(name, config)
    local success, err = pcall(function()
      vim.lsp.config(name, config)
    end)
    if not success then
      vim.notify(string.format("Failed to configure LSP server '%s': %s", name, err), vim.log.levels.WARN)
      return false
    end
    return true
  end

  -- Go/gopls setup
  safe_setup("gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    capabilities = capabilities,
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
          shadow = false,
          fieldalignment = false,
          nilness = true,
          useany = true,
          unusedwrite = true,
          ST1003 = false,
        },
        staticcheck = true,
        gofumpt = true,
        codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          run_govulncheck = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        usePlaceholders = true,
        completeUnimported = true,
        directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
        semanticTokens = true,
        buildFlags = { "-tags=integration" },
      },
    },
    init_options = {
      usePlaceholders = true,
    },
  })

  -- Lua/lua_ls setup
  safe_setup("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim", "describe", "it", "before_each", "after_each" },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })

  -- TypeScript setup
  safe_setup("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
    capabilities = capabilities,
  })

  -- Python setup
  safe_setup("basedpyright", {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
    capabilities = capabilities,
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  })

  -- YAML setup
  safe_setup("yamlls", {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
    root_markers = { ".git" },
    capabilities = capabilities,
    settings = {
      yaml = {
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          ["https://json.schemastore.org/docker-compose.json"] = "/docker-compose*.yml",
        },
      },
    },
  })

  -- C# setup
  safe_setup("omnisharp", {
    cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
    filetypes = { "cs", "vb" },
    root_markers = { "*.sln", "*.csproj", "omnisharp.json", "function.json", ".git" },
    capabilities = capabilities,
  })

  -- Helm setup
  safe_setup("helm_ls", {
    cmd = { "helm_ls", "serve" },
    filetypes = { "helm" },
    root_markers = { "Chart.yaml", ".git" },
    capabilities = capabilities,
  })

  -- Setup LSP keymaps on attach
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("YodaLspConfig", {}),
    callback = function(event)
      local opts = { buffer = event.buf }

      -- Keymaps
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

      -- Enable inlay hints if available
      if vim.lsp.inlay_hint then
        vim.keymap.set("n", "<leader>th", function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, opts)
      end
    end,
  })

  -- Diagnostic configuration
  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = "always",
    },
  })

  -- Diagnostic signs
  local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  -- Setup debug commands
  M._setup_debug_commands()
end

--- Setup debug commands for LSP troubleshooting
--- @private
function M._setup_debug_commands()
  -- LSP Status command
  vim.api.nvim_create_user_command("LSPStatus", function()
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

    -- Show all running LSP servers
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

    -- Show LSP server configurations
    print("--- Available LSP Servers ---")
    local available_servers = {
      "gopls",
      "lua_ls",
      "ts_ls",
      "basedpyright",
      "yamlls",
      "omnisharp",
      "helm_ls",
    }
    for _, server in ipairs(available_servers) do
      local cmd_available = vim.fn.executable(server) == 1
      print(string.format("  %s: %s", server, cmd_available and "✅ available" or "❌ not found"))
    end

    print("========================")
  end, { desc = "Show comprehensive LSP status" })

  -- LSP Restart command
  vim.api.nvim_create_user_command("LSPRestart", function()
    vim.cmd("LspRestart")
    print("LSP clients restarted")
  end, { desc = "Restart LSP clients" })

  -- LSP Info command
  vim.api.nvim_create_user_command("LSPInfo", function()
    vim.cmd("LspInfo")
  end, { desc = "Show LSP information" })
end

return M
