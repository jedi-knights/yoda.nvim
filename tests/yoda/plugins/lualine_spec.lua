-- tests/yoda/plugins/lualine_spec.lua
local helpers = require("tests.helpers")

describe("plugins.lualine", function()
  local original_diagnostic_status, original_lsp_status

  before_each(function()
    original_diagnostic_status = vim.diagnostic.status
    original_lsp_status = vim.lsp.status
  end)

  after_each(function()
    vim.diagnostic.status = original_diagnostic_status
    vim.lsp.status = original_lsp_status
    package.loaded["yoda.plugins.lualine"] = nil
    package.loaded.lualine = nil
  end)

  --- has_diagnostic_status/has_lsp_status are captured once at module load,
  --- so the feature-detection APIs must be stubbed before requiring.
  local function load_with(diagnostic_status_fn, lsp_status_fn)
    vim.diagnostic.status = diagnostic_status_fn
    vim.lsp.status = lsp_status_fn
    package.loaded["yoda.plugins.lualine"] = nil
    return require("yoda.plugins.lualine")
  end

  it("declares lualine.nvim, deferred to VeryLazy", function()
    -- Act
    local spec = load_with(nil, nil)

    -- Assert
    assert.equals("nvim-lualine/lualine.nvim", spec[1])
    assert.equals("VeryLazy", spec.event)
    assert.is_true(
      vim.tbl_contains(spec.dependencies, "echasnovski/mini.icons")
    )
  end)

  it(
    "falls back to the built-in diagnostics component when vim.diagnostic.status is absent",
    function()
      -- Arrange
      local spec = load_with(nil, nil)
      local setup_spy, setup_data = helpers.spy()
      package.loaded.lualine = { setup = setup_spy }

      -- Act
      spec.config()

      -- Assert
      assert.equals(
        "diagnostics",
        setup_data.last_call[1].sections.lualine_b[3]
      )
      assert.is_nil(setup_data.last_call[1].sections.lualine_c[3])
    end
  )

  describe("with vim.diagnostic.status and vim.lsp.status available", function()
    local spec, setup_data

    before_each(function()
      spec = load_with(function()
        return {}
      end, function()
        return ""
      end)
      local setup_spy, data = helpers.spy()
      setup_data = data
      package.loaded.lualine = { setup = setup_spy }
      spec.config()
    end)

    it("wires the diagnostic_status component into lualine_b", function()
      -- Assert
      assert.equals(
        "function",
        type(setup_data.last_call[1].sections.lualine_b[3][1])
      )
    end)

    it("formats no severities as an empty string", function()
      -- Arrange
      vim.diagnostic.status = function()
        return {}
      end
      local diagnostic_status = setup_data.last_call[1].sections.lualine_b[3][1]

      -- Act / Assert
      assert.equals("", diagnostic_status())
    end)

    it("formats each present severity with its count", function()
      -- Arrange
      local severity = vim.diagnostic.severity
      vim.diagnostic.status = function()
        return { [severity.ERROR] = 2, [severity.WARN] = 1 }
      end
      local diagnostic_status = setup_data.last_call[1].sections.lualine_b[3][1]

      -- Act
      local result = diagnostic_status()

      -- Assert
      assert.matches("2", result)
      assert.matches("1", result)
    end)

    it("wires the lsp_status component into lualine_c", function()
      -- Assert
      assert.equals(
        "function",
        type(setup_data.last_call[1].sections.lualine_c[3][1])
      )
    end)

    it("returns an empty string when there is no LSP status", function()
      -- Arrange
      vim.lsp.status = function()
        return ""
      end
      local lsp_status = setup_data.last_call[1].sections.lualine_c[3][1]

      -- Act / Assert
      assert.equals("", lsp_status())
    end)

    it("truncates long LSP status messages", function()
      -- Arrange
      vim.lsp.status = function()
        return string.rep("x", 60)
      end
      local lsp_status = setup_data.last_call[1].sections.lualine_c[3][1]

      -- Act
      local result = lsp_status()

      -- Assert
      assert.matches("%.%.%.$", result)
      assert.is_true(#result < 60)
    end)
  end)
end)
