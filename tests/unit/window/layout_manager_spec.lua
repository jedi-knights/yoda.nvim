-- tests/unit/window/layout_manager_spec.lua
-- Tests for window layout manager

local helpers = require("tests.helpers")

describe("window.layout_manager", function()
  local layout_manager

  before_each(function()
    package.loaded["yoda.window.layout_manager"] = nil
    layout_manager = require("yoda-window.layout_manager")
  end)

  describe("handle_buf_win_enter()", function()
    it("skips special buffer filetypes", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].filetype = "snacks-explorer"

      -- Should not error and should return early
      layout_manager.handle_buf_win_enter(buf)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("skips opencode filetype", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].filetype = "opencode"

      layout_manager.handle_buf_win_enter(buf)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("skips alpha filetype", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].filetype = "alpha"

      layout_manager.handle_buf_win_enter(buf)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("skips buffers with empty name", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, "")

      layout_manager.handle_buf_win_enter(buf)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("skips special buffer types", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].buftype = "nofile"
      vim.api.nvim_buf_set_name(buf, "test.lua")

      layout_manager.handle_buf_win_enter(buf)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("processes real file buffers", function()
      local buf = vim.api.nvim_create_buf(false, false)
      vim.api.nvim_buf_set_name(buf, "test.lua")
      vim.bo[buf].buftype = ""
      vim.bo[buf].filetype = "lua"

      -- Should not error
      layout_manager.handle_buf_win_enter(buf)

      -- Wait for vim.schedule
      vim.wait(50)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("handles invalid buffer gracefully", function()
      -- Should not error
      layout_manager.handle_buf_win_enter(99999)
    end)
  end)

  describe("setup_autocmds()", function()
    it("creates BufWinEnter autocmd", function()
      local autocmd_called = false
      local captured_event = nil

      local mock_autocmd = function(event, opts)
        autocmd_called = true
        captured_event = event
      end

      local mock_augroup = function(name, opts)
        return name
      end

      layout_manager.setup_autocmds(mock_autocmd, mock_augroup)

      assert.is_true(autocmd_called)
      assert.equals("BufWinEnter", captured_event)
    end)

    it("sets up autocmd with callback", function()
      local captured_callback = nil

      local mock_autocmd = function(event, opts)
        captured_callback = opts.callback
      end

      local mock_augroup = function(name, opts)
        return name
      end

      layout_manager.setup_autocmds(mock_autocmd, mock_augroup)

      assert.is_function(captured_callback)
    end)

    it("uses YodaWindowLayout augroup", function()
      local augroup_name = nil

      local mock_autocmd = function(event, opts)
        augroup_name = opts.group
      end

      local mock_augroup = function(name, opts)
        return name
      end

      layout_manager.setup_autocmds(mock_autocmd, mock_augroup)

      assert.equals("YodaWindowLayout", augroup_name)
    end)
  end)

  describe("integration", function()
    it("does not interfere when explorer or opencode not present", function()
      local buf = vim.api.nvim_create_buf(false, false)
      vim.api.nvim_buf_set_name(buf, "test.lua")
      vim.bo[buf].buftype = ""
      vim.bo[buf].filetype = "lua"

      local original_win = vim.api.nvim_get_current_win()

      layout_manager.handle_buf_win_enter(buf)

      -- Wait for vim.schedule
      vim.wait(100)

      -- Window should remain unchanged
      assert.equals(original_win, vim.api.nvim_get_current_win())

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("handles multiple buffer types correctly", function()
      local test_cases = {
        { filetype = "snacks-explorer", should_skip = true },
        { filetype = "opencode", should_skip = true },
        { filetype = "alpha", should_skip = true },
        { filetype = "lua", buftype = "", should_skip = false },
        { filetype = "python", buftype = "nofile", should_skip = true },
      }

      for _, case in ipairs(test_cases) do
        local buf = vim.api.nvim_create_buf(false, false)
        vim.bo[buf].filetype = case.filetype
        vim.bo[buf].buftype = case.buftype or ""
        vim.api.nvim_buf_set_name(buf, "test" .. case.filetype)

        -- Should not error regardless of skip status
        layout_manager.handle_buf_win_enter(buf)

        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)
  end)
end)
