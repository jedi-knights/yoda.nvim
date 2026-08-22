-- tests/yoda/extras/lang/node_spec.lua
local helpers = require("tests.helpers")

describe("extras.lang.node", function()
  local specs
  local neotest_registry = require("yoda.core.neotest_registry")
  local dap_registry = require("yoda.core.dap_registry")

  local function by_name(name)
    for _, spec in ipairs(specs) do
      if spec[1] == name then
        return spec
      end
    end
    return nil
  end

  before_each(function()
    package.loaded["yoda.extras.lang.node"] = nil
    specs = require("yoda.extras.lang.node")
    neotest_registry._reset()
    dap_registry._reset()
  end)

  after_each(function()
    package.loaded["neotest-jest"] = nil
    package.loaded["neotest-vitest"] = nil
    package.loaded["package-info"] = nil
    package.loaded["mason-registry"] = nil
    package.loaded["dap.utils"] = nil
    neotest_registry._reset()
    dap_registry._reset()
  end)

  it(
    "declares neotest-jest, neotest-vitest, package-info, and the dap wiring",
    function()
      -- Assert
      assert.is_not_nil(by_name("nvim-neotest/neotest-jest"))
      assert.is_not_nil(by_name("marilari88/neotest-vitest"))
      assert.is_not_nil(by_name("vuki656/package-info.nvim"))
      assert.is_not_nil(by_name("mfussenegger/nvim-dap"))
    end
  )

  describe("neotest-jest config()", function()
    local jest_spec

    before_each(function()
      jest_spec = by_name("nvim-neotest/neotest-jest")
    end)

    it("warns when neotest-jest is unavailable", function()
      -- Arrange
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      jest_spec.config()

      -- Assert
      assert.matches("neotest%-jest not available", notify_data.last_call[1])

      restore()
    end)

    it(
      "registers the adapter with the CI jest command when available",
      function()
        -- Arrange
        local captured
        package.loaded["neotest-jest"] = function(opts)
          captured = opts
          return opts
        end

        -- Act
        jest_spec.config()

        -- Assert
        assert.equals(1, #neotest_registry.adapters())
        assert.equals("npm test --", captured.jestCommand)
        assert.is_true(captured.env.CI)
        assert.equals(vim.fn.getcwd(), captured.cwd())
      end
    )

    it(
      "warns without registering when the Jest adapter factory raises (L36 else)",
      function()
        -- Arrange
        package.loaded["neotest-jest"] = function(_opts)
          error("jest factory blew up")
        end
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        jest_spec.config()

        -- Assert
        assert.matches("Jest adapter setup failed", notify_data.last_call[1])
        assert.equals(vim.log.levels.WARN, notify_data.last_call[2])
        assert.equals(0, #neotest_registry.adapters())

        restore()
      end
    )
  end)

  describe("neotest-vitest config()", function()
    local vitest_spec

    before_each(function()
      vitest_spec = by_name("marilari88/neotest-vitest")
    end)

    it("warns when neotest-vitest is unavailable", function()
      -- Arrange
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      vitest_spec.config()

      -- Assert
      assert.matches("neotest%-vitest not available", notify_data.last_call[1])

      restore()
    end)

    it("registers neotest-vitest directly when available", function()
      -- Arrange
      local adapter = {}
      package.loaded["neotest-vitest"] = adapter

      -- Act
      vitest_spec.config()

      -- Assert
      assert.equals(adapter, neotest_registry.adapters()[1])
    end)
  end)

  describe("package-info.nvim", function()
    local pkg_info_spec
    local pkg

    before_each(function()
      pkg_info_spec = by_name("vuki656/package-info.nvim")
      pkg = {
        show = function() end,
        update = function() end,
        delete = function() end,
        install = function() end,
        change_version = function() end,
      }
      package.loaded["package-info"] = pkg
    end)

    it("configures the up-to-date/outdated highlight groups", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      pkg.setup = setup_spy

      -- Act
      pkg_info_spec.config()

      -- Assert
      assert.equals("npm", setup_data.last_call[1].package_manager)
      assert.is_false(setup_data.last_call[1].autostart)
    end)

    describe("package.json BufRead autocmd", function()
      local buf

      before_each(function()
        pkg.setup = function() end
        pkg_info_spec.config()
        buf = vim.api.nvim_create_buf(false, false)
        -- The autocmd pattern "package.json" (no "/") matches only the
        -- exact basename.
        vim.api.nvim_buf_set_name(buf, "/tmp/yoda_node_spec/package.json")
      end)

      after_each(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)

      local function trigger()
        -- vim.keymap.set(..., {buffer = true}) binds to whatever buffer is
        -- current at call time, not args.buf -- nvim_exec_autocmds doesn't
        -- switch buffers on its own, so it must be made current first.
        vim.api.nvim_set_current_buf(buf)
        local original_eventignore = vim.o.eventignore
        vim.o.eventignore = ""
        vim.api.nvim_exec_autocmds("BufRead", { buffer = buf })
        vim.o.eventignore = original_eventignore
      end

      local function find_keymap(desc)
        for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
          if km.desc == desc then
            return km
          end
        end
        return nil
      end

      it("binds every package-info action and notifies once", function()
        -- Arrange
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        trigger()

        -- Assert
        assert.equals(
          pkg.show,
          find_keymap("JS: Fetch & show package versions").callback
        )
        assert.equals(pkg.update, find_keymap("JS: Update package").callback)
        assert.equals(pkg.delete, find_keymap("JS: Delete package").callback)
        assert.equals(pkg.install, find_keymap("JS: Install package").callback)
        assert.equals(
          pkg.change_version,
          find_keymap("JS: Change version").callback
        )
        assert.equals(1, notify_data.call_count)

        restore()
      end)

      it("only sets up keymaps once per buffer", function()
        -- Arrange
        local set_spy, set_data = helpers.spy()
        local original_set = vim.keymap.set
        vim.keymap.set = set_spy

        -- Act
        trigger()
        trigger()

        -- Assert: 6 keymaps the first time, none the second
        assert.equals(6, set_data.call_count)

        vim.keymap.set = original_set
      end)
    end)
  end)

  describe("nvim-dap init() / JS debug adapter registration", function()
    local dap_spec

    before_each(function()
      dap_spec = by_name("mfussenegger/nvim-dap")
    end)

    local function registered_configurator()
      dap_spec.init()
      return dap_registry.configurators()[1]
    end

    it(
      "declares itself optional so it only activates when nvim-dap is present",
      function()
        -- Assert
        assert.is_true(dap_spec.optional)
      end
    )

    it("does nothing when mason-registry is unavailable", function()
      -- Arrange
      local configurator = registered_configurator()
      local dap = { adapters = {}, configurations = {} }

      -- Act
      local ok = pcall(configurator, dap)

      -- Assert
      assert.is_true(ok)
      assert.equals(0, vim.tbl_count(dap.adapters))
    end)

    it(
      "does nothing when js-debug-adapter is not installed via mason",
      function()
        -- Arrange
        package.loaded["mason-registry"] = {
          get_package = function()
            return {
              is_installed = function()
                return false
              end,
            }
          end,
        }
        local configurator = registered_configurator()
        local dap = { adapters = {}, configurations = {} }

        -- Act
        configurator(dap)

        -- Assert
        assert.equals(0, vim.tbl_count(dap.adapters))
      end
    )

    it(
      "registers pwa-* adapters and language configurations when installed",
      function()
        -- Arrange
        package.loaded["dap.utils"] = { pick_process = function() end }
        package.loaded["mason-registry"] = {
          get_package = function()
            return {
              is_installed = function()
                return true
              end,
              get_install_path = function()
                return "/mason/packages/js-debug-adapter"
              end,
            }
          end,
        }
        local configurator = registered_configurator()
        local dap = { adapters = {}, configurations = {} }

        -- Act
        configurator(dap)

        -- Assert
        assert.equals("server", dap.adapters["pwa-node"].type)
        assert.matches(
          "js%-debug/src/dapDebugServer%.js$",
          dap.adapters["pwa-node"].executable.args[1]
        )
        assert.is_not_nil(dap.configurations.typescript)
        assert.equals(4, #dap.configurations.typescript)
      end
    )
  end)
end)
