local helpers = require("tests.helpers")

-- Create basic test for window protection module
describe("window.protection", function()
  local protection

  before_each(function()
    -- Clear require cache to ensure fresh module
    package.loaded["yoda.window.protection"] = nil
    package.loaded["yoda.window_utils"] = nil
    package.loaded["yoda.adapters.notification"] = nil

    -- Mock the dependencies that protection module requires
    local original_require = _G.require
    _G.require = function(module_name)
      if module_name == "yoda.window_utils" then
        return {
          find_snacks_explorer = function()
            return 1
          end,
        }
      elseif module_name == "yoda.adapters.notification" then
        return {
          notify = function() end,
        }
      else
        -- Return the original require for other modules
        return original_require(module_name)
      end
    end

    protection = require("yoda-window.protection")
  end)

  after_each(function()
    package.loaded["yoda.window.protection"] = nil
  end)

  describe("setup_autocmds()", function()
    it("creates window protection autocmds", function()
      local autocmd_calls = {}
      local augroup_calls = {}

      local function mock_autocmd(event, opts)
        table.insert(autocmd_calls, { event = event, opts = opts })
      end

      local function mock_augroup(name, opts)
        table.insert(augroup_calls, { name = name, opts = opts })
        return "test_group"
      end

      protection.setup_autocmds(mock_autocmd, mock_augroup)

      -- Should create BufWinEnter and WinClosed autocmds
      assert.equals(2, #autocmd_calls)
      assert.equals("BufWinEnter", autocmd_calls[1].event)
      assert.equals("WinClosed", autocmd_calls[2].event)

      -- Should create augroups
      assert.equals(2, #augroup_calls)
      assert.equals("YodaWindowProtection", augroup_calls[1].name)
      assert.equals("YodaWindowProtectionCleanup", augroup_calls[2].name)
    end)
  end)

  describe("protect_window()", function()
    it("handles protection attempt gracefully", function()
      -- Mock nvim API
      local original_api = vim.api
      vim.api = {
        nvim_win_is_valid = function()
          return true
        end,
        nvim_win_set_option = function() end,
      }

      -- Should not error
      local ok = pcall(function()
        protection.protect_window(1, "explorer")
      end)
      assert.is_true(ok)

      -- Restore
      vim.api = original_api
    end)
  end)

  describe("unprotect_window()", function()
    it("can be called safely", function()
      -- Should not error
      local ok = pcall(function()
        protection.unprotect_window(1)
      end)
      assert.is_true(ok)
    end)
  end)
end)
