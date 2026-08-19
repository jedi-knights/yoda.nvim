-- plugin/yoda.lua
-- Bootstrap commands so require("yoda").setup(opts) users get a discoverable
-- command surface without eagerly loading the whole plugin. This file is
-- auto-sourced from the runtimepath at startup (the standard lazy.nvim
-- "plugin/" convention) -- keep it minimal, registration only. See
-- lua/yoda/init.lua for actual setup logic.

if vim.g.loaded_yoda then
  return
end
vim.g.loaded_yoda = true

vim.api.nvim_create_user_command("Yoda", function()
  if require("yoda.config").get() then
    vim.notify(
      "[yoda] setup() has run -- see :help yoda for docs",
      vim.log.levels.INFO
    )
  else
    vim.notify(
      "[yoda] setup() has not run yet -- call require('yoda').setup(opts) "
        .. "from your lazy.nvim spec",
      vim.log.levels.WARN
    )
  end
end, { desc = "Show yoda.nvim setup status" })

vim.api.nvim_create_user_command("YodaExtras", function()
  local resolved = require("yoda.config").get()
  local extras = (resolved and resolved.extras) or {}
  if #extras == 0 then
    vim.notify("[yoda] no extras declared in opts.extras", vim.log.levels.INFO)
  else
    vim.notify(
      "[yoda] extras: " .. table.concat(extras, ", "),
      vim.log.levels.INFO
    )
  end
end, { desc = "List yoda.nvim extras declared in opts.extras" })

vim.api.nvim_create_user_command("YodaHealth", function()
  vim.cmd("checkhealth yoda")
end, { desc = "Run :checkhealth yoda" })
