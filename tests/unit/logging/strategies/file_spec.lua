-- Tests for logging/strategies/file.lua
describe("logging.strategies.file", function()
  local file_strategy
  local config
  local test_log_file = "/tmp/yoda_test_file_strategy.log"

  -- Mocks
  local original_fn_mkdir
  local original_fn_delete
  local original_fn_rename
  local original_fn_isdirectory
  local original_fn_filereadable
  local original_io_open
  local mock_file

  before_each(function()
    -- Clear package cache
    package.loaded["yoda.logging.strategies.file"] = nil
    package.loaded["yoda.logging.config"] = nil

    config = require("yoda-logging.config")
    config.reset()
    config.set_log_file(test_log_file)

    -- Mock vim.fn functions
    original_fn_mkdir = vim.fn.mkdir
    original_fn_delete = vim.fn.delete
    original_fn_rename = vim.fn.rename
    original_fn_isdirectory = vim.fn.isdirectory
    original_fn_filereadable = vim.fn.filereadable

    _G.mkdir_calls = {}
    vim.fn.mkdir = function(dir, flags)
      table.insert(_G.mkdir_calls, { dir = dir, flags = flags })
      return 1
    end

    _G.delete_calls = {}
    vim.fn.delete = function(file)
      table.insert(_G.delete_calls, file)
      return 0
    end

    _G.rename_calls = {}
    vim.fn.rename = function(old, new)
      table.insert(_G.rename_calls, { old = old, new = new })
      return 0
    end

    vim.fn.isdirectory = function(dir)
      return 1 -- Assume directory exists
    end

    vim.fn.filereadable = function(file)
      return 0 -- Assume file doesn't exist
    end

    -- Mock io.open
    original_io_open = io.open
    mock_file = {
      write_calls = {},
      close_called = false,
    }

    io.open = function(path, mode)
      return {
        write = function(self, content)
          table.insert(mock_file.write_calls, content)
        end,
        close = function(self)
          mock_file.close_called = true
        end,
      }
    end

    file_strategy = require("yoda-logging.strategies.file")
  end)

  after_each(function()
    -- Restore mocks
    vim.fn.mkdir = original_fn_mkdir
    vim.fn.delete = original_fn_delete
    vim.fn.rename = original_fn_rename
    vim.fn.isdirectory = original_fn_isdirectory
    vim.fn.filereadable = original_fn_filereadable
    io.open = original_io_open

    _G.mkdir_calls = nil
    _G.delete_calls = nil
    _G.rename_calls = nil
  end)

  describe("write()", function()
    it("writes message to file", function()
      file_strategy.write("Test message", 2)

      assert.are.equal(1, #mock_file.write_calls)
      assert.are.equal("Test message\n", mock_file.write_calls[1])
      assert.is_true(mock_file.close_called)
    end)

    it("writes multiple messages", function()
      file_strategy.write("Message 1", 2)
      file_strategy.write("Message 2", 3)

      assert.are.equal(2, #mock_file.write_calls)
    end)

    it("ignores non-string messages", function()
      file_strategy.write(nil, 2)
      file_strategy.write(123, 2)

      assert.are.equal(0, #mock_file.write_calls)
    end)

    it("creates directory if it doesn't exist", function()
      vim.fn.isdirectory = function(dir)
        return 0 -- Directory doesn't exist
      end

      file_strategy.write("Test", 2)

      assert.are.equal(1, #_G.mkdir_calls)
    end)
  end)

  describe("flush()", function()
    it("is callable (no-op - files closed after each write)", function()
      file_strategy.flush()
      -- Should not error
    end)
  end)

  describe("clear()", function()
    it("deletes log file if it exists", function()
      vim.fn.filereadable = function(file)
        return 1 -- File exists
      end

      file_strategy.clear()

      assert.are.equal(1, #_G.delete_calls)
      assert.are.equal(test_log_file, _G.delete_calls[1])
    end)

    it("does nothing if file doesn't exist", function()
      vim.fn.filereadable = function(file)
        return 0 -- File doesn't exist
      end

      file_strategy.clear()

      assert.are.equal(0, #_G.delete_calls)
    end)
  end)
end)
