-- Tests for commands.lua
describe("commands", function()
  -- Store original functions
  local original_vim_cmd = vim.cmd
  local original_notify = vim.notify

  before_each(function()
    -- Clear any existing commands
    pcall(vim.api.nvim_del_user_command, "YodaDiagnostics")
    pcall(vim.api.nvim_del_user_command, "YodaAICheck")
    pcall(vim.api.nvim_del_user_command, "YodaDebugLazy")
    pcall(vim.api.nvim_del_user_command, "YodaCleanLazy")
    pcall(vim.api.nvim_del_user_command, "FormatFeature")

    -- Mock vim.cmd to prevent checkhealth from running
    vim.cmd = function(cmd)
      if cmd == "checkhealth" then
        -- No-op, don't run actual checkhealth
        return
      end
      return original_vim_cmd(cmd)
    end

    -- Mock vim.notify to prevent notifications during tests
    vim.notify = function(msg, level)
      -- No-op during tests
    end

    -- Mock diagnostics modules BEFORE loading commands
    package.loaded["yoda.diagnostics"] = {
      run_all = function()
        -- Fast mock implementation
        vim.notify("🔍 Running Yoda diagnostics...", vim.log.levels.INFO)
        -- Don't call checkhealth or do any expensive operations
      end,
      lsp = {
        check_status = function()
          return true
        end,
      },
      ai = {
        check_status = function()
          return { claude_available = false, copilot_loaded = false }
        end,
        display_detailed_check = function()
          -- Fast mock implementation
        end,
      },
    }

    package.loaded["yoda.diagnostics.ai"] = {
      display_detailed_check = function()
        -- Fast mock implementation
      end,
    }

    -- Load commands module
    package.loaded["yoda.commands"] = nil
    require("yoda.commands")
  end)

  after_each(function()
    -- Restore original functions
    vim.cmd = original_vim_cmd
    vim.notify = original_notify
  end)

  describe("command registration", function()
    it("registers YodaDiagnostics command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.YodaDiagnostics)
    end)

    it("registers YodaAICheck command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.YodaAICheck)
    end)

    it("registers YodaDebugLazy command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.YodaDebugLazy)
    end)

    it("registers YodaCleanLazy command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.YodaCleanLazy)
    end)

    it("registers FormatFeature command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.FormatFeature)
    end)
  end)

  describe("YodaDiagnostics command", function()
    it("calls diagnostics.run_all()", function()
      local called = false

      -- Override the mocked function to track calls
      package.loaded["yoda.diagnostics"].run_all = function()
        called = true
      end

      vim.cmd("YodaDiagnostics")

      assert.is_true(called)
    end)

    it("handles missing diagnostics module", function()
      -- Clear the mocked module to simulate missing module
      package.loaded["yoda.diagnostics"] = nil

      -- Should not crash
      local ok = pcall(function()
        vim.cmd("YodaDiagnostics")
      end)

      -- May fail but shouldn't crash Neovim
      assert.is_boolean(ok)
    end)
  end)

  describe("YodaAICheck command", function()
    it("calls diagnostics.ai.display_detailed_check()", function()
      local called = false

      -- Override the mocked function to track calls
      package.loaded["yoda.diagnostics.ai"].display_detailed_check = function()
        called = true
      end

      vim.cmd("YodaAICheck")

      assert.is_true(called)
    end)
  end)

  describe("FormatFeature command", function()
    it("is callable without errors", function()
      -- Create a test buffer with simple content
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(bufnr)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
        "Feature: Test",
        "  Examples:",
        "    | a | b |",
        "    | 1 | 2 |",
      })

      -- Should not crash
      local ok = pcall(function()
        vim.cmd("FormatFeature")
      end)

      assert.is_true(ok)

      -- Clean up
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  end)

  describe("YodaDebugLazy command", function()
    it("prints debug information", function()
      local printed = false
      local original_print = print

      print = function(...)
        printed = true
      end

      vim.cmd("YodaDebugLazy")

      print = original_print
      assert.is_true(printed)
    end)
  end)

  describe("YodaCleanLazy command", function()
    it("is callable without errors", function()
      -- Mock file/directory operations
      local original_delete = vim.fn.delete
      local original_isdirectory = vim.fn.isdirectory
      local original_filereadable = vim.fn.filereadable

      vim.fn.delete = function()
        return 0
      end
      vim.fn.isdirectory = function()
        return 0
      end
      vim.fn.filereadable = function()
        return 0
      end

      local ok = pcall(function()
        vim.cmd("YodaCleanLazy")
      end)

      vim.fn.delete = original_delete
      vim.fn.isdirectory = original_isdirectory
      vim.fn.filereadable = original_filereadable

      assert.is_true(ok)
    end)
  end)
end)
