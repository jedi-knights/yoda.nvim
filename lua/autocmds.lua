local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local large_file = require("yoda.large_file")
local filetype_detection = require("yoda.filetype.detection")
local performance_autocmds = require("yoda.performance.autocmds")
local alpha_manager = require("yoda.ui.alpha_manager")
local buffer_state = require("yoda.buffer.state_checker")
local buffer_cache = require("yoda.buffer.type_cache")
local gitsigns = require("yoda.integrations.gitsigns")
local filetype_settings = require("yoda.filetype.settings")
local notify = require("yoda-adapters.notification")
local timer_manager = require("yoda.timer_manager")

local RESIZE_DEBOUNCE_DELAY = 300
local ALPHA_STARTUP_DELAY = 200
local GIT_COMMIT_TIMEOUT = 50
local BUFENTER_DEBOUNCE_DELAY = 100

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
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  -- Use cached buffer properties for performance
  local buftype = buffer_cache.get_buftype(buf)
  local filetype = buffer_cache.get_filetype(buf)
  local bufname = buffer_cache.get_bufname(buf)

  if buftype ~= "" and buftype ~= "help" then
    return false
  end

  if filetype == "opencode" or filetype == "alpha" or filetype == "" then
    return false
  end

  if bufname == "" or buffer_cache.is_snacks_buffer(buf) or buffer_cache.get_bufname(buf):match("^%[.-%]$") then
    return false
  end

  return buffer_cache.is_real_file_buffer(buf)
end

autocmd("BufEnter", {
  group = augroup("YodaAlphaClose", { clear = true }),
  desc = "Close alpha dashboard when opening real files (debounced to reduce overhead on rapid buffer switches)",
  callback = function(args)
    -- Early exit: skip if no alpha buffers exist
    if not alpha_manager.has_alpha_buffer() then
      return
    end

    local buf = args.buf or vim.api.nvim_get_current_buf()

    -- Debounce to reduce overhead during rapid buffer switching
    local timer_id = "bufenter_alpha_check"
    if timer_manager.is_vim_timer_active(timer_id) then
      timer_manager.stop_vim_timer(timer_id)
    end

    timer_manager.create_vim_timer(function()
      -- Recheck alpha exists before expensive should_close check
      if not alpha_manager.has_alpha_buffer() then
        return
      end

      if vim.api.nvim_buf_is_valid(buf) and should_close_alpha_for_buffer(buf) then
        alpha_manager.close_all_alpha_buffers()
      end
    end, BUFENTER_DEBOUNCE_DELAY, timer_id)
  end,
})

autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = augroup("YodaCheckExternalChanges", { clear = true }),
  desc = "Check for external file changes",
  callback = function()
    vim.schedule(function()
      if vim.bo.buftype == "" and vim.bo.filetype ~= "opencode" then
        pcall(vim.cmd, "checktime")
      end
    end)
  end,
})

autocmd({ "BufDelete", "BufWipeout" }, {
  group = augroup("YodaBufferCache", { clear = true }),
  desc = "Invalidate alpha cache when normal buffers are deleted (only on delete, not create)",
  callback = function(args)
    local buf = args.buf
    if vim.api.nvim_buf_is_valid(buf) then
      local buftype = vim.bo[buf].buftype
      local filetype = vim.bo[buf].filetype
      if (buftype == "" and filetype ~= "" and filetype ~= "alpha") or filetype == "alpha" then
        alpha_manager.invalidate_cache()
      end
    end
  end,
})

autocmd("VimEnter", {
  group = augroup("YodaStartup", { clear = true }),
  desc = "Show alpha dashboard on startup if no files (double-check prevents race conditions)",
  callback = function()
    if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
    end

    if alpha_manager.should_show_alpha(buffer_state.is_buffer_empty) then
      vim.defer_fn(function()
        if alpha_manager.should_show_alpha(buffer_state.is_buffer_empty) then
          alpha_manager.show_alpha_dashboard()
        end
      end, ALPHA_STARTUP_DELAY)
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
  desc = "Resize splits equally and recenter alpha dashboard (debounced to prevent rapid-fire resizing)",
  callback = function()
    local timer_id = "vim_resized"
    if timer_manager.is_vim_timer_active(timer_id) then
      timer_manager.stop_vim_timer(timer_id)
    end

    timer_manager.create_vim_timer(function()
      vim.schedule(function()
        local current_tab = vim.api.nvim_get_current_tabpage()

        for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
          if vim.api.nvim_tabpage_is_valid(tabpage) then
            local wins = vim.api.nvim_tabpage_list_wins(tabpage)

            -- Skip if tab contains OpenCode window (it manages its own size)
            local has_opencode = false
            for _, win in ipairs(wins) do
              if vim.api.nvim_win_is_valid(win) then
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "opencode" then
                  has_opencode = true
                  break
                end
              end
            end

            if not has_opencode and #wins > 0 and vim.api.nvim_win_is_valid(wins[1]) then
              local ok = pcall(vim.api.nvim_win_call, wins[1], function()
                vim.cmd("wincmd =")
              end)

              if not ok and tabpage == current_tab then
                pcall(vim.cmd, "wincmd =")
              end
            end
          end
        end

        alpha_manager.recenter_alpha_dashboard()
      end)
    end, RESIZE_DEBOUNCE_DELAY, timer_id)
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
  desc = "Disable expensive autocmds for git commit buffers (performance optimization)",
  pattern = { "gitcommit", "NeogitCommitMessage" },
  callback = function(args)
    local bufnr = args.buf

    vim.api.nvim_clear_autocmds({
      group = git_commit_augroup,
      buffer = bufnr,
      event = {
        "TextChanged",
        "TextChangedI",
        "TextChangedP",
        "CursorMoved",
        "CursorMovedI",
        "InsertEnter",
        "InsertLeave",
        "BufWritePost",
        "CompleteChanged",
        "CompleteDone",
      },
    })

    vim.opt_local.timeoutlen = GIT_COMMIT_TIMEOUT
  end,
})

autocmd("LspAttach", {
  group = augroup("YodaGitCommitNoLSP", { clear = true }),
  desc = "Prevent LSP from attaching to git commit buffers (faster commit editing)",
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

autocmd({ "BufEnter", "FocusGained", "WinEnter" }, {
  group = augroup("YodaNumberToggle", { clear = true }),
  desc = "Switch to relative line numbers when buffer is focused",
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = true
    end
  end,
})

autocmd({ "BufLeave", "FocusLost", "WinLeave" }, {
  group = augroup("YodaNumberToggle", { clear = false }),
  desc = "Switch to absolute line numbers when buffer loses focus",
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
    end
  end,
})

-- Setup OpenCode integration autocmds only if OpenCode is installed
-- This defers loading the heavy notification and gitsigns adapters until needed
local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
if ok and opencode_integration.is_available() then
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

-- Setup buffer type caching
buffer_cache.setup_autocmds()
buffer_cache.setup_commands()
