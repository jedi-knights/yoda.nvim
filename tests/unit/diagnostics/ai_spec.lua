-- Tests for diagnostics/ai.lua
local ai = require("yoda.diagnostics.ai")

describe("diagnostics.ai", function()
  -- Save originals
  local original_env = {}
  local original_notify = vim.notify
  local original_cmd = vim.cmd
  local original_api = {}

  before_each(function()
    -- Save env
    original_env.OPENAI_API_KEY = vim.env.OPENAI_API_KEY
    original_env.CLAUDE_API_KEY = vim.env.CLAUDE_API_KEY
    original_env.YODA_ENV = vim.env.YODA_ENV
  end)

  after_each(function()
    -- Restore env
    vim.env.OPENAI_API_KEY = original_env.OPENAI_API_KEY
    vim.env.CLAUDE_API_KEY = original_env.CLAUDE_API_KEY
    vim.env.YODA_ENV = original_env.YODA_ENV
    vim.notify = original_notify
    vim.cmd = original_cmd
    package.loaded["yoda.diagnostics.ai_cli"] = nil
    package.loaded["copilot"] = nil
    package.loaded["opencode"] = nil
  end)

  describe("get_config()", function()
    it("detects OpenAI API key", function()
      vim.env.OPENAI_API_KEY = "sk-test123456789"
      vim.env.CLAUDE_API_KEY = nil

      local config = ai.get_config()
      assert.is_true(config.openai_key_set)
      assert.is_true(config.openai_key_length > 0)
      assert.is_false(config.claude_key_set)
    end)

    it("detects Claude API key", function()
      vim.env.OPENAI_API_KEY = nil
      vim.env.CLAUDE_API_KEY = "sk-ant-test123"

      local config = ai.get_config()
      assert.is_false(config.openai_key_set)
      assert.is_true(config.claude_key_set)
      assert.is_true(config.claude_key_length > 0)
    end)

    it("detects both API keys", function()
      vim.env.OPENAI_API_KEY = "sk-openai"
      vim.env.CLAUDE_API_KEY = "sk-claude"

      local config = ai.get_config()
      assert.is_true(config.openai_key_set)
      assert.is_true(config.claude_key_set)
    end)

    it("handles no API keys set", function()
      vim.env.OPENAI_API_KEY = nil
      vim.env.CLAUDE_API_KEY = nil

      local config = ai.get_config()
      assert.is_false(config.openai_key_set)
      assert.is_false(config.claude_key_set)
      assert.equals(0, config.openai_key_length)
      assert.equals(0, config.claude_key_length)
    end)

    it("treats empty string as not set", function()
      vim.env.OPENAI_API_KEY = ""
      vim.env.CLAUDE_API_KEY = ""

      local config = ai.get_config()
      assert.is_false(config.openai_key_set)
      assert.is_false(config.claude_key_set)
    end)

    it("includes YODA_ENV", function()
      vim.env.YODA_ENV = "home"

      local config = ai.get_config()
      assert.equals("home", config.yoda_env)
    end)

    it("defaults YODA_ENV to 'not set'", function()
      vim.env.YODA_ENV = nil

      local config = ai.get_config()
      assert.equals("not set", config.yoda_env)
    end)
  end)

  describe("check_status()", function()
    it("detects Claude CLI when available", function()
      package.loaded["yoda.diagnostics.ai_cli"] = {
        is_claude_available = function()
          return true
        end,
        get_claude_version = function()
          return "1.0.0", nil
        end,
      }

      local notified = {}
      vim.notify = function(msg, level)
        table.insert(notified, msg)
      end

      package.loaded["copilot"] = nil
      package.loaded["opencode"] = nil

      local status = ai.check_status()
      assert.is_true(status.claude_available)

      local all_msgs = table.concat(notified, " ")
      assert.matches("Claude CLI", all_msgs)
      assert.matches("1.0.0", all_msgs)
    end)

    it("reports when Claude CLI not available", function()
      package.loaded["yoda.diagnostics.ai_cli"] = {
        is_claude_available = function()
          return false
        end,
        get_claude_version = function()
          return nil, "Not found"
        end,
      }

      local notified = {}
      vim.notify = function(msg, level)
        table.insert(notified, msg)
      end

      package.loaded["copilot"] = nil
      package.loaded["opencode"] = nil

      local status = ai.check_status()
      assert.is_false(status.claude_available)

      local all_msgs = table.concat(notified, " ")
      assert.matches("not available", all_msgs)
    end)

    it("detects Copilot when loaded", function()
      package.loaded["yoda.diagnostics.ai_cli"] = {
        is_claude_available = function()
          return false
        end,
      }

      package.loaded["copilot"] = {} -- Mock copilot
      package.loaded["opencode"] = nil

      local notified = {}
      vim.notify = function(msg)
        table.insert(notified, msg)
      end

      local status = ai.check_status()
      assert.is_true(status.copilot_available)

      local all_msgs = table.concat(notified, " ")
      assert.matches("Copilot", all_msgs)
    end)

    it("detects OpenCode when loaded", function()
      package.loaded["yoda.diagnostics.ai_cli"] = {
        is_claude_available = function()
          return false
        end,
      }

      package.loaded["copilot"] = nil
      package.loaded["opencode"] = {} -- Mock opencode

      local notified = {}
      vim.notify = function(msg)
        table.insert(notified, msg)
      end

      local status = ai.check_status()
      assert.is_true(status.opencode_available)

      local all_msgs = table.concat(notified, " ")
      assert.matches("OpenCode", all_msgs)
    end)

    it("returns comprehensive status object", function()
      package.loaded["yoda.diagnostics.ai_cli"] = {
        is_claude_available = function()
          return true
        end,
        get_claude_version = function()
          return "1.0", nil
        end,
      }

      package.loaded["copilot"] = {}
      package.loaded["opencode"] = {}

      vim.notify = function() end

      local status = ai.check_status()
      assert.is_not_nil(status.claude_available)
      assert.is_not_nil(status.claude_info)
      assert.is_not_nil(status.copilot_available)
      assert.is_not_nil(status.opencode_available)
    end)
  end)
end)
