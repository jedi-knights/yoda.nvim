-- tests/unit/python_venv_spec.lua
-- Tests for Python virtual environment detection

local helpers = require("tests.helpers")

describe("python_venv", function()
  local python_venv

  before_each(function()
    package.loaded["yoda.python_venv"] = nil
    python_venv = require("yoda.python_venv")
    python_venv.clear_cache()
  end)

  after_each(function()
    python_venv.clear_cache()
  end)

  describe("cache management", function()
    it("caches venv detection results", function()
      local root_dir = "/tmp/test_project"
      local venv_path = "/tmp/test_project/.venv/bin/python"
      local callback_count = 0

      python_venv.detect_venv_async(root_dir, function(path)
        callback_count = callback_count + 1
      end)

      vim.wait(200)
      assert.equals(1, callback_count)
    end)

    it("returns cached results on subsequent calls", function()
      local root_dir = "/tmp/test_project"
      local callback_count = 0

      python_venv.detect_venv_async(root_dir, function()
        callback_count = callback_count + 1
      end)

      vim.wait(200)

      python_venv.detect_venv_async(root_dir, function()
        callback_count = callback_count + 1
      end)

      vim.wait(50)
      assert.equals(2, callback_count)
    end)

    it("clears cache for specific root_dir", function()
      local root_dir = "/tmp/test_project"

      python_venv.detect_venv_async(root_dir, function() end)
      vim.wait(200)

      python_venv.clear_cache(root_dir)
      local stats = python_venv.get_cache_stats()
      assert.equals(0, stats.total)
    end)

    it("clears all cache entries when no root_dir provided", function()
      python_venv.detect_venv_async("/tmp/project1", function() end)
      python_venv.detect_venv_async("/tmp/project2", function() end)
      vim.wait(200)

      python_venv.clear_cache()
      local stats = python_venv.get_cache_stats()
      assert.equals(0, stats.total)
    end)
  end)

  describe("get_cache_stats()", function()
    it("returns correct statistics", function()
      local stats = python_venv.get_cache_stats()
      assert.equals(0, stats.total)
      assert.equals(0, stats.valid)
      assert.equals(0, stats.expired)
      assert.equals(300, stats.ttl_seconds)
    end)

    it("tracks cache entries", function()
      python_venv.detect_venv_async("/tmp/project1", function() end)
      python_venv.detect_venv_async("/tmp/project2", function() end)
      vim.wait(200)

      local stats = python_venv.get_cache_stats()
      assert.equals(2, stats.total)
      assert.equals(2, stats.valid)
    end)
  end)

  describe("detect_and_apply()", function()
    it("handles nil root_dir gracefully", function()
      python_venv.detect_and_apply(nil)
    end)

    it("detects and applies venv when found", function()
      local root_dir = "/tmp/test_project"
      python_venv.detect_and_apply(root_dir)
      vim.wait(200)
    end)
  end)

  describe("apply_venv_to_lsp()", function()
    it("updates LSP client configuration", function()
      local mock_client = {
        config = {
          root_dir = "/tmp/test_project",
          settings = {
            basedpyright = { analysis = {} },
            python = {},
          },
        },
        notify = helpers.spy(),
      }

      local original_get_clients = vim.lsp.get_clients
      vim.lsp.get_clients = function()
        return { mock_client }
      end

      local venv_path = "/tmp/test_project/.venv/bin/python"
      python_venv.apply_venv_to_lsp("/tmp/test_project", venv_path)

      assert.equals(venv_path, mock_client.config.settings.basedpyright.analysis.pythonPath)
      assert.equals(venv_path, mock_client.config.settings.python.pythonPath)

      vim.lsp.get_clients = original_get_clients
    end)

    it("only updates matching clients", function()
      local matching_client = {
        config = {
          root_dir = "/tmp/test_project",
          settings = {
            basedpyright = { analysis = {} },
            python = {},
          },
        },
        notify = helpers.spy(),
      }

      local non_matching_client = {
        config = {
          root_dir = "/tmp/other_project",
          settings = {
            basedpyright = { analysis = {} },
            python = {},
          },
        },
        notify = helpers.spy(),
      }

      local original_get_clients = vim.lsp.get_clients
      vim.lsp.get_clients = function()
        return { matching_client, non_matching_client }
      end

      local venv_path = "/tmp/test_project/.venv/bin/python"
      python_venv.apply_venv_to_lsp("/tmp/test_project", venv_path)

      assert.equals(venv_path, matching_client.config.settings.basedpyright.analysis.pythonPath)
      assert.is_nil(non_matching_client.config.settings.basedpyright.analysis.pythonPath)

      vim.lsp.get_clients = original_get_clients
    end)
  end)

  describe("commands", function()
    before_each(function()
      python_venv.setup_commands()
    end)

    it("creates PythonVenvDetect command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.PythonVenvDetect)
    end)

    it("creates PythonVenvCache command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.PythonVenvCache)
    end)

    it("creates PythonVenvClear command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.PythonVenvClear)
    end)
  end)

  describe("async behavior", function()
    it("executes callback asynchronously", function()
      local callback_executed = false
      local root_dir = "/tmp/test_project"

      python_venv.detect_venv_async(root_dir, function()
        callback_executed = true
      end)

      assert.is_false(callback_executed)

      vim.wait(200, function()
        return callback_executed
      end)

      assert.is_true(callback_executed)
    end)

    it("handles multiple concurrent requests", function()
      local callback_count = 0

      for i = 1, 5 do
        python_venv.detect_venv_async("/tmp/project" .. i, function()
          callback_count = callback_count + 1
        end)
      end

      vim.wait(300, function()
        return callback_count == 5
      end)

      assert.equals(5, callback_count)
    end)
  end)

  describe("error handling", function()
    it("handles invalid root directories", function()
      local callback_executed = false
      local returned_venv = "not_nil"

      python_venv.detect_venv_async("/nonexistent/path/that/does/not/exist", function(venv_path)
        callback_executed = true
        returned_venv = venv_path
      end)

      vim.wait(200, function()
        return callback_executed
      end)

      assert.is_true(callback_executed)
      assert.is_nil(returned_venv)
    end)

    it("handles empty root directory", function()
      local callback_executed = false

      python_venv.detect_venv_async("", function()
        callback_executed = true
      end)

      vim.wait(200, function()
        return callback_executed
      end)

      assert.is_true(callback_executed)
    end)
  end)
end)
