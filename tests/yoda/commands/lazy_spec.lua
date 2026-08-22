-- tests/yoda/commands/lazy_spec.lua
local helpers = require("tests.helpers")

describe("commands.lazy", function()
  local logger
  local logger_infos
  local logger_errors
  local original_logger
  local original_isdirectory
  local original_filereadable
  local original_delete

  local function clear_commands()
    pcall(vim.api.nvim_del_user_command, "YodaDebugLazy")
    pcall(vim.api.nvim_del_user_command, "YodaCleanLazy")
  end

  before_each(function()
    -- Spy'd logger so we can observe info/error calls made from the command
    -- callbacks. Callbacks re-require the logger each invocation, so we swap
    -- package.loaded rather than the stub's function table.
    logger_infos = {}
    logger_errors = {}
    logger = {
      trace = function() end,
      debug = function() end,
      info = function(msg, ctx)
        table.insert(logger_infos, { msg = msg, ctx = ctx })
      end,
      warn = function() end,
      error = function(msg, ctx)
        table.insert(logger_errors, { msg = msg, ctx = ctx })
      end,
      set_strategy = function() end,
      set_level = function() end,
    }
    original_logger = package.loaded["yoda-logging.logger"]
    package.loaded["yoda-logging.logger"] = logger

    original_isdirectory = vim.fn.isdirectory
    original_filereadable = vim.fn.filereadable
    original_delete = vim.fn.delete

    clear_commands()
    package.loaded["yoda.commands.lazy"] = nil
    require("yoda.commands.lazy").setup()
  end)

  after_each(function()
    clear_commands()
    vim.fn.isdirectory = original_isdirectory
    vim.fn.filereadable = original_filereadable
    vim.fn.delete = original_delete
    package.loaded["yoda-logging.logger"] = original_logger
    package.loaded.lazy = nil
    package.loaded["yoda.commands.lazy"] = nil
  end)

  describe("setup()", function()
    it("registers both YodaDebugLazy and YodaCleanLazy", function()
      -- Assert
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.YodaDebugLazy)
      assert.is_not_nil(commands.YodaCleanLazy)
    end)

    it("sets a descriptive help string on each command", function()
      -- Assert
      local commands = vim.api.nvim_get_commands({})
      assert.matches("Debug", commands.YodaDebugLazy.definition)
      assert.matches("Clean", commands.YodaCleanLazy.definition)
    end)
  end)

  describe(":YodaDebugLazy", function()
    it("logs Lazy.nvim state when the plugin loads", function()
      -- Arrange
      package.loaded.lazy = {
        get_plugins = function()
          return { { name = "example", _ = { loaded = true } } }
        end,
      }

      -- Act
      vim.api.nvim_exec2("YodaDebugLazy", {})

      -- Assert: two paths asserted -- the "loaded successfully" info and the
      -- "Total plugins" info with the count captured from the mock.
      local messages = vim.tbl_map(function(entry)
        return entry.msg
      end, logger_infos)
      assert.is_true(
        vim.tbl_contains(messages, "Lazy.nvim loaded successfully")
      )
      local total_entry
      for _, entry in ipairs(logger_infos) do
        if entry.msg == "Total plugins" then
          total_entry = entry
          break
        end
      end
      assert.is_not_nil(total_entry)
      assert.equals(1, total_entry.ctx.count)
      assert.equals(0, #logger_errors)
    end)

    it("logs an error entry for each plugin with a load_error", function()
      -- Arrange
      package.loaded.lazy = {
        get_plugins = function()
          return {
            { name = "healthy", _ = { loaded = true } },
            {
              name = "broken",
              _ = { loaded = true, load_error = "boom" },
            },
          }
        end,
      }

      -- Act
      vim.api.nvim_exec2("YodaDebugLazy", {})

      -- Assert
      assert.equals(1, #logger_errors)
      assert.equals("Plugin with error", logger_errors[1].msg)
      assert.equals("broken", logger_errors[1].ctx.plugin)
      assert.equals("boom", logger_errors[1].ctx.error)
    end)

    it(
      "does not log any plugin errors when no plugin has a load_error",
      function()
        -- Arrange
        package.loaded.lazy = {
          get_plugins = function()
            return {
              { name = "a", _ = { loaded = true } },
              { name = "b", _ = { loaded = false } },
              -- loaded=true but no load_error -- must be skipped
              { name = "c", _ = { loaded = true, load_error = nil } },
            }
          end,
        }

        -- Act
        vim.api.nvim_exec2("YodaDebugLazy", {})

        -- Assert
        assert.equals(0, #logger_errors)
      end
    )

    it("handles Lazy reporting zero plugins without iterating", function()
      -- Arrange
      package.loaded.lazy = {
        get_plugins = function()
          return {}
        end,
      }

      -- Act
      vim.api.nvim_exec2("YodaDebugLazy", {})

      -- Assert
      local total_entry
      for _, entry in ipairs(logger_infos) do
        if entry.msg == "Total plugins" then
          total_entry = entry
          break
        end
      end
      assert.is_not_nil(total_entry)
      assert.equals(0, total_entry.ctx.count)
      assert.equals(0, #logger_errors)
    end)

    it("logs an error when Lazy.nvim fails to load", function()
      -- Arrange: don't set package.loaded.lazy, and force require to raise.
      -- Any preloaded stub from a previous test is cleared in after_each.
      -- Act
      vim.api.nvim_exec2("YodaDebugLazy", {})

      -- Assert
      assert.equals(1, #logger_errors)
      assert.equals("Lazy.nvim failed to load", logger_errors[1].msg)
      assert.is_not_nil(logger_errors[1].ctx.error)
    end)
  end)

  describe(":YodaCleanLazy", function()
    local deleted

    before_each(function()
      deleted = {}
      vim.fn.delete = function(path, flags)
        table.insert(deleted, { path = path, flags = flags })
        return 0
      end
    end)

    it("removes the readme directory when it exists", function()
      -- Arrange
      vim.fn.isdirectory = function(path)
        return path:match("readme$") and 1 or 0
      end
      vim.fn.filereadable = function()
        return 0
      end

      -- Act
      vim.api.nvim_exec2("YodaCleanLazy", {})

      -- Assert
      local readme_deleted = false
      for _, d in ipairs(deleted) do
        if d.path:match("readme$") then
          readme_deleted = true
          assert.equals("rf", d.flags)
        end
      end
      assert.is_true(readme_deleted, "readme directory was not deleted")
    end)

    it("skips the readme directory when it does not exist", function()
      -- Arrange
      vim.fn.isdirectory = function()
        return 0
      end
      vim.fn.filereadable = function()
        return 0
      end

      -- Act
      vim.api.nvim_exec2("YodaCleanLazy", {})

      -- Assert
      for _, d in ipairs(deleted) do
        assert.is_nil(
          d.path:match("readme$"),
          "readme directory should not have been deleted"
        )
      end
    end)

    it("removes the lock file when it is readable", function()
      -- Arrange
      vim.fn.isdirectory = function()
        return 0
      end
      vim.fn.filereadable = function(path)
        return path:match("lock%.json$") and 1 or 0
      end

      -- Act
      vim.api.nvim_exec2("YodaCleanLazy", {})

      -- Assert
      local lock_deleted = false
      for _, d in ipairs(deleted) do
        if d.path:match("lock%.json$") then
          lock_deleted = true
          -- delete() with no flags for a single file
          assert.is_nil(d.flags)
        end
      end
      assert.is_true(lock_deleted, "lock file was not deleted")
    end)

    it("skips the lock file when it is not readable", function()
      -- Arrange
      vim.fn.isdirectory = function()
        return 0
      end
      vim.fn.filereadable = function()
        return 0
      end

      -- Act
      vim.api.nvim_exec2("YodaCleanLazy", {})

      -- Assert
      for _, d in ipairs(deleted) do
        assert.is_nil(
          d.path:match("lock%.json$"),
          "lock file should not have been deleted"
        )
      end
    end)

    it("removes the cache directory when it exists", function()
      -- Arrange
      vim.fn.isdirectory = function(path)
        return path:match("cache$") and 1 or 0
      end
      vim.fn.filereadable = function()
        return 0
      end

      -- Act
      vim.api.nvim_exec2("YodaCleanLazy", {})

      -- Assert
      local cache_deleted = false
      for _, d in ipairs(deleted) do
        if d.path:match("cache$") then
          cache_deleted = true
          assert.equals("rf", d.flags)
        end
      end
      assert.is_true(cache_deleted, "cache directory was not deleted")
    end)

    it("skips the cache directory when it does not exist", function()
      -- Arrange
      vim.fn.isdirectory = function()
        return 0
      end
      vim.fn.filereadable = function()
        return 0
      end

      -- Act
      vim.api.nvim_exec2("YodaCleanLazy", {})

      -- Assert
      for _, d in ipairs(deleted) do
        assert.is_nil(
          d.path:match("cache$"),
          "cache directory should not have been deleted"
        )
      end
    end)

    it("deletes nothing when the state directory is already empty", function()
      -- Arrange
      vim.fn.isdirectory = function()
        return 0
      end
      vim.fn.filereadable = function()
        return 0
      end

      -- Act
      vim.api.nvim_exec2("YodaCleanLazy", {})

      -- Assert
      assert.equals(0, #deleted)
    end)
  end)
end)
