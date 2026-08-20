-- tests/yoda/keymaps/help_spec.lua
local helpers = require("tests.helpers")

describe("keymaps.help", function()
  local notify_spy_fn, notify_spy_data
  local original_get_clients, original_expand, original_vim_cmd

  local function get_callback()
    for _, km in ipairs(vim.api.nvim_get_keymap("n")) do
      if km.desc == "Help: Show hover/help for word under cursor" then
        return km.callback
      end
    end
    error("keymap not registered")
  end

  before_each(function()
    package.loaded["yoda.keymaps.help"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }
    require("yoda.keymaps.help")

    original_get_clients = vim.lsp.get_clients
    original_expand = vim.fn.expand
    original_vim_cmd = vim.cmd
  end)

  after_each(function()
    vim.lsp.get_clients = original_get_clients
    vim.fn.expand = original_expand
    vim.cmd = original_vim_cmd
    package.loaded["yoda-adapters.notification"] = nil
  end)

  it("shows LSP hover when a client is attached", function()
    -- Arrange
    vim.lsp.get_clients = function()
      return { { id = 1 } }
    end
    local hover_spy, hover_data = helpers.spy()
    local original_hover = vim.lsp.buf.hover
    vim.lsp.buf.hover = hover_spy

    -- Act
    get_callback()()

    -- Assert
    helpers.assert_called(hover_data, 1)

    vim.lsp.buf.hover = original_hover
  end)

  describe("without an LSP client", function()
    before_each(function()
      vim.lsp.get_clients = function()
        return {}
      end
    end)

    it("opens :help for the word under the cursor when it exists", function()
      -- Arrange
      vim.fn.expand = function()
        return "nvim"
      end
      local cmd_spy, cmd_data = helpers.spy()
      vim.cmd = cmd_spy

      -- Act
      get_callback()()

      -- Assert
      helpers.assert_called_with(cmd_data, "help nvim")
      helpers.assert_not_called(notify_spy_data)
    end)

    it("warns when no help exists for the word", function()
      -- Arrange
      vim.fn.expand = function()
        return "zzznonexistenthelptagzzz"
      end

      -- Act
      get_callback()()

      -- Assert
      assert.matches(
        "No help found for: zzznonexistenthelptagzzz",
        notify_spy_data.last_call[1]
      )
      assert.equals("warn", notify_spy_data.last_call[2])
    end)

    it("notifies when there is no word under the cursor", function()
      -- Arrange
      vim.fn.expand = function()
        return ""
      end

      -- Act
      get_callback()()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "No word under cursor",
        "info"
      )
    end)
  end)
end)
