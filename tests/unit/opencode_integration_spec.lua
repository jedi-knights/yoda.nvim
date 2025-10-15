-- tests/unit/opencode_integration_spec.lua
-- Tests for OpenCode integration utilities

local helpers = require("tests.helpers")

describe("yoda.opencode_integration", function()
  local opencode_integration
  local mock_vim = {}
  local mock_api = {}
  local mock_fn = {}
  local mock_bo = {}
  local original_vim

  before_each(function()
    -- Reset modules
    package.loaded["yoda.opencode_integration"] = nil
    package.loaded["opencode"] = nil

    -- Store original vim
    original_vim = vim

    -- Create mocks
    mock_api = {
      nvim_list_bufs = helpers.spy(),
      nvim_buf_is_valid = helpers.spy(),
      nvim_buf_get_name = helpers.spy(),
      nvim_buf_call = helpers.spy(),
      nvim_get_current_buf = helpers.spy(),
      nvim_create_user_command = helpers.spy(),
      nvim_create_autocmd = helpers.spy(),
    }

    mock_fn = {
      filereadable = helpers.spy(),
      fnamemodify = helpers.spy(),
    }

    mock_bo = {}

    -- Mock vim global
    mock_vim = {
      api = mock_api,
      fn = mock_fn,
      bo = mock_bo,
      schedule = helpers.spy(),
      notify = helpers.spy(),
      cmd = helpers.spy(),
      log = { levels = { INFO = 2, WARN = 3 } },
      defer_fn = helpers.spy(),
    }

    -- Set global vim mock
    vim = mock_vim

    -- Load the module after mocking
    opencode_integration = require("yoda.opencode_integration")
  end)

  after_each(function()
    -- Restore original vim
    vim = original_vim
  end)

  describe("is_available()", function()
    it("returns true when opencode is available", function()
      package.loaded["opencode"] = {}
      assert.is_true(opencode_integration.is_available())
    end)

    it("returns false when opencode is not available", function()
      package.loaded["opencode"] = nil
      assert.is_false(opencode_integration.is_available())
    end)
  end)

  describe("save_all_buffers()", function()
    it("saves all modified buffers successfully", function()
      -- Setup mock data
      local buf1 = 1
      local buf2 = 2
      mock_api.nvim_list_bufs.returns({ buf1, buf2 })
      mock_api.nvim_buf_is_valid.returns_values({ true, true })
      mock_api.nvim_buf_get_name.returns_values({ "/path/to/file1.lua", "/path/to/file2.lua" })

      -- Mock buffer options
      mock_bo[buf1] = { modified = true, buftype = "" }
      mock_bo[buf2] = { modified = true, buftype = "" }

      -- Mock successful buffer calls
      mock_api.nvim_buf_call.callback(function(buf, fn)
        fn() -- Execute the callback
      end)

      local result = opencode_integration.save_all_buffers()

      assert.is_true(result)
      assert.spy(mock_api.nvim_buf_call).was_called(2)
      assert.spy(mock_vim.notify).was_called_with("🤖 OpenCode: Auto-saved 2 file(s)", mock_vim.log.levels.INFO)
    end)

    it("handles buffers with no modifications", function()
      local buf1 = 1
      mock_api.nvim_list_bufs.returns({ buf1 })
      mock_api.nvim_buf_is_valid.returns(true)
      mock_bo[buf1] = { modified = false, buftype = "" }

      local result = opencode_integration.save_all_buffers()

      assert.is_true(result)
      assert.spy(mock_api.nvim_buf_call).was_not_called()
      assert.spy(mock_vim.notify).was_not_called()
    end)

    it("skips special buffers", function()
      local buf1 = 1
      mock_api.nvim_list_bufs.returns({ buf1 })
      mock_api.nvim_buf_is_valid.returns(true)
      mock_api.nvim_buf_get_name.returns("/path/to/file.lua")
      mock_bo[buf1] = { modified = true, buftype = "terminal" }

      local result = opencode_integration.save_all_buffers()

      assert.is_true(result)
      assert.spy(mock_api.nvim_buf_call).was_not_called()
    end)

    it("handles save errors gracefully", function()
      local buf1 = 1
      mock_api.nvim_list_bufs.returns({ buf1 })
      mock_api.nvim_buf_is_valid.returns(true)
      mock_api.nvim_buf_get_name.returns("/path/to/file.lua")
      mock_bo[buf1] = { modified = true, buftype = "" }
      mock_fn.fnamemodify.returns("file.lua")

      -- Mock failed buffer call
      mock_api.nvim_buf_call.callback(function(buf, fn)
        error("Save failed")
      end)

      local result = opencode_integration.save_all_buffers()

      assert.is_false(result)
      assert.spy(mock_vim.notify).was_called_with("Failed to auto-save file.lua: Save failed", mock_vim.log.levels.WARN)
    end)
  end)

  describe("refresh_buffer()", function()
    it("refreshes a valid buffer successfully", function()
      local buf = 1
      mock_api.nvim_buf_is_valid.returns(true)
      mock_api.nvim_buf_get_name.returns("/path/to/file.lua")
      mock_fn.filereadable.returns(1)
      mock_bo[buf] = { modified = false, modifiable = true, buftype = "", readonly = false }

      -- Mock successful buffer call
      mock_api.nvim_buf_call.callback(function(buf, fn)
        fn() -- Execute the callback
      end)

      local result = opencode_integration.refresh_buffer(buf)

      assert.is_true(result)
      assert.spy(mock_api.nvim_buf_call).was_called_with(buf, helpers.match.is_function())
    end)

    it("skips invalid buffers", function()
      mock_api.nvim_buf_is_valid.returns(false)

      local result = opencode_integration.refresh_buffer(1)

      assert.is_false(result)
      assert.spy(mock_api.nvim_buf_call).was_not_called()
    end)

    it("skips modified buffers", function()
      local buf = 1
      mock_api.nvim_buf_is_valid.returns(true)
      mock_api.nvim_buf_get_name.returns("/path/to/file.lua")
      mock_fn.filereadable.returns(1)
      mock_bo[buf] = { modified = true, modifiable = true, buftype = "", readonly = false }

      local result = opencode_integration.refresh_buffer(buf)

      assert.is_false(result)
      assert.spy(mock_api.nvim_buf_call).was_not_called()
    end)

    it("skips readonly buffers", function()
      local buf = 1
      mock_api.nvim_buf_is_valid.returns(true)
      mock_api.nvim_buf_get_name.returns("/path/to/file.lua")
      mock_fn.filereadable.returns(1)
      mock_bo[buf] = { modified = false, modifiable = true, buftype = "", readonly = true }

      local result = opencode_integration.refresh_buffer(buf)

      assert.is_false(result)
      assert.spy(mock_api.nvim_buf_call).was_not_called()
    end)
  end)

  describe("refresh_all_buffers()", function()
    it("processes all valid buffers", function()
      local buf1, buf2 = 1, 2
      mock_api.nvim_list_bufs.returns({ buf1, buf2 })
      mock_api.nvim_buf_is_valid.returns_values({ true, true })
      mock_api.nvim_buf_get_name.returns_values({ "/path/to/file1.lua", "/path/to/file2.lua" })
      mock_fn.filereadable.returns_values({ 1, 1 })
      mock_bo[buf1] = { buftype = "" }
      mock_bo[buf2] = { buftype = "" }

      -- Mock successful buffer calls
      mock_api.nvim_buf_call.callback(function(buf, fn)
        fn() -- Execute the callback
      end)

      local result = opencode_integration.refresh_all_buffers()

      assert.equals(2, result)
      assert.spy(mock_api.nvim_buf_call).was_called(2)
    end)

    it("skips special buffers", function()
      local buf1 = 1
      mock_api.nvim_list_bufs.returns({ buf1 })
      mock_api.nvim_buf_is_valid.returns(true)
      mock_bo[buf1] = { buftype = "terminal" }

      local result = opencode_integration.refresh_all_buffers()

      assert.equals(0, result)
      assert.spy(mock_api.nvim_buf_call).was_not_called()
    end)
  end)

  describe("refresh_git_signs()", function()
    it("refreshes git signs when gitsigns is loaded", function()
      local mock_gitsigns = { refresh = helpers.spy() }
      package.loaded.gitsigns = mock_gitsigns
      mock_bo.buftype = ""

      opencode_integration.refresh_git_signs()

      assert.spy(mock_vim.schedule).was_called()
    end)

    it("does nothing when gitsigns is not loaded", function()
      package.loaded.gitsigns = nil

      opencode_integration.refresh_git_signs()

      assert.spy(mock_vim.schedule).was_not_called()
    end)
  end)

  describe("refresh_explorer()", function()
    it("refreshes explorer when snacks is loaded", function()
      local mock_snacks = { explorer = { refresh = helpers.spy() } }
      package.loaded.snacks = mock_snacks

      opencode_integration.refresh_explorer()

      assert.spy(mock_vim.schedule).was_called()
    end)

    it("does nothing when snacks is not loaded", function()
      package.loaded.snacks = nil

      opencode_integration.refresh_explorer()

      assert.spy(mock_vim.schedule).was_not_called()
    end)
  end)

  describe("complete_refresh()", function()
    it("performs complete refresh cycle", function()
      mock_api.nvim_get_current_buf.returns(1)
      mock_api.nvim_buf_is_valid.returns(true)
      mock_api.nvim_buf_get_name.returns("/path/to/file.lua")
      mock_fn.filereadable.returns(1)
      mock_bo[1] = { modified = false, modifiable = true, buftype = "", readonly = false }

      opencode_integration.complete_refresh()

      assert.spy(mock_vim.schedule).was_called()
    end)
  end)

  describe("setup()", function()
    it("creates user commands when opencode is available", function()
      package.loaded["opencode"] = {}

      opencode_integration.setup()

      assert.spy(mock_api.nvim_create_user_command).was_called(4)
      assert.spy(mock_api.nvim_create_autocmd).was_called(1)
    end)

    it("does nothing when opencode is not available", function()
      package.loaded["opencode"] = nil

      opencode_integration.setup()

      assert.spy(mock_api.nvim_create_user_command).was_not_called()
      assert.spy(mock_api.nvim_create_autocmd).was_not_called()
    end)
  end)
end)
