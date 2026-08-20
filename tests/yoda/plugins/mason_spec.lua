-- tests/yoda/plugins/mason_spec.lua
local helpers = require("tests.helpers")

describe("plugins.mason", function()
  local specs

  local function by_name(name)
    for _, spec in ipairs(specs) do
      if spec[1] == name then
        return spec
      end
    end
    return nil
  end

  before_each(function()
    package.loaded["yoda.plugins.mason"] = nil
    specs = require("yoda.plugins.mason")
  end)

  after_each(function()
    package.loaded.mason = nil
    package.loaded["mason-lspconfig"] = nil
    package.loaded["mason-nvim-dap"] = nil
  end)

  it(
    "declares mason.nvim, mason-lspconfig, and mason-nvim-dap deferred to VeryLazy",
    function()
      -- Assert
      local mason_spec = by_name("williamboman/mason.nvim")
      local lspconfig_spec = by_name("williamboman/mason-lspconfig.nvim")
      local dap_spec = by_name("jay-babu/mason-nvim-dap.nvim")

      assert.is_not_nil(mason_spec)
      assert.equals("VeryLazy", mason_spec.event)
      assert.equals(":MasonUpdate", mason_spec.build)

      assert.is_not_nil(lspconfig_spec)
      assert.same({ "williamboman/mason.nvim" }, lspconfig_spec.dependencies)

      assert.is_not_nil(dap_spec)
      assert.is_true(
        vim.tbl_contains(dap_spec.dependencies, "williamboman/mason.nvim")
      )
      assert.is_true(
        vim.tbl_contains(dap_spec.dependencies, "mfussenegger/nvim-dap")
      )
    end
  )

  describe("mason.nvim config()", function()
    local mason_spec

    before_each(function()
      mason_spec = by_name("williamboman/mason.nvim")
    end)

    it("warns when mason is unavailable", function()
      -- Arrange
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      mason_spec.config()

      -- Assert
      assert.matches("Failed to load mason", notify_data.last_call[1])

      restore()
    end)

    it("warns when mason.setup() raises", function()
      -- Arrange
      package.loaded.mason = {
        setup = function()
          error("boom")
        end,
      }
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      mason_spec.config()

      -- Assert
      assert.matches("mason%.setup failed", notify_data.last_call[1])

      restore()
    end)

    it("does not notify when mason.setup() succeeds", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      package.loaded.mason = { setup = setup_spy }
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      mason_spec.config()

      -- Assert
      helpers.assert_called(setup_data, 1)
      helpers.assert_not_called(notify_data)

      restore()
    end)
  end)

  describe("mason-lspconfig.nvim config()", function()
    local lspconfig_spec

    before_each(function()
      lspconfig_spec = by_name("williamboman/mason-lspconfig.nvim")
    end)

    it(
      "configures yoda.lsp first, then hands installed-server setup to mason-lspconfig",
      function()
        -- Arrange
        local setup_spy, setup_data = helpers.spy()
        package.loaded["mason-lspconfig"] = { setup = setup_spy }

        -- Act
        lspconfig_spec.config()

        -- Assert
        helpers.assert_called(setup_data, 1)
        local passed_opts = setup_data.last_call[1]
        assert.is_true(vim.tbl_contains(passed_opts.ensure_installed, "gopls"))
        assert.is_true(
          vim.tbl_contains(passed_opts.ensure_installed, "basedpyright")
        )
        assert.equals("function", type(passed_opts.handlers[1]))
      end
    )

    it(
      "the default handler no-ops for both pyright and other servers",
      function()
        -- Arrange
        local setup_spy, setup_data = helpers.spy()
        package.loaded["mason-lspconfig"] = { setup = setup_spy }
        lspconfig_spec.config()
        local handler = setup_data.last_call[1].handlers[1]

        -- Act / Assert: yoda.lsp.setup() already disables pyright; the
        -- handler just needs to not double-configure it or error for any
        -- server name.
        assert.is_true(pcall(handler, "pyright"))
        assert.is_true(pcall(handler, "gopls"))
      end
    )
  end)

  describe("mason-nvim-dap.nvim config()", function()
    it("installs the DAP adapters yoda's language extras rely on", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      package.loaded["mason-nvim-dap"] = { setup = setup_spy }
      local dap_spec = by_name("jay-babu/mason-nvim-dap.nvim")

      -- Act
      dap_spec.config()

      -- Assert
      helpers.assert_called(setup_data, 1)
      local passed_opts = setup_data.last_call[1]
      assert.same(
        { "codelldb", "debugpy", "delve", "js-debug-adapter" },
        passed_opts.ensure_installed
      )
      assert.is_true(passed_opts.automatic_installation)
    end)
  end)
end)
