local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local large_file = require("yoda.large_file")
local filetype_detection = require("yoda.filetype.detection")
local performance_autocmds = require("yoda.performance.autocmds")
local alpha_manager = require("yoda.ui.alpha_manager")
local buffer_state = require("yoda.buffer.state_checker")
local gitsigns = require("yoda.integrations.gitsigns")
local filetype_settings = require("yoda.filetype.settings")
local notify = require("yoda-adapters.notification")

filetype_detection.setup_all(autocmd, augroup)

autocmd("BufReadPre", {
  group = augroup("YodaLargeFile", { clear = true }),
  desc = "Detect and optimize for large files",
  callback = function(args)
    large_file.on_buf_read(args.buf)
  end,
})

performance_autocmds.setup_all(autocmd, augroup)

local function should_close_alpha_for_buffer(buf)
  local buftype = vim.bo[buf].buftype
  local filetype = vim.bo[buf].filetype
  local bufname = vim.api.nvim_buf_get_name(buf)

  if buftype ~= "" and buftype ~= "help" then
    return false
  end

  if filetype == "opencode" or filetype == "alpha" or filetype == "" then
    return false
  end

  if bufname == "" or bufname:match("snacks_") or bufname:match("^%[.-%]$") then
    return false
  end

  return buffer_state.is_real_file_buffer(buf)
end

autocmd({ "BufEnter", "BufReadPost", "BufNewFile", "WinEnter" }, {
  group = augroup("YodaAlphaClose", { clear = true }),
  desc = "Close alpha dashboard when opening real files",
  callback = function(args)
    local buf = args.buf or vim.api.nvim_get_current_buf()

    if should_close_alpha_for_buffer(buf) then
      vim.schedule(function()
        alpha_manager.close_all_alpha_buffers()
      end)
    end
  end,
})

autocmd({ "BufWritePost", "FileChangedShell" }, {
  group = augroup("YodaGitRefresh", { clear = true }),
  desc = "Refresh git signs on write/external changes",
  callback = function()
    if vim.bo.buftype == "" then
      vim.schedule(function()
        gitsigns.refresh_batched()
      end)
    end
  end,
})

autocmd("FocusGained", {
  group = augroup("YodaFocusGained", { clear = true }),
  desc = "Handle focus gained - check for file changes and refresh git signs",
  callback = function()
    vim.schedule(function()
      if vim.bo.filetype ~= "opencode" then
        pcall(vim.cmd, "checktime")
      end

      if vim.bo.buftype == "" then
        gitsigns.refresh_batched()
      end
    end)
  end,
})

autocmd({ "BufDelete", "BufWipeout", "BufNew", "BufAdd" }, {
  group = augroup("YodaBufferCache", { clear = true }),
  desc = "Invalidate alpha cache when buffers change",
  callback = function(args)
    local buf = args.buf
    if vim.api.nvim_buf_is_valid(buf) then
      local buftype = vim.bo[buf].buftype
      local filetype = vim.bo[buf].filetype
      if buftype == "" or filetype == "alpha" then
        alpha_manager.invalidate_cache()
      end
    end
  end,
})

autocmd("VimEnter", {
  group = augroup("YodaStartup", { clear = true }),
  desc = "Show alpha dashboard on startup if no files",
  callback = function()
    if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
    end

    if alpha_manager.should_show_alpha(buffer_state.is_buffer_empty) then
      vim.defer_fn(function()
        if alpha_manager.should_show_alpha(buffer_state.is_buffer_empty) then
          alpha_manager.show_alpha_dashboard()
        end
      end, 200)
    end
  end,
})

