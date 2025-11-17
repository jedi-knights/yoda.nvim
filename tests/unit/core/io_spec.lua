-- Tests for core/io.lua
local io_utils = require("yoda-core.io")
local helpers = require("tests.helpers")

describe("core.io", function()
  -- Save originals
  local original_filereadable = vim.fn.filereadable
  local original_isdirectory = vim.fn.isdirectory
  local original_tempname = vim.fn.tempname
  local original_mkdir = vim.fn.mkdir
  local original_io_open = io.open
  local original_json_decode = vim.json.decode
  local original_json_encode = vim.json.encode

  -- Restore after each test
  after_each(function()
    vim.fn.filereadable = original_filereadable
    vim.fn.isdirectory = original_isdirectory
    vim.fn.tempname = original_tempname
    vim.fn.mkdir = original_mkdir
    io.open = original_io_open
    vim.json.decode = original_json_decode
    vim.json.encode = original_json_encode
  end)

  describe("is_file()", function()
    it("returns true for existing file", function()
      vim.fn.filereadable = function(path)
        return path == "/test/file.txt" and 1 or 0
      end

      assert.is_true(io_utils.is_file("/test/file.txt"))
    end)

    it("returns false for non-existent file", function()
      vim.fn.filereadable = function()
        return 0
      end

      assert.is_false(io_utils.is_file("/nonexistent.txt"))
    end)

    it("returns false for empty string", function()
      assert.is_false(io_utils.is_file(""))
    end)

    it("returns false for nil", function()
      assert.is_false(io_utils.is_file(nil))
    end)

    it("returns false for non-string input", function()
      assert.is_false(io_utils.is_file(123))
      assert.is_false(io_utils.is_file(true))
      assert.is_false(io_utils.is_file({}))
    end)
  end)

  describe("is_dir()", function()
    it("returns true for existing directory", function()
      vim.fn.isdirectory = function(path)
        return path == "/test/dir" and 1 or 0
      end

      assert.is_true(io_utils.is_dir("/test/dir"))
    end)

    it("returns false for non-existent directory", function()
      vim.fn.isdirectory = function()
        return 0
      end

      assert.is_false(io_utils.is_dir("/nonexistent"))
    end)

    it("returns false for empty string", function()
      assert.is_false(io_utils.is_dir(""))
    end)

    it("returns false for nil", function()
      assert.is_false(io_utils.is_dir(nil))
    end)

    it("returns false for non-string input", function()
      assert.is_false(io_utils.is_dir(123))
      assert.is_false(io_utils.is_dir(false))
    end)
  end)

  describe("exists()", function()
    it("returns true for existing file", function()
      vim.fn.filereadable = function()
        return 1
      end
      vim.fn.isdirectory = function()
        return 0
      end

      assert.is_true(io_utils.exists("/test/file.txt"))
    end)

    it("returns true for existing directory", function()
      vim.fn.filereadable = function()
        return 0
      end
      vim.fn.isdirectory = function()
        return 1
      end

      assert.is_true(io_utils.exists("/test/dir"))
    end)

    it("returns false when neither file nor directory", function()
      vim.fn.filereadable = function()
        return 0
      end
      vim.fn.isdirectory = function()
        return 0
      end

      assert.is_false(io_utils.exists("/nonexistent"))
    end)

    it("handles empty path", function()
      assert.is_false(io_utils.exists(""))
    end)
  end)

  describe("file_exists()", function()
    it("returns true when file can be opened", function()
      local mock_file = { close = function() end }
      io.open = function(path, mode)
        if path == "/test/file.txt" and mode == "r" then
          return mock_file
        end
        return nil
      end

      assert.is_true(io_utils.file_exists("/test/file.txt"))
    end)

    it("returns false when file cannot be opened", function()
      io.open = function()
        return nil
      end

      assert.is_false(io_utils.file_exists("/nonexistent.txt"))
    end)

    it("closes file handle after check", function()
      local closed = false
      local mock_file = {
        close = function()
          closed = true
        end,
      }
      io.open = function()
        return mock_file
      end

      io_utils.file_exists("/test.txt")
      assert.is_true(closed)
    end)
  end)

  describe("read_file()", function()
    it("reads file content successfully", function()
      vim.fn.filereadable = function()
        return 1
      end

      -- Mock plenary Path
      local mock_path = {
        read = function()
          return "file content"
        end,
      }
      package.loaded["plenary.path"] = {
        new = function()
          return mock_path
        end,
      }

      local ok, content = io_utils.read_file("/test.txt")
      assert.is_true(ok)
      assert.equals("file content", content)

      package.loaded["plenary.path"] = nil
    end)

    it("returns error for non-existent file", function()
      vim.fn.filereadable = function()
        return 0
      end

      local ok, err = io_utils.read_file("/nonexistent.txt")
      assert.is_false(ok)
      assert.matches("File not found", err)
    end)

    it("handles read errors gracefully", function()
      vim.fn.filereadable = function()
        return 1
      end

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              error("Read error")
            end,
          }
        end,
      }

      local ok, err = io_utils.read_file("/test.txt")
      assert.is_false(ok)
      assert.matches("Failed to read file", err)

      package.loaded["plenary.path"] = nil
    end)
  end)

  describe("parse_json_file()", function()
    it("parses valid JSON file", function()
      vim.fn.filereadable = function()
        return 1
      end

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return '{"key": "value"}'
            end,
          }
        end,
      }

      vim.json.decode = function(str)
        return { key = "value" }
      end

      local ok, data = io_utils.parse_json_file("/test.json")
      assert.is_true(ok)
      assert.equals("value", data.key)

      package.loaded["plenary.path"] = nil
    end)

    it("returns error for non-existent file", function()
      vim.fn.filereadable = function()
        return 0
      end

      local ok, err = io_utils.parse_json_file("/nonexistent.json")
      assert.is_false(ok)
      assert.matches("File not found", err)
    end)

    it("returns error for invalid JSON", function()
      vim.fn.filereadable = function()
        return 1
      end

      package.loaded["plenary.path"] = {
        new = function()
          return {
            read = function()
              return "invalid json"
            end,
          }
        end,
      }

      vim.json.decode = function()
        error("Invalid JSON")
      end

      local ok, err = io_utils.parse_json_file("/test.json")
      assert.is_false(ok)
      assert.matches("Invalid JSON", err)

      package.loaded["plenary.path"] = nil
    end)
  end)

  describe("write_json_file()", function()
    it("writes JSON data successfully", function()
      local written_content = nil
      package.loaded["plenary.path"] = {
        new = function()
          return {
            write = function(self, content, mode)
              written_content = content
            end,
          }
        end,
      }

      vim.json.encode = function(data)
        return '{"key":"value"}'
      end

      local ok, err = io_utils.write_json_file("/test.json", { key = "value" })
      assert.is_true(ok)
      assert.is_nil(err)
      assert.equals('{"key":"value"}', written_content)

      package.loaded["plenary.path"] = nil
    end)

    it("returns error for non-table data", function()
      local ok, err = io_utils.write_json_file("/test.json", "not a table")
      assert.is_false(ok)
      assert.matches("Data must be a table", err)
    end)

    it("handles JSON encode errors", function()
      vim.json.encode = function()
        error("Encode error")
      end

      local ok, err = io_utils.write_json_file("/test.json", { key = "value" })
      assert.is_false(ok)
      assert.matches("Failed to encode JSON", err)
    end)

    it("handles write errors", function()
      vim.json.encode = function()
        return '{"key":"value"}'
      end

      package.loaded["plenary.path"] = {
        new = function()
          return {
            write = function()
              error("Write error")
            end,
          }
        end,
      }

      local ok, err = io_utils.write_json_file("/test.json", { key = "value" })
      assert.is_false(ok)
      assert.matches("Failed to write file", err)

      package.loaded["plenary.path"] = nil
    end)
  end)

  describe("create_temp_file()", function()
    it("creates temporary file with content", function()
      vim.fn.tempname = function()
        return "/tmp/test123"
      end

      local written_content = nil
      local mock_file = {
        write = function(self, content)
          written_content = content
        end,
        close = function() end,
      }

      io.open = function(path, mode)
        if path == "/tmp/test123" and mode == "w" then
          return mock_file
        end
        return nil
      end

      local path, err = io_utils.create_temp_file("test content")
      assert.equals("/tmp/test123", path)
      assert.is_nil(err)
      assert.equals("test content", written_content)
    end)

    it("returns error for non-string content", function()
      local path, err = io_utils.create_temp_file(123)
      assert.is_nil(path)
      assert.matches("Content must be a string", err)
    end)

    it("returns error for nil content", function()
      local path, err = io_utils.create_temp_file(nil)
      assert.is_nil(path)
      assert.matches("Content must be a string", err)
    end)

    it("handles file creation failure", function()
      vim.fn.tempname = function()
        return "/tmp/test123"
      end

      io.open = function()
        return nil
      end

      local path, err = io_utils.create_temp_file("content")
      assert.is_nil(path)
      assert.matches("Failed to create temporary file", err)
    end)

    it("handles empty string content", function()
      vim.fn.tempname = function()
        return "/tmp/test123"
      end

      local mock_file = {
        write = function() end,
        close = function() end,
      }

      io.open = function()
        return mock_file
      end

      local path, err = io_utils.create_temp_file("")
      assert.equals("/tmp/test123", path)
      assert.is_nil(err)
    end)
  end)

  describe("create_temp_dir()", function()
    it("creates temporary directory successfully", function()
      vim.fn.tempname = function()
        return "/tmp/dir123"
      end

      vim.fn.mkdir = function(path)
        if path == "/tmp/dir123" then
          return 1
        end
        return 0
      end

      local path, err = io_utils.create_temp_dir()
      assert.equals("/tmp/dir123", path)
      assert.is_nil(err)
    end)

    it("returns error when mkdir fails", function()
      vim.fn.tempname = function()
        return "/tmp/dir123"
      end

      vim.fn.mkdir = function()
        return 0
      end

      local path, err = io_utils.create_temp_dir()
      assert.is_nil(path)
      assert.matches("Failed to create temporary directory", err)
    end)

    it("handles different tempname values", function()
      local temp_paths = { "/tmp/a", "/tmp/b", "/tmp/c" }
      local index = 1

      vim.fn.tempname = function()
        local path = temp_paths[index]
        index = index + 1
        return path
      end

      vim.fn.mkdir = function()
        return 1
      end

      local path1 = io_utils.create_temp_dir()
      local path2 = io_utils.create_temp_dir()
      local path3 = io_utils.create_temp_dir()

      assert.equals("/tmp/a", path1)
      assert.equals("/tmp/b", path2)
      assert.equals("/tmp/c", path3)
    end)
  end)
end)
