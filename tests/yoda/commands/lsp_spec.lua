-- tests/yoda/commands/lsp_spec.lua
local helpers = require("tests.helpers")

describe("commands.lsp", function()
  local lsp_commands
  local original_get_clients
  local notify_spy_fn, notify_spy_data

  local ALL_COMMANDS = {
    "YodaLspInfo",
    "YodaHelmDebug",
    "LSPStatus",
    "LSPRestart",
    "LSPInfo",
    "PythonLSPDebug",
    "GroovyLSPDebug",
    "JdtlsQuiet",
    "JdtlsBuild",
  }

  local function clear_commands()
    for _, name in ipairs(ALL_COMMANDS) do
      pcall(vim.api.nvim_del_user_command, name)
    end
  end

  local function fake_client(overrides)
    return vim.tbl_deep_extend("force", {
      id = 1,
      name = "gopls",
      attached_buffers = {},
      config = { root_dir = "/proj" },
      is_stopped = function()
        return false
      end,
    }, overrides or {})
  end

  local function contains(haystack, needle)
    return haystack:find(needle, 1, true) ~= nil
  end

  before_each(function()
    package.loaded["yoda.commands.lsp"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }

    clear_commands()
    lsp_commands = require("yoda.commands.lsp")
    lsp_commands.setup()

    original_get_clients = vim.lsp.get_clients
  end)

  after_each(function()
    vim.lsp.get_clients = original_get_clients
    clear_commands()
    package.loaded["yoda-adapters.notification"] = nil
  end)

  describe("YodaLspInfo", function()
    it("notifies that no clients are attached when there are none", function()
      -- Arrange
      vim.lsp.get_clients = function()
        return {}
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("YodaLspInfo")

      -- Assert
      helpers.assert_called(spy_data, 1)
      assert.equals(
        "No LSP clients attached to current buffer",
        spy_data.last_call[1]
      )

      restore()
    end)

    it("lists every attached client with its id", function()
      -- Arrange
      vim.lsp.get_clients = function()
        return { fake_client({ id = 7, name = "gopls" }) }
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("YodaLspInfo")

      -- Assert
      assert.is_true(contains(spy_data.last_call[1], "gopls (id: 7)"))

      restore()
    end)
  end)

  describe("YodaHelmDebug", function()
    local buf

    after_each(function()
      if buf and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)

    local function open_buffer_named(path)
      buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, path)
      vim.api.nvim_set_current_buf(buf)
    end

    it("detects the templates/ directory pattern", function()
      -- Arrange
      open_buffer_named("/repo/templates/deployment.yaml")
      vim.lsp.get_clients = function()
        return {}
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("YodaHelmDebug")

      -- Assert
      local text = spy_data.last_call[1]
      assert.is_true(contains(text, "templates/ directory: true"))
      assert.is_true(contains(text, "charts/.../templates/: false"))
      assert.is_true(contains(text, "crds/ directory: false"))

      restore()
    end)

    it("detects the charts/.../templates/ pattern", function()
      -- Arrange
      open_buffer_named("/repo/charts/sub/templates/configmap.yml")
      vim.lsp.get_clients = function()
        return {}
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("YodaHelmDebug")

      -- Assert
      assert.is_true(
        contains(spy_data.last_call[1], "charts/.../templates/: true")
      )

      restore()
    end)

    it("detects the crds/ directory pattern", function()
      -- Arrange
      open_buffer_named("/repo/crds/mycrd.yaml")
      vim.lsp.get_clients = function()
        return {}
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("YodaHelmDebug")

      -- Assert
      assert.is_true(contains(spy_data.last_call[1], "crds/ directory: true"))

      restore()
    end)

    it("reports no matches for an unrelated file", function()
      -- Arrange
      open_buffer_named("/repo/main.go")
      vim.lsp.get_clients = function()
        return {}
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("YodaHelmDebug")

      -- Assert
      local text = spy_data.last_call[1]
      assert.is_true(contains(text, "templates/ directory: false"))
      assert.is_true(contains(text, "None"))

      restore()
    end)

    it("lists attached clients by name when present", function()
      -- Arrange
      open_buffer_named("/repo/templates/deployment.yaml")
      vim.lsp.get_clients = function()
        return { fake_client({ name = "yamlls" }) }
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("YodaHelmDebug")

      -- Assert
      assert.is_true(contains(spy_data.last_call[1], "- yamlls"))

      restore()
    end)
  end)

  describe("LSPStatus", function()
    it("reports no running clients when none are attached", function()
      -- Arrange
      vim.lsp.get_clients = function()
        return {}
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("LSPStatus")

      -- Assert
      local text = spy_data.last_call[1]
      assert.is_true(contains(text, "No LSP clients are running"))
      assert.is_true(contains(text, "--- Available LSP Servers ---"))
      assert.is_true(contains(text, "gopls:"))

      restore()
    end)

    it("reports attached clients with their root directory", function()
      -- Arrange
      local bufnr = vim.api.nvim_get_current_buf()
      vim.lsp.get_clients = function()
        return {
          fake_client({
            id = 3,
            name = "gopls",
            attached_buffers = { [bufnr] = true },
            config = { root_dir = "/proj/go" },
          }),
        }
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("LSPStatus")

      -- Assert
      local text = spy_data.last_call[1]
      assert.is_true(contains(text, "gopls (id:3): attached=true"))
      assert.is_true(contains(text, "root=/proj/go"))

      restore()
    end)
  end)

  describe("LSPRestart", function()
    it("restarts every LSP client and notifies", function()
      -- Arrange
      local original_vim_cmd = vim.cmd
      local captured_cmd
      vim.cmd = function(cmd)
        if cmd == "lsp restart *" then
          captured_cmd = cmd
          return
        end
        return original_vim_cmd(cmd)
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("LSPRestart")

      -- Assert
      assert.equals("lsp restart *", captured_cmd)
      helpers.assert_called_with(
        spy_data,
        "LSP clients restarted",
        vim.log.levels.INFO
      )

      restore()
      vim.cmd = original_vim_cmd
    end)
  end)

  describe("LSPInfo", function()
    it("delegates to the built-in :lsp command", function()
      -- Arrange
      local original_vim_cmd = vim.cmd
      local captured_cmd
      vim.cmd = function(cmd)
        if cmd == "lsp" then
          captured_cmd = cmd
          return
        end
        return original_vim_cmd(cmd)
      end

      -- Act
      vim.cmd("LSPInfo")

      -- Assert
      assert.equals("lsp", captured_cmd)

      vim.cmd = original_vim_cmd
    end)
  end)

  describe("PythonLSPDebug", function()
    it(
      "reports no clients and offers install guidance when unavailable",
      function()
        -- Arrange
        vim.lsp.get_clients = function()
          return {}
        end
        local spy_fn, spy_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", spy_fn)

        -- Act
        vim.cmd("PythonLSPDebug")

        -- Assert
        local text = spy_data.last_call[1]
        assert.is_true(contains(text, "No Python LSP clients attached!"))
        assert.is_true(contains(text, "Virtual environment check:"))

        restore()
      end
    )

    it("reports basedpyright settings when a client is attached", function()
      -- Arrange
      vim.lsp.get_clients = function()
        return {
          fake_client({
            name = "basedpyright",
            config = {
              root_dir = "/proj/py",
              settings = {
                basedpyright = {
                  analysis = {
                    pythonPath = "/proj/py/.venv/bin/python",
                    extraPaths = { "/proj/py/src" },
                    autoSearchPaths = true,
                    diagnosticMode = "openFilesOnly",
                  },
                },
              },
            },
          }),
        }
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("PythonLSPDebug")

      -- Assert
      local text = spy_data.last_call[1]
      assert.is_true(contains(text, "Python path: /proj/py/.venv/bin/python"))
      assert.is_true(contains(text, "Diagnostic mode: openFilesOnly"))

      restore()
    end)
  end)

  describe("GroovyLSPDebug", function()
    it(
      "reports no clients and checks for a java runtime when unavailable",
      function()
        -- Arrange
        vim.lsp.get_clients = function()
          return {}
        end
        local spy_fn, spy_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", spy_fn)

        -- Act
        vim.cmd("GroovyLSPDebug")

        -- Assert
        local text = spy_data.last_call[1]
        assert.is_true(contains(text, "No JDTLS clients attached!"))

        restore()
      end
    )

    it("reports jdtls status and java settings when attached", function()
      -- Arrange
      local bufnr = vim.api.nvim_get_current_buf()
      vim.lsp.get_clients = function()
        return {
          fake_client({
            id = 9,
            name = "jdtls",
            attached_buffers = { [bufnr] = true },
            config = { root_dir = "/proj/java", settings = { java = {} } },
            is_stopped = function()
              return true
            end,
          }),
        }
      end
      local spy_fn, spy_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", spy_fn)

      -- Act
      vim.cmd("GroovyLSPDebug")

      -- Assert
      local text = spy_data.last_call[1]
      assert.is_true(contains(text, "Status: stopped"))
      assert.is_true(contains(text, "Java settings configured: yes"))
      assert.is_true(contains(text, "Client attached buffers: 1"))

      restore()
    end)
  end)

  describe("JdtlsQuiet", function()
    it("runs codelens and notifies", function()
      -- Arrange
      local original_run = vim.lsp.codelens.run
      local spy_fn, spy_data = helpers.spy()
      vim.lsp.codelens.run = spy_fn

      -- Act
      vim.cmd("JdtlsQuiet")

      -- Assert
      helpers.assert_called(spy_data, 1)
      helpers.assert_called_with(
        notify_spy_data,
        "JDTLS quiet mode toggled",
        "info"
      )

      vim.lsp.codelens.run = original_run
    end)
  end)

  describe("JdtlsBuild", function()
    it("issues the java.project.buildWorkspace command and notifies", function()
      -- Arrange
      local original_execute = vim.lsp.buf.execute_command
      local spy_fn, spy_data = helpers.spy()
      vim.lsp.buf.execute_command = spy_fn

      -- Act
      vim.cmd("JdtlsBuild")

      -- Assert
      helpers.assert_called(spy_data, 1)
      assert.same({
        command = "java.project.buildWorkspace",
        arguments = { true },
      }, spy_data.last_call[1])
      helpers.assert_called_with(
        notify_spy_data,
        "JDTLS build initiated",
        "info"
      )

      vim.lsp.buf.execute_command = original_execute
    end)
  end)
end)
