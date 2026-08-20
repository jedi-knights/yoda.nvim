-- tests/yoda/keymaps/javascript_spec.lua
local helpers = require("tests.helpers")

describe("keymaps.javascript", function()
  local buf
  local notify_spy_fn, notify_spy_data
  local cmd_spy_fn, cmd_spy_data
  local original_vim_cmd

  local function get_callback(desc)
    for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
      if km.desc == desc then
        return km.callback
      end
    end
    error("no keymap registered with desc: " .. desc)
  end

  before_each(function()
    package.loaded["yoda.keymaps.javascript"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }
    require("yoda.keymaps.javascript")

    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "/tmp/yoda_js_spec_" .. buf .. ".ts")
    vim.api.nvim_set_current_buf(buf)

    local original_eventignore = vim.o.eventignore
    vim.o.eventignore = ""
    vim.bo[buf].filetype = "typescript"
    vim.o.eventignore = original_eventignore

    cmd_spy_fn, cmd_spy_data = helpers.spy()
    original_vim_cmd = vim.cmd
    vim.cmd = cmd_spy_fn
  end)

  after_each(function()
    vim.cmd = original_vim_cmd
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded["snacks.terminal"] = nil
    package.loaded["neotest"] = nil
    package.loaded["dap"] = nil
    package.loaded["trouble"] = nil
    if buf and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  it("<leader>jr shells out to node on the current file", function()
    -- Act
    get_callback("JavaScript: Run Node.js file")()

    -- Assert
    assert.matches("^!node ", cmd_spy_data.last_call[1])
  end)

  it("<leader>jn opens a Node REPL terminal", function()
    -- Arrange
    local toggle_spy, toggle_data = helpers.spy()
    package.loaded["snacks.terminal"] = { toggle = toggle_spy }

    -- Act
    get_callback("JavaScript: Open Node REPL")()

    -- Assert
    helpers.assert_called(toggle_data, 1)
    assert.equals("node", toggle_data.last_call[1])
    assert.same({ "node" }, toggle_data.last_call[2].cmd)
  end)

  for _, desc in ipairs({
    "JavaScript: Test nearest",
    "JavaScript: Test file",
    "JavaScript: Test suite",
  }) do
    it(desc .. " notifies when neotest is unavailable", function()
      -- Act
      get_callback(desc)()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Neotest not available. Install via :Lazy sync",
        "error"
      )
    end)

    it(desc .. " runs neotest when available", function()
      -- Arrange
      local run_spy, run_data = helpers.spy()
      package.loaded["neotest"] = { run = { run = run_spy } }

      -- Act
      get_callback(desc)()

      -- Assert
      helpers.assert_called(run_data, 1)
    end)
  end

  describe("<leader>jd (start debugger)", function()
    it("notifies when DAP is unavailable", function()
      -- Act
      get_callback("JavaScript: Start debugger")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "DAP not available. Install via :Lazy sync",
        "error"
      )
    end)

    it("starts DAP when available", function()
      -- Arrange
      local continue_spy, continue_data = helpers.spy()
      package.loaded["dap"] = { continue = continue_spy }

      -- Act
      get_callback("JavaScript: Start debugger")()

      -- Assert
      helpers.assert_called(continue_data, 1)
    end)
  end)

  describe("<leader>jo (toggle outline)", function()
    after_each(function()
      pcall(vim.api.nvim_del_user_command, "AerialToggle")
    end)

    it("notifies when aerial is unavailable", function()
      -- Act
      vim.cmd = original_vim_cmd
      get_callback("JavaScript: Toggle outline")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Aerial not available. Install via :Lazy sync",
        "error"
      )
    end)

    it("does not notify when AerialToggle exists", function()
      -- Arrange
      vim.cmd = original_vim_cmd
      vim.api.nvim_create_user_command("AerialToggle", function() end, {})

      -- Act
      get_callback("JavaScript: Toggle outline")()

      -- Assert
      helpers.assert_not_called(notify_spy_data)
    end)
  end)

  describe("<leader>je (open diagnostics)", function()
    it(
      "falls back to the diagnostic loclist when trouble is unavailable",
      function()
        -- Arrange
        local setloclist_spy, setloclist_data = helpers.spy()
        local original_setloclist = vim.diagnostic.setloclist
        vim.diagnostic.setloclist = setloclist_spy

        -- Act
        get_callback("JavaScript: Open diagnostics")()

        -- Assert
        helpers.assert_called(setloclist_data, 1)
        helpers.assert_not_called(cmd_spy_data)

        vim.diagnostic.setloclist = original_setloclist
      end
    )

    it("opens Trouble when available", function()
      -- Arrange
      package.loaded["trouble"] = {}

      -- Act
      get_callback("JavaScript: Open diagnostics")()

      -- Assert
      helpers.assert_called_with(
        cmd_spy_data,
        "Trouble diagnostics toggle filter.buf=0"
      )
    end)
  end)

  it("<leader>jI organizes imports via a source code action", function()
    -- Arrange
    local action_spy, action_data = helpers.spy()
    local original_code_action = vim.lsp.buf.code_action
    vim.lsp.buf.code_action = action_spy

    -- Act
    get_callback("JavaScript: Organize imports")()

    -- Assert
    helpers.assert_called(action_data, 1)
    assert.is_true(action_data.last_call[1].apply)
    assert.same(
      { "source.organizeImports" },
      action_data.last_call[1].context.only
    )

    vim.lsp.buf.code_action = original_code_action
  end)

  describe("<leader>jh (toggle inlay hints)", function()
    local original_enable, original_is_enabled

    before_each(function()
      original_enable = vim.lsp.inlay_hint.enable
      original_is_enabled = vim.lsp.inlay_hint.is_enabled
    end)

    after_each(function()
      vim.lsp.inlay_hint.enable = original_enable
      vim.lsp.inlay_hint.is_enabled = original_is_enabled
    end)

    it("enables hints when currently disabled", function()
      -- Arrange
      vim.lsp.inlay_hint.is_enabled = function()
        return false
      end
      local enable_spy, enable_data = helpers.spy()
      vim.lsp.inlay_hint.enable = enable_spy

      -- Act
      get_callback("JavaScript: Toggle inlay hints")()

      -- Assert
      helpers.assert_called_with(enable_data, true)
    end)

    it("disables hints when currently enabled", function()
      -- Arrange
      vim.lsp.inlay_hint.is_enabled = function()
        return true
      end
      local enable_spy, enable_data = helpers.spy()
      vim.lsp.inlay_hint.enable = enable_spy

      -- Act
      get_callback("JavaScript: Toggle inlay hints")()

      -- Assert
      helpers.assert_called_with(enable_data, false)
    end)
  end)

  it(
    "<leader>jl inserts a console.log for the word under the cursor",
    function()
      -- Arrange
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "myVar" })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      local append_spy, append_data = helpers.spy()
      local original_append = vim.fn.append
      vim.fn.append = append_spy

      -- Act
      get_callback("JavaScript: Insert console.log")()

      -- Assert
      helpers.assert_called_with(
        append_data,
        1,
        'console.log("myVar:", myVar);'
      )

      vim.fn.append = original_append
    end
  )

  it("<leader>jL removes console.log statements and notifies", function()
    -- Act
    get_callback("JavaScript: Remove console.logs")()

    -- Assert
    helpers.assert_called_with(cmd_spy_data, [[%g/console\.log/d]])
    helpers.assert_called_with(
      notify_spy_data,
      "Removed all console.log statements",
      "info"
    )
  end)
end)
