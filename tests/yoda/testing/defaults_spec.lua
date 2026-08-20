-- tests/yoda/testing/defaults_spec.lua
local config = require("yoda.config")

describe("yoda.testing.defaults", function()
  local defaults

  before_each(function()
    package.loaded["yoda.testing.defaults"] = nil
    defaults = require("yoda.testing.defaults")
    config._reset()
  end)

  after_each(function()
    config._reset()
  end)

  describe("get_config()", function()
    it(
      "returns the built-in defaults before setup() has ever resolved",
      function()
        -- Act
        local cfg = defaults.get_config()

        -- Assert
        assert.same(defaults.ENVIRONMENTS, cfg.environments)
        assert.same(defaults.ENVIRONMENT_ORDER, cfg.environment_order)
        assert.same(defaults.MARKERS, cfg.markers)
        assert.same(defaults.MARKER_DEFAULTS, cfg.marker_defaults)
      end
    )

    it("returns the built-in defaults when testing opts are empty", function()
      -- Arrange
      config.resolve({})

      -- Act
      local cfg = defaults.get_config()

      -- Assert
      assert.same(defaults.MARKER_DEFAULTS, cfg.marker_defaults)
    end)

    it("deep-merges user testing overrides over the defaults", function()
      -- Arrange
      config.resolve({
        testing = {
          marker_defaults = { environment = "prod" },
        },
      })

      -- Act
      local cfg = defaults.get_config()

      -- Assert: overridden field wins
      assert.equals("prod", cfg.marker_defaults.environment)
      -- Assert: sibling fields in the same table are preserved
      assert.equals("auto", cfg.marker_defaults.region)
      assert.equals("bdd", cfg.marker_defaults.markers)
      -- Assert: untouched top-level keys keep their defaults
      assert.same(defaults.ENVIRONMENTS, cfg.environments)
      assert.same(defaults.MARKERS, cfg.markers)
    end)

    it(
      "adds a new environment alongside the defaults rather than replacing them",
      function()
        -- Arrange: vim.tbl_deep_extend("force", ...) merges nested tables
        -- recursively, so a new environment key is added alongside the
        -- defaults, not swapped in wholesale.
        config.resolve({
          testing = {
            environments = { staging = { "auto" } },
          },
        })

        -- Act
        local cfg = defaults.get_config()

        -- Assert
        assert.same({ "auto" }, cfg.environments.staging)
        assert.same(defaults.ENVIRONMENTS.qa, cfg.environments.qa)
        assert.same(defaults.ENVIRONMENTS.prod, cfg.environments.prod)
      end
    )
  end)

  it("get_environments() returns the environments table", function()
    -- Act / Assert
    assert.same(defaults.ENVIRONMENTS, defaults.get_environments())
  end)

  it("get_environment_order() returns the environment order list", function()
    -- Act / Assert
    assert.same(defaults.ENVIRONMENT_ORDER, defaults.get_environment_order())
  end)

  it("get_markers() returns the markers list", function()
    -- Act / Assert
    assert.same(defaults.MARKERS, defaults.get_markers())
  end)

  it("get_marker_defaults() returns the marker defaults", function()
    -- Act / Assert
    assert.same(defaults.MARKER_DEFAULTS, defaults.get_marker_defaults())
  end)

  it("get_marker_defaults() reflects a resolved override", function()
    -- Arrange
    config.resolve({ testing = { marker_defaults = { open_allure = true } } })

    -- Act
    local marker_defaults = defaults.get_marker_defaults()

    -- Assert
    assert.is_true(marker_defaults.open_allure)
  end)
end)
