-- lua/yoda/lsp.lua
-- LSP configuration

local logger = require("yoda.logging.logger")

-- Configure diagnostics to disable underlines
vim.diagnostic.config({
  underline = false,  -- Disable the white underlines
  virtual_text = true, -- Keep virtual text (error messages)
  signs = true,       -- Keep signs in the gutter
  update_in_insert = false,
  severity_sort = true,
})

-- Function to configure Python LSP with virtual environment
local function configure_python_lsp()
  local venv_ok, venv = pcall(require, "yoda.functions")
  if venv_ok then
    local venvs = venv.find_virtual_envs()
    if #venvs > 0 then
      local venv_path = venvs[1]
      local python_path = venv.find_python_interpreter(venv_path)
      
      -- Update basedpyright configuration properly
      if vim.lsp.config.basedpyright then
        vim.lsp.config.basedpyright.settings = vim.lsp.config.basedpyright.settings or {}
        vim.lsp.config.basedpyright.settings.basedpyright = vim.lsp.config.basedpyright.settings.basedpyright or {}
        vim.lsp.config.basedpyright.settings.basedpyright.pythonPath = python_path
      end
      
      -- Also update any active clients
      local clients = vim.lsp.get_clients({ name = "basedpyright" })
      for _, client in ipairs(clients) do
        if client.config and client.config.settings then
          client.config.settings.basedpyright = client.config.settings.basedpyright or {}
          client.config.settings.basedpyright.pythonPath = python_path
        end
      end
      
      -- Notify user
      vim.notify("Python LSP configured with virtual environment: " .. python_path, vim.log.levels.INFO)
      
      return true
    end
  end
  return false
end

-- Filetypes where LSP should not attach
-- These are typically plain text or special buffers where LSP provides no value
-- and can cause significant lag
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
  "markdown", -- Optional: remove if you want LSP in markdown
  "alpha", -- Dashboard
  "terminal", -- Terminal buffers
  "toggleterm",
  "qf", -- Quickfix lists
  "loclist", -- Location lists
}

-- Lua LSP
vim.lsp.config.lua_ls = {
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
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
}

-- Go LSP
vim.lsp.config.gopls = {
  filetypes = { "go", "gomod", "gowork" },
}

-- TypeScript/JavaScript LSP (enhanced)
vim.lsp.config.ts_ls = {
  filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      suggest = {
        completeFunctionCalls = true,
      },
      preferences = {
        importModuleSpecifier = "non-relative",
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
  init_options = {
    preferences = {
      disableSuggestions = false,
    },
  },
}

-- Python LSP (basedpyright)
vim.lsp.config.basedpyright = {
  filetypes = { "python" },
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic", -- "off", "basic", "strict"
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly", -- Changed from "workspace" for better performance
        autoImportCompletions = true,
      },
      pythonPath = nil, -- Will be set by configure_python_lsp() when virtual environment is detected
    },
  },
}

-- C# LSP (OmniSharp - more reliable than csharp_ls)
vim.lsp.config.omnisharp = {
  filetypes = { "cs", "csx", "cake" },
  settings = {
    OmniSharp = {
      enableRoslynAnalyzers = true,
      enableEditorConfigSupport = true,
      enableImportCompletion = true,
      enableAsyncCompletion = true,
      enableSnippets = true,
      organizeImportsOnFormat = true,
      enableMsBuildLoadProjectsOnDemand = false,
      sdkPath = nil, -- Will be auto-detected
      sdkVersion = nil, -- Will be auto-detected
      monoPath = nil, -- Will be auto-detected
      dotNetCliPath = nil, -- Will be auto-detected
      useModernNet = true,
      projectLoadTimeout = 60,
      maxProjectResults = 250,
      maxProjectFileResults = 50,
      enableSemanticHighlighting = true,
      enableHighlightRelated = true,
      enableHighlightTypedSymbols = true,
      enableInlayHints = true,
      enableInlayHintsForParameters = true,
      enableInlayHintsForLiteralParameters = true,
      enableInlayHintsForIndexerParameters = true,
      enableInlayHintsForObjectCreationParameters = true,
      enableInlayHintsForOtherParameters = true,
      suppressInlayHintsForParametersThatDifferOnlyBySuffix = false,
      suppressInlayHintsForParametersThatMatchMethodIntent = false,
      suppressInlayHintsForParametersThatMatchArgumentName = false,
      enableInlayHintsForTypes = true,
      enableInlayHintsForImplicitVariableTypes = true,
      enableInlayHintsForLambdaParameterTypes = true,
      enableInlayHintsForImplicitObjectCreation = true,
    },
  },
}

