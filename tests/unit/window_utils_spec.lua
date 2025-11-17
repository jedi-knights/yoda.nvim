-- Tests for window_utils.lua
local window_utils = require("yoda-window_utils")

describe("window_utils", function()
  -- Save originals
  local original_list_wins = vim.api.nvim_list_wins
  local original_win_get_buf = vim.api.nvim_win_get_buf
  local original_buf_get_name = vim.api.nvim_buf_get_name
  local original_bo = vim.bo
  local original_set_current_win = vim.api.nvim_set_current_win
  local original_win_close = vim.api.nvim_win_close
  local original_notify = vim.notify

  -- Mock window/buffer setup
  local function setup_mock_windows(windows_data)
    -- windows_data = { {win=1, buf=1, name="file.lua", ft="lua"}, ... }
    vim.api.nvim_list_wins = function()
      local wins = {}
      for _, data in ipairs(windows_data) do
        table.insert(wins, data.win)
      end
      return wins
    end

    vim.api.nvim_win_get_buf = function(win)
      for _, data in ipairs(windows_data) do
        if data.win == win then
          return data.buf
        end
      end
      return nil
    end

    vim.api.nvim_buf_get_name = function(buf)
      for _, data in ipairs(windows_data) do
        if data.buf == buf then
          return data.name or ""
        end
      end
      return ""
    end

    -- Mock vim.bo for filetype access
    vim.bo = setmetatable({}, {
      __index = function(_, buf)
        return setmetatable({}, {
          __index = function(_, opt)
            if opt == "filetype" then
              for _, data in ipairs(windows_data) do
                if data.buf == buf then
                  return data.ft or ""
                end
              end
            end
            return ""
          end,
        })
      end,
    })
  end

  -- Restore after each test
  after_each(function()
    vim.api.nvim_list_wins = original_list_wins
    vim.api.nvim_win_get_buf = original_win_get_buf
    vim.api.nvim_buf_get_name = original_buf_get_name
    vim.bo = original_bo
    vim.api.nvim_set_current_win = original_set_current_win
    vim.api.nvim_win_close = original_win_close
    vim.notify = original_notify
  end)

  describe("find_window()", function()
    it("finds window matching function", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file.lua", ft = "lua" },
        { win = 2, buf = 2, name = "test.txt", ft = "text" },
        { win = 3, buf = 3, name = "README.md", ft = "markdown" },
      })

      local win, buf = window_utils.find_window(function(w, b, name, ft)
        return ft == "text"
      end)

      assert.equals(2, win)
      assert.equals(2, buf)
    end)

    it("returns nil when no window matches", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file.lua", ft = "lua" },
      })

      local win, buf = window_utils.find_window(function(w, b, name, ft)
        return ft == "nonexistent"
      end)

      assert.is_nil(win)
      assert.is_nil(buf)
    end)

    it("returns first matching window", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file1.lua", ft = "lua" },
        { win = 2, buf = 2, name = "file2.lua", ft = "lua" },
      })

      local win, buf = window_utils.find_window(function(w, b, name, ft)
        return ft == "lua"
      end)

      assert.equals(1, win) -- First match
      assert.equals(1, buf)
    end)

    it("passes all parameters to match function", function()
      setup_mock_windows({
        { win = 10, buf = 20, name = "/path/file.txt", ft = "text" },
      })

      local received = {}
      window_utils.find_window(function(w, b, name, ft)
        received = { win = w, buf = b, name = name, ft = ft }
        return false
      end)

      assert.equals(10, received.win)
      assert.equals(20, received.buf)
      assert.equals("/path/file.txt", received.name)
      assert.equals("text", received.ft)
    end)

    it("validates match_fn is a function", function()
      local notified = false
      vim.notify = function()
        notified = true
      end

      local win, buf = window_utils.find_window("not a function")

      assert.is_true(notified)
      assert.is_nil(win)
      assert.is_nil(buf)
    end)

    it("handles empty window list", function()
      setup_mock_windows({})

      local win, buf = window_utils.find_window(function()
        return true
      end)

      assert.is_nil(win)
      assert.is_nil(buf)
    end)
  end)

  describe("find_all_windows()", function()
    it("finds all matching windows", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file1.lua", ft = "lua" },
        { win = 2, buf = 2, name = "test.txt", ft = "text" },
        { win = 3, buf = 3, name = "file2.lua", ft = "lua" },
      })

      local matches = window_utils.find_all_windows(function(w, b, name, ft)
        return ft == "lua"
      end)

      assert.equals(2, #matches)
      assert.equals(1, matches[1].win)
      assert.equals(1, matches[1].buf)
      assert.equals(3, matches[2].win)
      assert.equals(3, matches[2].buf)
    end)

    it("returns empty table when no matches", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file.lua", ft = "lua" },
      })

      local matches = window_utils.find_all_windows(function(w, b, name, ft)
        return ft == "nonexistent"
      end)

      assert.same({}, matches)
    end)

    it("returns all windows when all match", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "a", ft = "text" },
        { win = 2, buf = 2, name = "b", ft = "text" },
        { win = 3, buf = 3, name = "c", ft = "text" },
      })

      local matches = window_utils.find_all_windows(function()
        return true
      end)

      assert.equals(3, #matches)
    end)
  end)

  describe("focus_window()", function()
    it("focuses matching window", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file.lua", ft = "lua" },
        { win = 2, buf = 2, name = "test.txt", ft = "text" },
      })

      local focused_win = nil
      vim.api.nvim_set_current_win = function(win)
        focused_win = win
      end

      local success = window_utils.focus_window(function(w, b, name, ft)
        return ft == "text"
      end)

      assert.is_true(success)
      assert.equals(2, focused_win)
    end)

    it("returns false when window not found", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file.lua", ft = "lua" },
      })

      local success = window_utils.focus_window(function(w, b, name, ft)
        return ft == "nonexistent"
      end)

      assert.is_false(success)
    end)
  end)

  describe("close_windows()", function()
    it("closes matching windows", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file.lua", ft = "lua" },
        { win = 2, buf = 2, name = "test.txt", ft = "text" },
        { win = 3, buf = 3, name = "other.lua", ft = "lua" },
      })

      local closed_wins = {}
      vim.api.nvim_win_close = function(win, force)
        table.insert(closed_wins, { win = win, force = force })
      end

      local count = window_utils.close_windows(function(w, b, name, ft)
        return ft == "lua"
      end)

      assert.equals(2, count)
      assert.equals(2, #closed_wins)
      assert.equals(1, closed_wins[1].win)
      assert.equals(3, closed_wins[2].win)
    end)

    it("passes force parameter", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file.lua", ft = "lua" },
      })

      local force_used = nil
      vim.api.nvim_win_close = function(win, force)
        force_used = force
      end

      window_utils.close_windows(function()
        return true
      end, true)

      assert.is_true(force_used)
    end)

    it("defaults force to false", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file.lua", ft = "lua" },
      })

      local force_used = nil
      vim.api.nvim_win_close = function(win, force)
        force_used = force
      end

      window_utils.close_windows(function()
        return true
      end)

      assert.is_false(force_used)
    end)

    it("handles close errors gracefully", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "a", ft = "lua" },
        { win = 2, buf = 2, name = "b", ft = "lua" },
      })

      vim.api.nvim_win_close = function(win, force)
        if win == 1 then
          error("Cannot close")
        end
      end

      local count = window_utils.close_windows(function()
        return true
      end)

      assert.equals(1, count) -- Only win 2 closed successfully
    end)

    it("returns 0 when no windows match", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file.lua", ft = "lua" },
      })

      local count = window_utils.close_windows(function()
        return false
      end)

      assert.equals(0, count)
    end)
  end)

  describe("find_snacks_explorer()", function()
    it("finds window by snacks_ filetype prefix", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "normal.lua", ft = "lua" },
        { win = 2, buf = 2, name = "explorer", ft = "snacks_explorer" },
      })

      local win, buf = window_utils.find_snacks_explorer()
      assert.equals(2, win)
      assert.equals(2, buf)
    end)

    it("finds window by snacks filetype", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file", ft = "snacks" },
      })

      local win, buf = window_utils.find_snacks_explorer()
      assert.equals(1, win)
    end)

    it("finds window by snacks in buffer name", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "/snacks/explorer", ft = "other" },
      })

      local win, buf = window_utils.find_snacks_explorer()
      assert.equals(1, win)
    end)
  end)

  describe("find_opencode()", function()
    it("finds OpenCode window by name", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file.lua", ft = "lua" },
        { win = 2, buf = 2, name = "Opencode", ft = "other" },
      })

      local win, buf = window_utils.find_opencode()
      assert.equals(2, win)
    end)

    it("is case insensitive for name", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "opencode", ft = "other" },
      })

      local win = window_utils.find_opencode()
      assert.equals(1, win)
    end)

    it("finds by filetype", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "other", ft = "opencode" },
      })

      local win = window_utils.find_opencode()
      assert.equals(1, win)
    end)
  end)

  describe("find_trouble()", function()
    it("finds Trouble window by name", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "Trouble", ft = "other" },
      })

      local win = window_utils.find_trouble()
      assert.equals(1, win)
    end)

    it("finds by filetype", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "other", ft = "trouble" },
      })

      local win = window_utils.find_trouble()
      assert.equals(1, win)
    end)
  end)

  describe("find_by_name()", function()
    it("finds window by name pattern", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "/path/file.txt", ft = "text" },
        { win = 2, buf = 2, name = "/path/test.lua", ft = "lua" },
      })

      local win, buf = window_utils.find_by_name("%.lua")
      assert.equals(2, win)
      assert.equals(2, buf)
    end)

    it("validates pattern is a string", function()
      local notified = false
      vim.notify = function()
        notified = true
      end

      local win, buf = window_utils.find_by_name(123)

      assert.is_true(notified)
      assert.is_nil(win)
      assert.is_nil(buf)
    end)

    it("validates pattern is not empty", function()
      local notified = false
      vim.notify = function()
        notified = true
      end

      local win, buf = window_utils.find_by_name("")

      assert.is_true(notified)
      assert.is_nil(win)
    end)

    it("uses Lua pattern matching", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "test123.lua", ft = "lua" },
      })

      local win = window_utils.find_by_name("test%d+")
      assert.equals(1, win)
    end)
  end)

  describe("find_by_filetype()", function()
    it("finds window by exact filetype", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file.lua", ft = "lua" },
        { win = 2, buf = 2, name = "file.txt", ft = "text" },
      })

      local win, buf = window_utils.find_by_filetype("text")
      assert.equals(2, win)
      assert.equals(2, buf)
    end)

    it("validates filetype is a string", function()
      local notified = false
      vim.notify = function()
        notified = true
      end

      local win, buf = window_utils.find_by_filetype(nil)

      assert.is_true(notified)
      assert.is_nil(win)
      assert.is_nil(buf)
    end)

    it("validates filetype is not empty", function()
      local notified = false
      vim.notify = function()
        notified = true
      end

      local win, buf = window_utils.find_by_filetype("")

      assert.is_true(notified)
      assert.is_nil(win)
    end)

    it("matches exactly (no pattern matching)", function()
      setup_mock_windows({
        { win = 1, buf = 1, name = "file", ft = "markdown" },
      })

      -- "mark" shouldn't match "markdown" (exact match only)
      local win = window_utils.find_by_filetype("mark")
      assert.is_nil(win)

      -- Exact match should work
      local win2 = window_utils.find_by_filetype("markdown")
      assert.equals(1, win2)
    end)
  end)
end)
