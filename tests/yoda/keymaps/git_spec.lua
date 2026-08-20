-- tests/yoda/keymaps/git_spec.lua
local helpers = require("tests.helpers")

describe("keymaps.git", function()
  before_each(function()
    package.loaded["yoda.keymaps.git"] = nil
    require("yoda.keymaps.git")
  end)

  after_each(function()
    package.loaded.neogit = nil
  end)

  it("<leader>gg opens Neogit", function()
    -- Arrange
    local open_spy, open_data = helpers.spy()
    package.loaded.neogit = { open = open_spy }
    local callback
    for _, km in ipairs(vim.api.nvim_get_keymap("n")) do
      if km.desc == "Git: Open Neogit" then
        callback = km.callback
      end
    end

    -- Act
    callback()

    -- Assert
    helpers.assert_called(open_data, 1)
  end)
end)
