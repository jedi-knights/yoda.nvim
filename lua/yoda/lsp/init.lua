-- lua/yoda/lsp/init.lua
-- LSP module initialization with dependency injection

local container = require("yoda.container")

-- Services
local lsp_manager_factory = require("yoda.lsp.services.lsp_manager")
local keymap_service_factory = require("yoda.lsp.services.keymap_service")
local config_builder_factory = require("yoda.lsp.services.config_builder")
local filetype_detector_factory = require("yoda.lsp.services.filetype_detector")
local python_venv_service_factory = require("yoda.lsp.services.python_venv_service")

-- Configurations
local lua_config = require("yoda.lsp.configs.lua_ls")
local typescript_config = require("yoda.lsp.configs.typescript")
local python_config = require("yoda.lsp.configs.python")
local yaml_config = require("yoda.lsp.configs.yaml")

local M = {}

--- Filetypes where LSP should not attach
local LSP_SKIP_FILETYPES = {
  "gitcommit",
  "gitrebase",
  "gitconfig",
  "NeogitCommitMessage",
  "NeogitPopup",
  "NeogitStatus",
  "fugitive",
  "fugitiveblame",
  "help",
  "markdown",
  "alpha",
  "terminal",
  "toggleterm",
  "qf",
  "loclist",
}

--- Initialize LSP system with dependency injection
function M.setup()
  -- Get dependencies from container
  local logger = container.get("logger")
  local notification = container.get("notification")
  local diagnostics = container.get("diagnostics")

  -- Configure diagnostics
  vim.diagnostic.config({
    underline = false,
    virtual_text = true,
    signs = true,
    update_in_insert = false,
    severity_sort = true,
  })

  -- Create services
  local lsp_manager = lsp_manager_factory.new(logger, diagnostics)
  local keymap_service = keymap_service_factory.new(logger, LSP_SKIP_FILETYPES)
  local config_builder = config_builder_factory.new(logger)
  local filetype_detector = filetype_detector_factory.new(logger)
  local python_venv_service = python_venv_service_factory.new(logger, notification)

  -- Register services in container for other modules to use
  container.register("lsp_manager", lsp_manager)
  container.register("lsp_keymap_service", keymap_service)
  container.register("lsp_config_builder", config_builder)
  container.register("filetype_detector", filetype_detector)
  container.register("python_venv_service", python_venv_service)

  -- Setup server configurations
  M._setup_server_configurations(lsp_manager, config_builder)

  -- Setup lazy loading
  M._setup_lazy_loading(lsp_manager)

  -- Setup LSP keymaps
  M._setup_lsp_keymaps(keymap_service, logger)

  -- Setup filetype detection
  filetype_detector:setup_yaml_helm_detection()

  -- Setup Python virtual environment
  python_venv_service:setup_auto_configure()
  python_venv_service:create_configure_command()

  -- Create debug commands
  M._create_debug_commands(lsp_manager, keymap_service, logger)

  logger.info("LSP system initialized successfully")
end

--- Setup server configurations
--- @param lsp_manager table LSP manager service
--- @param config_builder table Config builder service
--- @private
function M._setup_server_configurations(lsp_manager, config_builder)
  local server_configs = {
    { name = "lua_ls", factory = lua_config.create_config },
    { name = "ts_ls", factory = typescript_config.create_config },
    { name = "basedpyright", factory = python_config.create_config },
    { name = "yamlls", factory = yaml_config.create_yaml_config },
    { name = "helm_ls", factory = yaml_config.create_helm_config },
    {
      name = "gopls",
      factory = function(builder)
        return builder:with_filetypes({ "go", "gomod", "gowork" }):build()
      end,
    },
    {
      name = "omnisharp",
      factory = function(builder)
        return builder
          :with_filetypes({ "cs", "csx", "cake" })
          :with_settings({
            OmniSharp = {
              enableRoslynAnalyzers = true,
              enableEditorConfigSupport = true,
              enableImportCompletion = true,
              useModernNet = true,
            },
          })
          :build()
      end,
    },
  }

  for _, config in ipairs(server_configs) do
    local server_config = config.factory(config_builder)
    vim.lsp.config[config.name] = server_config
    lsp_manager:register_server(config.name, server_config)
  end
