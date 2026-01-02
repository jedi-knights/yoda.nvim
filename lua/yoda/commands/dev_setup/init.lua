-- lua/yoda/commands/dev_setup/init.lua
-- Development environment setup commands loader

local M = {}

function M.setup()
  require("yoda.commands.dev_setup.rust").setup()
  require("yoda.commands.dev_setup.python").setup()
  require("yoda.commands.dev_setup.javascript").setup()
  require("yoda.commands.dev_setup.csharp").setup()
end

return M
