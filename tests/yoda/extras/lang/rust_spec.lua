-- tests/yoda/extras/lang/rust_spec.lua
local helpers = require("tests.helpers")

describe("extras.lang.rust", function()
  local specs
  local neotest_registry = require("yoda.core.neotest_registry")
  local original_rustaceanvim

  local function by_name(name)
    for _, spec in ipairs(specs) do
      if spec[1] == name then
        return spec
      end
    end
    return nil
  end

  before_each(function()
    package.loaded["yoda.extras.lang.rust"] = nil
    specs = require("yoda.extras.lang.rust")
    neotest_registry._reset()
    original_rustaceanvim = vim.g.rustaceanvim
  end)

  after_each(function()
    package.loaded["rustaceanvim.neotest"] = nil
    package.loaded.crates = nil
    neotest_registry._reset()
    vim.g.rustaceanvim = original_rustaceanvim
    pcall(vim.api.nvim_del_augroup_by_name, "YodaCratesKeymaps")
  end)

  it(
    "declares rustaceanvim scoped to *.rs and crates.nvim scoped to Cargo.toml",
    function()
      -- Assert
      local rustaceanvim_spec = by_name("mrcjkb/rustaceanvim")
      local crates_spec = by_name("saecki/crates.nvim")
      assert.is_not_nil(rustaceanvim_spec)
      assert.same({ "rust" }, rustaceanvim_spec.ft)
      assert.is_not_nil(crates_spec)
      assert.same({ "BufRead Cargo.toml" }, crates_spec.event)
    end
  )

  describe("rustaceanvim config()", function()
    local rustaceanvim_spec

    before_each(function()
      rustaceanvim_spec = by_name("mrcjkb/rustaceanvim")
    end)

    it("configures rust-analyzer, clippy-on-save, and DAP autoload", function()
      -- Act
      rustaceanvim_spec.config()

      -- Assert
      local cfg = vim.g.rustaceanvim
      assert.equals(
        "clippy",
        cfg.server.settings["rust-analyzer"].checkOnSave.command
      )
      assert.is_true(cfg.tools.hover_actions.auto_focus)
      assert.is_true(cfg.dap.autoload_configurations)
    end)

    it(
      "logs at debug level when rustaceanvim.neotest is unavailable",
      function()
        -- Arrange
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        rustaceanvim_spec.config()

        -- Assert
        assert.matches(
          "rustaceanvim%.neotest not available",
          notify_data.last_call[1]
        )
        assert.equals(vim.log.levels.DEBUG, notify_data.last_call[2])
        assert.equals(0, #neotest_registry.adapters())

        restore()
      end
    )

    it(
      "registers the neotest adapter when rustaceanvim.neotest is available",
      function()
        -- Arrange
        package.loaded["rustaceanvim.neotest"] = {}

        -- Act
        rustaceanvim_spec.config()

        -- Assert
        assert.equals(1, #neotest_registry.adapters())
      end
    )
  end)

  describe("crates.nvim config()", function()
    local crates_spec
    local crates

    before_each(function()
      crates_spec = by_name("saecki/crates.nvim")
      crates = {
        setup = function() end,
        show_popup = function() end,
        update_crate = function() end,
        update_all_crates = function() end,
        show_versions_popup = function() end,
        show_features_popup = function() end,
      }
      package.loaded.crates = crates
    end)

    it("enables the version-date popup", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      crates.setup = setup_spy

      -- Act
      crates_spec.config()

      -- Assert
      assert.is_true(setup_data.last_call[1].popup.show_version_date)
    end)

    describe("Cargo.toml keymaps", function()
      local buf

      before_each(function()
        crates_spec.config()
        buf = vim.api.nvim_create_buf(false, false)
        -- The autocmd pattern "Cargo.toml" (no "/") matches only the exact
        -- basename, so the buffer must be named .../Cargo.toml verbatim.
        vim.api.nvim_buf_set_name(buf, "/tmp/yoda_rust_spec/Cargo.toml")

        local original_eventignore = vim.o.eventignore
        vim.o.eventignore = ""
        vim.api.nvim_exec_autocmds("BufRead", { buffer = buf })
        vim.o.eventignore = original_eventignore
      end)

      after_each(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)

      local function find_keymap(desc)
        for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
          if km.desc == desc then
            return km
          end
        end
        return nil
      end

      it(
        "binds every crates.nvim action directly, without an extra wrapper",
        function()
          -- Assert
          assert.equals(
            crates.show_popup,
            find_keymap("Crates: Show popup").callback
          )
          assert.equals(
            crates.update_crate,
            find_keymap("Crates: Update crate").callback
          )
          assert.equals(
            crates.update_all_crates,
            find_keymap("Crates: Update all").callback
          )
          assert.equals(
            crates.show_versions_popup,
            find_keymap("Crates: Show versions").callback
          )
          assert.equals(
            crates.show_features_popup,
            find_keymap("Crates: Show features").callback
          )
        end
      )
    end)
  end)
end)
