-- Load core settings
require("yoda.core.options")
require("yoda.core.keymaps")
require("yoda.core.autocmds")

-- Load plugins
require("yoda.plugins.lazy") -- bootstrap lazy.nvim

require("yoda.core.colorscheme")

vim.api.nvim_create_user_command("GenerateKeymapsDoc", function()
  require("yoda.utils.generate_keymaps_doc")()
end, {})

