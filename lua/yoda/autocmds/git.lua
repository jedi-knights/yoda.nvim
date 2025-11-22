local M = {}

local notify = require("yoda-adapters.notification")

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

      vim.opt_local.timeoutlen = 50

      notify.notify("🔥 Disabled expensive autocmds for git commit buffer", "debug")
    end,
  })

  autocmd("LspAttach", {
    group = augroup("YodaGitCommitNoLSP", { clear = true }),
    desc = "Prevent LSP from attaching to git commit buffers",
    pattern = { "gitcommit", "NeogitCommitMessage" },
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        notify.notify(string.format("Detaching %s from commit buffer", client.name), "debug")
        vim.schedule(function()
          vim.lsp.buf_detach_client(bufnr, client.id)
        end)
      end
    end,
  })
end

return M
