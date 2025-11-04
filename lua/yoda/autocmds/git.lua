local M = {}

local notify = require("yoda.adapters.notification")

function M.setup_all(autocmd, augroup)
  autocmd("FileType", {
    group = augroup("YodaGitCommitPerformance", { clear = true }),
    desc = "Disable expensive autocmds for git commit buffers to prevent typing lag",
    pattern = { "gitcommit", "NeogitCommitMessage" },
    callback = function()
      vim.cmd("autocmd! TextChanged,TextChangedI,TextChangedP <buffer>")
      vim.cmd("autocmd! CursorMoved,CursorMovedI <buffer>")
      vim.cmd("autocmd! InsertEnter,InsertLeave <buffer>")
      vim.cmd("autocmd! BufWritePost <buffer>")
      vim.cmd("autocmd! CompleteChanged,CompleteDone <buffer>")

      notify.notify("🔥 Disabled expensive autocmds for git commit buffer", "debug")
    end,
  })
end

return M
