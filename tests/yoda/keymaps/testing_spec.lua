-- tests/yoda/keymaps/testing_spec.lua
local helpers = require("tests.helpers")

describe("keymaps.testing", function()
  local notify_spy_fn, notify_spy_data
  local original_win_utils_preload

  local function get_callback(desc)
    for _, km in ipairs(vim.api.nvim_get_keymap("n")) do
      if km.desc == desc then
        return km.callback
      end
    end
    error("no keymap registered with desc: " .. desc)
  end

  before_each(function()
    package.loaded["yoda.keymaps.testing"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }
    original_win_utils_preload = package.preload["yoda-window.utils"]
    require("yoda.keymaps.testing")
  end)

  after_each(function()
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded["neotest"] = nil
    package.loaded["snacks"] = nil
    package.loaded["yoda-window.utils"] = nil
    package.loaded["pytest-atlas"] = nil
    package.loaded["pytest-atlas.logger"] = nil
    package.preload["yoda-window.utils"] = original_win_utils_preload
  end)

  describe("<leader>ta (run all tests)", function()
    it(
      "runs neotest against the cwd when snacks explorer is unavailable",
      function()
        -- Arrange
        local run_spy, run_data = helpers.spy()
        package.loaded["neotest"] = { run = { run = run_spy } }

        -- Act
        get_callback("Test: Run all tests (explorer dir)")()

        -- Assert
        helpers.assert_called(run_data, 1)
        assert.equals(vim.uv.cwd(), run_data.last_call[1])
      end
    )

    it(
      "runs neotest against the explorer's cwd when snacks reports one",
      function()
        -- Arrange
        local run_spy, run_data = helpers.spy()
        package.loaded["neotest"] = { run = { run = run_spy } }
        package.loaded["snacks"] = {
          picker = {
            get = function()
              return {
                {
                  cwd = function()
                    return "/explorer/dir"
                  end,
                },
              }
            end,
          },
        }

        -- Act
        get_callback("Test: Run all tests (explorer dir)")()

        -- Assert
        assert.equals("/explorer/dir", run_data.last_call[1])
      end
    )
  end)

  for _, case in ipairs({
    { desc = "Test: Run nearest test", ["end"] = "run" },
    { desc = "Test: Run file tests", ["end"] = "run" },
    { desc = "Test: Run last test", ["end"] = "run_last" },
    { desc = "Test: Toggle summary", ["end"] = "toggle" },
    { desc = "Test: Toggle output panel", ["end"] = "toggle" },
    { desc = "Test: Debug nearest test", ["end"] = "run" },
    { desc = "Test: View test output", ["end"] = "open" },
    { desc = "Test: Clear output panel", ["end"] = "clear" },
  }) do
    it(case.desc .. " delegates to neotest", function()
      -- Arrange
      local spy_fn, spy_data = helpers.spy()
      package.loaded["neotest"] = {
        run = { run = spy_fn, run_last = spy_fn },
        summary = { toggle = spy_fn },
        output_panel = { toggle = spy_fn, clear = spy_fn },
        output = { open = spy_fn },
      }

      -- Act
      get_callback(case.desc)()

      -- Assert
      helpers.assert_called(spy_data, 1)
    end)
  end

  it("Test: Clear output panel notifies after clearing", function()
    -- Arrange
    package.loaded["neotest"] = { output_panel = { clear = function() end } }

    -- Act
    get_callback("Test: Clear output panel")()

    -- Assert
    helpers.assert_called_with(
      notify_spy_data,
      "Neotest output panel cleared",
      "info"
    )
  end)

  describe("<leader>tO / <leader>tF (focus panels)", function()
    local function make_unavailable()
      package.preload["yoda-window.utils"] = nil
      package.loaded["yoda-window.utils"] = nil
    end

    it(
      "notifies when yoda-window.utils is unavailable (output panel)",
      function()
        -- Arrange
        make_unavailable()

        -- Act
        get_callback("Test: Focus output panel")()

        -- Assert
        helpers.assert_called_with(
          notify_spy_data,
          "yoda-window.utils not available",
          "error"
        )
      end
    )

    it("notifies when the output panel isn't open", function()
      -- Arrange
      package.loaded["yoda-window.utils"] = {
        focus_window = function()
          return false
        end,
      }

      -- Act
      get_callback("Test: Focus output panel")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Neotest output panel not open",
        "warn"
      )
    end)

    it("does not notify when the output panel is found", function()
      -- Arrange
      package.loaded["yoda-window.utils"] = {
        focus_window = function()
          return true
        end,
      }

      -- Act
      get_callback("Test: Focus output panel")()

      -- Assert
      helpers.assert_not_called(notify_spy_data)
    end)

    it("notifies when the summary window isn't open", function()
      -- Arrange
      package.loaded["yoda-window.utils"] = {
        focus_window = function()
          return false
        end,
      }

      -- Act
      get_callback("Test: Focus summary window")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Neotest summary not open. Use <leader>ts to open it.",
        "warn"
      )
    end)
  end)

  describe("<leader>tc (run current file by filetype)", function()
    local original_filetype

    before_each(function()
      original_filetype = vim.bo.filetype
    end)

    after_each(function()
      vim.bo.filetype = original_filetype
    end)

    it("runs neotest for python files when available", function()
      -- Arrange
      vim.bo.filetype = "python"
      local run_spy, run_data = helpers.spy()
      package.loaded["neotest"] = { run = { run = run_spy } }

      -- Act
      get_callback("Test: Run current file")()

      -- Assert
      helpers.assert_called(run_data, 1)
    end)

    it("notifies when neotest is unavailable for python files", function()
      -- Arrange
      vim.bo.filetype = "python"

      -- Act
      get_callback("Test: Run current file")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Neotest not available. Install via :Lazy sync",
        "error"
      )
    end)

    it("points to `make test` for lua files", function()
      -- Arrange
      vim.bo.filetype = "lua"

      -- Act
      get_callback("Test: Run current file")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Run tests with: make test",
        "info"
      )
    end)

    it("warns when no runner is configured for the filetype", function()
      -- Arrange
      vim.bo.filetype = "markdown"

      -- Act
      get_callback("Test: Run current file")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "No test runner configured for filetype: markdown",
        "warn"
      )
    end)
  end)

  describe("<leader>tS (environment status)", function()
    local original_env, original_region

    before_each(function()
      original_env = vim.env.TEST_ENVIRONMENT
      original_region = vim.env.TEST_REGION
    end)

    after_each(function()
      vim.env.TEST_ENVIRONMENT = original_env
      vim.env.TEST_REGION = original_region
    end)

    it(
      "reports env/region defaults when pytest-atlas is unavailable",
      function()
        -- Arrange
        vim.env.TEST_ENVIRONMENT = nil
        vim.env.TEST_REGION = nil

        -- Act
        get_callback("Test: Show environment status")()

        -- Assert
        helpers.assert_called_with(
          notify_spy_data,
          "Current test environment: qa (auto)",
          "info"
        )
      end
    )

    it("reports configured env/region when set", function()
      -- Arrange
      vim.env.TEST_ENVIRONMENT = "prod"
      vim.env.TEST_REGION = "use1"

      -- Act
      get_callback("Test: Show environment status")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Current test environment: prod (use1)",
        "info"
      )
    end)

    it("delegates to pytest-atlas.show_status when available", function()
      -- Arrange
      local status_spy, status_data = helpers.spy()
      package.loaded["pytest-atlas"] = { show_status = status_spy }

      -- Act
      get_callback("Test: Show environment status")()

      -- Assert
      helpers.assert_called(status_data, 1)
      helpers.assert_not_called(notify_spy_data)
    end)

    it("notifies an error when pytest-atlas.show_status raises", function()
      -- Arrange
      package.loaded["pytest-atlas"] = {
        show_status = function()
          error("boom")
        end,
      }

      -- Act
      get_callback("Test: Show environment status")()

      -- Assert
      assert.matches(
        "Error showing pytest%-atlas status:",
        notify_spy_data.last_call[1]
      )
      assert.equals("error", notify_spy_data.last_call[2])
    end)
  end)

  describe("pytest-atlas log commands", function()
    it("opens the log tail when pytest-atlas.logger is available", function()
      -- Arrange
      local tail_spy, tail_data = helpers.spy()
      package.loaded["pytest-atlas.logger"] = { open_log_tail = tail_spy }

      -- Act
      get_callback("Test: Open pytest-atlas log (tail)")()

      -- Assert
      helpers.assert_called_with(tail_data, 100)
    end)

    it("notifies when pytest-atlas.logger is unavailable", function()
      -- Act
      get_callback("Test: Open pytest-atlas log (tail)")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "pytest-atlas not available",
        "error"
      )
    end)

    it("opens the full log when pytest-atlas is available", function()
      -- Arrange
      local open_spy, open_data = helpers.spy()
      package.loaded["pytest-atlas"] = { open_log = open_spy }

      -- Act
      get_callback("Test: Open pytest-atlas log (full)")()

      -- Assert
      helpers.assert_called(open_data, 1)
    end)

    it("clears the log when pytest-atlas is available", function()
      -- Arrange
      local clear_spy, clear_data = helpers.spy()
      package.loaded["pytest-atlas"] = { clear_log = clear_spy }

      -- Act
      get_callback("Test: Clear pytest-atlas log")()

      -- Assert
      helpers.assert_called(clear_data, 1)
    end)

    it(
      "notifies when pytest-atlas is unavailable for full log / clear",
      function()
        -- Act
        get_callback("Test: Open pytest-atlas log (full)")()

        -- Assert
        helpers.assert_called_with(
          notify_spy_data,
          "pytest-atlas not available",
          "error"
        )
      end
    )
  end)
end)
