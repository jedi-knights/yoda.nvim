-- tests/yoda/keymaps/devtools_spec.lua
local helpers = require("tests.helpers")

describe("keymaps.devtools", function()
  local notify_spy_fn, notify_spy_data
  local original_log

  local function get_callback(desc)
    for _, km in ipairs(vim.api.nvim_get_keymap("n")) do
      if km.desc == desc then
        return km.callback
      end
    end
    error("no keymap registered with desc: " .. desc)
  end

  before_each(function()
    package.loaded["yoda.keymaps.devtools"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }
    original_log = _G.yoda_keymap_log
    _G.yoda_keymap_log = nil
    require("yoda.keymaps.devtools")
  end)

  after_each(function()
    package.loaded["yoda-adapters.notification"] = nil
    _G.yoda_keymap_log = original_log
  end)

  local function delete_current_buf()
    local buf = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "nofile" then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  it("initializes _G.yoda_keymap_log when absent", function()
    -- Assert
    assert.same({}, _G.yoda_keymap_log)
  end)

  describe("<leader>kd (dump keymaps)", function()
    it(
      "dumps every logged keymap sorted by lhs, then mode, into a scratch buffer",
      function()
        -- Arrange
        _G.yoda_keymap_log = {
          { mode = "n", lhs = "<leader>b", rhs = "action_b", source = "b.lua" },
          {
            mode = "n",
            lhs = "<leader>a",
            rhs = "action_a",
            desc = "First",
            source = "a.lua",
          },
        }

        -- Act
        get_callback("DevTools: Dump Keymaps")()

        -- Assert
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        assert.equals(2, #lines)
        assert.matches("<leader>a", lines[1])
        assert.matches("<leader>b", lines[2])
        assert.equals("nofile", vim.bo.buftype)
        assert.equals("keymap-dump", vim.bo.filetype)

        delete_current_buf()
      end
    )

    it("dumps an empty buffer when nothing has been logged", function()
      -- Act
      get_callback("DevTools: Dump Keymaps")()

      -- Assert
      assert.same({ "" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))

      delete_current_buf()
    end)
  end)

  describe("<leader>kc (find keymap conflicts)", function()
    it("notifies success when there are no conflicts", function()
      -- Arrange
      _G.yoda_keymap_log = {
        { mode = "n", lhs = "<leader>a" },
        { mode = "n", lhs = "<leader>b" },
      }

      -- Act
      get_callback("DevTools: Find Keymap Conflicts")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "✅ No keymap conflicts detected!",
        "info"
      )
    end)

    it("dumps every conflicting mode:lhs pair into a scratch buffer", function()
      -- Arrange
      _G.yoda_keymap_log = {
        { mode = "n", lhs = "<leader>a" },
        { mode = "n", lhs = "<leader>a" },
        { mode = "n", lhs = "<leader>b" },
      }

      -- Act
      get_callback("DevTools: Find Keymap Conflicts")()

      -- Assert
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.equals(1, #lines)
      assert.matches("<leader>a", lines[1])
      assert.equals("keymap-conflicts", vim.bo.filetype)
      helpers.assert_not_called(notify_spy_data)

      delete_current_buf()
    end)
  end)
end)
