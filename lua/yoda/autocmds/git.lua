local M = {}

local notify = require("yoda-adapters.notification")

function M.setup_all(autocmd, augroup)
  autocmd("FileType", {
    group = augroup("YodaGitCommitPerformance", { clear = true }),
    desc = "Optimize git commit buffers to prevent typing lag",
    pattern = { "gitcommit", "NeogitCommitMessage" },
    callback = function(args)
      local bufnr = args.buf

      -- Use buffer-local augroups that auto-cleanup when buffer is deleted
      -- This is safer than vim.cmd("autocmd!") which can affect other buffers
      local buf_group = augroup("YodaGitCommitBuffer_" .. bufnr, { clear = true })

      -- Instead of disabling autocmds globally, we simply don't create heavy ones
      -- for git commit buffers. Most autocmds check filetype anyway.

      -- Set performance options
      vim.opt_local.timeoutlen = 50
      vim.opt_local.updatetime = 1000

      -- Disable some heavy features for commit buffers
      vim.b[bufnr].yoda_disable_lsp_diagnostics = true
      vim.b[bufnr].yoda_commit_buffer = true

      notify.notify("🔥 Optimized git commit buffer for fast typing", "debug")
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

  autocmd("FileType", {
    group = augroup("YodaGitCommitInsertMode", { clear = true }),
    desc = "Auto-enter insert mode for git commit messages",
    pattern = { "gitcommit", "NeogitCommitMessage" },
    callback = function()
      vim.schedule(function()
        vim.cmd("startinsert")
      end)
    end,
  })

  autocmd("FileType", {
    group = augroup("YodaNeogitStatusInsertMode", { clear = true }),
    desc = "Auto-enter insert mode for Neogit status buffer",
    pattern = "NeogitStatus",
    callback = function()
      vim.schedule(function()
        vim.cmd("startinsert")
      end)
    end,
  })
end

return M
