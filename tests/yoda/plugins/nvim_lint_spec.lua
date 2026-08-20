-- tests/yoda/plugins/nvim_lint_spec.lua
local helpers = require("tests.helpers")

describe("plugins.nvim-lint", function()
  local spec
  local original_findfile, original_expand, original_filereadable

  local function fresh_lint_stub()
    return {
      linters_by_ft = {},
      linters = {},
      try_lint = function() end,
    }
  end

  before_each(function()
    package.loaded["yoda.plugins.nvim-lint"] = nil
    spec = require("yoda.plugins.nvim-lint")

    package.loaded["lint.linters.golangcilint"] = { parser = "stub-parser" }

    original_findfile = vim.fn.findfile
    original_expand = vim.fn.expand
    original_filereadable = vim.fn.filereadable
    -- Default: no project or user golangci-lint config found.
    vim.fn.findfile = function()
      return ""
    end
    vim.fn.expand = function(arg)
      return original_expand(arg)
    end
    vim.fn.filereadable = function()
      return 0
    end
  end)

  after_each(function()
    vim.fn.findfile = original_findfile
    vim.fn.expand = original_expand
    vim.fn.filereadable = original_filereadable
    package.loaded.lint = nil
    package.loaded["lint.linters.golangcilint"] = nil
    pcall(vim.api.nvim_del_augroup_by_name, "YodaLint")
    pcall(vim.api.nvim_del_augroup_by_name, "YodaLintGo")
  end)

  it("declares nvim-lint, deferred to buffer read events", function()
    -- Assert
    assert.equals("mfussenegger/nvim-lint", spec[1])
    assert.same({ "BufReadPre", "BufNewFile" }, spec.event)
  end)

  it("assigns linters_by_ft for every language yoda formats", function()
    -- Arrange
    local lint = fresh_lint_stub()
    package.loaded.lint = lint

    -- Act
    spec.config()

    -- Assert
    assert.same({ "clippy" }, lint.linters_by_ft.rust)
    assert.same({ "ruff" }, lint.linters_by_ft.python)
    assert.same({ "biome" }, lint.linters_by_ft.javascript)
    assert.same({ "markdownlint" }, lint.linters_by_ft.markdown)
  end)

  describe("golangci-lint arg resolution", function()
    it(
      "omits --config when neither a project nor a user config exists",
      function()
        -- Arrange
        local lint = fresh_lint_stub()
        package.loaded.lint = lint

        -- Act
        spec.config()

        -- Assert
        assert.is_false(
          vim.tbl_contains(lint.linters.golangcilint.args, "--config")
        )
        assert.equals("run", lint.linters.golangcilint.args[1])
      end
    )

    it("prefers a project-level .golangci.yml when present", function()
      -- Arrange
      vim.fn.findfile = function(name)
        if name == ".golangci.yml" then
          return ".golangci.yml"
        end
        return ""
      end
      local lint = fresh_lint_stub()
      package.loaded.lint = lint

      -- Act
      spec.config()

      -- Assert
      local args = lint.linters.golangcilint.args
      local config_idx
      for i, a in ipairs(args) do
        if a == "--config" then
          config_idx = i
        end
      end
      assert.is_not_nil(config_idx)
      assert.matches("%.golangci%.yml$", args[config_idx + 1])
    end)

    it(
      "falls back to the user-level config when no project config exists",
      function()
        -- Arrange
        vim.fn.filereadable = function()
          return 1
        end
        local lint = fresh_lint_stub()
        package.loaded.lint = lint

        -- Act
        spec.config()

        -- Assert
        local args = lint.linters.golangcilint.args
        local config_idx
        for i, a in ipairs(args) do
          if a == "--config" then
            config_idx = i
          end
        end
        assert.is_not_nil(config_idx)
        assert.matches("golangci%-lint/config%.yml$", args[config_idx + 1])
      end
    )

    it("registers golangcilint using nvim-lint's own parser", function()
      -- Arrange
      local lint = fresh_lint_stub()
      package.loaded.lint = lint

      -- Act
      spec.config()

      -- Assert
      assert.equals("stub-parser", lint.linters.golangcilint.parser)
      assert.equals("golangci-lint", lint.linters.golangcilint.cmd)
    end)
  end)

  describe("lint-on-save autocmds", function()
    it("lints on save when the buffer is modifiable", function()
      -- Arrange
      local lint = fresh_lint_stub()
      local try_lint_spy, try_lint_data = helpers.spy()
      lint.try_lint = try_lint_spy
      package.loaded.lint = lint
      spec.config()
      local callback = vim.api.nvim_get_autocmds({
        group = "YodaLint",
        event = "BufWritePost",
      })[1].callback

      -- Act
      callback()

      -- Assert
      helpers.assert_called(try_lint_data, 1)
      assert.equals(0, #try_lint_data.last_call)
    end)

    it("skips linting on save for a non-modifiable buffer", function()
      -- Arrange
      local lint = fresh_lint_stub()
      local try_lint_spy, try_lint_data = helpers.spy()
      lint.try_lint = try_lint_spy
      package.loaded.lint = lint
      spec.config()
      local callback = vim.api.nvim_get_autocmds({
        group = "YodaLint",
        event = "BufWritePost",
      })[1].callback
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.bo[buf].modifiable = false

      -- Act
      callback()

      -- Assert
      helpers.assert_not_called(try_lint_data)

      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it(
      "always runs golangci-lint on *.go saves regardless of modifiable state",
      function()
        -- Arrange
        local lint = fresh_lint_stub()
        local try_lint_spy, try_lint_data = helpers.spy()
        lint.try_lint = try_lint_spy
        package.loaded.lint = lint
        spec.config()
        local callback = vim.api.nvim_get_autocmds({
          group = "YodaLintGo",
          event = "BufWritePost",
        })[1].callback

        -- Act
        callback()

        -- Assert
        helpers.assert_called_with(try_lint_data, "golangcilint")
      end
    )
  end)
end)
