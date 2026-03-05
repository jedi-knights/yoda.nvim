-- lua/yoda/git_refresh.lua
-- Centralized git refresh coordination (single source of truth)

local M = {}

local gitsigns = require("yoda.integrations.gitsigns")

-- Recursion guard for FileChangedShell events
local file_changed_in_progress = false

-- ============================================================================
-- Public API
-- ============================================================================

--- Setup all git refresh autocmds in one place
--- This is the ONLY place that should register git refresh autocmds
--- @param autocmd function vim.api.nvim_create_autocmd
--- @param augroup function vim.api.nvim_create_augroup
function M.setup_autocmds(autocmd, augroup)
  local git_refresh_group = augroup("YodaGitRefresh", { clear = true })

  -- Refresh after saving files
  autocmd("BufWritePost", {
    group = git_refresh_group,
    desc = "Refresh git signs after buffer is written",
    callback = function()
      if vim.bo.buftype == "" then
        gitsigns.refresh_batched()
      end
    end,
  })

  -- Refresh when external file changes detected
  autocmd("FileChangedShell", {
    group = git_refresh_group,
    desc = "Refresh git signs when files changed externally",
    callback = function(args)
      -- Prevent recursive FileChangedShell events
      if file_changed_in_progress then
        return
      end

      file_changed_in_progress = true

      vim.schedule(function()
        if args.buf and vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].buftype == "" then
          gitsigns.refresh_batched()
        end
        file_changed_in_progress = false
      end)
    end,
  })

  -- Refresh when Neovim gains focus and check for external file changes
  autocmd("FocusGained", {
    group = git_refresh_group,
    desc = "Check for external changes and refresh git signs when Neovim gains focus",
    callback = function()
      if vim.bo.buftype == "" and vim.bo.filetype ~= "opencode" then
        pcall(vim.cmd, "checktime")
        vim.schedule(function()
          gitsigns.refresh_batched()
        end)
      end
    end,
  })
end

return M
