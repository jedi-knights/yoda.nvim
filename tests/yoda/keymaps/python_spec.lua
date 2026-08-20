-- tests/yoda/keymaps/python_spec.lua
local helpers = require("tests.helpers")

describe("keymaps.python", function()
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
    package.loaded["yoda.keymaps.python"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }
    require("yoda.keymaps.python")

    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "/tmp/yoda_python_spec_" .. buf .. ".py")
    vim.api.nvim_set_current_buf(buf)

    -- minimal_init.lua sets eventignore=all for test speed, which also
    -- suppresses FileType -- lift it just long enough to fire the autocmd
    -- this module registers.
    local original_eventignore = vim.o.eventignore
    vim.o.eventignore = ""
    vim.bo[buf].filetype = "python"
    vim.o.eventignore = original_eventignore

    cmd_spy_fn, cmd_spy_data = helpers.spy()
    original_vim_cmd = vim.cmd
    vim.cmd = cmd_spy_fn
  end)

  after_each(function()
    vim.cmd = original_vim_cmd
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded["yoda.terminal.venv"] = nil
    package.loaded["snacks.terminal"] = nil
    package.loaded["neotest"] = nil
    package.loaded["dap-python"] = nil
    package.loaded["dap"] = nil
    package.loaded["trouble"] = nil
    if buf and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  it("registers a buffer-local keymap for every Python action", function()
    -- Assert
    local expected_descs = {
      "Python: Run file",
      "Python: Open REPL",
      "Python: Test nearest",
      "Python: Test file",
      "Python: Test suite",
      "Python: Debug test",
      "Python: Debug test class",
      "Python: Select venv",
      "Python: Toggle outline",
      "Python: Open diagnostics",
      "Python: Run mypy",
      "Python: Configure LSP with venv",
    }
    for _, desc in ipairs(expected_descs) do
      assert.is_not_nil(get_callback(desc), desc)
    end
  end)

  describe("<leader>pr (run file)", function()
    it("falls back to python3 when no venv is found", function()
      -- Act
      get_callback("Python: Run file")()

      -- Assert
      helpers.assert_called(cmd_spy_data, 1)
      assert.matches("^!python3 ", cmd_spy_data.last_call[1])
      helpers.assert_not_called(notify_spy_data)
    end)

    it("uses the first discovered venv's interpreter and notifies", function()
      -- Arrange
      package.loaded["yoda.terminal.venv"] = {
        find_virtual_envs = function()
          return { "/proj/.venv" }
        end,
      }

      -- Act
      get_callback("Python: Run file")()

      -- Assert
      assert.matches("^!/proj/%.venv/bin/python ", cmd_spy_data.last_call[1])
      helpers.assert_called_with(
        notify_spy_data,
        "Using venv: /proj/.venv",
        "info"
      )
    end)
  end)

  describe("<leader>pi (open REPL)", function()
    it("opens a terminal with python3 when no venv is found", function()
      -- Arrange
      local toggle_spy, toggle_data = helpers.spy()
      package.loaded["snacks.terminal"] = { toggle = toggle_spy }

      -- Act
      get_callback("Python: Open REPL")()

      -- Assert
      helpers.assert_called(toggle_data, 1)
      assert.equals("python", toggle_data.last_call[1])
      assert.same({ "python3" }, toggle_data.last_call[2].cmd)
    end)

    it("opens a terminal with the venv interpreter when found", function()
      -- Arrange
      package.loaded["yoda.terminal.venv"] = {
        find_virtual_envs = function()
          return { "/proj/.venv" }
        end,
      }
      local toggle_spy, toggle_data = helpers.spy()
      package.loaded["snacks.terminal"] = { toggle = toggle_spy }

      -- Act
      get_callback("Python: Open REPL")()

      -- Assert
      assert.same({ "/proj/.venv/bin/python" }, toggle_data.last_call[2].cmd)
    end)
  end)

  for _, case in ipairs({
    { desc = "Python: Test nearest", method = "run.run", args = {} },
    { desc = "Python: Test file", method = "run.run", args = { "expand" } },
    {
      desc = "Python: Test suite",
      method = "run.run",
      args = { { suite = true } },
    },
  }) do
    describe(case.desc, function()
      it("notifies when neotest is unavailable", function()
        -- Act
        get_callback(case.desc)()

        -- Assert
        helpers.assert_called_with(
          notify_spy_data,
          "Neotest not available. Install via :Lazy sync",
          "error"
        )
      end)

      it("runs neotest when available", function()
        -- Arrange
        local run_spy, run_data = helpers.spy()
        package.loaded["neotest"] = { run = { run = run_spy } }

        -- Act
        get_callback(case.desc)()

        -- Assert
        helpers.assert_called(run_data, 1)
      end)
    end)
  end

  describe("<leader>pd (debug test)", function()
    it(
      "falls back to plain dap.continue() when dap-python is unavailable",
      function()
        -- Arrange
        local continue_spy, continue_data = helpers.spy()
        package.loaded["dap"] = { continue = continue_spy }

        -- Act
        get_callback("Python: Debug test")()

        -- Assert
        helpers.assert_called_with(
          notify_spy_data,
          "dap-python not available. Opening standard DAP...",
          "warn"
        )
        helpers.assert_called(continue_data, 1)
      end
    )

    it("runs dap-python's test_method when available", function()
      -- Arrange
      local test_method_spy, test_method_data = helpers.spy()
      package.loaded["dap-python"] = { test_method = test_method_spy }

      -- Act
      get_callback("Python: Debug test")()

      -- Assert
      helpers.assert_called(test_method_data, 1)
      helpers.assert_not_called(notify_spy_data)
    end)
  end)

  describe("<leader>pD (debug test class)", function()
    it("notifies when dap-python is unavailable", function()
      -- Act
      get_callback("Python: Debug test class")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "dap-python not available",
        "error"
      )
    end)

    it("runs dap-python's test_class when available", function()
      -- Arrange
      local test_class_spy, test_class_data = helpers.spy()
      package.loaded["dap-python"] = { test_class = test_class_spy }

      -- Act
      get_callback("Python: Debug test class")()

      -- Assert
      helpers.assert_called(test_class_data, 1)
    end)
  end)

  describe("<leader>pv (select venv)", function()
    after_each(function()
      pcall(vim.api.nvim_del_user_command, "VenvSelect")
    end)

    it("notifies when venv-selector is unavailable", function()
      -- Act: vim.cmd is stubbed to a spy that never raises, so pcall
      -- succeeds and the "unavailable" branch is only reachable when the
      -- underlying command genuinely doesn't exist -- restore the real
      -- vim.cmd for this one assertion.
      vim.cmd = original_vim_cmd
      get_callback("Python: Select venv")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "venv-selector not available. Install via :Lazy sync",
        "error"
      )
    end)

    it("does not notify when VenvSelect exists", function()
      -- Arrange
      vim.cmd = original_vim_cmd
      vim.api.nvim_create_user_command("VenvSelect", function() end, {})

      -- Act
      get_callback("Python: Select venv")()

      -- Assert
      helpers.assert_not_called(notify_spy_data)
    end)
  end)

  describe("<leader>po (toggle outline)", function()
    after_each(function()
      pcall(vim.api.nvim_del_user_command, "AerialToggle")
    end)

    it("notifies when aerial is unavailable", function()
      -- Act
      vim.cmd = original_vim_cmd
      get_callback("Python: Toggle outline")()

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
      get_callback("Python: Toggle outline")()

      -- Assert
      helpers.assert_not_called(notify_spy_data)
    end)
  end)

  describe("<leader>pe (open diagnostics)", function()
    it(
      "falls back to the diagnostic loclist when trouble is unavailable",
      function()
        -- Arrange
        local setloclist_spy, setloclist_data = helpers.spy()
        local original_setloclist = vim.diagnostic.setloclist
        vim.diagnostic.setloclist = setloclist_spy

        -- Act
        get_callback("Python: Open diagnostics")()

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
      get_callback("Python: Open diagnostics")()

      -- Assert
      helpers.assert_called_with(
        cmd_spy_data,
        "Trouble diagnostics toggle filter.buf=0"
      )
    end)
  end)

  it("<leader>pm shells out to mypy on the current file", function()
    -- Act
    get_callback("Python: Run mypy")()

    -- Assert
    assert.matches("^!mypy ", cmd_spy_data.last_call[1])
  end)

  it("<leader>pL delegates to :ConfigurePythonLSP", function()
    -- Act
    get_callback("Python: Configure LSP with venv")()

    -- Assert
    helpers.assert_called_with(cmd_spy_data, "ConfigurePythonLSP")
  end)
end)
