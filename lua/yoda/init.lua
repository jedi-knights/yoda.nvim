-- Load core settings
require("yoda.options")
require("yoda.keymaps")
require("yoda.autocmds")

-- Load plugins
require("yoda.plugins.lazy") -- bootstrap lazy.nvim

-- Load colorscheme
require("yoda.colorscheme")

-- Load Plenary test keymaps
require("yoda.plenary")

vim.api.nvim_create_user_command("YodaKeymapDump", function()
  require("yoda.devtools.keymaps").dump_all_keymaps()
end, {})

vim.api.nvim_create_user_command("YodaKeymapConflicts", function()
  require("yoda.devtools.keymaps").find_conflicts()
end, {})

vim.api.nvim_create_user_command("YodaLoggedKeymaps", function()
  require("yoda.utils.keymap_logger").dump()
end, {})

