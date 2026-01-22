local helpers = require("tests.helpers")

describe("autocmds.focus", function()
  local focus_handler
  local original_hrtime

  before_each(function()
    package.loaded["yoda.autocmds.focus"] = nil
    package.loaded["yoda.integrations.gitsigns"] = nil
    package.loaded["yoda.buffer.state_checker"] = nil
    package.loaded["yoda.opencode_integration"] = nil

    original_hrtime = vim.loop.hrtime

    local mock_time = 0
    vim.loop.hrtime = function()
      return mock_time
    end

    _G.mock_set_time = function(time_ms)
      mock_time = time_ms * 1000000
    end

    package.loaded["yoda.integrations.gitsigns"] = {
      refresh_debounced = function() end,
      is_available = function()
        return true
      end,
    }

    package.loaded["yoda.buffer.state_checker"] = {
      can_reload_buffer = function()
        return true
      end,
    }

    package.loaded["yoda.opencode_integration"] = {
      refresh_buffer = function() end,
      refresh_git_signs = function() end,
    }

    focus_handler = require("yoda.autocmds.focus")
    focus_handler.reset_state()
  end)

  after_each(function()
    vim.loop.hrtime = original_hrtime
    _G.mock_set_time = nil
    focus_handler.reset_state()
    package.loaded["yoda.autocmds.focus"] = nil
    package.loaded["yoda.integrations.gitsigns"] = nil
    package.loaded["yoda.buffer.state_checker"] = nil
    package.loaded["yoda.opencode_integration"] = nil
  end)

  describe("setup_all", function()
    it("creates FocusGained autocmd", function()
      local autocmd_created = false
      local autocmd_event = nil

      local mock_autocmd = function(event, opts)
        autocmd_created = true
        autocmd_event = event
      end

      local mock_augroup = function(name, opts)
        return name
      end

      focus_handler.setup_all(mock_autocmd, mock_augroup)

      assert.is_true(autocmd_created, "Autocmd should be created")
      assert.equals("FocusGained", autocmd_event)
    end)

    it("uses YodaConsolidatedFocusRefresh augroup", function()
      local augroup_name = nil

      local mock_autocmd = function(event, opts) end

      local mock_augroup = function(name, opts)
        augroup_name = name
        return name
      end

      focus_handler.setup_all(mock_autocmd, mock_augroup)

      assert.equals("YodaConsolidatedFocusRefresh", augroup_name)
    end)
  end)

  describe("focus refresh coordination", function()
    it("debounces rapid focus events", function()
      local refresh_count = 0
      local gitsigns = package.loaded["yoda.integrations.gitsigns"]
      gitsigns.refresh_debounced = function()
        refresh_count = refresh_count + 1
      end

      local callback_fn
      local mock_autocmd = function(event, opts)
        callback_fn = opts.callback
      end

      local mock_augroup = function(name, opts)
        return name
      end

      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      vim.fn.filereadable = function()
        return 1
      end
      vim.fn.expand = function()
        return "test.lua"
      end
      vim.api.nvim_get_current_buf = function()
        return 1
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "lua" }
        end,
      })

      focus_handler.setup_all(mock_autocmd, mock_augroup)

      _G.mock_set_time(0)
      callback_fn()

      _G.mock_set_time(50)
      callback_fn()

      vim.wait(20)

      assert.is_true(refresh_count <= 1, "Should refresh at most once due to debouncing, got " .. refresh_count)
    end)

    it("allows refresh after debounce period", function()
      local refresh_count = 0
      local gitsigns = package.loaded["yoda.integrations.gitsigns"]
      gitsigns.refresh_debounced = function()
        refresh_count = refresh_count + 1
      end

      local callback_fn
      local mock_autocmd = function(event, opts)
        callback_fn = opts.callback
      end

      local mock_augroup = function(name, opts)
        return name
      end

      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      vim.fn.filereadable = function()
        return 1
      end
      vim.fn.expand = function()
        return "test.lua"
      end
      vim.api.nvim_get_current_buf = function()
        return 1
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "lua" }
        end,
      })

      focus_handler.setup_all(mock_autocmd, mock_augroup)

      _G.mock_set_time(0)
      callback_fn()

      vim.wait(20)

      _G.mock_set_time(150)
      callback_fn()

      vim.wait(20)

      assert.is_true(refresh_count >= 1, "Should refresh at least once, got " .. refresh_count)
    end)

    it("skips refresh for opencode buffers", function()
      local refresh_called = false
      local gitsigns = package.loaded["yoda.integrations.gitsigns"]
      gitsigns.refresh_debounced = function()
        refresh_called = true
      end

      local callback_fn
      local mock_autocmd = function(event, opts)
        callback_fn = opts.callback
      end

      local mock_augroup = function(name, opts)
        return name
      end

      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "opencode" }
        end,
      })

      focus_handler.setup_all(mock_autocmd, mock_augroup)

      _G.mock_set_time(0)
      callback_fn()

      vim.wait(10)

      assert.is_false(refresh_called, "Should not refresh for opencode buffers")
    end)

    it("tracks last focus time", function()
      local callback_fn
      local mock_autocmd = function(event, opts)
        callback_fn = opts.callback
      end

      local mock_augroup = function(name, opts)
        return name
      end

      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      vim.fn.filereadable = function()
        return 1
      end
      vim.fn.expand = function()
        return "test.lua"
      end
      vim.api.nvim_get_current_buf = function()
        return 1
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "lua" }
        end,
      })

      focus_handler.setup_all(mock_autocmd, mock_augroup)

      local state_before = focus_handler.get_state()
      assert.equals(0, state_before.last_focus_time)

      _G.mock_set_time(1000)
      callback_fn()

      local state_after = focus_handler.get_state()
      assert.is_true(state_after.last_focus_time > 0, "Should track last focus time")
    end)
  end)

  describe("state management", function()
    it("get_state returns current state", function()
      local state = focus_handler.get_state()

      assert.is_not_nil(state)
      assert.is_not_nil(state.last_focus_time)
      assert.is_not_nil(state.debounce_ms)
      assert.equals(100, state.debounce_ms)
    end)

    it("reset_state clears last_focus_time", function()
      _G.mock_set_time(1000)

      local callback_fn
      local mock_autocmd = function(event, opts)
        callback_fn = opts.callback
      end

      local mock_augroup = function(name, opts)
        return name
      end

      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "lua" }
        end,
      })

      focus_handler.setup_all(mock_autocmd, mock_augroup)
      callback_fn()

      local state_before = focus_handler.get_state()
      assert.is_true(state_before.last_focus_time > 0, "Should have focus time")

      focus_handler.reset_state()

      local state_after = focus_handler.get_state()
      assert.equals(0, state_after.last_focus_time, "Should reset to 0")
    end)
  end)
end)
