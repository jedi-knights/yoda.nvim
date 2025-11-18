local M = {}

local gitsigns = require("yoda.integrations.gitsigns")
local buffer_state = require("yoda.buffer.state_checker")

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

  autocmd("FocusGained", {
    group = augroup("YodaOpenCodeFocusRefresh", { clear = true }),
    desc = "Refresh buffers and git signs when focus is gained",
    callback = function()
      local current_ft = vim.bo.filetype
      if current_ft == "opencode" then
        return
      end

      vim.schedule(function()
        pcall(vim.cmd, "checktime")

        if buffer_state.can_reload_buffer() and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
          local current_buf = vim.api.nvim_get_current_buf()
          opencode_integration.refresh_buffer(current_buf)
        end

        opencode_integration.refresh_git_signs()
      end)
    end,
  })

  autocmd("BufWritePost", {
    group = augroup("YodaGitSignsWriteRefresh", { clear = true }),
    desc = "Refresh git signs after buffer is written",
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
    desc = "Post-process file changes from external tools",
    callback = function()
      vim.schedule(function()
        opencode_integration.refresh_git_signs()
      end)
    end,
  })

  opencode_integration.setup_autocmds(autocmd, augroup)
end

function M.setup_fallback(autocmd, augroup)
  autocmd("FocusGained", {
    group = augroup("YodaOpenCodeFocusRefreshFallback", { clear = true }),
    desc = "Fallback: Refresh buffers and git signs when focus is gained",
    callback = function()
      if buffer_state.can_reload_buffer() then
        pcall(vim.cmd, "checktime")
        gitsigns.refresh_debounced()
      end
    end,
  })

  autocmd("BufWritePost", {
    group = augroup("YodaGitSignsWriteRefreshFallback", { clear = true }),
    desc = "Fallback: Refresh git signs after buffer is written",
    callback = function()
      if vim.bo.buftype == "" then
        gitsigns.refresh_debounced()
      end
    end,
  })

  autocmd("FileChangedShell", {
    group = augroup("YodaOpenCodeFileChangeFallback", { clear = true }),
    desc = "Fallback: Handle files changed by external tools",
    callback = function()
      vim.schedule(function()
        pcall(vim.cmd, "checktime")
        gitsigns.refresh_debounced()
      end)
    end,
  })

  autocmd("FileChangedShellPost", {
    group = augroup("YodaOpenCodeFileChangePostFallback", { clear = true }),
    desc = "Fallback: Post-process file changes",
    callback = function()
      vim.schedule(function()
        gitsigns.refresh_debounced()
      end)
    end,
  })
end

return M