end

--- Setup lazy loading for LSP servers
--- @param lsp_manager table LSP manager service
--- @private
function M._setup_lazy_loading(lsp_manager)
  local server_filetypes = {
    { server = "lua_ls", filetypes = { "lua" } },
    { server = "gopls", filetypes = { "go", "gomod", "gowork" } },
    { server = "ts_ls", filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" } },
    { server = "basedpyright", filetypes = { "python" } },
    { server = "omnisharp", filetypes = { "cs", "csx", "cake" } },
    { server = "yamlls", filetypes = { "yaml" } },
    { server = "helm_ls", filetypes = { "helm" } },
  }

  for _, config in ipairs(server_filetypes) do
    lsp_manager:setup_lazy_loading(config.server, config.filetypes)
  end
end

--- Setup LSP keymaps
--- @param keymap_service table Keymap service
--- @param logger table Logger service
--- @private
function M._setup_lsp_keymaps(keymap_service, logger)
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if client then
        keymap_service:setup_keymaps(client, bufnr)
      end
    end,
    desc = "Setup LSP keymaps on attach",
  })
end

--- Create debug commands
--- @param lsp_manager table LSP manager service
--- @param keymap_service table Keymap service
--- @param logger table Logger service
--- @private
function M._create_debug_commands(lsp_manager, keymap_service, logger)
  -- LSP Status command
  vim.api.nvim_create_user_command("LSPStatus", function()
    local clients = vim.lsp.get_clients()
    local bufnr = vim.api.nvim_get_current_buf()
    local filetype = vim.bo[bufnr].filetype

    print("=== Smart LSP Status Debug ===")
    print("Current buffer:", bufnr)
    print("Current filetype:", filetype)
    print("Total active LSP clients:", #clients)
    print("")

    -- Show all running LSP servers
    print("--- Running LSP Servers ---")
    for _, client in ipairs(clients) do
      local attached = vim.lsp.buf_is_attached(bufnr, client.id)
      print(string.format("  %s: attached=%s", client.name, attached))
    end
    print("")

    -- Show enabled servers
    print("--- Enabled Servers ---")
    local enabled_servers = lsp_manager:get_enabled_servers()
    for server, enabled in pairs(enabled_servers) do
      print(string.format("  %s: %s", server, enabled and "✅ enabled" or "❌ not enabled"))
    end
    print("")

    -- Show filetype skip status
    local is_skipped = keymap_service:should_skip_filetype(filetype)
    print("--- Current Buffer Analysis ---")
    print("Filetype in skip list:", is_skipped and "✅ YES (LSP keymaps skipped)" or "❌ NO (LSP keymaps active)")
    print("===============================")
  end, { desc = "Show comprehensive LSP status" })

  -- LSP Mapping command
  vim.api.nvim_create_user_command("LSPMapping", function()
    print("=== LSP Server to Filetype Mapping ===")
    print("")

    local enabled_servers = lsp_manager:get_enabled_servers()
    for server, _ in pairs(enabled_servers) do
      local config = lsp_manager:get_server_config(server)
      if config and config.filetypes then
        print(string.format("📋 %s:", server))
        print("   Filetypes: " .. table.concat(config.filetypes, ", "))
        print("   Status: " .. (enabled_servers[server] and "✅ Enabled" or "⏱️ Will enable on demand"))
        print("")
      end
    end

    print("--- Skipped Filetypes (No LSP) ---")
    local skip_filetypes = keymap_service:get_skip_filetypes()
    print("These filetypes will never have LSP attached:")
    print(table.concat(skip_filetypes, ", "))
    print("=====================================")
  end, { desc = "Show LSP server to filetype mapping" })
end

return M
