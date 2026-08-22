-- tests/yoda/extras/lang/python_spec.lua
local helpers = require("tests.helpers")

describe("extras.lang.python", function()
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
    package.loaded["yoda.extras.lang.python"] = nil
    specs = require("yoda.extras.lang.python")
  end)

  after_each(function()
    package.loaded["neotest-python"] = nil
    package.loaded["yoda.terminal.venv"] = nil
    package.loaded["pytest-atlas"] = nil
    package.loaded.dap = nil
    package.loaded["dap-python"] = nil
  end)

  it("declares neotest-python, pytest-atlas, and nvim-dap-python", function()
    -- Assert
    assert.is_not_nil(by_name("nvim-neotest/neotest-python"))
    assert.is_not_nil(by_name("ocrosby/pytest-atlas.nvim"))
    assert.is_not_nil(by_name("mfussenegger/nvim-dap-python"))
  end)

  describe("neotest-python config()", function()
    local neotest_spec

    before_each(function()
      neotest_spec = by_name("nvim-neotest/neotest-python")
    end)

    it("warns when neotest-python is unavailable", function()
      -- Arrange
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      neotest_spec.config()

      -- Assert
      assert.matches("neotest%-python not available", notify_data.last_call[1])

      restore()
    end)

    describe("the python() resolver passed to the adapter", function()
      local function build_adapter()
        local captured
        package.loaded["neotest-python"] = function(opts)
          captured = opts
          return opts
        end
        neotest_spec.config()
        return captured
      end

      it(
        "falls back to exepath when yoda.terminal.venv is unavailable",
        function()
          -- Arrange
          local opts = build_adapter()

          -- Act
          local result = opts.python()

          -- Assert
          assert.matches("python3?$", result)
        end
      )

      it(
        "uses the first discovered venv's interpreter when available",
        function()
          -- Arrange
          package.loaded["yoda.terminal.venv"] = {
            find_virtual_envs = function()
              return { "/proj/.venv" }
            end,
          }
          local opts = build_adapter()

          -- Act
          local result = opts.python()

          -- Assert
          assert.equals("/proj/.venv/bin/python", result)
        end
      )

      it("falls back to exepath when no venvs are found", function()
        -- Arrange
        package.loaded["yoda.terminal.venv"] = {
          find_virtual_envs = function()
            return {}
          end,
        }
        local opts = build_adapter()

        -- Act
        local result = opts.python()

        -- Assert
        assert.matches("python3?$", result)
      end)
    end)

    it(
      "registers the adapter with yoda's neotest registry when available",
      function()
        -- Arrange
        local neotest_registry = require("yoda.core.neotest_registry")
        neotest_registry._reset()
        package.loaded["neotest-python"] = function(opts)
          return opts
        end

        -- Act
        neotest_spec.config()

        -- Assert
        assert.equals(1, #neotest_registry.adapters())
        neotest_registry._reset()
      end
    )

    it(
      "warns without registering when the neotest-python adapter factory raises",
      function()
        -- Arrange
        local neotest_registry = require("yoda.core.neotest_registry")
        neotest_registry._reset()
        package.loaded["neotest-python"] = function(_opts)
          error("neotest-python factory blew up")
        end
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        neotest_spec.config()

        -- Assert
        assert.matches("Python adapter setup failed", notify_data.last_call[1])
        assert.equals(vim.log.levels.WARN, notify_data.last_call[2])
        assert.equals(0, #neotest_registry.adapters())

        restore()
        neotest_registry._reset()
      end
    )
  end)

  describe("pytest-atlas", function()
    local pytest_atlas_spec

    before_each(function()
      pytest_atlas_spec = by_name("ocrosby/pytest-atlas.nvim")
    end)

    describe("config()", function()
      it("notifies an error when pytest-atlas is unavailable", function()
        -- Arrange
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        pytest_atlas_spec.config()

        -- Assert
        assert.matches("Failed to load pytest%-atlas", notify_data.last_call[1])

        restore()
      end)

      it("configures the snacks picker when available", function()
        -- Arrange
        local setup_spy, setup_data = helpers.spy()
        package.loaded["pytest-atlas"] = { setup = setup_spy }

        -- Act
        pytest_atlas_spec.config()

        -- Assert
        assert.equals("snacks", setup_data.last_call[1].picker)
        assert.is_false(setup_data.last_call[1].enable_keymap)
      end)

      it("notifies an error when pytest_atlas.setup() raises", function()
        -- Arrange
        package.loaded["pytest-atlas"] = {
          setup = function()
            error("boom")
          end,
        }
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        pytest_atlas_spec.config()

        -- Assert
        assert.matches("pytest%-atlas setup failed", notify_data.last_call[1])

        restore()
      end)
    end)

    describe("<leader>tt keymap", function()
      it("notifies an error when pytest-atlas is unavailable", function()
        -- Arrange
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        pytest_atlas_spec.keys[1][2]()

        -- Assert
        assert.matches("Failed to load pytest%-atlas", notify_data.last_call[1])

        restore()
      end)

      it("runs tests with the picker when available", function()
        -- Arrange
        local run_tests_spy, run_tests_data = helpers.spy()
        package.loaded["pytest-atlas"] = { run_tests = run_tests_spy }

        -- Act
        pytest_atlas_spec.keys[1][2]()

        -- Assert
        helpers.assert_called(run_tests_data, 1)
      end)
    end)
  end)

  describe("nvim-dap-python", function()
    local dap_python_spec
    local dap, dap_python

    before_each(function()
      dap_python_spec = by_name("mfussenegger/nvim-dap-python")
      dap = { configurations = { python = { { name = "existing" } } } }
      dap_python = { setup = function() end, test_runner = nil }
      package.loaded.dap = dap
      package.loaded["dap-python"] = dap_python
    end)

    it("resolves the venv python at setup time", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      dap_python.setup = setup_spy

      -- Act
      dap_python_spec.config()

      -- Assert
      helpers.assert_called(setup_data, 1)
      assert.equals("string", type(setup_data.last_call[1]))
    end)

    it("sets pytest as the test runner", function()
      -- Act
      dap_python_spec.config()

      -- Assert
      assert.equals("pytest", dap_python.test_runner)
    end)

    it(
      "patches existing python configurations with a dynamic resolver",
      function()
        -- Act
        dap_python_spec.config()

        -- Assert
        assert.equals("function", type(dap.configurations.python[1].pythonPath))
      end
    )

    it("adds a launch-with-arguments configuration", function()
      -- Act
      dap_python_spec.config()

      -- Assert
      local added = dap.configurations.python[#dap.configurations.python]
      assert.equals("Launch file with arguments", added.name)
      assert.equals("function", type(added.pythonPath))
      assert.equals("function", type(added.args))
    end)

    it("splits the launch args from vim.fn.input", function()
      -- Arrange
      dap_python_spec.config()
      local added = dap.configurations.python[#dap.configurations.python]
      local original_input = vim.fn.input
      vim.fn.input = function()
        return "--foo --bar"
      end

      -- Act
      local args = added.args()

      -- Assert
      assert.same({ "--foo", "--bar" }, args)

      vim.fn.input = original_input
    end)

    describe("pythonPath() stored on dap configurations", function()
      -- Covers the venv-hit branch of get_python_path(). Without invoking the
      -- stored closure, LuaCov silently marks the "or vim.fn.exepath(...)"
      -- fallback as the only path exercised: no test in the suite actually
      -- calls pythonPath() with vim.uv.fs_stat returning truthy.
      it("returns cwd/.venv/bin/python when the project venv exists", function()
        -- Arrange
        dap_python_spec.config()
        local added = dap.configurations.python[#dap.configurations.python]
        local restore_cwd = helpers.mock(vim.fn, "getcwd", function()
          return "/proj/py-app"
        end)
        local restore_stat = helpers.mock(vim.uv, "fs_stat", function(path)
          if path == "/proj/py-app/.venv/bin/python" then
            return { type = "file" }
          end
          return nil
        end)

        -- Act
        local result = added.pythonPath()

        -- Assert
        assert.equals("/proj/py-app/.venv/bin/python", result)

        restore_stat()
        restore_cwd()
      end)

      it(
        "falls back to vim.fn.exepath('python') when the venv is absent",
        function()
          -- Arrange
          dap_python_spec.config()
          local added = dap.configurations.python[#dap.configurations.python]
          local restore_cwd = helpers.mock(vim.fn, "getcwd", function()
            return "/proj/no-venv"
          end)
          local restore_stat = helpers.mock(vim.uv, "fs_stat", function()
            return nil
          end)
          local restore_exepath = helpers.mock(vim.fn, "exepath", function(bin)
            assert.equals("python", bin)
            return "/usr/local/bin/python"
          end)

          -- Act
          local result = added.pythonPath()

          -- Assert
          assert.equals("/usr/local/bin/python", result)

          restore_exepath()
          restore_stat()
          restore_cwd()
        end
      )
    end)

    describe("build()", function()
      it("installs debugpy via uv", function()
        -- Arrange
        local jobstart_spy, jobstart_data = helpers.spy()
        local original_jobstart = vim.fn.jobstart
        vim.fn.jobstart = jobstart_spy

        -- Act
        dap_python_spec.build()

        -- Assert
        assert.same(
          { "uv", "tool", "install", "debugpy" },
          jobstart_data.last_call[1]
        )

        vim.fn.jobstart = original_jobstart
      end)

      it("notifies an error when the uv install fails", function()
        -- Arrange
        local original_jobstart = vim.fn.jobstart
        local on_exit
        vim.fn.jobstart = function(_, opts)
          on_exit = opts.on_exit
          return 1
        end
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        dap_python_spec.build()
        on_exit(1, 1)

        -- Assert
        assert.matches("Failed to install debugpy", notify_data.last_call[1])

        restore()
        vim.fn.jobstart = original_jobstart
      end)

      it("does not notify when the uv install succeeds", function()
        -- Arrange
        local original_jobstart = vim.fn.jobstart
        local on_exit
        vim.fn.jobstart = function(_, opts)
          on_exit = opts.on_exit
          return 1
        end
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        dap_python_spec.build()
        on_exit(1, 0)

        -- Assert
        helpers.assert_not_called(notify_data)

        restore()
        vim.fn.jobstart = original_jobstart
      end)
    end)
  end)
end)
