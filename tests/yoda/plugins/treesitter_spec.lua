-- tests/yoda/plugins/treesitter_spec.lua
local helpers = require("tests.helpers")

describe("plugins.treesitter", function()
  local spec
  local original_executable

  local function fresh_ts_stub(installed)
    return {
      setup = function() end,
      get_installed = function()
        return installed or {}
      end,
      indentexpr = function() end,
      install = function() end,
    }
  end

  before_each(function()
    package.loaded["yoda.plugins.treesitter"] = nil
    spec = require("yoda.plugins.treesitter")
    package.loaded["nvim-treesitter.parsers"] = {}
    package.loaded["nvim-treesitter-textobjects"] = { setup = function() end }
    package.loaded["nvim-treesitter-textobjects.select"] =
      { select_textobject = function() end }
    original_executable = vim.fn.executable
  end)

  after_each(function()
    vim.fn.executable = original_executable
    package.loaded["nvim-treesitter"] = nil
    package.loaded["nvim-treesitter.parsers"] = nil
    package.loaded["nvim-treesitter-textobjects"] = nil
    package.loaded["nvim-treesitter-textobjects.select"] = nil
    _G.YodaTSIndent = nil
    pcall(vim.api.nvim_del_augroup_by_name, "YodaTreesitter")
  end)

  it("declares nvim-treesitter, loaded eagerly on the main branch", function()
    -- Assert
    assert.equals("nvim-treesitter/nvim-treesitter", spec[1])
    assert.equals("main", spec.branch)
    assert.equals(":TSUpdate", spec.build)
    assert.is_false(spec.lazy)
    assert.equals("main", spec.dependencies[1].branch)
  end)

  it("registers the gherkin parser info when TSUpdate fires", function()
    -- Arrange
    package.loaded["nvim-treesitter"] = fresh_ts_stub({})
    spec.config()
    local callback =
      vim.api.nvim_get_autocmds({ pattern = "TSUpdate" })[1].callback

    -- Act
    callback()

    -- Assert
    local gherkin = package.loaded["nvim-treesitter.parsers"].gherkin
    assert.is_not_nil(gherkin)
    assert.matches("tree%-sitter%-gherkin", gherkin.install_info.url)
  end)

  describe("missing-parser install", function()
    it(
      "errors when tree-sitter CLI is missing instead of installing",
      function()
        -- Arrange
        package.loaded["nvim-treesitter"] = fresh_ts_stub({})
        vim.fn.executable = function()
          return 0
        end
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        spec.config()

        -- Assert
        assert.matches("tree%-sitter.*CLI not found", notify_data.last_call[1])
        restore()
      end
    )

    it("installs every missing parser when the CLI is available", function()
      -- Arrange
      local install_spy, install_data = helpers.spy()
      local ts = fresh_ts_stub({ "lua" })
      ts.install = install_spy
      package.loaded["nvim-treesitter"] = ts
      vim.fn.executable = function()
        return 1
      end

      -- Act
      spec.config()

      -- Assert
      helpers.assert_called(install_data, 1)
      local missing = install_data.last_call[1]
      assert.is_false(vim.tbl_contains(missing, "lua"))
      assert.is_true(vim.tbl_contains(missing, "gherkin"))
    end)

    it(
      "does not install anything when every parser is already present",
      function()
        -- Arrange
        local install_spy, install_data = helpers.spy()
        local ts = fresh_ts_stub({
          "lua",
          "vim",
          "vimdoc",
          "python",
          "rust",
          "go",
          "javascript",
          "typescript",
          "c_sharp",
          "json",
          "yaml",
          "toml",
          "markdown",
          "markdown_inline",
          "bash",
          "regex",
          "gherkin",
        })
        ts.install = install_spy
        package.loaded["nvim-treesitter"] = ts
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        spec.config()

        -- Assert
        helpers.assert_not_called(install_data)
        helpers.assert_not_called(notify_data)
        restore()
      end
    )
  end)

  it("caches indentexpr on _G.YodaTSIndent", function()
    -- Arrange
    local indent_fn = function() end
    local ts = fresh_ts_stub({})
    ts.indentexpr = indent_fn
    package.loaded["nvim-treesitter"] = ts

    -- Act
    spec.config()

    -- Assert
    assert.equals(indent_fn, _G.YodaTSIndent)
  end)

  describe("FileType highlight/indent autocmd", function()
    local buf

    before_each(function()
      package.loaded["nvim-treesitter"] = fresh_ts_stub({})
      spec.config()
      buf = vim.api.nvim_create_buf(false, true)
    end)

    after_each(function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)

    it("sets indentexpr when the parser starts successfully", function()
      -- Arrange
      local callback = vim.api.nvim_get_autocmds({
        group = "YodaTreesitter",
        event = "FileType",
      })[1].callback
      vim.bo[buf].filetype = "lua"

      -- Act
      callback({ buf = buf })

      -- Assert
      assert.equals("v:lua.YodaTSIndent()", vim.bo[buf].indentexpr)
    end)

    it("leaves indentexpr untouched when the parser can't start", function()
      -- Arrange
      local callback = vim.api.nvim_get_autocmds({
        group = "YodaTreesitter",
        event = "FileType",
      })[1].callback
      -- No filetype/parser is installed for a plain scratch buffer's
      -- default filetype, so vim.treesitter.start genuinely fails here.
      local original_indentexpr = vim.bo[buf].indentexpr

      -- Act
      local ok = pcall(callback, { buf = buf })

      -- Assert
      assert.is_true(ok)
      assert.equals(original_indentexpr, vim.bo[buf].indentexpr)
    end)
  end)

  it("configures textobjects with lookahead selection", function()
    -- Arrange
    local setup_spy, setup_data = helpers.spy()
    package.loaded["nvim-treesitter"] = fresh_ts_stub({})
    package.loaded["nvim-treesitter-textobjects"] = { setup = setup_spy }

    -- Act
    spec.config()

    -- Assert
    helpers.assert_called_with(setup_data, { select = { lookahead = true } })
  end)

  describe("textobjects keymaps", function()
    before_each(function()
      package.loaded["nvim-treesitter"] = fresh_ts_stub({})
      spec.config()
    end)

    local function find_keymap(lhs)
      for _, km in ipairs(vim.api.nvim_get_keymap("x")) do
        if km.lhs == lhs then
          return km
        end
      end
      return nil
    end

    it("registers around/inside function and class text objects", function()
      -- Assert
      assert.is_not_nil(find_keymap("af"))
      assert.is_not_nil(find_keymap("if"))
      assert.is_not_nil(find_keymap("ac"))
      assert.is_not_nil(find_keymap("ic"))
    end)

    it("'af' selects the outer function text object", function()
      -- Arrange
      local select_spy, select_data = helpers.spy()
      package.loaded["nvim-treesitter-textobjects.select"] =
        { select_textobject = select_spy }
      local callback = find_keymap("af").callback

      -- Act
      callback()

      -- Assert
      helpers.assert_called_with(select_data, "@function.outer", "textobjects")
    end)

    it("'if' selects the inner function text object", function()
      -- Arrange
      local select_spy, select_data = helpers.spy()
      package.loaded["nvim-treesitter-textobjects.select"] =
        { select_textobject = select_spy }
      local callback = find_keymap("if").callback

      -- Act
      callback()

      -- Assert
      helpers.assert_called_with(select_data, "@function.inner", "textobjects")
    end)

    it("'ac' selects the outer class text object", function()
      -- Arrange
      local select_spy, select_data = helpers.spy()
      package.loaded["nvim-treesitter-textobjects.select"] =
        { select_textobject = select_spy }
      local callback = find_keymap("ac").callback

      -- Act
      callback()

      -- Assert
      helpers.assert_called_with(select_data, "@class.outer", "textobjects")
    end)

    it("'ic' selects the inner class text object", function()
      -- Arrange
      local select_spy, select_data = helpers.spy()
      package.loaded["nvim-treesitter-textobjects.select"] =
        { select_textobject = select_spy }
      local callback = find_keymap("ic").callback

      -- Act
      callback()

      -- Assert
      helpers.assert_called_with(select_data, "@class.inner", "textobjects")
    end)
  end)

  it("sets the Gherkin commentstring for .feature files", function()
    -- Arrange
    package.loaded["nvim-treesitter"] = fresh_ts_stub({})
    spec.config()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    local callback =
      vim.api.nvim_get_autocmds({ pattern = "feature" })[1].callback

    -- Act
    callback()

    -- Assert
    assert.equals("# %s", vim.bo.commentstring)

    vim.api.nvim_buf_delete(buf, { force = true })
  end)
end)
