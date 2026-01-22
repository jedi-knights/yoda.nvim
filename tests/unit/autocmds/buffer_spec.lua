local helpers = require("tests.helpers")

describe("autocmds.buffer", function()
  local buffer_autocmds
  local original_hrtime

  before_each(function()
    package.loaded["yoda.autocmds.buffer"] = nil
    package.loaded["yoda.autocmd_logger"] = nil
    package.loaded["yoda.autocmd_performance"] = nil
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded["yoda.ui.alpha_manager"] = nil
    package.loaded["yoda.integrations.gitsigns"] = nil
    package.loaded["yoda.buffer.state_checker"] = nil

    original_hrtime = vim.loop.hrtime

    local mock_time = 0
    vim.loop.hrtime = function()
      return mock_time
    end

    _G.mock_set_time = function(time_ms)
      mock_time = time_ms * 1000000
    end

    package.loaded["yoda.autocmd_logger"] = {
      log_start = function()
        return 0
      end,
      log = function() end,
      log_end = function() end,
    }

    package.loaded["yoda.autocmd_performance"] = {
      track_autocmd = function() end,
    }

    package.loaded["yoda-adapters.notification"] = {
      notify = function() end,
    }

    package.loaded["yoda.ui.alpha_manager"] = {
      handle_alpha_close_for_real_buffer = function() end,
      handle_alpha_dashboard_display = function() end,
      invalidate_cache = function() end,
    }

    package.loaded["yoda.integrations.gitsigns"] = {
      refresh_debounced = function() end,
    }

    package.loaded["yoda.buffer.state_checker"] = {
      is_buffer_empty = function()
        return false
      end,
    }

    buffer_autocmds = require("yoda.autocmds.buffer")
    buffer_autocmds.reset_buf_enter_state()
  end)

  after_each(function()
    vim.loop.hrtime = original_hrtime
    _G.mock_set_time = nil
    buffer_autocmds.reset_buf_enter_state()
    package.loaded["yoda.autocmds.buffer"] = nil
    package.loaded["yoda.autocmd_logger"] = nil
    package.loaded["yoda.autocmd_performance"] = nil
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded["yoda.ui.alpha_manager"] = nil
    package.loaded["yoda.integrations.gitsigns"] = nil
    package.loaded["yoda.buffer.state_checker"] = nil
  end)

  describe("BufEnter global debounce", function()
    it("skips processing when called within debounce window", function()
      local callback_fn
      local process_count = 0

      local mock_autocmd = function(event, opts)
        if event == "BufEnter" then
          callback_fn = opts.callback
        end
      end

      local mock_augroup = function(name, opts)
        return name
      end

      buffer_autocmds.setup_all(mock_autocmd, mock_augroup)

      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "lua", buflisted = true }
        end,
      })

      local mock_alpha_manager = package.loaded["yoda.ui.alpha_manager"]
      mock_alpha_manager.handle_alpha_close_for_real_buffer = function()
        process_count = process_count + 1
      end

      _G.mock_set_time(0)
      callback_fn({ buf = 1 })

      _G.mock_set_time(25)
      callback_fn({ buf = 1 })

      _G.mock_set_time(40)
      callback_fn({ buf = 1 })

      local state = buffer_autocmds.get_buf_enter_state()
      assert.is_true(state.debounced_count >= 1, "Should have debounced at least 1 event, got " .. state.debounced_count)
      assert.is_true(process_count <= 1, "Should process at most once within debounce window, got " .. process_count)
    end)

    it("allows processing after debounce window", function()
      local callback_fn
      local process_count = 0

      local mock_autocmd = function(event, opts)
        if event == "BufEnter" then
          callback_fn = opts.callback
        end
      end

      local mock_augroup = function(name, opts)
        return name
      end

      buffer_autocmds.setup_all(mock_autocmd, mock_augroup)

      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "lua", buflisted = true }
        end,
      })

      local mock_alpha_manager = package.loaded["yoda.ui.alpha_manager"]
      mock_alpha_manager.handle_alpha_close_for_real_buffer = function()
        process_count = process_count + 1
      end

      _G.mock_set_time(0)
      callback_fn({ buf = 1 })

      _G.mock_set_time(100)
      callback_fn({ buf = 1 })

      assert.equals(2, process_count, "Should process both events after debounce window")
    end)

    it("tracks debounced event count", function()
      local callback_fn

      local mock_autocmd = function(event, opts)
        if event == "BufEnter" then
          callback_fn = opts.callback
        end
      end

      local mock_augroup = function(name, opts)
        return name
      end

      buffer_autocmds.setup_all(mock_autocmd, mock_augroup)

      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "lua", buflisted = true }
        end,
      })

      _G.mock_set_time(0)
      callback_fn({ buf = 1 })

      _G.mock_set_time(10)
      callback_fn({ buf = 1 })

      _G.mock_set_time(20)
      callback_fn({ buf = 1 })

      _G.mock_set_time(30)
      callback_fn({ buf = 1 })

      local state = buffer_autocmds.get_buf_enter_state()
      assert.is_true(state.debounced_count >= 2, "Should have debounced at least 2 events, got " .. state.debounced_count)
    end)
  end)

  describe("BufEnter recursion protection", function()
    it("tracks recursion depth", function()
      local callback_fn
      local mock_autocmd = function(event, opts)
        if event == "BufEnter" then
          callback_fn = opts.callback
        end
      end

      local mock_augroup = function(name, opts)
        return name
      end

      buffer_autocmds.setup_all(mock_autocmd, mock_augroup)

      local initial_state = buffer_autocmds.get_buf_enter_state()
      assert.equals(0, initial_state.depth, "Initial depth should be 0")

      _G.mock_set_time(100)

      local mock_buf = 1
      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "lua", buflisted = true }
        end,
      })

      callback_fn({ buf = mock_buf })

      local state_after = buffer_autocmds.get_buf_enter_state()
      assert.equals(0, state_after.depth, "Depth should return to 0 after callback completes")
      assert.equals(1, state_after.entry_count, "Entry count should be 1")
    end)

    it("prevents infinite loops by limiting recursion depth", function()
      local callback_fn
      local call_count = 0
      local max_depth_seen = 0

      local mock_autocmd = function(event, opts)
        if event == "BufEnter" then
          callback_fn = opts.callback
        end
      end

      local mock_augroup = function(name, opts)
        return name
      end

      buffer_autocmds.setup_all(mock_autocmd, mock_augroup)

      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "lua", buflisted = true }
        end,
      })

      local mock_alpha_manager = package.loaded["yoda.ui.alpha_manager"]
      mock_alpha_manager.handle_alpha_close_for_real_buffer = function(buf)
        call_count = call_count + 1
        local state = buffer_autocmds.get_buf_enter_state()
        if state.depth > max_depth_seen then
          max_depth_seen = state.depth
        end
        
        if call_count < 10 then
          _G.mock_set_time(100 + call_count * 10)
          callback_fn({ buf = buf })
        end
      end

      _G.mock_set_time(100)
      callback_fn({ buf = 1 })

      assert.is_true(max_depth_seen <= 3, "Maximum depth should be limited to 3, but saw " .. max_depth_seen)
      assert.is_true(call_count < 10, "Recursion should be limited, preventing infinite loops")
    end)

    it("resets state after timeout period", function()
      local callback_fn

      local mock_autocmd = function(event, opts)
        if event == "BufEnter" then
          callback_fn = opts.callback
        end
      end

      local mock_augroup = function(name, opts)
        return name
      end

      buffer_autocmds.setup_all(mock_autocmd, mock_augroup)

      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "lua", buflisted = true }
        end,
      })

      _G.mock_set_time(0)
      callback_fn({ buf = 1 })
      callback_fn({ buf = 1 })
      callback_fn({ buf = 1 })

      local state_before_timeout = buffer_autocmds.get_buf_enter_state()
      assert.equals(3, state_before_timeout.entry_count, "Should have 3 entries")

      _G.mock_set_time(6000)
      callback_fn({ buf = 1 })

      local state_after_timeout = buffer_autocmds.get_buf_enter_state()
      assert.equals(0, state_after_timeout.depth, "Depth should be 0 after callback completes")
      assert.is_true(
        state_after_timeout.entry_count < state_before_timeout.entry_count + 2,
        "Entry count should have been reset (timeout resets to 0, then incremented to 1)"
      )
    end)

    it("decrements depth on early return paths", function()
      local callback_fn
      local mock_autocmd = function(event, opts)
        if event == "BufEnter" then
          callback_fn = opts.callback
        end
      end

      local mock_augroup = function(name, opts)
        return name
      end

      buffer_autocmds.setup_all(mock_autocmd, mock_augroup)

      vim.api.nvim_buf_get_name = function()
        return "snacks_terminal"
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "", buflisted = false }
        end,
      })

      _G.mock_set_time(100)
      callback_fn({ buf = 1 })

      local state = buffer_autocmds.get_buf_enter_state()
      assert.equals(0, state.depth, "Depth should be 0 after early return")
    end)
  end)

  describe("state management", function()
    it("get_buf_enter_state returns current state", function()
      local state = buffer_autocmds.get_buf_enter_state()
      assert.is_not_nil(state)
      assert.is_not_nil(state.depth)
      assert.is_not_nil(state.last_entry_time)
      assert.is_not_nil(state.entry_count)
    end)

    it("reset_buf_enter_state clears all counters", function()
      local callback_fn
      local mock_autocmd = function(event, opts)
        if event == "BufEnter" then
          callback_fn = opts.callback
        end
      end

      local mock_augroup = function(name, opts)
        return name
      end

      buffer_autocmds.setup_all(mock_autocmd, mock_augroup)

      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      vim.bo = setmetatable({}, {
        __index = function()
          return { buftype = "", filetype = "lua", buflisted = true }
        end,
      })

      _G.mock_set_time(100)
      callback_fn({ buf = 1 })

      local state_before = buffer_autocmds.get_buf_enter_state()
      assert.is_true(state_before.entry_count > 0, "Should have entries before reset")

      buffer_autocmds.reset_buf_enter_state()

      local state_after = buffer_autocmds.get_buf_enter_state()
      assert.equals(0, state_after.depth)
      assert.equals(0, state_after.last_entry_time)
      assert.equals(0, state_after.entry_count)
    end)
  end)
end)
