-- lua/yoda/lsp.lua
-- Modern LSP setup using vim.lsp.config (Neovim 0.11+)

local M = {}
local lsp_perf = require("yoda.lsp_performance")
local notify = require("yoda-adapters.notification")
local timer_manager = require("yoda.timer_manager")

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

  -- Prefer blink.cmp over nvim-cmp
  local blink_ok, blink = pcall(require, "blink.cmp")
  if blink_ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
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

  -- Helper function to safely setup LSP servers using vim.lsp.config.
  -- Uses vim.notify directly (not the adapter) because this runs during setup
  -- before the notification adapter is guaranteed to be fully initialized.
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
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 300,
    },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = {
          globals = { "vim", "describe", "it", "before_each", "after_each" },
        },
        -- Do NOT set workspace.library here — lazydev.nvim manages it and
        -- sets it correctly on LspAttach. If we also set it here, lua_ls
        -- indexes the entire Neovim runtime tree twice on startup, doubling
        -- startup time and memory for Lua files.
        workspace = { checkThirdParty = false },
        completion = { callSnippet = "Replace" },
        telemetry = { enable = false },
      },
    },
  })

  -- TypeScript setup
  safe_setup("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 300,
    },
  })

  -- Python setup with virtual environment support
  --
  -- Document highlight is disabled in three places because basedpyright
  -- re-registers documentHighlightProvider via dynamic capability registration
  -- after the server initializes, overriding a single disable:
  --   1. capabilities table (here) — advertise "we don't want it" during handshake
  --   2. on_init callback        — strip the capability immediately on init
  --   3. LspAttach + 500ms timer — strip it again after dynamic re-registration
  local python_capabilities = vim.deepcopy(capabilities)
  python_capabilities.textDocument.documentHighlight = nil

  safe_setup("basedpyright", {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
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
  })

  -- YAML setup
  safe_setup("yamlls", {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
    root_markers = { ".git" },
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

  -- Java setup (also works for Jenkinsfiles/Groovy)
  -- NOTE: jdtls is intentionally absent from mason-lspconfig's ensure_installed.
  -- The Eclipse JDT Language Server requires a workspace directory and JVM flags
  -- that Mason cannot configure automatically — it must be installed and managed
  -- manually (e.g. via Homebrew: `brew install jdtls`).
  safe_setup("jdtls", {
    cmd = { "jdtls" },
    filetypes = { "java", "groovy" },
    root_markers = { "build.gradle", "build.gradle.kts", "pom.xml", "settings.gradle", "settings.gradle.kts", ".git" },
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
    root_markers = { ".git", ".marksman.toml" },
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 300,
    },
    on_attach = function(client, bufnr)
      -- Don't attach to git commit buffers
      local ft = vim.bo[bufnr].filetype
      if ft == "gitcommit" or ft == "NeogitCommitMessage" then
        vim.schedule(function()
          client:detach(bufnr)
        end)
        return
      end
    end,
  })

  -- Consolidated LSP attach handler (optimized - single autocmd)
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("YodaLspConfig", { clear = true }),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if not client then
        return
      end

      -- 1. Client optimizations (immediate)
      -- Silently stop pyright if it somehow still attaches
      if client.name == "pyright" then
        vim.schedule(function()
          vim.lsp.stop_client(client.id, true)
        end)
        return
      end

      -- Disable semantic tokens for all LSP servers (major performance win)
      client.server_capabilities.semanticTokensProvider = nil

      -- Python-specific optimizations
      if client.name == "basedpyright" then
        client.server_capabilities.documentHighlightProvider = false

        -- Re-apply after dynamic capability registration completes (~500ms window)
        local timer_id = "basedpyright_highlight_" .. client.id
        local timer, id = timer_manager.create_timer(function()
          if client.server_capabilities and client.server_capabilities.documentHighlightProvider then
            client.server_capabilities.documentHighlightProvider = false
          end
        end, 500, 0, timer_id)

        if timer then
          vim.api.nvim_create_autocmd("LspDetach", {
            callback = function(args)
              if args.data.client_id == client.id then
                timer_manager.stop_timer(id)
              end
            end,
          })
        end

        vim.schedule(function()
          vim.lsp.buf.clear_references()
        end)

        -- on_new_config is an nvim-lspconfig hook that Neovim 0.11's vim.lsp
        -- never calls. Replicate its work here: push extraPaths and venv via
        -- workspace/didChangeConfiguration once the server has attached.
        local root_dir = client.config and client.config.root_dir
        if root_dir then
          local function join_path(...)
            return table.concat({ ... }, "/")
          end

          -- Build extraPaths: root + src/ layout + known internal packages
          local extra_paths = { root_dir }
          local src_dir = join_path(root_dir, "src")
          if vim.fn.isdirectory(src_dir) == 1 then
            table.insert(extra_paths, src_dir)
          end

          local project_name = vim.fn.fnamemodify(root_dir, ":t")
          if project_name:match("sun%-qa%-python%-tools") or vim.fn.isdirectory(join_path(root_dir, "sun_qa_python_tools")) == 1 then
            local package_dirs = {
              join_path(root_dir, "sun_qa_python_tools"),
              join_path(root_dir, "src", "sun_qa_python_tools"),
            }
            for _, pkg_dir in ipairs(package_dirs) do
              if vim.fn.isdirectory(pkg_dir) == 1 then
                table.insert(extra_paths, pkg_dir)
              end
            end
          end

          -- Push extraPaths immediately so imports resolve before venv is found
          vim.schedule(function()
            local settings = client.config and client.config.settings
            if settings then
              if settings.basedpyright and settings.basedpyright.analysis then
                settings.basedpyright.analysis.extraPaths = extra_paths
              end
              if settings.python and settings.python.analysis then
                settings.python.analysis.extraPaths = extra_paths
              end
              client.notify("workspace/didChangeConfiguration", { settings = settings })
            end
          end)

          -- Async venv detection — pushes pythonPath via didChangeConfiguration
          require("yoda.python_venv").detect_and_apply(root_dir)
        end
      end

      -- 2. Document highlighting: highlight references to the symbol under the
      -- cursor. Only on CursorHold — CursorMovedI and CursorHoldI fire "very
      -- often" (per docs) and would add an LSP round-trip + render + clear on
      -- every keypress during insert mode with no UX benefit.
      if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
        local hl_group = vim.api.nvim_create_augroup("YodaLspHighlight", { clear = false })
        vim.api.nvim_create_autocmd("CursorHold", {
          buffer = event.buf,
          group = hl_group,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
          buffer = event.buf,
          group = hl_group,
          callback = vim.lsp.buf.clear_references,
        })
        -- { clear = false } is intentional: LspAttach fires once per client per
        -- buffer, so multiple clients would each register a detach handler.
        -- { clear = true } would wipe the previous client's handler on each
        -- subsequent attach, leaving earlier clients without cleanup.
        vim.api.nvim_create_autocmd("LspDetach", {
          group = vim.api.nvim_create_augroup("YodaLspDetach", { clear = false }),
          callback = function(ev)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = "YodaLspHighlight", buffer = ev.buf })
          end,
        })
      end

      -- 3. Setup keymaps and UI (deferred to prevent flickering)
      local opts = { buffer = event.buf }
      vim.schedule(function()
        -- Keymaps
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "K", function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients > 0 then
            vim.lsp.buf.hover()
          else
            local word = vim.fn.expand("<cword>")
            if word ~= "" then
              local ok, err = pcall(vim.cmd, "help " .. word)
              if not ok then
                vim.notify("No help found for '" .. word .. "': " .. tostring(err), vim.log.levels.WARN)
              end
            end
          end
        end, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

        -- Toggle inlay hints
        vim.keymap.set("n", "<leader>th", function()
          local clients = vim.lsp.get_clients({ bufnr = event.buf })
          for _, client in ipairs(clients) do
            if client.supports_method("textDocument/inlayHint") then
              local is_enabled = vim.lsp.inlay_hint.is_enabled(event.buf)
              vim.lsp.inlay_hint.enable(not is_enabled, { bufnr = event.buf })
              notify.notify(is_enabled and "Inlay hints disabled" or "Inlay hints enabled", "info")
              return
            end
          end
          notify.notify("Inlay hints not supported by any active LSP server", "warn")
        end, { desc = "Toggle Inlay Hints" })
      end)
    end,
  })

  -- Diagnostic configuration (optimized for performance)
  vim.diagnostic.config({
    severity_sort = true,
    -- update_in_insert = false prevents diagnostic re-runs on every keystroke;
    -- diagnostics refresh on InsertLeave instead, which is the right trade-off.
    update_in_insert = false,
    -- underline only on ERROR: warnings and hints underline large swaths of
    -- code and add visual noise without helping prioritise what to fix first.
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "󰅚 ",
        [vim.diagnostic.severity.WARN] = "󰀪 ",
        [vim.diagnostic.severity.INFO] = "󰋽 ",
        [vim.diagnostic.severity.HINT] = "󰌶 ",
      },
    },
    -- source = "if_many" shows the diagnostic source only when multiple LSP
    -- servers are active on the buffer, avoiding redundant "[server]" prefixes
    -- in single-server contexts.
    virtual_text = { source = "if_many", spacing = 2 },
    float = {
      border = "rounded",
      source = "if_many",
    },
    -- status icons shown in the statuscolumn / sign column
    status = {
      text = {
        [vim.diagnostic.severity.ERROR] = "󰅚",
        [vim.diagnostic.severity.WARN] = "󰀪",
        [vim.diagnostic.severity.INFO] = "󰋽",
        [vim.diagnostic.severity.HINT] = "󰌶",
      },
    },
  })

  -- Auto-restart Python LSP when entering different Python projects
  vim.api.nvim_create_autocmd("DirChanged", {
    group = vim.api.nvim_create_augroup("YodaPythonLSPRestart", {}),
    callback = function()
      local timer_id = "python_lsp_restart"

      if timer_manager.is_vim_timer_active(timer_id) then
        timer_manager.stop_vim_timer(timer_id)
      end

      timer_manager.create_vim_timer(function()
        local current_root = vim.fs.root(0, { "pyproject.toml", "setup.py", "requirements.txt", ".git" })
        if current_root and vim.g.last_python_root ~= current_root then
          vim.g.last_python_root = current_root

          vim.schedule(function()
            local clients = vim.lsp.get_clients({ name = "basedpyright" })
            if #clients > 0 then
              lsp_perf.track_lsp_restart("basedpyright")
              notify.notify(string.format("Restarting Python LSP for project: %s", current_root), "info")
              for _, client in ipairs(clients) do
                client:stop()
              end
            end
          end)
        end
      end, 1000, timer_id)
    end,
  })

  require("yoda.commands.lsp").setup()

  lsp_perf.setup_commands()

  -- Setup Python venv commands
  local python_venv = require("yoda.python_venv")
  python_venv.setup_commands()
end

return M
