-- lua/yoda/lsp.lua
-- Modern LSP setup using vim.lsp.config (Neovim 0.11+)

local M = {}
local lsp_perf = require("yoda.lsp_performance")
local notify = require("yoda.adapters.notification")

--- Setup LSP servers using vim.lsp.config
function M.setup()
  -- Disable pyright completely (we use basedpyright instead)
  -- This prevents it from even trying to start
  vim.lsp.config("pyright", {
    enabled = false,
    autostart = false,
  })

  -- Setup completion capabilities
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Add nvim-cmp capabilities if available
  local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if cmp_ok then
    capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
  end

  -- Global LSP handler optimizations for responsiveness
  local handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
    ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.handlers["textDocument/publishDiagnostics"], {
      update_in_insert = false,
      virtual_text = { spacing = 4, prefix = "●" },
    }),
  }

  -- Apply handlers globally
  for method, handler in pairs(handlers) do
    vim.lsp.handlers[method] = handler
  end

  -- Helper function to safely setup LSP servers using vim.lsp.config
  local function safe_setup(name, config)
    local success, err = pcall(function()
      vim.lsp.config(name, config)
    end)
    if not success then
      notify.notify(string.format("Failed to configure LSP server '%s': %s", name, err), "warn")
      return false
    end
    return true
  end

  -- Go/gopls setup
  safe_setup("gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_dir = function(fname)
      return vim.fs.root(fname, { "go.work", "go.mod", ".git" })
    end,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 300,
    },
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
          assignVariableTypes = false,
          compositeLiteralFields = false,
          compositeLiteralTypes = false,
          constantValues = false,
          functionTypeParameters = false,
          parameterNames = false,
          rangeVariableTypes = false,
        },
        usePlaceholders = true,
        completeUnimported = true,
        directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
        semanticTokens = false,
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
    root_dir = function(fname)
      return vim.fs.root(fname, { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" })
    end,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 300,
    },
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim", "describe", "it", "before_each", "after_each" },
        },
        workspace = {
          library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
            "${3rd}/luv/library",
          }),
          checkThirdParty = false,
        },
        completion = {
          callSnippet = "Replace",
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
    root_dir = function(fname)
      return vim.fs.root(fname, { "tsconfig.json", "package.json", "jsconfig.json", ".git" })
    end,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 300,
    },
  })

  -- Python setup with virtual environment support
  -- Disable document highlight capability
  local python_capabilities = vim.deepcopy(capabilities)
  python_capabilities.textDocument.documentHighlight = nil

  safe_setup("basedpyright", {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_dir = function(fname)
      return vim.fs.root(fname, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" })
    end,
    capabilities = python_capabilities,
    flags = {
      debounce_text_changes = 500,
    },
    on_init = function(client)
      -- Disable document highlight immediately when server initializes
      if client.server_capabilities then
        client.server_capabilities.documentHighlightProvider = false
      end
    end,
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          autoImportCompletions = true,
          diagnosticMode = "openFilesOnly",
          -- Include common Python project patterns
          include = { "**/*.py" },
          exclude = {
            "**/node_modules",
            "**/__pycache__",
            ".git",
            "**/*.pyc",
            "**/venv",
            "**/.venv",
            "**/env",
            "**/site-packages",
          },
        },
      },
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly",
          typeCheckingMode = "basic",
        },
      },
    },
    on_new_config = function(config, root_dir)
      local function join_path(...)
        return table.concat({ ... }, "/")
      end

      if root_dir then
        local python_paths = { root_dir }
        local src_dir = join_path(root_dir, "src")

        if vim.fn.isdirectory(src_dir) == 1 then
          table.insert(python_paths, src_dir)
        end

        local project_name = vim.fn.fnamemodify(root_dir, ":t")
        if project_name:match("sun%-qa%-python%-tools") or vim.fn.isdirectory(join_path(root_dir, "sun_qa_python_tools")) == 1 then
          local package_dirs = {
            join_path(root_dir, "sun_qa_python_tools"),
            join_path(root_dir, "src", "sun_qa_python_tools"),
          }

          for _, pkg_dir in ipairs(package_dirs) do
            if vim.fn.isdirectory(pkg_dir) == 1 then
              table.insert(python_paths, pkg_dir)
            end
          end
        end

        config.settings.basedpyright.analysis.extraPaths = python_paths
        config.settings.python.analysis.extraPaths = python_paths
      end

      vim.schedule(function()
        local venv_start_time = vim.loop.hrtime()
        local possible_venv_paths = {
          join_path(root_dir, ".venv", "bin", "python"),
          join_path(root_dir, "venv", "bin", "python"),
          join_path(root_dir, "env", "bin", "python"),
          join_path(vim.fn.getcwd(), ".venv", "bin", "python"),
          join_path(vim.fn.getcwd(), "venv", "bin", "python"),
          join_path(vim.fn.getcwd(), "env", "bin", "python"),
        }

        local found_venv = false
        for _, venv_python in ipairs(possible_venv_paths) do
          if vim.fn.executable(venv_python) == 1 then
            local clients = vim.lsp.get_clients({ name = "basedpyright" })
            for _, client in ipairs(clients) do
              if client.config.root_dir == root_dir then
                client.config.settings.basedpyright.analysis.pythonPath = venv_python
                client.config.settings.python.pythonPath = venv_python
                client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                notify.notify(string.format("Python LSP: Using venv at %s", venv_python), "info")
              end
            end
            found_venv = true
            lsp_perf.track_venv_detection(root_dir, venv_start_time, true)
            return
          end
        end

        if not found_venv then
          lsp_perf.track_venv_detection(root_dir, venv_start_time, false)
          notify.notify("Python LSP: No venv found, using system Python", "info")
        end
      end)
    end,
  })

  -- YAML setup
  safe_setup("yamlls", {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
    root_dir = function(fname)
      return vim.fs.root(fname, { ".git" })
    end,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 300,
    },
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
    root_dir = function(fname)
      return vim.fs.root(fname, { "*.sln", "*.csproj", "omnisharp.json", "function.json", ".git" })
    end,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 300,
    },
  })

  -- Helm setup
  safe_setup("helm_ls", {
    cmd = { "helm_ls", "serve" },
    filetypes = { "helm" },
    root_dir = function(fname)
      return vim.fs.root(fname, { "Chart.yaml", ".git" })
    end,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 300,
    },
  })

  -- Java setup (also works for Jenkinsfiles/Groovy)
  safe_setup("jdtls", {
    cmd = { "jdtls" },
    filetypes = { "java", "groovy" },
    root_dir = function(fname)
      return vim.fs.root(fname, { "build.gradle", "build.gradle.kts", "pom.xml", "settings.gradle", "settings.gradle.kts", ".git" })
    end,
    capabilities = capabilities,
    settings = {
      java = {
        configuration = {
          runtimes = {},
        },
        signatureHelp = {
          enabled = true,
        },
        contentProvider = {
          preferred = "fernflower",
        },
        completion = {
          favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.junit.Assert.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*",
          },
          importOrder = {
            "java",
            "javax",
            "com",
            "org",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        codeGeneration = {
          toString = {
            template = "${member.name()}=${member.value()}",
          },
          useBlocks = true,
        },
      },
    },
    on_attach = function(client, bufnr)
      -- Disable document formatting capabilities
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false

      local function jdtls_setup_commands()
        vim.api.nvim_create_user_command("JdtlsQuiet", function()
          vim.lsp.codelens.run()
          notify.notify("JDTLS quiet mode toggled", "info")
        end, {
          desc = "Toggle JDTLS quiet mode",
        })

        vim.api.nvim_create_user_command("JdtlsBuild", function()
          vim.lsp.buf.execute_command({
            command = "java.project.buildWorkspace",
            arguments = { true },
          })
          notify.notify("JDTLS build initiated", "info")
        end, {
          desc = "Force JDTLS build",
        })
      end

      jdtls_setup_commands()
    end,
    flags = {
      debounce_text_changes = 500,
    },
  })

  -- Markdown setup
  safe_setup("marksman", {
    cmd = { "marksman", "server" },
    filetypes = { "markdown", "markdown.mdx" },
    root_dir = function(fname)
      return vim.fs.root(fname, { ".git", ".marksman.toml" })
    end,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 300,
    },
  })

  -- Setup LSP keymaps on attach with debounced UI updates
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("YodaLspConfig", { clear = true }),
    callback = function(event)
      local opts = { buffer = event.buf }

      -- Defer UI-affecting operations to prevent flickering
      vim.schedule(function()
        -- Keymaps
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "K", function()
          -- Try LSP hover first, fallback to help
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients > 0 then
            vim.lsp.buf.hover()
          else
            -- Fallback to help for the word under cursor
            local word = vim.fn.expand("<cword>")
            if word ~= "" then
              pcall(vim.cmd, "help " .. word)
            end
          end
        end, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

        -- Toggle inlay hints
        vim.keymap.set("n", "<leader>th", function()
          -- Check if inlay hints are supported and enabled
          local clients = vim.lsp.get_clients({ bufnr = event.buf })
          for _, client in ipairs(clients) do
            if client.supports_method("textDocument/inlayHint") then
              local is_enabled = vim.lsp.inlay_hint.is_enabled(event.buf)
              vim.lsp.inlay_hint.enable(not is_enabled, { bufnr = event.buf })
              if is_enabled then
                notify.notify("Inlay hints disabled", "info")
              else
                notify.notify("Inlay hints enabled", "info")
              end
              return
            end
          end
          notify.notify("Inlay hints not supported by any active LSP server", "warn")
        end, { desc = "Toggle Inlay Hints" })

        -- Enable inlay hints if available
        if vim.lsp.inlay_hint then
          vim.keymap.set("n", "<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, opts)
        end
      end)
    end,
  })

  -- Diagnostic configuration (optimized for performance)
  vim.diagnostic.config({
    virtual_text = {
      spacing = 4,
      prefix = "●",
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "󰅚 ",
        [vim.diagnostic.severity.WARN] = "󰀪 ",
        [vim.diagnostic.severity.INFO] = " ",
        [vim.diagnostic.severity.HINT] = "󰌶 ",
      },
      texthl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = "always",
    },
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("YodaLspOptimizations", { clear = true }),
    callback = function(args)
      local start_time = vim.loop.hrtime()
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        -- Silently stop pyright if it somehow still attaches
        if client.name == "pyright" then
          vim.schedule(function()
            vim.lsp.stop_client(client.id, true) -- true = force stop
          end)
          return
        end

        -- Disable semantic tokens for all LSP servers (major performance win)
        client.server_capabilities.semanticTokensProvider = nil

        -- Python-specific optimizations
        if client.name == "basedpyright" then
          -- Aggressively disable document highlight to prevent cursor movement updates
          client.server_capabilities.documentHighlightProvider = false

          -- Keep it disabled - some servers re-enable it
          local timer = vim.loop.new_timer()
          if timer then
            local timer_active = true

            timer:start(
              100,
              100,
              vim.schedule_wrap(function()
                if not timer_active then
                  return
                end
                if client.server_capabilities and client.server_capabilities.documentHighlightProvider then
                  client.server_capabilities.documentHighlightProvider = false
                end
              end)
            )

            -- Stop timer when client stops
            vim.api.nvim_create_autocmd("LspDetach", {
              callback = function(args)
                if args.data.client_id == client.id and timer_active then
                  timer_active = false
                  if timer and not timer:is_closing() then
                    timer:stop()
                    timer:close()
                  end
                end
              end,
            })
          end

          -- Also clear any existing document highlights
          vim.schedule(function()
            vim.lsp.buf.clear_references()
          end)

          -- Custom diagnostic handler with debouncing
          vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.handlers["textDocument/publishDiagnostics"], {
            update_in_insert = false,
            virtual_text = {
              spacing = 4,
              prefix = "●",
            },
          })
        end

        lsp_perf.track_lsp_attach(client.name, start_time)
      end
    end,
  })

  -- Auto-restart Python LSP when entering different Python projects
  local python_lsp_restart_timer = nil
  local autocmd_logger = require("yoda.autocmd_logger")

  vim.api.nvim_create_autocmd("DirChanged", {
    group = vim.api.nvim_create_augroup("YodaPythonLSPRestart", {}),
    callback = function()
      autocmd_logger.log("Python_LSP_Check", { event = "DirChanged" })

      -- Cancel any pending restart
      if python_lsp_restart_timer then
        autocmd_logger.log("Python_LSP_Cancel_Pending", {})
        vim.fn.timer_stop(python_lsp_restart_timer)
        python_lsp_restart_timer = nil
      end

      -- Debounce the restart check
      python_lsp_restart_timer = vim.fn.timer_start(1000, function()
        autocmd_logger.log("Python_LSP_Debounce_Fire", {})
        python_lsp_restart_timer = nil

        -- Only restart if we detect a new Python project root
        local current_root = vim.fs.root(0, { "pyproject.toml", "setup.py", "requirements.txt", ".git" })
        if current_root and vim.g.last_python_root ~= current_root then
          autocmd_logger.log("Python_LSP_Root_Change", { old = vim.g.last_python_root or "none", new = current_root })
          vim.g.last_python_root = current_root

          -- Schedule restart to avoid UI flicker
          vim.schedule(function()
            -- Restart Python LSP clients
            local clients = vim.lsp.get_clients({ name = "basedpyright" })
            if #clients > 0 then
              autocmd_logger.log("Python_LSP_Restart", { client_count = #clients, root = current_root })
              lsp_perf.track_lsp_restart("basedpyright")
              notify.notify(string.format("Restarting Python LSP for project: %s", current_root), "info")
              for _, client in ipairs(clients) do
                client.stop()
              end
            else
              autocmd_logger.log("Python_LSP_No_Clients", { root = current_root })
            end
          end)
        else
          autocmd_logger.log("Python_LSP_Same_Root", { root = current_root or "none" })
        end
      end)
    end,
  })

  local debug_commands_loaded = false
  local function ensure_debug_commands()
    if debug_commands_loaded then
      return
    end

    debug_commands_loaded = true
    M._setup_debug_commands()
  end

  -- DISABLED: CmdlineEnter causing crashes in Neovim 0.11.4
  -- vim.api.nvim_create_autocmd("CmdlineEnter", {
  --   pattern = ":",
  --   once = true,
  --   callback = function()
  --     vim.schedule(ensure_debug_commands)
  --   end,
  -- })

  vim.api.nvim_create_autocmd("LspAttach", {
    once = true,
    callback = function()
      vim.schedule(ensure_debug_commands)
    end,
  })

  lsp_perf.setup_commands()
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
      "jdtls",
      "marksman",
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

  -- Python-specific LSP debugging command
  vim.api.nvim_create_user_command("PythonLSPDebug", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "basedpyright" })

    print("=== Python LSP Debug ===")
    print("Buffer filetype:", vim.bo[bufnr].filetype)
    print("Python LSP clients:", #clients)

    if #clients > 0 then
      local client = clients[1]
      print("Client name:", client.name)
      print("Client ID:", client.id)
      print("Root dir:", client.config.root_dir or "unknown")

      if client.config.settings and client.config.settings.basedpyright then
        local settings = client.config.settings.basedpyright.analysis
        print("Python path:", settings.pythonPath or "default")
        print("Extra paths:", vim.inspect(settings.extraPaths or {}))
        print("Auto search paths:", settings.autoSearchPaths or false)
        print("Diagnostic mode:", settings.diagnosticMode or "default")
      end
    else
      print("No Python LSP clients attached!")

      -- Check if basedpyright is available
      if vim.fn.executable("basedpyright-langserver") == 1 then
        print("✅ basedpyright-langserver is available")
      else
        print("❌ basedpyright-langserver not found in PATH")
        print("Install with: npm install -g basedpyright")
      end

      -- Check project root detection
      local root = vim.fs.root(bufnr, { "pyproject.toml", "setup.py", "requirements.txt", ".git" })
      print("Detected project root:", root or "none")

      -- Check for virtual environments
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
  end, { desc = "Debug Python LSP configuration" })

  -- Groovy/Java LSP debugging command
  vim.api.nvim_create_user_command("GroovyLSPDebug", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })

    print("=== Groovy/Java LSP Debug ===")
    print("Buffer filetype:", vim.bo[bufnr].filetype)
    print("JDTLS clients:", #clients)

    if #clients > 0 then
      local client = clients[1]
      print("Client name:", client.name)
      print("Client ID:", client.id)
      print("Root dir:", client.config.root_dir or "unknown")
      print("Status:", client.is_stopped() and "stopped" or "running")

      -- Show workspace information
      if client.config.settings and client.config.settings.java then
        print("Java settings configured: ✅")
      end

      -- Check memory usage (if available)
      local stats = vim.lsp.get_client_by_id(client.id)
      if stats then
        print("Client attached buffers:", #vim.lsp.get_buffers_by_client_id(client.id))
      end
    else
      print("No JDTLS clients attached!")

      -- Check if jdtls is available
      if vim.fn.executable("jdtls") == 1 then
        print("✅ jdtls is available")
      else
        print("❌ jdtls not found in PATH")
        print("Install Eclipse JDT Language Server")
      end

      -- Check project root detection
      local root = vim.fs.root(bufnr, { "build.gradle", "build.gradle.kts", "pom.xml", "settings.gradle", "settings.gradle.kts", ".git" })
      print("Detected project root:", root or "none")

      -- Check for Java runtime
      if vim.fn.executable("java") == 1 then
        print("✅ Java runtime available")
      else
        print("❌ Java runtime not found")
      end
    end
    print("========================")
  end, { desc = "Debug Groovy/Java LSP configuration" })
end

return M
