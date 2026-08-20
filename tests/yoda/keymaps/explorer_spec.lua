-- tests/yoda/keymaps/explorer_spec.lua
local helpers = require("tests.helpers")

describe("keymaps.explorer", function()
  local notify_spy_fn, notify_spy_data

  local function get_callback()
    for _, km in ipairs(vim.api.nvim_get_keymap("n")) do
      if km.desc == "Explorer: Toggle" then
        return km.callback
      end
    end
    error("keymap not registered")
  end

  before_each(function()
    package.loaded["yoda.keymaps.explorer"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }
    require("yoda.keymaps.explorer")
  end)

  after_each(function()
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded["yoda-window.utils"] = nil
    package.loaded.snacks = nil
  end)

  it("notifies when yoda-window.utils is unavailable", function()
    -- Arrange: minimal_init.lua preloads a (partial) yoda-window.utils
    -- stub, so pcall(require, ...) would otherwise succeed -- force a
    -- genuine require failure to reach this branch.
    local original_preload = package.preload["yoda-window.utils"]
    local original_loaded = package.loaded["yoda-window.utils"]
    package.preload["yoda-window.utils"] = nil
    package.loaded["yoda-window.utils"] = nil

    -- Act
    get_callback()()

    package.preload["yoda-window.utils"] = original_preload
    package.loaded["yoda-window.utils"] = original_loaded

    -- Assert
    helpers.assert_called_with(
      notify_spy_data,
      "yoda-window.utils not available",
      "error"
    )
  end)

  it(
    "closes existing explorer/picker windows instead of opening a new one",
    function()
      -- Arrange: capture and invoke the predicates find_all_windows/
      -- close_windows receive, the same way the real yoda-window.utils
      -- implementation would, so their bodies are actually exercised
      -- rather than just passed around unused.
      local find_predicate, close_predicate
      local close_spy, close_data = helpers.spy()
      package.loaded["yoda-window.utils"] = {
        find_all_windows = function(predicate)
          find_predicate = predicate
          return { 1000 }
        end,
        close_windows = function(predicate, force)
          close_predicate = predicate
          return close_spy(predicate, force)
        end,
      }
      package.loaded.snacks = {
        explorer = {
          open = function()
            error("should not be called")
          end,
        },
      }

      -- Act
      get_callback()()

      -- Assert
      helpers.assert_called(close_data, 1)
      assert.equals(true, close_data.last_call[2])

      -- Assert: both predicates recognize every explorer/picker filetype
      -- and reject an unrelated one, matching find_all_windows' own
      -- decision of whether to short-circuit.
      for _, predicate in ipairs({ find_predicate, close_predicate }) do
        for _, ft in ipairs({
          "snacks_picker_list",
          "snacks_picker_input",
          "snacks_layout_box",
          "snacks-explorer",
          "snacks_explorer",
        }) do
          assert.is_true(predicate(0, 0, "", ft), ft)
        end
        assert.is_false(predicate(0, 0, "", "lua"))
      end
    end
  )

  it("opens the explorer when none is currently open", function()
    -- Arrange
    local open_spy, open_data = helpers.spy()
    package.loaded["yoda-window.utils"] = {
      find_all_windows = function()
        return {}
      end,
      close_windows = function()
        error("should not be called")
      end,
    }
    package.loaded.snacks = { explorer = { open = open_spy } }

    -- Act
    get_callback()()

    -- Assert
    helpers.assert_called(open_data, 1)
    helpers.assert_not_called(notify_spy_data)
  end)

  it("notifies when the explorer fails to open", function()
    -- Arrange
    package.loaded["yoda-window.utils"] = {
      find_all_windows = function()
        return {}
      end,
      close_windows = function() end,
    }
    package.loaded.snacks = {} -- no .explorer field -> indexing it raises

    -- Act
    get_callback()()

    -- Assert
    helpers.assert_called_with(
      notify_spy_data,
      "Snacks Explorer could not be opened",
      "error"
    )
  end)
end)
