local helpers = require("tests.helpers")

describe("ui.alpha_manager", function()
  local alpha_manager
  local original_list_bufs
  local original_buf_is_valid
  local original_bo

  before_each(function()
    package.loaded["yoda.ui.alpha_manager"] = nil
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded["yoda-window.utils"] = nil

    original_list_bufs = vim.api.nvim_list_bufs
    original_buf_is_valid = vim.api.nvim_buf_is_valid
    original_bo = vim.bo

    _G.mock_bufs = {}
    vim.api.nvim_list_bufs = function()
      local bufs = {}
      for buf_num, _ in pairs(_G.mock_bufs) do
        table.insert(bufs, buf_num)
      end
      return bufs
    end

    vim.api.nvim_buf_is_valid = function(buf)
      return _G.mock_bufs[buf] ~= nil
    end

    vim.bo = setmetatable({}, {
      __index = function(_, buf)
        return _G.mock_bufs[buf] or {}
      end,
    })

    package.loaded["yoda-adapters.notification"] = {
      notify = function() end,
    }

    package.loaded["yoda-window.utils"] = {
      find_by_filetype = function()
        return nil, nil
      end,
    }

    alpha_manager = require("yoda.ui.alpha_manager")
  end)

  after_each(function()
    vim.api.nvim_list_bufs = original_list_bufs
    vim.api.nvim_buf_is_valid = original_buf_is_valid
    vim.bo = original_bo
    _G.mock_bufs = nil
    package.loaded["yoda.ui.alpha_manager"] = nil
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded["yoda-window.utils"] = nil
    package.loaded["alpha"] = nil
    package.loaded["alpha.themes.dashboard"] = nil
  end)

  describe("race condition protection", function()
    describe("cache invalidation on buffer events", function()
      it("invalidates cache on buffer creation", function()
        _G.mock_bufs = {
          [1] = { buflisted = true, filetype = "alpha" },
        }

        local has_alpha = alpha_manager.has_alpha_buffer()
        assert.is_true(has_alpha, "Should detect alpha buffer")

        alpha_manager.invalidate_cache()

        _G.mock_bufs = {}

        local has_alpha_after = alpha_manager.has_alpha_buffer()
        assert.is_false(has_alpha_after, "Should detect no alpha buffer after invalidation")
      end)

      it("invalidates cache on buffer deletion", function()
        _G.mock_bufs = {}

        local has_alpha = alpha_manager.has_alpha_buffer()
        assert.is_false(has_alpha, "Should detect no alpha buffer")

        alpha_manager.invalidate_cache()

        _G.mock_bufs = {
          [1] = { buflisted = true, filetype = "alpha" },
        }

        local has_alpha_after = alpha_manager.has_alpha_buffer()
        assert.is_true(has_alpha_after, "Should detect alpha buffer after invalidation")
      end)

      it("invalidates both has_alpha_buffer and normal_count caches", function()
        _G.mock_bufs = {
          [1] = { buflisted = true, filetype = "alpha" },
          [2] = { buflisted = true, filetype = "lua" },
        }

        local has_alpha = alpha_manager.has_alpha_buffer()
        local normal_count = alpha_manager.count_normal_buffers()

        assert.is_true(has_alpha, "Should cache alpha presence")
        assert.equals(1, normal_count, "Should cache normal buffer count")

        alpha_manager.invalidate_cache()

        _G.mock_bufs = {
          [2] = { buflisted = true, filetype = "lua" },
          [3] = { buflisted = true, filetype = "python" },
        }

        local has_alpha_after = alpha_manager.has_alpha_buffer()
        local normal_count_after = alpha_manager.count_normal_buffers()

        assert.is_false(has_alpha_after, "Should detect no alpha buffer")
        assert.equals(2, normal_count_after, "Should detect 2 normal buffers")
      end)
    end)
  end)

  describe("has_alpha_buffer", function()
    it("returns false when no buffers exist", function()
      _G.mock_bufs = {}
      local result = alpha_manager.has_alpha_buffer()
      assert.is_false(result)
    end)

    it("returns true when alpha buffer exists", function()
      _G.mock_bufs = {
        [1] = { buflisted = true, filetype = "alpha" },
      }
      local result = alpha_manager.has_alpha_buffer()
      assert.is_true(result)
    end)

    it("returns false when only non-alpha buffers exist", function()
      _G.mock_bufs = {
        [1] = { buflisted = true, filetype = "lua" },
        [2] = { buflisted = true, filetype = "python" },
      }
      local result = alpha_manager.has_alpha_buffer()
      assert.is_false(result)
    end)

    it("ignores unlisted alpha buffers", function()
      _G.mock_bufs = {
        [1] = { buflisted = false, filetype = "alpha" },
      }
      local result = alpha_manager.has_alpha_buffer()
      assert.is_false(result)
    end)
  end)

  describe("count_normal_buffers", function()
    it("returns 0 when no buffers exist", function()
      _G.mock_bufs = {}
      local result = alpha_manager.count_normal_buffers()
      assert.equals(0, result)
    end)

    it("counts normal buffers correctly", function()
      _G.mock_bufs = {
        [1] = { buflisted = true, filetype = "lua" },
        [2] = { buflisted = true, filetype = "python" },
      }
      local result = alpha_manager.count_normal_buffers()
      assert.equals(2, result)
    end)

    it("excludes alpha buffers from count", function()
      _G.mock_bufs = {
        [1] = { buflisted = true, filetype = "alpha" },
        [2] = { buflisted = true, filetype = "lua" },
      }
      local result = alpha_manager.count_normal_buffers()
      assert.equals(1, result)
    end)

    it("excludes empty filetype buffers from count", function()
      _G.mock_bufs = {
        [1] = { buflisted = true, filetype = "" },
        [2] = { buflisted = true, filetype = "lua" },
      }
      local result = alpha_manager.count_normal_buffers()
      assert.equals(1, result)
    end)

    it("excludes unlisted buffers from count", function()
      _G.mock_bufs = {
        [1] = { buflisted = false, filetype = "lua" },
        [2] = { buflisted = true, filetype = "python" },
      }
      local result = alpha_manager.count_normal_buffers()
      assert.equals(1, result)
    end)
  end)

  describe("invalidate_cache", function()
    it("clears cached values", function()
      _G.mock_bufs = {
        [1] = { buflisted = true, filetype = "alpha" },
      }

      local first_result = alpha_manager.has_alpha_buffer()
      assert.is_true(first_result)

      _G.mock_bufs = {}
      alpha_manager.invalidate_cache()

      local second_result = alpha_manager.has_alpha_buffer()
      assert.is_false(second_result)
    end)
  end)
end)
