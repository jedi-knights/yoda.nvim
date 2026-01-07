local M = {}
local _autocmds_loaded = false

function M.setup()
  if _autocmds_loaded then
    return
  end
  _autocmds_loaded = true

  local autocmd = vim.api.nvim_create_autocmd
  local augroup = vim.api.nvim_create_augroup

  local filetype_detection = require("yoda.filetype.detection")
  local performance_autocmds = require("yoda.performance.autocmds")
  local yoda_autocmds = require("yoda.autocmds")

  filetype_detection.setup_all(autocmd, augroup)

  performance_autocmds.setup_all(autocmd, augroup)

  yoda_autocmds.setup_all()

  yoda_autocmds.setup_commands()
end

M.setup()

return M
