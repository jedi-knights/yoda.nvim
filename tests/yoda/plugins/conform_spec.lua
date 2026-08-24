-- tests/yoda/plugins/conform_spec.lua
local helpers = require("tests.helpers")
local formatter_registry = require("yoda.core.formatter_registry")

describe("plugins.conform", function()
  local spec
  local original_autoformat

  before_each(function()
    formatter_registry._reset()
    package.loaded["yoda.plugins.conform"] = nil
    spec = require("yoda.plugins.conform")
    original_autoformat = vim.g.autoformat
  end)

  after_each(function()
    formatter_registry._reset()
    vim.g.autoformat = original_autoformat
    package.loaded.conform = nil
  end)

  it(
    "declares conform.nvim, deferred to BufWritePre, with a format keymap",
    function()
      -- Assert
      assert.equals("stevearc/conform.nvim", spec[1])
      assert.same({ "BufWritePre" }, spec.event)
      assert.same({ "ConformInfo" }, spec.cmd)
      assert.equals("<leader>f", spec.keys[1][1])
      assert.equals("Format buffer", spec.keys[1].desc)
    end
  )

  it("initializes vim.g.autoformat to true", function()
    -- Arrange
    vim.g.autoformat = nil

    -- Act
    spec.init()

    -- Assert
    assert.is_true(vim.g.autoformat)
  end)

  it("<leader>f formats the buffer asynchronously with LSP fallback", function()
    -- Arrange
    local format_spy, format_data = helpers.spy()
    package.loaded.conform = { format = format_spy }

    -- Act
    spec.keys[1][2]()

    -- Assert
    helpers.assert_called_with(
      format_data,
      { async = true, lsp_format = "fallback" }
    )
  end)

  describe("format_on_save()", function()
    local buf

    before_each(function()
      buf = vim.api.nvim_create_buf(false, true)
    end)

    after_each(function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)

    it("returns nil when autoformat is disabled", function()
      -- Arrange
      vim.g.autoformat = false

      -- Act / Assert
      assert.is_nil(spec.opts.format_on_save(buf))
    end)

    it("returns nil for a non-modifiable buffer", function()
      -- Arrange
      vim.g.autoformat = true
      vim.bo[buf].modifiable = false

      -- Act / Assert
      assert.is_nil(spec.opts.format_on_save(buf))

      vim.bo[buf].modifiable = true
    end)

    it(
      "returns format opts when enabled and the buffer is modifiable",
      function()
        -- Arrange
        vim.g.autoformat = true
        vim.bo[buf].modifiable = true

        -- Act
        local result = spec.opts.format_on_save(buf)

        -- Assert
        assert.same({ timeout_ms = 500, lsp_format = "fallback" }, result)
      end
    )
  end)

  it("applies gofumpt's -extra flag", function()
    -- Assert
    assert.same({ "-extra" }, spec.opts.formatters.gofumpt.prepend_args)
  end)

  it("resolves formatters per filetype", function()
    -- Assert
    assert.same({ "rustfmt" }, spec.opts.formatters_by_ft.rust)
    assert.same({ "stylua" }, spec.opts.formatters_by_ft.lua)
    assert.same({ "goimports", "gofumpt" }, spec.opts.formatters_by_ft.go)
    assert.same(
      { "ruff_fix", "ruff_format" },
      spec.opts.formatters_by_ft.python
    )
    assert.equals("biome", spec.opts.formatters_by_ft.javascript[1])
    assert.is_true(spec.opts.formatters_by_ft.javascript.stop_after_first)
  end)

  describe("config() drain of formatter_registry", function()
    local setup_spy, setup_data

    before_each(function()
      setup_spy, setup_data = helpers.spy()
      package.loaded.conform = { setup = setup_spy }
    end)

    it("calls conform.setup with the received opts", function()
      -- Act
      spec.config(spec, spec.opts)

      -- Assert
      helpers.assert_called(setup_data, 1)
    end)

    it("adds registry-contributed formatters for a new filetype", function()
      -- Arrange: an extra registers formatters for a filetype conform
      -- core does not know about.
      formatter_registry.register({
        formatters_by_ft = { php = { "php_cs_fixer" } },
      })
      local opts = vim.deepcopy(spec.opts)

      -- Act
      spec.config(spec, opts)

      -- Assert: php now has the contributed pipeline; core filetypes
      -- untouched.
      assert.same({ "php_cs_fixer" }, opts.formatters_by_ft.php)
      assert.same({ "rustfmt" }, opts.formatters_by_ft.rust)
    end)

    it(
      "appends to a core filetype without displacing existing formatters",
      function()
        -- Arrange: an extra augments a filetype conform already handles.
        formatter_registry.register({
          formatters_by_ft = { markdown = { "cbfmt" } },
        })
        local opts = vim.deepcopy(spec.opts)

        -- Act
        spec.config(spec, opts)

        -- Assert: the core prettier entry stays, the contribution appends.
        assert.same({ "prettier", "cbfmt" }, opts.formatters_by_ft.markdown)
      end
    )

    it("merges custom formatter definitions from the registry", function()
      -- Arrange
      formatter_registry.register({
        formatters = {
          my_fmt = { command = "my-fmt", args = { "-w" } },
        },
      })
      local opts = vim.deepcopy(spec.opts)

      -- Act
      spec.config(spec, opts)

      -- Assert: contributed definition present alongside the core
      -- gofumpt override.
      assert.equals("my-fmt", opts.formatters.my_fmt.command)
      assert.same({ "-extra" }, opts.formatters.gofumpt.prepend_args)
    end)
  end)
end)
