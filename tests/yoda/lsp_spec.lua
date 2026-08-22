-- tests/yoda/lsp_spec.lua
local helpers = require("tests.helpers")

describe("yoda.lsp", function()
  local lsp
  local timer_manager = require("yoda.timer_manager")

  local MANAGED_COMMANDS = {
    "YodaLspInfo",
    "YodaHelmDebug",
    "LSPStatus",
    "LSPRestart",
    "LSPInfo",
    "PythonLSPDebug",
    "GroovyLSPDebug",
    "JdtlsQuiet",
    "JdtlsBuild",
    "LSPPerfReport",
    "LSPPerfReset",
    "PythonVenvDetect",
    "PythonVenvCache",
    "PythonVenvClear",
  }

  local function fake_client(overrides)
    return vim.tbl_deep_extend("force", {
      id = 1,
      name = "gopls",
      server_capabilities = {},
      config = {},
      supports_method = function()
        return false
      end,
      stop = function() end,
      detach = function() end,
      notify = function() end,
    }, overrides or {})
  end

  local function contains(haystack, needle)
    return haystack:find(needle, 1, true) ~= nil
  end

  before_each(function()
    package.loaded["yoda.lsp"] = nil
    for _, name in ipairs(MANAGED_COMMANDS) do
      pcall(vim.api.nvim_del_user_command, name)
    end
    lsp = require("yoda.lsp")
  end)

  after_each(function()
    timer_manager.reset()
  end)

  describe("setup()", function()
    it("does not raise", function()
      -- Act
      local ok = pcall(lsp.setup)

      -- Assert
      assert.is_true(ok)
    end)

    it(
      "disables pyright and shares capabilities via the wildcard config",
      function()
        -- Act
        lsp.setup()

        -- Assert
        local pyright_cfg = vim.lsp.config["pyright"]
        assert.is_false(pyright_cfg.enabled)
        assert.is_false(pyright_cfg.autostart)
        assert.is_not_nil(vim.lsp.config["*"].capabilities)
      end
    )

    it(
      "registers gopls, lua_ls, and basedpyright with expected filetypes",
      function()
        -- Act
        lsp.setup()

        -- Assert
        assert.same(
          { "go", "gomod", "gowork", "gotmpl" },
          vim.lsp.config["gopls"].filetypes
        )
        assert.same({ "lua" }, vim.lsp.config["lua_ls"].filetypes)
        assert.same({ "python" }, vim.lsp.config["basedpyright"].filetypes)
      end
    )

    it(
      "passes basedpyright a capabilities delta with documentHighlight stripped",
      function()
        -- Arrange: vim.lsp.config resolves a server's config by deep-merging
        -- '*' underneath it (see Neovim's vim.lsp.lua), so the wildcard's
        -- capabilities.textDocument.documentHighlight reappears in the
        -- *resolved* config regardless of what basedpyright's own delta
        -- strips. Assert on the delta setup() actually passes in, which is
        -- the only thing this module controls.
        local original_config = vim.lsp.config
        local passed_cfg
        local spy_config = setmetatable({}, {
          __call = function(_, name, cfg)
            if name == "basedpyright" and cfg then
              passed_cfg = cfg
            end
            return original_config(name, cfg)
          end,
          __index = function(_, name)
            return original_config[name]
          end,
          __newindex = function(_, name, cfg)
            original_config[name] = cfg
          end,
        })
        vim.lsp.config = spy_config

        -- Act
        lsp.setup()
        vim.lsp.config = original_config

        -- Assert
        assert.is_nil(passed_cfg.capabilities.textDocument.documentHighlight)
        assert.is_not_nil(vim.lsp.config["gopls"].capabilities)
      end
    )

    it("configures global diagnostics", function()
      -- Act
      lsp.setup()

      -- Assert
      local diag_cfg = vim.diagnostic.config()
      assert.is_true(diag_cfg.severity_sort)
      assert.is_false(diag_cfg.update_in_insert)
    end)

    it("registers the LspAttach and DirChanged autocmds", function()
      -- Act
      lsp.setup()

      -- Assert
      assert.equals(1, #vim.api.nvim_get_autocmds({
        group = "YodaLspConfig",
        event = "LspAttach",
      }))
      assert.equals(1, #vim.api.nvim_get_autocmds({
        group = "YodaPythonLSPRestart",
        event = "DirChanged",
      }))
    end)

    it(
      "delegates to the LSP commands, performance, and python venv sub-modules",
      function()
        -- Act
        lsp.setup()

        -- Assert
        local commands = vim.api.nvim_get_commands({})
        assert.is_not_nil(commands.YodaLspInfo)
        assert.is_not_nil(commands.LSPPerfReport)
        assert.is_not_nil(commands.PythonVenvDetect)
      end
    )
  end)

  describe("hover and signature-help handlers", function()
    it(
      "wraps hover with a rounded border, preserving existing config",
      function()
        -- Arrange
        lsp.setup()
        local spy_fn, spy_data = helpers.spy()
        local original = vim.lsp.handlers.hover
        vim.lsp.handlers.hover = spy_fn

        -- Act
        vim.lsp.handlers["textDocument/hover"](
          nil,
          { result = "x" },
          { ctx = 1 },
          { existing = "keep" }
        )

        -- Assert
        helpers.assert_called(spy_data, 1)
        assert.equals("keep", spy_data.last_call[4].existing)
        assert.equals("rounded", spy_data.last_call[4].border)

        vim.lsp.handlers.hover = original
      end
    )

    it("wraps signature help with a rounded border", function()
      -- Arrange
      lsp.setup()
      local spy_fn, spy_data = helpers.spy()
      local original = vim.lsp.handlers.signature_help
      vim.lsp.handlers.signature_help = spy_fn

      -- Act
      vim.lsp.handlers["textDocument/signatureHelp"](nil, nil, {}, nil)

      -- Assert
      helpers.assert_called(spy_data, 1)
      assert.equals("rounded", spy_data.last_call[4].border)

      vim.lsp.handlers.signature_help = original
    end)
  end)

  describe("publishDiagnostics gopls go.mod workaround", function()
    it(
      "filters the false-positive message but keeps other diagnostics",
      function()
        -- Arrange: the pre-existing handler is captured by setup() as
        -- `default_publish`, so it must be stubbed before setup() runs.
        local spy_fn, spy_data = helpers.spy()
        vim.lsp.handlers["textDocument/publishDiagnostics"] = spy_fn
        lsp.setup()

        -- Act
        vim.lsp.handlers["textDocument/publishDiagnostics"](nil, {
          diagnostics = {
            { message = "foo is not in your go.mod file" },
            { message = "undefined: bar" },
          },
        }, {}, {})

        -- Assert
        helpers.assert_called(spy_data, 1)
        local passed_result = spy_data.last_call[2]
        assert.equals(1, #passed_result.diagnostics)
        assert.equals("undefined: bar", passed_result.diagnostics[1].message)
      end
    )

    it("passes through untouched when there are no diagnostics", function()
      -- Arrange
      local spy_fn, spy_data = helpers.spy()
      vim.lsp.handlers["textDocument/publishDiagnostics"] = spy_fn
      lsp.setup()

      -- Act
      local ok = pcall(
        vim.lsp.handlers["textDocument/publishDiagnostics"],
        nil,
        {},
        {},
        {}
      )

      -- Assert
      assert.is_true(ok)
      helpers.assert_called(spy_data, 1)
    end)
  end)

  describe("LspAttach handler", function()
    local buf
    local original_get_client_by_id

    local function attach_callback()
      lsp.setup()
      local acs = vim.api.nvim_get_autocmds({
        group = "YodaLspConfig",
        event = "LspAttach",
      })
      return acs[1].callback
    end

    before_each(function()
      buf = vim.api.nvim_create_buf(false, true)
      original_get_client_by_id = vim.lsp.get_client_by_id
    end)

    after_each(function()
      vim.lsp.get_client_by_id = original_get_client_by_id
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)

    it("returns early when the client cannot be resolved", function()
      -- Arrange
      local callback = attach_callback()
      vim.lsp.get_client_by_id = function()
        return nil
      end

      -- Act
      local ok = pcall(callback, { buf = buf, data = { client_id = 999 } })

      -- Assert
      assert.is_true(ok)
    end)

    it("stops pyright if it attaches despite being disabled", function()
      -- Arrange
      local callback = attach_callback()
      local stop_spy, stop_data = helpers.spy()
      local client = fake_client({ name = "pyright", stop = stop_spy })
      vim.lsp.get_client_by_id = function()
        return client
      end

      -- Act
      callback({ buf = buf, data = { client_id = 1 } })
      vim.wait(50)

      -- Assert
      helpers.assert_called(stop_data, 1)
      assert.equals(true, stop_data.last_call[2])
    end)

    it("detaches marksman from gitcommit buffers", function()
      -- Arrange
      vim.bo[buf].filetype = "gitcommit"
      local callback = attach_callback()
      local detach_spy, detach_data = helpers.spy()
      local client = fake_client({ name = "marksman", detach = detach_spy })
      vim.lsp.get_client_by_id = function()
        return client
      end

      -- Act
      callback({ buf = buf, data = { client_id = 1 } })
      vim.wait(50)

      -- Assert
      helpers.assert_called(detach_data, 1)
      assert.equals(buf, detach_data.last_call[2])
    end)

    it("does not detach marksman from a non-commit buffer", function()
      -- Arrange
      vim.bo[buf].filetype = "markdown"
      local callback = attach_callback()
      local detach_spy, detach_data = helpers.spy()
      local client = fake_client({ name = "marksman", detach = detach_spy })
      vim.lsp.get_client_by_id = function()
        return client
      end

      -- Act
      local ok = pcall(callback, { buf = buf, data = { client_id = 1 } })

      -- Assert
      assert.is_true(ok)
      helpers.assert_not_called(detach_data)
    end)

    it("disables formatting for jdtls", function()
      -- Arrange
      local callback = attach_callback()
      local client = fake_client({
        name = "jdtls",
        server_capabilities = {
          documentFormattingProvider = true,
          documentRangeFormattingProvider = true,
        },
      })
      vim.lsp.get_client_by_id = function()
        return client
      end

      -- Act
      callback({ buf = buf, data = { client_id = 1 } })

      -- Assert
      assert.is_false(client.server_capabilities.documentFormattingProvider)
      assert.is_false(
        client.server_capabilities.documentRangeFormattingProvider
      )
    end)

    it("disables semantic tokens for every attaching client", function()
      -- Arrange
      local callback = attach_callback()
      local client = fake_client({
        name = "gopls",
        server_capabilities = { semanticTokensProvider = {} },
      })
      vim.lsp.get_client_by_id = function()
        return client
      end

      -- Act
      callback({ buf = buf, data = { client_id = 1 } })

      -- Assert
      assert.is_nil(client.server_capabilities.semanticTokensProvider)
    end)

    it("disables document highlight immediately for basedpyright", function()
      -- Arrange
      local callback = attach_callback()
      local client = fake_client({
        name = "basedpyright",
        server_capabilities = { documentHighlightProvider = true },
      })
      vim.lsp.get_client_by_id = function()
        return client
      end

      -- Act
      callback({ buf = buf, data = { client_id = 1 } })

      -- Assert
      assert.is_false(client.server_capabilities.documentHighlightProvider)
      vim.wait(20)
    end)

    it(
      "registers document-highlight autocmds when the client supports it",
      function()
        -- Arrange
        local callback = attach_callback()
        local client = fake_client({
          name = "gopls",
          supports_method = function()
            return true
          end,
        })
        vim.lsp.get_client_by_id = function()
          return client
        end

        -- Act
        callback({ buf = buf, data = { client_id = 1 } })

        -- Assert
        assert.is_true(vim.b[buf]._yoda_hl_registered)
        assert.is_true(#vim.api.nvim_get_autocmds({
          group = "YodaLspHighlight",
          buffer = buf,
        }) >= 1)
      end
    )

    it(
      "does not register document-highlight autocmds when unsupported",
      function()
        -- Arrange
        local callback = attach_callback()
        local client = fake_client({
          name = "gopls",
          supports_method = function()
            return false
          end,
        })
        vim.lsp.get_client_by_id = function()
          return client
        end

        -- Act
        callback({ buf = buf, data = { client_id = 1 } })

        -- Assert
        assert.is_nil(vim.b[buf]._yoda_hl_registered)
      end
    )

    it("schedules buffer-local LSP keymaps", function()
      -- Arrange
      local callback = attach_callback()
      local client = fake_client({ name = "gopls" })
      vim.lsp.get_client_by_id = function()
        return client
      end

      -- Act
      callback({ buf = buf, data = { client_id = 1 } })
      vim.wait(50)

      -- Assert
      local keymaps = vim.api.nvim_buf_get_keymap(buf, "n")
      local found = false
      for _, km in ipairs(keymaps) do
        if km.lhs == "gd" then
          found = true
        end
      end
      assert.is_true(found, "expected buffer-local 'gd' keymap")
    end)

    describe("basedpyright Python venv extraPaths setup", function()
      -- Covers L469 (root_dir), L478 (src/ isdirectory), L485-L489
      -- (settings munging). All four zero-arm branches live inside the
      -- vim.schedule callback that runs on LspAttach for basedpyright.

      local original_isdirectory
      local original_python_venv_detect

      before_each(function()
        original_isdirectory = vim.fn.isdirectory
        -- yoda.python_venv.detect_and_apply is invoked as a side effect and
        -- has its own tests -- stub it so this describe block does not
        -- reach into venv detection during unit testing.
        original_python_venv_detect =
          require("yoda.python_venv").detect_and_apply
        require("yoda.python_venv").detect_and_apply = function() end
      end)

      after_each(function()
        vim.fn.isdirectory = original_isdirectory
        require("yoda.python_venv").detect_and_apply =
          original_python_venv_detect
      end)

      local function attach_basedpyright(overrides)
        local callback = attach_callback()
        local notify_spy, notify_data = helpers.spy()
        local client = fake_client(vim.tbl_deep_extend("force", {
          name = "basedpyright",
          server_capabilities = { documentHighlightProvider = true },
          notify = notify_spy,
        }, overrides or {}))
        vim.lsp.get_client_by_id = function()
          return client
        end
        callback({ buf = buf, data = { client_id = 1 } })
        vim.wait(50)
        return client, notify_data
      end

      it(
        "sends workspace/didChangeConfiguration with extraPaths derived from root_dir",
        function()
          -- Arrange
          vim.fn.isdirectory = function()
            return 0
          end

          -- Act
          local client, notify_data = attach_basedpyright({
            config = {
              root_dir = "/proj/py-app",
              settings = {
                basedpyright = { analysis = {} },
                python = { analysis = {} },
              },
            },
          })

          -- Assert
          helpers.assert_called(notify_data)
          assert.equals(
            "workspace/didChangeConfiguration",
            notify_data.last_call[1]
          )
          local sent_settings = notify_data.last_call[2].settings
          assert.same(
            { "/proj/py-app" },
            sent_settings.basedpyright.analysis.extraPaths
          )
          assert.same(
            { "/proj/py-app" },
            sent_settings.python.analysis.extraPaths
          )
          -- Direct read on the client also reflects the mutation.
          assert.same(
            { "/proj/py-app" },
            client.config.settings.basedpyright.analysis.extraPaths
          )
        end
      )

      it(
        "appends the src/ directory to extraPaths when it exists (src-layout project)",
        function()
          -- Arrange
          vim.fn.isdirectory = function(path)
            return path == "/proj/src-app/src" and 1 or 0
          end

          -- Act
          local _, notify_data = attach_basedpyright({
            config = {
              root_dir = "/proj/src-app",
              settings = { basedpyright = { analysis = {} } },
            },
          })

          -- Assert
          helpers.assert_called(notify_data)
          local sent_settings = notify_data.last_call[2].settings
          assert.same(
            { "/proj/src-app", "/proj/src-app/src" },
            sent_settings.basedpyright.analysis.extraPaths
          )
        end
      )

      it("does nothing when the client has no root_dir", function()
        -- Arrange
        vim.fn.isdirectory = function()
          return 0
        end

        -- Act
        local _, notify_data = attach_basedpyright({
          config = { settings = { basedpyright = { analysis = {} } } },
        })

        -- Assert: no root_dir means no vim.schedule extraPaths push. The
        -- notify spy stays clean (it would fire from workspace/didChange
        -- otherwise).
        helpers.assert_not_called(notify_data)
      end)

      it(
        "skips the didChangeConfiguration push when the client has no settings table",
        function()
          -- Arrange
          vim.fn.isdirectory = function()
            return 0
          end

          -- Act
          local _, notify_data = attach_basedpyright({
            config = {
              root_dir = "/proj/no-settings-app",
              settings = nil,
            },
          })

          -- Assert: root_dir is present so the vim.schedule runs, but the
          -- inner `if settings then` guards against pushing anything.
          helpers.assert_not_called(notify_data)
        end
      )
    end)

    describe("inlay hint toggle keymap", function()
      -- Covers L668: the c:supports_method(...) conditional inside the
      -- <leader>lh keymap. Every existing test uses supports_method=false,
      -- so the true branch was never entered.

      local original_get_clients
      local original_inlay_enable
      local original_inlay_is_enabled

      before_each(function()
        original_get_clients = vim.lsp.get_clients
        original_inlay_enable = vim.lsp.inlay_hint.enable
        original_inlay_is_enabled = vim.lsp.inlay_hint.is_enabled
      end)

      after_each(function()
        vim.lsp.get_clients = original_get_clients
        vim.lsp.inlay_hint.enable = original_inlay_enable
        vim.lsp.inlay_hint.is_enabled = original_inlay_is_enabled
      end)

      local function attach_and_get_lh_callback(client_supports)
        local callback = attach_callback()
        local client = fake_client({
          name = "gopls",
          supports_method = function()
            return true
          end,
        })
        vim.lsp.get_client_by_id = function()
          return client
        end
        callback({ buf = buf, data = { client_id = 1 } })
        vim.wait(50)
        -- Now the <leader>lh keymap is registered on the buffer. Find it.
        vim.lsp.get_clients = function()
          return {
            {
              supports_method = function()
                return client_supports
              end,
            },
          }
        end
        for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
          if km.desc == "Toggle Inlay Hints" then
            return km.callback
          end
        end
        return nil
      end

      it("enables inlay hints when a client supports them", function()
        -- Arrange
        local enable_spy, enable_data = helpers.spy()
        vim.lsp.inlay_hint.enable = enable_spy
        vim.lsp.inlay_hint.is_enabled = function()
          return false
        end
        local cb = attach_and_get_lh_callback(true)
        assert.is_not_nil(cb, "<leader>lh keymap not found")

        -- Act
        cb()

        -- Assert: called with `not is_enabled` = true, plus the buf table
        helpers.assert_called(enable_data)
        assert.is_true(enable_data.last_call[1])
        assert.equals(buf, enable_data.last_call[2].bufnr)
      end)

      it(
        "does nothing when no client supports the inlay hint method",
        function()
          -- Arrange
          local enable_spy, enable_data = helpers.spy()
          vim.lsp.inlay_hint.enable = enable_spy
          local cb = attach_and_get_lh_callback(false)
          assert.is_not_nil(cb, "<leader>lh keymap not found")

          -- Act
          cb()

          -- Assert
          helpers.assert_not_called(enable_data)
        end
      )
    end)
  end)

  describe("blink-cmp capabilities integration", function()
    -- Covers L24: `if blink_ok then capabilities = blink.get_lsp_capabilities()`.
    -- Every prior test runs with blink.cmp absent (fall-through branch), so the
    -- truthy branch that enriches capabilities was never entered.

    it(
      "merges blink.cmp capabilities into the wildcard config when available",
      function()
        -- Arrange
        package.loaded["blink.cmp"] = {
          get_lsp_capabilities = function(caps)
            caps.textDocument = caps.textDocument or {}
            caps.textDocument.__blink_test_marker = "blink-enriched"
            return caps
          end,
        }

        -- Act
        lsp.setup()

        -- Assert
        assert.equals(
          "blink-enriched",
          vim.lsp.config["*"].capabilities.textDocument.__blink_test_marker
        )

        package.loaded["blink.cmp"] = nil
      end
    )
  end)

  describe("safe_setup failure path", function()
    -- Covers L91: `if not success then vim.notify(...)`. Every prior test
    -- runs safe_setup happy-path (vim.lsp.config succeeds), so the WARN
    -- branch was never exercised.

    it("warns when vim.lsp.config raises for a specific server", function()
      -- Arrange: wrap vim.lsp.config so calling it with the "gopls" server
      -- raises. Every other setter must still succeed, otherwise setup()
      -- errors out before we reach the assertion.
      local original_config = vim.lsp.config
      local spy_config = setmetatable({}, {
        __call = function(_, name, cfg)
          if name == "gopls" then
            error("simulated gopls config failure")
          end
          return original_config(name, cfg)
        end,
        __index = original_config,
        __newindex = function(_, name, cfg)
          original_config[name] = cfg
        end,
      })
      vim.lsp.config = spy_config
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      lsp.setup()

      -- Assert: at least one notify call should mention the gopls failure.
      local saw_expected = false
      for _, call in ipairs(notify_data.calls) do
        if
          call[1] and call[1]:find("Failed to configure LSP server 'gopls'")
        then
          saw_expected = true
          assert.equals(vim.log.levels.WARN, call[2])
          break
        end
      end
      assert.is_true(saw_expected, "expected a WARN notify for gopls")

      restore()
      vim.lsp.config = original_config
    end)
  end)

  describe("basedpyright on_init handler", function()
    -- Covers L232: `if client.server_capabilities then ...` inside the
    -- basedpyright on_init hook. Never exercised because tests attach clients
    -- directly rather than initializing them through the vim.lsp lifecycle.

    it(
      "disables documentHighlightProvider immediately when server capabilities are set",
      function()
        -- Arrange
        lsp.setup()
        local on_init = vim.lsp.config["basedpyright"].on_init
        assert.is_function(on_init)
        local client =
          { server_capabilities = { documentHighlightProvider = true } }

        -- Act
        on_init(client)

        -- Assert
        assert.is_false(client.server_capabilities.documentHighlightProvider)
      end
    )

    it("no-ops when the client has no server_capabilities yet", function()
      -- Arrange
      lsp.setup()
      local on_init = vim.lsp.config["basedpyright"].on_init
      local client = {} -- no server_capabilities

      -- Act / Assert: must not raise even when the field is absent.
      local ok = pcall(on_init, client)
      assert.is_true(ok)
    end)
  end)

  describe("basedpyright post-attach timer + LspDetach cleanup", function()
    -- Covers L435 (`if client.server_capabilities and
    -- .documentHighlightProvider then`) inside the 500ms timer callback, and
    -- L451 (`if args.data.client_id == client.id then`) inside the LspDetach
    -- cleanup autocmd. Both live behind create_timer and LspDetach dispatch,
    -- so neither was reached by the phase-1 tests.

    local buf
    local original_get_client_by_id
    local original_create_timer
    local original_stop_timer
    local captured_timer_cb
    local captured_timer_id

    local function attach_callback()
      lsp.setup()
      local acs = vim.api.nvim_get_autocmds({
        group = "YodaLspConfig",
        event = "LspAttach",
      })
      return acs[1].callback
    end

    before_each(function()
      buf = vim.api.nvim_create_buf(false, true)
      original_get_client_by_id = vim.lsp.get_client_by_id
      original_create_timer = timer_manager.create_timer
      original_stop_timer = timer_manager.stop_timer
      captured_timer_cb = nil
      captured_timer_id = nil
      -- Capture the timer callback rather than letting it run for real.
      timer_manager.create_timer = function(cb, _timeout, _repeat, timer_id)
        captured_timer_cb = cb
        captured_timer_id = timer_id
        return {}, timer_id
      end
    end)

    after_each(function()
      vim.lsp.get_client_by_id = original_get_client_by_id
      timer_manager.create_timer = original_create_timer
      timer_manager.stop_timer = original_stop_timer
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
      pcall(
        vim.api.nvim_clear_autocmds,
        { group = "YodaBasedpyrightTimerCleanup" }
      )
    end)

    it(
      "timer callback re-disables documentHighlightProvider when the server re-enables it",
      function()
        -- Arrange
        local callback = attach_callback()
        local client = fake_client({
          name = "basedpyright",
          id = 42,
          server_capabilities = { documentHighlightProvider = true },
        })
        vim.lsp.get_client_by_id = function()
          return client
        end
        callback({ buf = buf, data = { client_id = 42 } })
        -- The LspAttach handler runs on_init synchronously via the vim.lsp
        -- lifecycle, but here we drive it directly -- so the immediate
        -- documentHighlightProvider=false at LspAttach fires *before* the
        -- timer callback. Simulate the server re-enabling it (the exact
        -- race the timer exists to catch).
        client.server_capabilities.documentHighlightProvider = true
        assert.is_function(captured_timer_cb)

        -- Act
        captured_timer_cb()

        -- Assert
        assert.is_false(client.server_capabilities.documentHighlightProvider)
      end
    )

    it(
      "timer callback no-ops when server_capabilities was cleared entirely",
      function()
        -- Arrange
        local callback = attach_callback()
        local client = fake_client({
          name = "basedpyright",
          id = 43,
          server_capabilities = { documentHighlightProvider = true },
        })
        vim.lsp.get_client_by_id = function()
          return client
        end
        callback({ buf = buf, data = { client_id = 43 } })
        -- Simulate the client losing server_capabilities entirely (client
        -- stopped, edge case). The `if client.server_capabilities and ...`
        -- guard exists exactly to survive this.
        client.server_capabilities = nil

        -- Act / Assert: must not raise on nil server_capabilities.
        local ok = pcall(captured_timer_cb)
        assert.is_true(ok)
      end
    )

    -- Dispatch a real LspDetach autocmd for the cleanup group. Lifts the
    -- eventignore="all" set in minimal_init.lua so the autocmd actually
    -- runs, and restores it afterward.
    local function dispatch_lsp_detach(client_id)
      local original_eventignore = vim.o.eventignore
      vim.o.eventignore = ""
      vim.api.nvim_exec_autocmds("LspDetach", {
        group = "YodaBasedpyrightTimerCleanup",
        data = { client_id = client_id },
      })
      vim.o.eventignore = original_eventignore
    end

    it(
      "LspDetach for the matching client_id stops the highlight-disable timer",
      function()
        -- Arrange
        local callback = attach_callback()
        local client = fake_client({
          name = "basedpyright",
          id = 77,
          server_capabilities = { documentHighlightProvider = true },
        })
        vim.lsp.get_client_by_id = function()
          return client
        end
        callback({ buf = buf, data = { client_id = 77 } })
        local stop_spy, stop_data = helpers.spy()
        timer_manager.stop_timer = stop_spy

        -- Act
        dispatch_lsp_detach(77)

        -- Assert
        helpers.assert_called(stop_data)
        assert.equals(captured_timer_id, stop_data.last_call[1])
      end
    )

    it(
      "LspDetach for a non-matching client_id leaves the timer alone",
      function()
        -- Arrange
        local callback = attach_callback()
        local client = fake_client({
          name = "basedpyright",
          id = 77,
          server_capabilities = { documentHighlightProvider = true },
        })
        vim.lsp.get_client_by_id = function()
          return client
        end
        callback({ buf = buf, data = { client_id = 77 } })
        local stop_spy, stop_data = helpers.spy()
        timer_manager.stop_timer = stop_spy

        -- Act: detach a *different* client
        dispatch_lsp_detach(999)

        -- Assert
        helpers.assert_not_called(stop_data)
      end
    )
  end)

  describe("DirChanged Python-restart handler", function()
    -- Covers L725 (`if timer_manager.is_vim_timer_active(timer_id) then`),
    -- L737 (`if current_root and vim.g.last_python_root ~= current_root then`),
    -- L741 (`if #clients > 0 then`), and L750 (`for _, client in ipairs(...)`)
    -- inside the DirChanged callback + its scheduled inner timer.

    local original_create_vim_timer
    local original_is_vim_timer_active
    local original_stop_vim_timer
    local original_fs_root
    local original_get_clients
    local original_last_python_root
    local captured_inner_cb

    local function dispatch_dirchanged()
      lsp.setup()
      -- eventignore="all" is set in minimal_init.lua to prevent test
      -- pollution -- temporarily lift it so DirChanged autocmds actually
      -- fire.
      local original_eventignore = vim.o.eventignore
      vim.o.eventignore = ""
      vim.api.nvim_exec_autocmds("DirChanged", {
        group = "YodaPythonLSPRestart",
      })
      vim.o.eventignore = original_eventignore
    end

    before_each(function()
      original_create_vim_timer = timer_manager.create_vim_timer
      original_is_vim_timer_active = timer_manager.is_vim_timer_active
      original_stop_vim_timer = timer_manager.stop_vim_timer
      original_fs_root = vim.fs.root
      original_get_clients = vim.lsp.get_clients
      original_last_python_root = vim.g.last_python_root
      captured_inner_cb = nil
      -- Capture the inner timer callback so we can invoke it directly
      -- rather than blocking for 1000ms.
      timer_manager.create_vim_timer = function(cb, _delay, _timer_id)
        captured_inner_cb = cb
        return 1, _timer_id
      end
    end)

    after_each(function()
      timer_manager.create_vim_timer = original_create_vim_timer
      timer_manager.is_vim_timer_active = original_is_vim_timer_active
      timer_manager.stop_vim_timer = original_stop_vim_timer
      vim.fs.root = original_fs_root
      vim.lsp.get_clients = original_get_clients
      vim.g.last_python_root = original_last_python_root
      pcall(vim.api.nvim_clear_autocmds, { group = "YodaPythonLSPRestart" })
    end)

    it(
      "stops a previously scheduled restart timer before creating a new one",
      function()
        -- Arrange
        timer_manager.is_vim_timer_active = function()
          return true
        end
        local stop_spy, stop_data = helpers.spy()
        timer_manager.stop_vim_timer = stop_spy

        -- Act
        dispatch_dirchanged()

        -- Assert
        helpers.assert_called(stop_data)
        assert.equals("python_lsp_restart", stop_data.last_call[1])
      end
    )

    it(
      "does not call stop_vim_timer when no previous restart is pending",
      function()
        -- Arrange
        timer_manager.is_vim_timer_active = function()
          return false
        end
        local stop_spy, stop_data = helpers.spy()
        timer_manager.stop_vim_timer = stop_spy

        -- Act
        dispatch_dirchanged()

        -- Assert
        helpers.assert_not_called(stop_data)
      end
    )

    it(
      "restarts every basedpyright client when the project root changes",
      function()
        -- Arrange
        timer_manager.is_vim_timer_active = function()
          return false
        end
        vim.fs.root = function()
          return "/proj/py-app"
        end
        vim.g.last_python_root = nil
        local stop_spy_a, stop_data_a = helpers.spy()
        local stop_spy_b, stop_data_b = helpers.spy()
        vim.lsp.get_clients = function(opts)
          if opts and opts.name == "basedpyright" then
            return {
              { stop = stop_spy_a, name = "basedpyright" },
              { stop = stop_spy_b, name = "basedpyright" },
            }
          end
          return {}
        end
        dispatch_dirchanged()
        assert.is_function(captured_inner_cb)

        -- Act
        captured_inner_cb()
        vim.wait(20)

        -- Assert
        helpers.assert_called(stop_data_a)
        helpers.assert_called(stop_data_b)
        assert.equals("/proj/py-app", vim.g.last_python_root)
      end
    )

    it(
      "does not restart anything when no basedpyright clients are active",
      function()
        -- Arrange
        timer_manager.is_vim_timer_active = function()
          return false
        end
        vim.fs.root = function()
          return "/proj/no-lsp"
        end
        vim.g.last_python_root = nil
        vim.lsp.get_clients = function()
          return {}
        end
        dispatch_dirchanged()

        -- Act
        captured_inner_cb()
        vim.wait(20)

        -- Assert: last_python_root still updates (root was new), but no
        -- clients to stop.
        assert.equals("/proj/no-lsp", vim.g.last_python_root)
      end
    )

    it(
      "no-ops when the project root has not changed from vim.g.last_python_root",
      function()
        -- Arrange
        timer_manager.is_vim_timer_active = function()
          return false
        end
        vim.fs.root = function()
          return "/proj/same"
        end
        vim.g.last_python_root = "/proj/same"
        local stop_spy, stop_data = helpers.spy()
        vim.lsp.get_clients = function()
          return { { stop = stop_spy, name = "basedpyright" } }
        end
        dispatch_dirchanged()

        -- Act
        captured_inner_cb()
        vim.wait(20)

        -- Assert: same root, no stop should fire.
        helpers.assert_not_called(stop_data)
      end
    )

    it("no-ops when vim.fs.root returns nil (no project detected)", function()
      -- Arrange
      timer_manager.is_vim_timer_active = function()
        return false
      end
      vim.fs.root = function()
        return nil
      end
      vim.g.last_python_root = "/proj/prior"
      local stop_spy, stop_data = helpers.spy()
      vim.lsp.get_clients = function()
        return { { stop = stop_spy, name = "basedpyright" } }
      end
      dispatch_dirchanged()

      -- Act
      captured_inner_cb()
      vim.wait(20)

      -- Assert: no root, no stop, last_python_root untouched.
      helpers.assert_not_called(stop_data)
      assert.equals("/proj/prior", vim.g.last_python_root)
    end)
  end)

  describe("YodaLspDetach highlight-cleanup callback", function()
    -- Covers lsp.lua:541 -- the LspDetach callback that clears references
    -- and removes the YodaLspHighlight autocmds. Fires when a supporting
    -- client detaches from the buffer.
    it("clears references and removes the YodaLspHighlight autocmds", function()
      -- Arrange: run an LspAttach with a client that supports
      -- documentHighlight so the LspDetach autocmd + highlight autocmds
      -- get registered.
      local original_get_client_by_id = vim.lsp.get_client_by_id
      local buf = vim.api.nvim_create_buf(false, true)
      lsp.setup()
      local acs = vim.api.nvim_get_autocmds({
        group = "YodaLspConfig",
        event = "LspAttach",
      })
      local attach_cb = acs[1].callback
      local client = {
        id = 55,
        name = "gopls",
        server_capabilities = {},
        config = {},
        supports_method = function()
          return true
        end,
        stop = function() end,
        detach = function() end,
        notify = function() end,
      }
      vim.lsp.get_client_by_id = function()
        return client
      end
      attach_cb({ buf = buf, data = { client_id = 55 } })
      vim.wait(20)
      assert.is_true(vim.b[buf]._yoda_hl_registered)

      -- Grab the detach callback from the YodaLspDetach group.
      local detach_acs = vim.api.nvim_get_autocmds({
        group = "YodaLspDetach",
        event = "LspDetach",
        buffer = buf,
      })
      assert.is_true(
        #detach_acs >= 1,
        "expected at least one LspDetach autocmd on buffer " .. buf
      )
      local clear_calls = 0
      local original_clear = vim.lsp.buf.clear_references
      vim.lsp.buf.clear_references = function()
        clear_calls = clear_calls + 1
      end

      -- Act
      detach_acs[1].callback({ buf = buf })

      -- Assert: clear_references fired, buffer flag cleared, highlight
      -- autocmds gone from the buffer.
      assert.equals(1, clear_calls)
      assert.is_nil(vim.b[buf]._yoda_hl_registered)
      local remaining = vim.api.nvim_get_autocmds({
        group = "YodaLspHighlight",
        buffer = buf,
      })
      assert.equals(0, #remaining)

      vim.lsp.buf.clear_references = original_clear
      vim.lsp.get_client_by_id = original_get_client_by_id
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)
  end)

  describe("<leader>lf format keymap", function()
    -- Covers lsp.lua:648 -- the async format callback bound to <leader>lf.
    it("invokes vim.lsp.buf.format with async = true", function()
      -- Arrange
      local original_get_client_by_id = vim.lsp.get_client_by_id
      local buf = vim.api.nvim_create_buf(false, true)
      lsp.setup()
      local attach_cb = vim.api.nvim_get_autocmds({
        group = "YodaLspConfig",
        event = "LspAttach",
      })[1].callback
      local client = {
        id = 77,
        name = "gopls",
        server_capabilities = {},
        config = {},
        supports_method = function()
          return false
        end,
        stop = function() end,
        detach = function() end,
        notify = function() end,
      }
      vim.lsp.get_client_by_id = function()
        return client
      end
      attach_cb({ buf = buf, data = { client_id = 77 } })
      vim.wait(50)

      local original_format = vim.lsp.buf.format
      local captured_opts
      vim.lsp.buf.format = function(opts)
        captured_opts = opts
      end
      local cb
      for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
        if km.desc == "LSP: Format Buffer" then
          cb = km.callback
          break
        end
      end
      assert.is_function(cb, "<leader>lf keymap not registered")

      -- Act
      cb()

      -- Assert
      assert.is_not_nil(captured_opts)
      assert.is_true(captured_opts.async)

      vim.lsp.buf.format = original_format
      vim.lsp.get_client_by_id = original_get_client_by_id
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)
  end)
end)
