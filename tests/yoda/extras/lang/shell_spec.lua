-- tests/yoda/extras/lang/shell_spec.lua
local helpers = require("tests.helpers")
local registry = require("yoda.core.lsp_registry")
local formatter_registry = require("yoda.core.formatter_registry")
local linter_registry = require("yoda.core.linter_registry")

describe("extras.lang.shell", function()
  local function load_module()
    package.loaded["yoda.extras.lang.shell"] = nil
    return require("yoda.extras.lang.shell")
  end

  local original_lsp_config

  before_each(function()
    registry._reset()
    formatter_registry._reset()
    linter_registry._reset()
    package.loaded["yoda.extras.lang.shell"] = nil
    original_lsp_config = vim.lsp.config
  end)

  after_each(function()
    registry._reset()
    formatter_registry._reset()
    linter_registry._reset()
    vim.lsp.config = original_lsp_config
  end)

  it("registers bashls -- one server covers bash and zsh", function()
    -- Arrange
    vim.lsp.config = function() end

    -- Act
    load_module()

    -- Assert
    assert.same({ "bashls" }, registry.servers())
    assert.same({}, registry.dap_adapters())
  end)

  it("returns an empty spec list -- LSP-only extra", function()
    -- Arrange
    vim.lsp.config = function() end

    -- Act
    local specs = load_module()

    -- Assert
    assert.same({}, specs)
  end)

  it("contributes shfmt for bash and zsh (core covers sh)", function()
    -- Arrange
    vim.lsp.config = function() end

    -- Act
    load_module()

    -- Assert
    assert.same({
      bash = { "shfmt" },
      zsh = { "shfmt" },
    }, formatter_registry.formatters_by_ft())
  end)

  it("contributes shellcheck as the linter for sh, bash, and zsh", function()
    -- Arrange
    vim.lsp.config = function() end

    -- Act
    load_module()

    -- Assert
    assert.same({
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      zsh = { "shellcheck" },
    }, linter_registry.linters_by_ft())
  end)

  it(
    "extends bashls filetypes to include zsh so *.zsh buffers get the LSP",
    function()
      -- Arrange: nvim-lspconfig ships bashls with filetypes = { bash, sh }.
      -- Add zsh here rather than in core lsp.lua because it is opt-in for
      -- users who explicitly imported this extra.
      local config_spy, config_data = helpers.spy()
      vim.lsp.config = config_spy

      -- Act
      load_module()

      -- Assert
      helpers.assert_called(config_data, 1)
      assert.equals("bashls", config_data.last_call[1])
      assert.same({ "bash", "sh", "zsh" }, config_data.last_call[2].filetypes)
    end
  )
end)