-- Rust LSP
-- Note: rust_analyzer is managed by rust-tools.nvim plugin
-- See lua/plugins.lua RUST DEVELOPMENT section for configuration
-- rust-tools provides enhanced features like inlay hints, hover actions, and DAP integration

-- Disable stylua as LSP server (it's a formatter, not a language server)
-- stylua is not enabled as an LSP server

-- Enable the language servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("basedpyright")
vim.lsp.enable("omnisharp")
-- rust_analyzer is handled by rust-tools.nvim, not enabled here

-- Setup keymaps for LSP
local function on_attach(client, bufnr)
  -- Performance optimization: Disable semantic tokens to reduce lag
  -- Semantic tokens cause "Processing full semantic tokens" messages and slow typing
  if client.server_capabilities.semanticTokensProvider then
    client.server_capabilities.semanticTokensProvider = nil
  end

  local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- LSP keymaps
  map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
  map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
  map("n", "K", vim.lsp.buf.hover, { desc = "Show hover" })
  map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
  map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help" })
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
  map("n", "<leader>wl", function()
    logger.set_strategy("console")
    logger.info("Workspace folders", { folders = vim.lsp.buf.list_workspace_folders() })
  end, { desc = "List workspace folders" })
  map("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
  map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
  map("n", "gr", vim.lsp.buf.references, { desc = "Show references" })
  map("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format" })
end

-- Set up LSP keymaps for all LSP clients (except skipped filetypes)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(args)
    local bufnr = args.buf
    local filetype = vim.bo[bufnr].filetype

    -- Skip LSP keymaps for plain text and git-related filetypes
    for _, skip_ft in ipairs(LSP_SKIP_FILETYPES) do
      if filetype == skip_ft then
        logger.set_strategy("console")
        logger.debug("Skipping LSP attach for filetype", { filetype = filetype, buffer = bufnr })
        return -- Don't attach LSP keymaps
      end
    end

    -- Attach LSP keymaps for code filetypes
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      on_attach(client, bufnr)
    end
  end,
})

