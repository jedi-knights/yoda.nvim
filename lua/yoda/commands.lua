-- lua/yoda/commands.lua
-- Command registration - loads all command modules

-- Load command modules
require("yoda.commands.lazy").setup()
require("yoda.commands.dev_setup").setup()
require("yoda.commands.diagnostics").setup()
require("yoda.commands.formatting").setup()
require("yoda.commands.opencode").setup()
require("yoda.commands.lsp").setup()
