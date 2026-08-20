-- tests/yoda/plugins/conform_spec.lua
local helpers = require("tests.helpers")

describe("plugins.conform", function()
  local spec
  local original_autoformat

  before_each(function()
    package.loaded["yoda.plugins.conform"] = nil
    spec = require("yoda.plugins.conform")
    original_autoformat = vim.g.autoformat
  end)

  after_each(function()
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
end)
