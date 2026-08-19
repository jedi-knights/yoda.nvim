-- tests/yoda/core/startup_mode_spec.lua
-- Pure-logic tests for lua/yoda/core/startup_mode.lua. Exercises the argv
-- classifier directly, without loading the ui/layout stack.

local core = require("yoda.core.startup_mode")

describe("core.startup_mode", function()
  describe("mode_from_argv()", function()
    it("returns 'claude' for the exact trigger 'claude'", function()
      -- Arrange / Act / Assert
      assert.equals("claude", core.mode_from_argv({ "claude" }))
    end)

    it("returns 'claude' for the short alias 'c'", function()
      -- Arrange / Act / Assert
      assert.equals("claude", core.mode_from_argv({ "c" }))
    end)

    it("returns nil for zero args", function()
      -- Arrange / Act / Assert
      assert.is_nil(core.mode_from_argv({}))
    end)

    it("returns nil for more than one arg", function()
      -- Arrange / Act / Assert
      assert.is_nil(core.mode_from_argv({ "claude", "extra" }))
    end)

    it("returns nil for non-trigger args", function()
      -- Arrange / Act / Assert
      assert.is_nil(core.mode_from_argv({ "foo.lua" }))
    end)

    it("returns nil when argv is not a table", function()
      -- Arrange / Act / Assert
      assert.is_nil(core.mode_from_argv(nil))
      assert.is_nil(core.mode_from_argv("claude"))
    end)

    it(
      "degrades to nil when a real file named 'claude' exists in cwd",
      function()
        -- Arrange: create a temp file, cd into its dir, name arg after it
        local tmpdir = vim.fn.tempname()
        vim.fn.mkdir(tmpdir, "p")
        local filepath = tmpdir .. "/claude"
        local f = io.open(filepath, "w")
        assert(f, "failed to create temp file")
        f:write("")
        f:close()
        local prev_cwd = vim.fn.getcwd()
        vim.cmd("cd " .. tmpdir)

        -- Act
        local result = core.mode_from_argv({ "claude" })

        -- Assert
        assert.is_nil(result)

        -- Cleanup
        vim.cmd("cd " .. prev_cwd)
        os.remove(filepath)
        vim.fn.delete(tmpdir, "d")
      end
    )

    it(
      "degrades to nil when a real directory named 'c' exists in cwd",
      function()
        -- Arrange
        local tmpdir = vim.fn.tempname()
        vim.fn.mkdir(tmpdir .. "/c", "p")
        local prev_cwd = vim.fn.getcwd()
        vim.cmd("cd " .. tmpdir)

        -- Act
        local result = core.mode_from_argv({ "c" })

        -- Assert
        assert.is_nil(result)

        -- Cleanup
        vim.cmd("cd " .. prev_cwd)
        vim.fn.delete(tmpdir, "rf")
      end
    )
  end)

  describe("TRIGGERS", function()
    it("recognizes both long and short forms", function()
      -- Arrange / Act / Assert
      assert.is_true(core.TRIGGERS.claude)
      assert.is_true(core.TRIGGERS.c)
    end)
  end)
end)
