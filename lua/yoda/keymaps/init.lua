local M = {}

function M.setup()
  require("yoda.keymaps.core")
  require("yoda.keymaps.explorer")
  require("yoda.keymaps.git")
  require("yoda.keymaps.lsp")
  require("yoda.keymaps.testing")
  require("yoda.keymaps.debugging")
  require("yoda.keymaps.coverage")
  require("yoda.keymaps.terminal")
  require("yoda.keymaps.ai")

  require("yoda.keymaps.modes.visual")
  require("yoda.keymaps.modes.insert")

  require("yoda.keymaps.languages.rust")
  require("yoda.keymaps.languages.python")
  require("yoda.keymaps.languages.javascript")
  require("yoda.keymaps.languages.csharp")
end

return M
