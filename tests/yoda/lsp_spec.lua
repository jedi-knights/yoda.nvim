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
  end)
end)
