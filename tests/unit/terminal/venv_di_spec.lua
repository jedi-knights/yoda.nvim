-- Tests for terminal/venv_di.lua (DI version)
local VenvDI = require("yoda-terminal.venv_di")

describe("terminal.venv_di (with dependency injection)", function()
  -- Mock dependencies
  local mock_deps

  before_each(function()
    mock_deps = {
      platform = {
        is_windows = function()
          return false
        end,
      },
      io = {
        is_file = function(path)
          return path:match("/bin/activate$") ~= nil
        end,
        is_dir = function(path)
          return path:match("venv") ~= nil or path:match("%.venv") ~= nil
        end,
      },
      picker = {
        select = function(items, opts, callback)
          -- Auto-select first item
          callback(items[1])
        end,
      },
    }
  end)

  describe("new()", function()
    it("creates instance with dependencies", function()
      local venv = VenvDI.new(mock_deps)
      assert.is_not_nil(venv)
      assert.is_table(venv)
    end)

    it("validates dependencies is table", function()
      local ok = pcall(function()
        VenvDI.new("not a table")
      end)
      assert.is_false(ok)
    end)

    it("validates platform dependency", function()
      local ok = pcall(function()
        VenvDI.new({ io = {}, picker = {} })
      end)
      assert.is_false(ok)
    end)

    it("validates io dependency", function()
      local ok = pcall(function()
        VenvDI.new({ platform = {}, picker = {} })
      end)
      assert.is_false(ok)
    end)

    it("validates picker dependency", function()
      local ok = pcall(function()
        VenvDI.new({ platform = {}, io = {} })
      end)
      assert.is_false(ok)
    end)

    it("allows optional notify dependency", function()
      local venv = VenvDI.new(mock_deps)
      assert.is_not_nil(venv)
    end)
  end)

  describe("get_activate_script_path()", function()
    it("returns Unix activate script path", function()
      local venv = VenvDI.new(mock_deps)
      local path = venv.get_activate_script_path("/path/to/venv")

      assert.equals("/path/to/venv/bin/activate", path)
    end)

    it("returns Windows activate script path", function()
      mock_deps.platform.is_windows = function()
        return true
      end
      mock_deps.io.is_file = function(path)
        -- Match both forward and backslash paths
        return path:match("/Scripts/activate$") ~= nil or path:match("\\Scripts\\activate$") ~= nil
      end

      local venv = VenvDI.new(mock_deps)
      local path = venv.get_activate_script_path("C:\\path\\to\\venv")

      -- The implementation uses forward slash in the constant
      assert.equals("C:\\path\\to\\venv/Scripts/activate", path)
    end)

    it("returns nil when activate script not found", function()
      mock_deps.io.is_file = function()
        return false
      end

      local venv = VenvDI.new(mock_deps)
      local path = venv.get_activate_script_path("/path/to/venv")

      assert.is_nil(path)
    end)

    it("returns nil for empty path", function()
      local venv = VenvDI.new(mock_deps)
      assert.is_nil(venv.get_activate_script_path(""))
    end)

    it("returns nil for nil path", function()
      local venv = VenvDI.new(mock_deps)
      assert.is_nil(venv.get_activate_script_path(nil))
    end)
  end)

  describe("find_virtual_envs() - with DI", function()
    it("finds virtual environments using injected io", function()
      -- Mock vim.fn.getcwd and readdir
      local original_getcwd = vim.fn.getcwd
      local original_readdir = vim.fn.readdir

      vim.fn.getcwd = function()
        return "/project"
      end
      vim.fn.readdir = function()
        return { "venv", ".venv", "node_modules" }
      end

      local venv = VenvDI.new(mock_deps)
      local venvs = venv.find_virtual_envs()

      vim.fn.getcwd = original_getcwd
      vim.fn.readdir = original_readdir

      assert.equals(2, #venvs)
      assert.equals("/project/venv", venvs[1])
      assert.equals("/project/.venv", venvs[2])
    end)

    it("returns empty array when no venvs found", function()
      mock_deps.io.is_dir = function()
        return false
      end

      local original_getcwd = vim.fn.getcwd
      local original_readdir = vim.fn.readdir

      vim.fn.getcwd = function()
        return "/project"
      end
      vim.fn.readdir = function()
        return { "src", "tests" }
      end

      local venv = VenvDI.new(mock_deps)
      local venvs = venv.find_virtual_envs()

      vim.fn.getcwd = original_getcwd
      vim.fn.readdir = original_readdir

      assert.same({}, venvs)
    end)
  end)

  describe("select_virtual_env() - with injected picker", function()
    it("uses injected picker for selection", function()
      local selected = nil
      local picker_called = false

      mock_deps.picker.select = function(items, opts, callback)
        picker_called = true
        callback(items[2]) -- Select second item
      end

      local original_getcwd = vim.fn.getcwd
      local original_readdir = vim.fn.readdir

      vim.fn.getcwd = function()
        return "/project"
      end
      vim.fn.readdir = function()
        return { "venv1", "venv2", "venv3" }
      end

      local venv = VenvDI.new(mock_deps)
      venv.select_virtual_env(function(choice)
        selected = choice
      end)

      vim.fn.getcwd = original_getcwd
      vim.fn.readdir = original_readdir

      assert.is_true(picker_called)
      assert.equals("/project/venv2", selected)
    end)

    it("calls callback with nil when no venvs found", function()
      local selected = "NOT_CALLED"

      mock_deps.io.is_dir = function()
        return false
      end

      local original_getcwd = vim.fn.getcwd
      local original_readdir = vim.fn.readdir

      vim.fn.getcwd = function()
        return "/project"
      end
      vim.fn.readdir = function()
        return {}
      end

      local venv = VenvDI.new(mock_deps)
      venv.select_virtual_env(function(choice)
        selected = choice
      end)

      vim.fn.getcwd = original_getcwd
      vim.fn.readdir = original_readdir

      assert.is_nil(selected)
    end)

    it("demonstrates testability with fake dependencies", function()
      -- This is the key benefit of DI: easy testing!
      local fake_picker = {
        select = function(items, opts, callback)
          -- Fake picker always selects first item
          callback(items[1])
        end,
      }

      local test_deps = {
        platform = mock_deps.platform,
        io = mock_deps.io,
        picker = fake_picker,
      }

      local original_getcwd = vim.fn.getcwd
      local original_readdir = vim.fn.readdir

      vim.fn.getcwd = function()
        return "/test"
      end
      vim.fn.readdir = function()
        return { "test_venv" }
      end

      local venv = VenvDI.new(test_deps)
      local result = nil

      venv.select_virtual_env(function(choice)
        result = choice
      end)

      vim.fn.getcwd = original_getcwd
      vim.fn.readdir = original_readdir

      assert.equals("/test/test_venv", result)
    end)
  end)
end)
