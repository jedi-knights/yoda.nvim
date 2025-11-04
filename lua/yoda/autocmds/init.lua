local M = {}

local autocmd_logger = require("yoda.autocmd_logger")
local autocmd_perf = require("yoda.autocmd_performance")

function M.setup_all()
  local autocmd = vim.api.nvim_create_autocmd
  local augroup = vim.api.nvim_create_augroup

  require("yoda.autocmds.buffer").setup_all(autocmd, augroup)
  require("yoda.autocmds.alpha").setup_all(autocmd, augroup)
  require("yoda.autocmds.window").setup_all(autocmd, augroup)
  require("yoda.autocmds.git").setup_all(autocmd, augroup)

  local ok = pcall(require, "yoda.opencode_integration")
  if ok then
    require("yoda.autocmds.opencode").setup_all(autocmd, augroup)
  else
    require("yoda.autocmds.opencode").setup_fallback(autocmd, augroup)
  end
end

function M.setup_commands()
  require("yoda.autocmds.buffer").setup_commands()

  vim.api.nvim_create_user_command("YodaAutocmdLogEnable", function()
    autocmd_logger.enable()
  end, { desc = "Enable detailed autocmd logging for debugging" })

  vim.api.nvim_create_user_command("YodaAutocmdLogDisable", function()
    autocmd_logger.disable()
  end, { desc = "Disable autocmd logging" })

  vim.api.nvim_create_user_command("YodaAutocmdLogToggle", function()
    autocmd_logger.toggle()
  end, { desc = "Toggle autocmd logging" })

  vim.api.nvim_create_user_command("YodaAutocmdLogView", function()
    autocmd_logger.view_log()
  end, { desc = "View autocmd log file" })

  vim.api.nvim_create_user_command("YodaAutocmdLogClear", function()
    autocmd_logger.clear_log()
  end, { desc = "Clear autocmd log file" })

  autocmd_perf.setup_commands()
end

return M
