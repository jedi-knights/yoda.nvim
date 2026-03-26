-- lua/plugins/mini-icons.lua
-- File type icons with a compatibility shim so plugins expecting
-- the devicons API work without modification.

return {
  "echasnovski/mini.icons",
  lazy = false,
  config = function()
    local mini_icons = require("mini.icons")
    mini_icons.setup()
    mini_icons.mock_nvim_web_devicons()
  end,
}
