local M = {}

local gitsigns = require("yoda.integrations.gitsigns")
local buffer_state = require("yoda.buffer.state_checker")
local focus_handler = require("yoda.autocmds.focus")

function M.setup_all(autocmd, augroup)
  local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
  if not ok then
    return
  end

  autocmd("User", {
    group = augroup("YodaOpenCodeAutoSave", { clear = true }),
    pattern = "OpencodeStart",
    desc = "Auto-save all buffers when OpenCode starts",
    callback = function()
      vim.schedule(function()
        pcall(opencode_integration.save_all_buffers)
      end)
    end,
  })

  -- Use consolidated focus handler
  focus_handler.setup_all(autocmd, augroup)

  autocmd("BufWritePost", {
    group = augroup("YodaGitSignsWriteRefresh", { clear = true }),
    desc = "Refresh git signs after buffer is written (batched)",
    callback = function()
      opencode_integration.refresh_git_signs()
    end,
  })

  autocmd("FileChangedShell", {
    group = augroup("YodaOpenCodeFileChange", { clear = true }),
    desc = "Handle files changed by external tools like OpenCode with complete refresh",
    callback = function(args)
      vim.schedule(function()
        if args.buf and vim.api.nvim_buf_is_valid(args.buf) then
          opencode_integration.refresh_buffer(args.buf)
        end

        opencode_integration.complete_refresh()
      end)
    end,
  })

  autocmd("FileChangedShellPost", {
    group = augroup("YodaOpenCodeFileChangePost", { clear = true }),
    desc = "Post-process file changes from external tools (batched)",
    callback = function()
      vim.schedule(function()
        opencode_integration.refresh_git_signs()
      end)
    end,
  })

  opencode_integration.setup_autocmds(autocmd, augroup)
end

function M.setup_fallback(autocmd, augroup)
  -- Use consolidated focus handler
  focus_handler.setup_all(autocmd, augroup)

  autocmd("BufWritePost", {
    group = augroup("YodaGitSignsWriteRefreshFallback", { clear = true }),
    desc = "Fallback: Refresh git signs after buffer is written (batched)",
    callback = function()
      if vim.bo.buftype == "" then
        gitsigns.refresh_batched()
      end
    end,
  })

  autocmd("FileChangedShell", {
    group = augroup("YodaOpenCodeFileChangeFallback", { clear = true }),
    desc = "Fallback: Handle files changed by external tools (batched)",
    callback = function()
      vim.schedule(function()
        pcall(vim.cmd, "checktime")
        gitsigns.refresh_batched()
      end)
    end,
  })

  autocmd("FileChangedShellPost", {
    group = augroup("YodaOpenCodeFileChangePostFallback", { clear = true }),
    desc = "Fallback: Post-process file changes (batched)",
    callback = function()
      vim.schedule(function()
        gitsigns.refresh_batched()
      end)
    end,
  })
end

return M
