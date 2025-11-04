local M = {}

local alpha_manager = require("yoda.ui.alpha_manager")
local filetype_settings = require("yoda.filetype.settings")
local layout_manager = require("yoda.window.layout_manager")

function M.setup_all(autocmd, augroup)
  autocmd("BufReadPost", {
    group = augroup("YodaRestoreCursor", { clear = true }),
    desc = "Restore cursor to last known position",
    callback = function()
      if vim.bo.buftype ~= "" then
        return
      end

      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local line_count = vim.api.nvim_buf_line_count(0)

      if mark[1] > 0 and mark[1] <= line_count then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })

  autocmd("VimResized", {
    group = augroup("YodaResizeSplits", { clear = true }),
    desc = "Automatically resize splits on window resize and recenter alpha dashboard",
    callback = function()
      vim.cmd("tabdo wincmd =")

      vim.schedule(function()
        alpha_manager.recenter_alpha_dashboard()
      end)
    end,
  })

  autocmd("FileType", {
    group = augroup("YodaFileTypes", { clear = true }),
    desc = "Apply filetype-specific settings",
    callback = function()
      filetype_settings.apply(vim.bo.filetype)
    end,
  })

  layout_manager.setup_autocmds(autocmd, augroup)
end

return M