autocmd("BufReadPost", {
  group = augroup("YodaRestoreCursor", { clear = true }),
  desc = "Restore cursor to last position",
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
  desc = "Resize splits equally and recenter alpha dashboard",
  callback = function()
    vim.schedule(function()
      for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
        local current_tab = vim.api.nvim_get_current_tabpage()

        if tabpage ~= current_tab then
          vim.api.nvim_set_current_tabpage(tabpage)
        end

        pcall(vim.cmd, "wincmd =")

        if tabpage ~= current_tab then
          vim.api.nvim_set_current_tabpage(current_tab)
        end
      end

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

local git_commit_augroup = augroup("YodaGitCommitPerformance", { clear = true })

autocmd("FileType", {
  group = git_commit_augroup,
  desc = "Disable expensive autocmds for git commit buffers",
  pattern = { "gitcommit", "NeogitCommitMessage" },
  callback = function(args)
    local bufnr = args.buf

    vim.api.nvim_clear_autocmds({
      group = git_commit_augroup,
      buffer = bufnr,
      event = { "TextChanged", "TextChangedI", "TextChangedP" },
    })

    vim.api.nvim_clear_autocmds({
      group = git_commit_augroup,
      buffer = bufnr,
      event = { "CursorMoved", "CursorMovedI" },
    })

    vim.api.nvim_clear_autocmds({
      group = git_commit_augroup,
      buffer = bufnr,
      event = { "InsertEnter", "InsertLeave" },
    })

    vim.api.nvim_clear_autocmds({
      group = git_commit_augroup,
      buffer = bufnr,
      event = "BufWritePost",
    })

    vim.api.nvim_clear_autocmds({
      group = git_commit_augroup,
      buffer = bufnr,
      event = { "CompleteChanged", "CompleteDone" },
    })

    vim.opt_local.timeoutlen = 50
  end,
})

autocmd("LspAttach", {
  group = augroup("YodaGitCommitNoLSP", { clear = true }),
  desc = "Prevent LSP from attaching to git commit buffers",
  callback = function(args)
    local bufnr = args.buf
    local filetype = vim.bo[bufnr].filetype

    if not vim.tbl_contains({ "gitcommit", "NeogitCommitMessage" }, filetype) then
      return
    end

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.lsp.buf_detach_client(bufnr, client.id)
        end
      end)
    end
  end,
})

local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
if ok then
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

  opencode_integration.setup_autocmds(autocmd, augroup)
end

vim.api.nvim_create_user_command("Bd", function(opts)
  local buf = vim.api.nvim_get_current_buf()
  local window_protection = require("yoda-window.protection")

  if vim.bo[buf].buftype ~= "" then
    vim.cmd("bdelete" .. (opts.bang and "!" or ""))
    return
  end

  local windows_with_buf = vim.fn.win_findbuf(buf)

  local normal_buffers = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and b ~= buf and vim.bo[b].buflisted and vim.bo[b].buftype == "" then
      table.insert(normal_buffers, b)
    end
  end

  if #normal_buffers > 0 then
    local alt = vim.fn.bufnr("#")
    local target_buf

    if alt ~= -1 and alt ~= buf and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buftype == "" then
      target_buf = alt
    else
      target_buf = normal_buffers[1]
    end

    for _, win in ipairs(windows_with_buf) do
      if vim.api.nvim_win_is_valid(win) then
        if window_protection.is_buffer_switch_allowed(win, target_buf) then
          pcall(vim.api.nvim_win_set_buf, win, target_buf)
        end
      end
    end
  end

  local delete_cmd = "bdelete" .. (opts.bang and "!" or "") .. " " .. buf

  local ok_delete, err = pcall(vim.cmd, delete_cmd)
  if not ok_delete then
    notify.notify("Buffer delete failed: " .. tostring(err), "error")
  end
end, { bang = true, desc = "Smart buffer delete that preserves window layout" })

vim.api.nvim_create_user_command("BD", function(opts)
  vim.cmd("Bd" .. (opts.bang and "!" or ""))
end, { bang = true, desc = "Alias for Bd" })

vim.cmd([[
  cnoreabbrev <expr> bd getcmdtype() == ':' && getcmdline() == 'bd' ? 'Bd' : 'bd'
  cnoreabbrev <expr> bdelete getcmdtype() == ':' && getcmdline() == 'bdelete' ? 'Bd' : 'bdelete'
]])
