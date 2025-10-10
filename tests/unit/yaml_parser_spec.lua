-- Tests for yaml_parser.lua
local yaml_parser = require("yoda.yaml_parser")

describe("yaml_parser", function()
  -- Save originals
  local original_notify = vim.notify
  local original_io_open = io.open
  local original_stdpath = vim.fn.stdpath

  -- Restore after each test
  after_each(function()
    vim.notify = original_notify
    io.open = original_io_open
    vim.fn.stdpath = original_stdpath
    package.loaded["plenary.path"] = nil
  end)

  describe("parse_ingress_mapping()", function()
    it("parses valid ingress mapping YAML", function()
      local yaml_content = [[
environments:
  - name: fastly
    regions:
      - name: auto
      - name: use1
  - name: qa
    regions:
      - name: auto
      - name: use1
  - name: prod
    regions:
      - name: auto
      - name: use1
      - name: usw2
]]

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return yaml_content
            end,
          }
        end,
      }

      -- Mock stdpath and io.open to suppress debug file
      vim.fn.stdpath = function()
        return "/tmp"
      end
      io.open = function()
        return {
          write = function() end,
          close = function() end,
        }
      end

      local result = yaml_parser.parse_ingress_mapping("ingress-mapping.yaml")
      assert.is_not_nil(result)
      assert.is_not_nil(result.environments)
      assert.same({ "auto", "use1" }, result.environments.fastly)
      assert.same({ "auto", "use1" }, result.environments.qa)
      assert.same({ "auto", "use1", "usw2" }, result.environments.prod)
    end)

    it("preserves environment order", function()
      local yaml_content = [[
environments:
  - name: qa
    regions:
      - name: auto
  - name: prod
    regions:
      - name: use1
  - name: fastly
    regions:
      - name: auto
]]

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return yaml_content
            end,
          }
        end,
      }

      vim.fn.stdpath = function()
        return "/tmp"
      end
      io.open = function()
        return { write = function() end, close = function() end }
      end

      local result = yaml_parser.parse_ingress_mapping("test.yaml")
      assert.same({ "qa", "prod", "fastly" }, result.env_order)
    end)

    it("returns nil when file cannot be read", function()
      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              error("File not found")
            end,
          }
        end,
      }

      local notified = false
      vim.notify = function()
        notified = true
      end

      local result = yaml_parser.parse_ingress_mapping("nonexistent.yaml")
      assert.is_nil(result)
      assert.is_true(notified)
    end)

    it("handles empty YAML file", function()
      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return ""
            end,
          }
        end,
      }

      vim.fn.stdpath = function()
        return "/tmp"
      end
      io.open = function()
        return { write = function() end, close = function() end }
      end

      local result = yaml_parser.parse_ingress_mapping("empty.yaml")
      assert.is_not_nil(result)
      assert.same({}, result.environments)
      assert.same({}, result.env_order)
    end)

    it("skips comments and empty lines", function()
      local yaml_content = [[
# This is a comment
environments:
  - name: qa
    # Comment in the middle
    regions:
      - name: auto
      # Another comment
      - name: use1

# Final comment
]]

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return yaml_content
            end,
          }
        end,
      }

      vim.fn.stdpath = function()
        return "/tmp"
      end
      io.open = function()
        return { write = function() end, close = function() end }
      end

      local result = yaml_parser.parse_ingress_mapping("test.yaml")
      assert.same({ "auto", "use1" }, result.environments.qa)
    end)

    it("handles single environment", function()
      local yaml_content = [[
environments:
  - name: qa
    regions:
      - name: auto
]]

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return yaml_content
            end,
          }
        end,
      }

      vim.fn.stdpath = function()
        return "/tmp"
      end
      io.open = function()
        return { write = function() end, close = function() end }
      end

      local result = yaml_parser.parse_ingress_mapping("test.yaml")
      assert.equals(1, #result.env_order)
      assert.same({ "auto" }, result.environments.qa)
    end)

    it("handles environment with no regions", function()
      local yaml_content = [[
environments:
  - name: qa
    regions:
]]

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return yaml_content
            end,
          }
        end,
      }

      vim.fn.stdpath = function()
        return "/tmp"
      end
      io.open = function()
        return { write = function() end, close = function() end }
      end

      local result = yaml_parser.parse_ingress_mapping("test.yaml")
      assert.same({}, result.environments.qa)
    end)

    it("only parses known environments", function()
      local yaml_content = [[
environments:
  - name: fastly
    regions:
      - name: auto
  - name: qa
    regions:
      - name: use1
  - name: prod
    regions:
      - name: usw2
]]

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return yaml_content
            end,
          }
        end,
      }

      vim.fn.stdpath = function()
        return "/tmp"
      end
      io.open = function()
        return { write = function() end, close = function() end }
      end

      local result = yaml_parser.parse_ingress_mapping("test.yaml")
      -- All three known environments should be parsed
      assert.same({ "auto" }, result.environments.fastly)
      assert.same({ "use1" }, result.environments.qa)
      assert.same({ "usw2" }, result.environments.prod)
      -- Should have all three in env_order
      assert.equals(3, #result.env_order)
    end)

    it("handles multiple regions per environment", function()
      local yaml_content = [[
environments:
  - name: prod
    regions:
      - name: auto
      - name: use1
      - name: usw2
      - name: euc1
      - name: apse2
]]

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return yaml_content
            end,
          }
        end,
      }

      vim.fn.stdpath = function()
        return "/tmp"
      end
      io.open = function()
        return { write = function() end, close = function() end }
      end

      local result = yaml_parser.parse_ingress_mapping("test.yaml")
      assert.equals(5, #result.environments.prod)
      assert.same({ "auto", "use1", "usw2", "euc1", "apse2" }, result.environments.prod)
    end)

    it("writes debug log", function()
      local debug_written = false
      local debug_content = nil

      vim.fn.stdpath = function()
        return "/tmp"
      end

      io.open = function(path, mode)
        if path:match("yoda_yaml_debug.log") and mode == "w" then
          debug_written = true
          return {
            write = function(self, content)
              debug_content = content
            end,
            close = function() end,
          }
        end
        return nil
      end

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return "environments:\n  - name: qa\n    regions:\n      - name: auto"
            end,
          }
        end,
      }

      yaml_parser.parse_ingress_mapping("test.yaml")
      assert.is_true(debug_written)
      assert.is_not_nil(debug_content)
      assert.matches("YAML Parser Debug", debug_content)
    end)

    it("notifies when debug log is written", function()
      local notified = false
      vim.notify = function(msg, level)
        if msg:match("Debug log written") then
          notified = true
        end
      end

      vim.fn.stdpath = function()
        return "/tmp"
      end
      io.open = function()
        return { write = function() end, close = function() end }
      end

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return ""
            end,
          }
        end,
      }

      yaml_parser.parse_ingress_mapping("test.yaml")
      assert.is_true(notified)
    end)
  end)
end)

