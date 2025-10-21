-- Tests for config_loader.lua
local config_loader = require("yoda.config_loader")

describe("config_loader", function()
  -- Save originals
  local original_notify = vim.notify
  local original_json_decode = vim.json.decode
  local original_json_encode = vim.json.encode

  -- Reset state after each test
  after_each(function()
    vim.notify = original_notify
    vim.json.decode = original_json_decode
    vim.json.encode = original_json_encode
    package.loaded["yoda.core.io"] = nil
    package.loaded["yoda.yaml_parser"] = nil
    package.loaded["yoda.testing.defaults"] = nil
    package.loaded["plenary.path"] = nil
  end)

  describe("load_json_config()", function()
    it("loads valid JSON config", function()
      -- Mock core.io
      package.loaded["yoda.core.io"] = {
        parse_json_file = function(path)
          if path == "/test/config.json" then
            return true, { key = "value" }
          end
          return false, "Not found"
        end,
      }

      local result = config_loader.load_json_config("/test/config.json")
      assert.same({ key = "value" }, result)
    end)

    it("returns nil when file not found", function()
      package.loaded["yoda.core.io"] = {
        parse_json_file = function()
          return false, "File not found"
        end,
      }

      local result = config_loader.load_json_config("/nonexistent.json")
      assert.is_nil(result)
    end)

    it("validates path is a string", function()
      local notified = false
      vim.notify = function()
        notified = true
      end

      local result = config_loader.load_json_config(123)
      assert.is_nil(result)
      assert.is_true(notified)
    end)

    it("validates path is not empty", function()
      local notified = false
      vim.notify = function()
        notified = true
      end

      local result = config_loader.load_json_config("")
      assert.is_nil(result)
      assert.is_true(notified)
    end)

    it("returns nil for nil path", function()
      local notified = false
      vim.notify = function()
        notified = true
      end

      local result = config_loader.load_json_config(nil)
      assert.is_nil(result)
      assert.is_true(notified)
    end)
  end)

  describe("load_ingress_mapping()", function()
    it("loads valid ingress mapping YAML", function()
      package.loaded["yoda.core.io"] = {
        is_file = function(path)
          return path == "ingress-mapping.yaml"
        end,
      }

      package.loaded["yoda.yaml_parser"] = {
        parse_ingress_mapping = function(path)
          return {
            environments = {
              qa = { "auto" },
              prod = { "use1" },
            },
          }
        end,
      }

      local result = config_loader.load_ingress_mapping()
      assert.is_not_nil(result)
      assert.same({ "auto" }, result.environments.qa)
    end)

    it("returns nil when file not found", function()
      package.loaded["yoda.core.io"] = {
        is_file = function()
          return false
        end,
      }

      local result = config_loader.load_ingress_mapping()
      assert.is_nil(result)
    end)

    it("returns nil when YAML parsing fails", function()
      package.loaded["yoda.core.io"] = {
        is_file = function()
          return true
        end,
      }

      package.loaded["yoda.yaml_parser"] = {
        parse_ingress_mapping = function()
          return nil
        end,
      }

      local result = config_loader.load_ingress_mapping()
      assert.is_nil(result)
    end)

    it("returns nil when environments is empty", function()
      package.loaded["yoda.core.io"] = {
        is_file = function()
          return true
        end,
      }

      package.loaded["yoda.yaml_parser"] = {
        parse_ingress_mapping = function()
          return { environments = {} }
        end,
      }

      local result = config_loader.load_ingress_mapping()
      assert.is_nil(result)
    end)

    it("notifies on parse failure", function()
      local notified = false
      vim.notify = function(msg, level)
        notified = true
      end

      package.loaded["yoda.core.io"] = {
        is_file = function()
          return true
        end,
      }

      package.loaded["yoda.yaml_parser"] = {
        parse_ingress_mapping = function()
          return nil
        end,
      }

      config_loader.load_ingress_mapping()
      assert.is_true(notified)
    end)
  end)

  describe("load_env_region()", function()
    it("loads from environments.json when available", function()
      package.loaded["yoda.core.io"] = {
        is_file = function(path)
          return path == "environments.json"
        end,
        parse_json_file = function(path)
          if path == "environments.json" then
            return true, { environments = { qa = { "auto" } } }
          end
          return false, "Not found"
        end,
      }

      local config, source = config_loader.load_env_region()
      assert.equals("json", source)
      assert.same({ "auto" }, config.environments.qa)
    end)

    it("falls back to YAML when JSON not found", function()
      package.loaded["yoda.core.io"] = {
        is_file = function(path)
          return path == "ingress-mapping.yaml"
        end,
      }

      package.loaded["yoda.yaml_parser"] = {
        parse_ingress_mapping = function()
          return { environments = { prod = { "use1" } } }
        end,
      }

      local config, source = config_loader.load_env_region()
      assert.equals("yaml", source)
      assert.same({ "use1" }, config.environments.prod)
    end)

    it("falls back to defaults when no config files", function()
      package.loaded["yoda.core.io"] = {
        is_file = function()
          return false
        end,
      }

      package.loaded["yoda.testing.defaults"] = {
        get_environments = function()
          return {
            qa = { "auto" },
            prod = { "use1", "usw2" },
          }
        end,
      }

      local config, source = config_loader.load_env_region()
      assert.equals("fallback", source)
      assert.same({ "auto" }, config.environments.qa)
    end)

    it("prefers JSON over YAML", function()
      local loaded_from = nil
      package.loaded["yoda.core.io"] = {
        is_file = function(path)
          return true -- Both exist
        end,
        parse_json_file = function(path)
          loaded_from = "json"
          return true, { environments = { json_env = {} } }
        end,
      }

      local config, source = config_loader.load_env_region()
      assert.equals("json", source)
      assert.equals("json", loaded_from)
    end)
  end)

  describe("load_marker()", function()
    it("loads marker from cache file", function()
      package.loaded["yoda.core.io"] = {
        parse_json_file = function(path)
          if path == "/cache/marker.json" then
            return true,
              {
                environment = "qa",
                region = "auto",
                markers = "bdd",
                open_allure = false,
              }
          end
          return false, "Not found"
        end,
      }

      local marker = config_loader.load_marker("/cache/marker.json")
      assert.equals("qa", marker.environment)
      assert.equals("bdd", marker.markers)
    end)

    it("returns defaults when cache file not found", function()
      package.loaded["yoda.core.io"] = {
        parse_json_file = function()
          return false, "Not found"
        end,
      }

      package.loaded["yoda.testing.defaults"] = {
        get_marker_defaults = function()
          return {
            environment = "qa",
            region = "auto",
            markers = "bdd",
            open_allure = false,
          }
        end,
      }

      local marker = config_loader.load_marker("/cache/marker.json")
      assert.equals("qa", marker.environment)
      assert.equals("bdd", marker.markers)
    end)

    it("returns defaults for empty cache_file", function()
      package.loaded["yoda.testing.defaults"] = {
        get_marker_defaults = function()
          return { markers = "default" }
        end,
      }

      local marker = config_loader.load_marker("")
      assert.equals("default", marker.markers)
    end)

    it("returns defaults for nil cache_file", function()
      package.loaded["yoda.testing.defaults"] = {
        get_marker_defaults = function()
          return { markers = "default" }
        end,
      }

      local marker = config_loader.load_marker(nil)
      assert.equals("default", marker.markers)
    end)
  end)

  -- NOTE: load_pytest_markers() tests removed - functionality moved to pytest-atlas.nvim plugin

  describe("save_marker()", function()
    it("saves marker configuration to cache file", function()
      local written_content = nil
      package.loaded["plenary.path"] = {
        new = function(path)
          return {
            write = function(self, content, mode)
              written_content = content
            end,
          }
        end,
      }

      vim.json.encode = function(data)
        return vim.inspect(data) -- Simple mock
      end

      config_loader.save_marker("/cache/marker.json", "qa", "auto", "bdd", false)
      assert.is_not_nil(written_content)
    end)

    it("uses default markers when nil", function()
      local saved_data = nil

      vim.json.encode = function(data)
        saved_data = data -- Capture before write is called
        return "{}"
      end

      package.loaded["plenary.path"] = {
        new = function()
          return {
            write = function(self, content)
              -- saved_data already captured by encode
            end,
          }
        end,
      }

      config_loader.save_marker("/cache/marker.json", "qa", "auto", nil, nil)
      assert.is_not_nil(saved_data)
      assert.equals("bdd", saved_data.markers)
      assert.is_false(saved_data.open_allure)
    end)

    it("notifies on write failure", function()
      local notified = false
      vim.notify = function(msg, level)
        notified = true
      end

      package.loaded["plenary.path"] = {
        new = function()
          return {
            write = function()
              error("Write failed")
            end,
          }
        end,
      }

      vim.json.encode = function()
        return "{}"
      end

      config_loader.save_marker("/cache/marker.json", "qa", "auto", "bdd", false)
      assert.is_true(notified)
    end)

    it("saves all parameters correctly", function()
      local saved_data = nil
      package.loaded["plenary.path"] = {
        new = function()
          return {
            write = function(self, content)
              -- capture for verification
            end,
          }
        end,
      }

      vim.json.encode = function(data)
        saved_data = data
        return "{}"
      end

      config_loader.save_marker("/cache/marker.json", "prod", "use1", "unit,integration", true)

      assert.equals("prod", saved_data.environment)
      assert.equals("use1", saved_data.region)
      assert.equals("unit,integration", saved_data.markers)
      assert.is_true(saved_data.open_allure)
    end)
  end)
end)
