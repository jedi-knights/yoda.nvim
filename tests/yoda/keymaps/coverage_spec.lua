-- tests/yoda/keymaps/coverage_spec.lua
local helpers = require("tests.helpers")

describe("keymaps.coverage", function()
  before_each(function()
    package.loaded["yoda.keymaps.coverage"] = nil
    require("yoda.keymaps.coverage")
  end)

  after_each(function()
    package.loaded.coverage = nil
  end)

  local function get_callback(desc)
    for _, km in ipairs(vim.api.nvim_get_keymap("n")) do
      if km.desc == desc then
        return km.callback
      end
    end
    error("no keymap registered with desc: " .. desc)
  end

  it("<leader>cv loads and shows the coverage report", function()
    -- Arrange
    local load_spy, load_data = helpers.spy()
    local show_spy, show_data = helpers.spy()
    package.loaded.coverage = { load = load_spy, show = show_spy }

    -- Act
    get_callback("Coverage: Show")()

    -- Assert
    helpers.assert_called(load_data, 1)
    helpers.assert_called(show_data, 1)
  end)

  it("<leader>cx hides the coverage report", function()
    -- Arrange
    local hide_spy, hide_data = helpers.spy()
    package.loaded.coverage = { hide = hide_spy }

    -- Act
    get_callback("Coverage: Hide")()

    -- Assert
    helpers.assert_called(hide_data, 1)
  end)
end)
