-- tests/unit/config_spec.lua
-- Tests for centralized configuration module

describe("config", function()
  local config

  before_each(function()
    config = require("yoda.config")

    -- Clear all global state
    vim.g.yoda_config = nil
    vim.g.yoda_notify_backend = nil
    vim.g.yoda_picker_backend = nil
    vim.g.yoda_test_config = nil
  end)

  after_each(function()
    -- Cleanup
    vim.g.yoda_config = nil
    vim.g.yoda_notify_backend = nil
    vim.g.yoda_picker_backend = nil
    vim.g.yoda_test_config = nil
  end)

  describe("get_config()", function()
    it("returns nil when no config is set", function()
      assert.is_nil(config.get_config())
    end)

    it("returns config when set", function()
      vim.g.yoda_config = { test = true }
      local result = config.get_config()
      assert.is_not_nil(result)
      assert.is_true(result.test)
    end)
  end)

  describe("should_show_environment_notification()", function()
    it("returns false when config is nil", function()
      assert.is_false(config.should_show_environment_notification())
    end)

    it("returns false when show_environment_notification is false", function()
      vim.g.yoda_config = { show_environment_notification = false }
      assert.is_false(config.should_show_environment_notification())
    end)

    it("returns true when show_environment_notification is true", function()
      vim.g.yoda_config = { show_environment_notification = true }
      assert.is_true(config.should_show_environment_notification())
    end)

    it("returns false when show_environment_notification is not set", function()
      vim.g.yoda_config = {}
      assert.is_false(config.should_show_environment_notification())
    end)
  end)

  describe("is_verbose_startup()", function()
    it("returns false when config is nil", function()
      assert.is_false(config.is_verbose_startup())
    end)

    it("returns false when verbose_startup is false", function()
      vim.g.yoda_config = { verbose_startup = false }
      assert.is_false(config.is_verbose_startup())
    end)

    it("returns true when verbose_startup is true", function()
      vim.g.yoda_config = { verbose_startup = true }
      assert.is_true(config.is_verbose_startup())
    end)
  end)

  describe("get_notify_backend()", function()
    it("returns nil when not set", function()
      assert.is_nil(config.get_notify_backend())
    end)

    it("returns backend when set", function()
      vim.g.yoda_notify_backend = "noice"
      assert.equals("noice", config.get_notify_backend())
    end)

    it("returns snacks backend", function()
      vim.g.yoda_notify_backend = "snacks"
      assert.equals("snacks", config.get_notify_backend())
    end)

    it("returns native backend", function()
      vim.g.yoda_notify_backend = "native"
      assert.equals("native", config.get_notify_backend())
    end)
  end)

  describe("get_picker_backend()", function()
    it("returns nil when not set", function()
      assert.is_nil(config.get_picker_backend())
    end)

    it("returns backend when set", function()
      vim.g.yoda_picker_backend = "snacks"
      assert.equals("snacks", config.get_picker_backend())
    end)

    it("returns telescope backend", function()
      vim.g.yoda_picker_backend = "telescope"
      assert.equals("telescope", config.get_picker_backend())
    end)

    it("returns native backend", function()
      vim.g.yoda_picker_backend = "native"
      assert.equals("native", config.get_picker_backend())
    end)
  end)

  describe("get_test_config()", function()
    it("returns nil when not set", function()
      assert.is_nil(config.get_test_config())
    end)

    it("returns test config when set", function()
      vim.g.yoda_test_config = { environments = { test = {} } }
      local result = config.get_test_config()
      assert.is_not_nil(result)
      assert.is_not_nil(result.environments)
    end)
  end)

  describe("set_config()", function()
    it("sets config when valid table", function()
      config.set_config({ test = true })
      assert.is_not_nil(vim.g.yoda_config)
      assert.is_true(vim.g.yoda_config.test)
    end)

    it("ignores non-table values", function()
      config.set_config("invalid")
      assert.is_nil(vim.g.yoda_config)
    end)

    it("allows overwriting config", function()
      config.set_config({ first = true })
      config.set_config({ second = true })
      assert.is_nil(vim.g.yoda_config.first)
      assert.is_true(vim.g.yoda_config.second)
    end)
  end)

  describe("set_notify_backend()", function()
    it("sets valid backend", function()
      config.set_notify_backend("noice")
      assert.equals("noice", vim.g.yoda_notify_backend)
    end)

    it("ignores invalid backend", function()
      config.set_notify_backend("invalid")
      assert.is_nil(vim.g.yoda_notify_backend)
    end)

    it("ignores non-string values", function()
      config.set_notify_backend(123)
      assert.is_nil(vim.g.yoda_notify_backend)
    end)
  end)

  describe("set_picker_backend()", function()
    it("sets valid backend", function()
      config.set_picker_backend("snacks")
      assert.equals("snacks", vim.g.yoda_picker_backend)
    end)

    it("ignores invalid backend", function()
      config.set_picker_backend("invalid")
      assert.is_nil(vim.g.yoda_picker_backend)
    end)

    it("ignores non-string values", function()
      config.set_picker_backend(false)
      assert.is_nil(vim.g.yoda_picker_backend)
    end)
  end)

  describe("set_test_config()", function()
    it("sets test config when valid table", function()
      local test_config = { environments = { test = {} } }
      config.set_test_config(test_config)
      assert.is_not_nil(vim.g.yoda_test_config)
    end)

    it("ignores non-table values", function()
      config.set_test_config("invalid")
      assert.is_nil(vim.g.yoda_test_config)
    end)
  end)

  describe("validate()", function()
    it("returns true for nil config", function()
      local ok, err = config.validate()
      assert.is_true(ok)
      assert.is_nil(err)
    end)

    it("returns true for valid config", function()
      vim.g.yoda_config = {
        show_environment_notification = true,
        verbose_startup = false,
      }
      local ok, err = config.validate()
      assert.is_true(ok)
      assert.is_nil(err)
    end)

    it("returns false for non-table config", function()
      vim.g.yoda_config = "invalid"
      local ok, err = config.validate()
      assert.is_false(ok)
      assert.equals("yoda_config must be a table", err)
    end)

    it("returns false for invalid boolean field", function()
      vim.g.yoda_config = { show_environment_notification = "true" }
      local ok, err = config.validate()
      assert.is_false(ok)
      assert.has_match("must be a boolean", err)
    end)

    it("allows extra fields", function()
      vim.g.yoda_config = { custom_field = "value" }
      local ok, err = config.validate()
      assert.is_true(ok)
      assert.is_nil(err)
    end)
  end)

  describe("get_defaults()", function()
    it("returns default configuration", function()
      local defaults = config.get_defaults()
      assert.is_not_nil(defaults)
      assert.is_true(defaults.show_environment_notification)
      assert.is_false(defaults.verbose_startup)
    end)

    it("returns a new table each time", function()
      local defaults1 = config.get_defaults()
      local defaults2 = config.get_defaults()
      assert.are_not.equal(defaults1, defaults2)
    end)
  end)

  describe("init_defaults()", function()
    it("initializes config when not set", function()
      config.init_defaults()
      assert.is_not_nil(vim.g.yoda_config)
      assert.is_true(vim.g.yoda_config.show_environment_notification)
    end)

    it("does not overwrite existing config", function()
      vim.g.yoda_config = { custom = true }
      config.init_defaults()
      assert.is_true(vim.g.yoda_config.custom)
      assert.is_nil(vim.g.yoda_config.show_environment_notification)
    end)
  end)

  describe("encapsulation", function()
    it("hides vim.g implementation detail", function()
      -- Users should use config.get_notify_backend(), not vim.g directly
      config.set_notify_backend("noice")

      -- The config module is the only one that should know about vim.g
      assert.equals("noice", config.get_notify_backend())
    end)

    it("provides single source of truth", function()
      -- All modules should go through config module
      vim.g.yoda_notify_backend = "snacks"

      -- Config module returns the same value
      assert.equals("snacks", config.get_notify_backend())
    end)
  end)
end)
