local M = {}
local _keymaps_loaded = false

function M.setup()
  if _keymaps_loaded then
    return
  end
  _keymaps_loaded = true

  require("yoda.keymaps.help")
  require("yoda.keymaps.explorer")
  require("yoda.keymaps.window")
  require("yoda.keymaps.finding")
  require("yoda.keymaps.lsp")
  require("yoda.keymaps.git")
  require("yoda.keymaps.testing")
  require("yoda.keymaps.debugging")
  require("yoda.keymaps.coverage")
  require("yoda.keymaps.rust")
  require("yoda.keymaps.python")
  require("yoda.keymaps.javascript")
  require("yoda.keymaps.csharp")
  require("yoda.keymaps.go")
  require("yoda.keymaps.ai")
  require("yoda.keymaps.terminal")
  require("yoda.keymaps.utilities")
  require("yoda.keymaps.modes")
  require("yoda.keymaps.devtools")
end

M.setup()

return M
