-- tests/yoda/commands/diagnostics_spec.lua
local helpers = require("tests.helpers")

describe("commands.diagnostics", function()
  local logger
  local logger_infos
  local logger_errors
  local original_logger
  local original_diagnostics
  local original_diagnostics_ai
  local original_blink_cmp
  local original_get_clients

  local function clear_commands()
    pcall(vim.api.nvim_del_user_command, "YodaDiagnostics")
    pcall(vim.api.nvim_del_user_command, "YodaAICheck")
    pcall(vim.api.nvim_del_user_command, "YodaCmpStatus")
  end

  before_each(function()
    -- Spy'd logger so we can observe info/error calls made from
    -- YodaCmpStatus. The command re-requires the logger each invocation,
    -- so we swap package.loaded rather than the stub's function table.
    logger_infos = {}
    logger_errors = {}
    logger = {
      trace = function() end,
      debug = function() end,
      info = function(msg, ctx)
        table.insert(logger_infos, { msg = msg, ctx = ctx })
      end,
      warn = function() end,
      error = function(msg, ctx)
        table.insert(logger_errors, { msg = msg, ctx = ctx })
      end,
      set_strategy = function() end,
      set_level = function() end,
    }
    original_logger = package.loaded["yoda-logging.logger"]
    package.loaded["yoda-logging.logger"] = logger

    original_diagnostics = package.loaded["yoda-diagnostics"]
    original_diagnostics_ai = package.loaded["yoda-diagnostics.ai"]
    original_blink_cmp = package.loaded["blink.cmp"]
    original_get_clients = vim.lsp.get_clients

    clear_commands()
    package.loaded["yoda.commands.diagnostics"] = nil
    require("yoda.commands.diagnostics").setup()
  end)

  after_each(function()
    clear_commands()
    package.loaded["yoda-logging.logger"] = original_logger
    package.loaded["yoda-diagnostics"] = original_diagnostics
    package.loaded["yoda-diagnostics.ai"] = original_diagnostics_ai
    package.loaded["blink.cmp"] = original_blink_cmp
    vim.lsp.get_clients = original_get_clients
    package.loaded["yoda.commands.diagnostics"] = nil
  end)

  describe("setup()", function()
    it("registers all three diagnostic commands", function()
      -- Assert
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.YodaDiagnostics)
      assert.is_not_nil(commands.YodaAICheck)
      assert.is_not_nil(commands.YodaCmpStatus)
    end)

    it("sets descriptive help strings on each command", function()
      -- Assert
      local commands = vim.api.nvim_get_commands({})
      assert.matches("diagnostics", commands.YodaDiagnostics.definition)
      assert.matches("AI", commands.YodaAICheck.definition)
      assert.matches("completion", commands.YodaCmpStatus.definition)
    end)
  end)

  describe(":YodaDiagnostics", function()
    it("delegates to yoda-diagnostics.run_all", function()
      -- Arrange
      local run_all_spy, run_all_data = helpers.spy()
      package.loaded["yoda-diagnostics"] = { run_all = run_all_spy }

      -- Act
      vim.api.nvim_exec2("YodaDiagnostics", {})

      -- Assert
      helpers.assert_called(run_all_data, 1)
    end)
  end)

  describe(":YodaAICheck", function()
    it("delegates to yoda-diagnostics.ai.display_detailed_check", function()
      -- Arrange
      local check_spy, check_data = helpers.spy()
      package.loaded["yoda-diagnostics.ai"] = {
        display_detailed_check = check_spy,
      }

      -- Act
      vim.api.nvim_exec2("YodaAICheck", {})

      -- Assert
      helpers.assert_called(check_data, 1)
    end)
  end)

  describe(":YodaCmpStatus", function()
    it("logs success when blink.cmp loads", function()
      -- Arrange
      package.loaded["blink.cmp"] = { get_lsp_capabilities = function() end }
      vim.lsp.get_clients = function()
        return {}
      end

      -- Act
      vim.api.nvim_exec2("YodaCmpStatus", {})

      -- Assert
      local messages = vim.tbl_map(function(entry)
        return entry.msg
      end, logger_infos)
      assert.is_true(
        vim.tbl_contains(messages, "✅ blink.cmp loaded successfully")
      )
      assert.equals(0, #logger_errors)
    end)

    it("logs an error when blink.cmp fails to load", function()
      -- Arrange: force blink.cmp require to fail
      local original_preload = package.preload["blink.cmp"]
      package.loaded["blink.cmp"] = nil
      package.preload["blink.cmp"] = function()
        error("simulated blink failure")
      end
      vim.lsp.get_clients = function()
        return {}
      end

      -- Act
      vim.api.nvim_exec2("YodaCmpStatus", {})

      -- Assert
      assert.equals(1, #logger_errors)
      assert.equals("❌ blink.cmp failed to load", logger_errors[1].msg)

      package.preload["blink.cmp"] = original_preload
    end)

    it(
      "logs each LSP client with a check-mark when it advertises completionProvider",
      function()
        -- Arrange
        package.loaded["blink.cmp"] = {}
        vim.lsp.get_clients = function()
          return {
            {
              name = "gopls",
              server_capabilities = {
                completionProvider = { triggerCharacters = { "." } },
              },
            },
          }
        end

        -- Act
        vim.api.nvim_exec2("YodaCmpStatus", {})

        -- Assert
        local messages = vim.tbl_map(function(entry)
          return entry.msg
        end, logger_infos)
        assert.is_true(vim.tbl_contains(messages, "  ✅ gopls"))
      end
    )

    it(
      "logs each LSP client with an X when it lacks completionProvider",
      function()
        -- Arrange
        package.loaded["blink.cmp"] = {}
        vim.lsp.get_clients = function()
          return {
            {
              name = "null-ls",
              server_capabilities = {},
            },
          }
        end

        -- Act
        vim.api.nvim_exec2("YodaCmpStatus", {})

        -- Assert
        local messages = vim.tbl_map(function(entry)
          return entry.msg
        end, logger_infos)
        assert.is_true(
          vim.tbl_contains(messages, "  ❌ null-ls (no completion)")
        )
      end
    )

    it("handles a mix of completion-capable and non-capable clients", function()
      -- Arrange
      package.loaded["blink.cmp"] = {}
      vim.lsp.get_clients = function()
        return {
          {
            name = "gopls",
            server_capabilities = { completionProvider = {} },
          },
          {
            name = "null-ls",
            server_capabilities = {},
          },
        }
      end

      -- Act
      vim.api.nvim_exec2("YodaCmpStatus", {})

      -- Assert
      local messages = vim.tbl_map(function(entry)
        return entry.msg
      end, logger_infos)
      assert.is_true(vim.tbl_contains(messages, "  ✅ gopls"))
      assert.is_true(
        vim.tbl_contains(messages, "  ❌ null-ls (no completion)")
      )
    end)

    it("logs the header even when no LSP clients are active", function()
      -- Arrange
      package.loaded["blink.cmp"] = {}
      vim.lsp.get_clients = function()
        return {}
      end

      -- Act
      vim.api.nvim_exec2("YodaCmpStatus", {})

      -- Assert
      local messages = vim.tbl_map(function(entry)
        return entry.msg
      end, logger_infos)
      assert.is_true(
        vim.tbl_contains(
          messages,
          "🔌 LSP clients with completion capability:"
        )
      )
    end)
  end)
end)
