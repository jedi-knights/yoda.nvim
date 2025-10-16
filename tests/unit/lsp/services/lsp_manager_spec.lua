-- tests/unit/lsp/services/lsp_manager_spec.lua
-- Tests for LSP manager service

describe("LSPManager", function()
  local lsp_manager_factory = require("yoda.lsp.services.lsp_manager")
  local helpers = require("tests.helpers")

  local mock_logger
  local mock_diagnostics
  local lsp_manager

  before_each(function()
    -- Create mock dependencies
    mock_logger = {
      debug = helpers.spy(),
      error = helpers.spy(),
    }

    mock_diagnostics = {}

    -- Create LSP manager with mocked dependencies
    lsp_manager = lsp_manager_factory.new(mock_logger, mock_diagnostics)
  end)

  describe("new()", function()
    it("creates LSP manager with dependencies", function()
      assert.is_not_nil(lsp_manager)
      assert.is_table(lsp_manager)
    end)
  end)

  describe("register_server()", function()
    it("registers server with valid name and config", function()
      local config = { filetypes = { "lua" } }
      local result = lsp_manager:register_server("lua_ls", config)

      assert.is_true(result)
      assert.is_true(lsp_manager:is_server_registered("lua_ls"))
    end)

    it("rejects invalid server name", function()
      local result = lsp_manager:register_server("", {})
      assert.is_false(result)
      helpers.assert_called(mock_logger.error)
    end)

    it("rejects invalid config", function()
      local result = lsp_manager:register_server("test", "not_a_table")
      assert.is_false(result)
      helpers.assert_called(mock_logger.error)
    end)
  end)

  describe("setup_lazy_loading()", function()
    it("sets up lazy loading with valid parameters", function()
      local result = lsp_manager:setup_lazy_loading("lua_ls", { "lua" })
      assert.is_true(result)
    end)

    it("rejects invalid server name", function()
      local result = lsp_manager:setup_lazy_loading("", { "lua" })
      assert.is_false(result)
      helpers.assert_called(mock_logger.error)
    end)

    it("rejects empty filetypes", function()
      local result = lsp_manager:setup_lazy_loading("lua_ls", {})
      assert.is_false(result)
      helpers.assert_called(mock_logger.error)
    end)
  end)

  describe("get_enabled_servers()", function()
    it("returns empty table initially", function()
      local enabled = lsp_manager:get_enabled_servers()
      assert.is_table(enabled)
      assert.are.equal(0, vim.tbl_count(enabled))
    end)
  end)

  describe("is_server_registered()", function()
    it("returns false for unregistered server", function()
      assert.is_false(lsp_manager:is_server_registered("nonexistent"))
    end)

    it("returns true for registered server", function()
      lsp_manager:register_server("test_server", { filetypes = { "test" } })
      assert.is_true(lsp_manager:is_server_registered("test_server"))
    end)
  end)

  describe("get_server_config()", function()
    it("returns nil for unregistered server", function()
      assert.is_nil(lsp_manager:get_server_config("nonexistent"))
    end)

    it("returns config for registered server", function()
      local config = { filetypes = { "test" } }
      lsp_manager:register_server("test_server", config)

      local retrieved = lsp_manager:get_server_config("test_server")
      assert.are.same(config, retrieved)
    end)
  end)
end)
