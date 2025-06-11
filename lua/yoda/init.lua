-- Load core settings
require("yoda.core.options")

pcall(function()
  local telescope = require("telescope")
  telescope.extensions.test_picker = telescope.extensions.test_picker or require("yoda.testpicker")
end)

require("yoda.core.keymaps")
require("yoda.core.functions")
require("yoda.core.autocmds")

-- Load plugins
require("yoda.plugins.lazy") -- bootstrap lazy.nvim

-- Load colorscheme
require("yoda.core.colorscheme")

-- Load Plenary test keymaps
require("yoda.core.plenary")

vim.api.nvim_create_user_command("YodaKeymapDump", function()
  require("yoda.devtools.keymaps").dump_all_keymaps()
end, {})

vim.api.nvim_create_user_command("YodaKeymapConflicts", function()
  require("yoda.devtools.keymaps").find_conflicts()
end, {})

vim.api.nvim_create_user_command("YodaLoggedKeymaps", function()
  require("yoda.utils.keymap_logger").dump()
end, {})