-- Performance debugging command
vim.api.nvim_create_user_command("LSPPerformance", function()
  local clients = vim.lsp.get_clients()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype

  print("=== LSP Performance Debug ===")
  print("Current filetype:", filetype)
  print("Active LSP clients:", #clients)

  for _, client in ipairs(clients) do
    local attached = vim.lsp.buf_is_attached(bufnr, client.id)
    local semantic_tokens = client.server_capabilities.semanticTokensProvider ~= nil
    print(string.format("  - %s: attached=%s, semantic_tokens=%s", client.name, attached, semantic_tokens))
  end

  -- Check if current filetype is in skip list
  local is_skipped = false
  for _, skip_ft in ipairs(LSP_SKIP_FILETYPES) do
    if filetype == skip_ft then
      is_skipped = true
      break
    end
  end

  print("Filetype in skip list:", is_skipped)
  print("=============================")
end, { desc = "Debug LSP performance for current buffer" })

-- Markdown performance debugging command
vim.api.nvim_create_user_command("MarkdownPerformance", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype

  print("=== Markdown Performance Debug ===")
  print("Current filetype:", filetype)
  print("Spell enabled:", vim.wo.spell)
  print("Conceal level:", vim.wo.conceallevel)
  print("Fold method:", vim.wo.foldmethod)
  print("Update time:", vim.bo.updatetime)
  print("Spell language:", vim.bo.spelllang)

  -- Check treesitter status
  local ts_ok, ts = pcall(require, "nvim-treesitter.configs")
  if ts_ok then
    local config = ts.get_config()
    print("Treesitter markdown enabled:", config.markdown and config.markdown.enable or "not configured")
  end

  print("================================")
end, { desc = "Debug markdown performance settings" })

-- Emergency markdown performance mode
vim.api.nvim_create_user_command("MarkdownTurboMode", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype

  if filetype ~= "markdown" then
    print("❌ This command only works in markdown files")
    return
  end

  print("🚀 ENABLING TURBO MODE FOR MARKDOWN...")

  -- Disable EVERYTHING that could cause lag
  vim.opt_local.spell = false
  vim.opt_local.conceallevel = 0
  vim.opt_local.foldmethod = "manual"
  vim.opt_local.updatetime = 4000
  vim.opt_local.timeoutlen = 1000
  vim.opt_local.ttimeoutlen = 0
  vim.opt_local.lazyredraw = true
  vim.opt_local.synmaxcol = 200
  vim.opt_local.maxmempattern = 1000
  vim.opt_local.relativenumber = false
  vim.opt_local.number = false
  vim.opt_local.cursorline = false
  vim.opt_local.cursorcolumn = false
  vim.opt_local.colorcolumn = ""
  vim.opt_local.complete = ""
  vim.opt_local.completeopt = ""
  vim.opt_local.statusline = ""

  -- Disable treesitter
  vim.cmd("silent! TSDisable markdown")
  vim.cmd("silent! TSDisableAll")

  -- Disable diagnostics
  vim.diagnostic.disable()

  -- Disable ALL autocmds that could cause lag
  vim.cmd("autocmd! TextChanged,TextChangedI,TextChangedP <buffer>")
  vim.cmd("autocmd! InsertEnter,InsertLeave <buffer>")
  vim.cmd("autocmd! CursorMoved,CursorMovedI <buffer>")
  vim.cmd("autocmd! BufEnter,BufWritePost <buffer>")
  vim.cmd("autocmd! LspAttach <buffer>")

  -- Disable copilot and linting
  vim.cmd("silent! Copilot disable")
  vim.cmd("silent! LintDisable")

  -- Disable all plugin loading
  vim.opt_local.eventignore = "all"

  print("✅ TURBO MODE ENABLED - ZERO DELAY TYPING")
  print("📝 ALL autocmds, plugins, and features disabled")
  print("🚀 This should eliminate ALL typing delay")
end, { desc = "Enable maximum performance mode for markdown (disables all features)" })

-- Debug what's running on keystroke
vim.api.nvim_create_user_command("DebugKeystrokeEvents", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype

  print("=== KEYSTROKE EVENT DEBUG ===")
  print("Current filetype:", filetype)
  print("Buffer:", bufnr)

  -- Check active autocmds
  print("\n--- Active Autocmds ---")
  vim.cmd("autocmd TextChanged,TextChangedI,TextChangedP,InsertEnter,InsertLeave,CursorMoved,CursorMovedI")

  -- Check LSP clients
  print("\n--- LSP Clients ---")
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    local attached = vim.lsp.buf_is_attached(bufnr, client.id)
    print(string.format("  - %s: attached=%s", client.name, attached))
  end

  -- Check plugins
  print("\n--- Plugin Status ---")
  local plugins = {
    "copilot",
    "treesitter",
    "lint",
    "diagnostic",
  }

  for _, plugin in ipairs(plugins) do
    local ok = pcall(require, plugin)
    print(string.format("  - %s: %s", plugin, ok and "loaded" or "not loaded"))
  end

  print("\n--- Performance Settings ---")
  print("updatetime:", vim.bo.updatetime)
  print("timeoutlen:", vim.bo.timeoutlen)
  print("ttimeoutlen:", vim.bo.ttimeoutlen)
  print("lazyredraw:", vim.wo.lazyredraw)
  print("synmaxcol:", vim.bo.synmaxcol)
  print("maxmempattern:", vim.bo.maxmempattern)
  print("eventignore:", vim.bo.eventignore)

  print("==========================")
end, { desc = "Debug what events are running on keystroke" })

-- Command to configure Python LSP with virtual environment
vim.api.nvim_create_user_command("ConfigurePythonLSP", function()
  if configure_python_lsp() then
    -- Restart LSP to apply changes
    vim.cmd("LspRestart")
  else
    vim.notify("No virtual environment found", vim.log.levels.WARN)
  end
end, { desc = "Configure Python LSP with virtual environment" })

-- Auto-configure Python LSP when opening Python files
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.py",
  callback = function()
    -- Only configure if LSP is not already configured with a venv
    local clients = vim.lsp.get_clients({ name = "basedpyright" })
    if #clients > 0 then
      local client = clients[1]
      local current_python_path = client.config.settings and 
                                 client.config.settings.basedpyright and 
                                 client.config.settings.basedpyright.pythonPath
      
      if not current_python_path then
        configure_python_lsp()
      end
    else
      -- No clients yet, try to configure anyway
      configure_python_lsp()
    end
  end,
})
