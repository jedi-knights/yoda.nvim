-- Load core settings
require("yoda.core.options")

-- Removed telescope integration (using Snacks picker instead)

require("yoda.commands").setup()
require("yoda.core.keymaps")
require("yoda.core.functions")
require("yoda.core.autocmds")

-- Load plugins first
require("yoda.plugins.lazy") -- bootstrap lazy.nvim

-- Wait for plugins to load, then set colorscheme
vim.defer_fn(function()
  require("yoda.core.colorscheme")
end, 100)

-- Note: Plenary test harness removed, using Snacks test harness instead

vim.api.nvim_create_user_command("YodaKeymapDump", function()
  require("yoda.devtools.keymaps").dump_all_keymaps()
end, {})

vim.api.nvim_create_user_command("YodaKeymapConflicts", function()
  require("yoda.devtools.keymaps").find_conflicts()
end, {})

vim.api.nvim_create_user_command("YodaLoggedKeymaps", function()
  require("yoda.utils.keymap_logger").dump()
end, {})

