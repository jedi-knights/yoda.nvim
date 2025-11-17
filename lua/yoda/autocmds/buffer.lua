local M = {}

local autocmd_logger = require("yoda.autocmd_logger")
local autocmd_perf = require("yoda.autocmd_performance")
local notify = require("yoda-adapters.notification")
local alpha_manager = require("yoda.ui.alpha_manager")
local gitsigns = require("yoda.integrations.gitsigns")
local buffer_state = require("yoda.buffer.state_checker")

local DELAYS = {
  ALPHA_CLOSE = 50,
  BUF_ENTER_DEBOUNCE = 150,
}

function M.setup_all(autocmd, augroup)
  autocmd("BufEnter", {
    group = augroup("YodaConsolidatedBufEnter", { clear = true }),
    desc = "Consolidated buffer enter handler for alpha, refresh, and git signs",
    callback = function(args)
      local perf_start_time = vim.loop.hrtime()
      local start_time = autocmd_logger.log_start("BufEnter", { buf = args.buf })
      local buf = args.buf

      local bufname = vim.api.nvim_buf_get_name(buf)
      if bufname:match("snacks_") or bufname:match("^%[.-%]$") then
        autocmd_logger.log("BufEnter_SKIP", { buf = buf, reason = "snacks_buffer" })
        autocmd_logger.log_end("BufEnter", start_time, { action = "skipped_snacks" })
        return
      end

      local buftype = vim.bo[buf].buftype
      local filetype = vim.bo[buf].filetype
      local buflisted = vim.bo[buf].buflisted

      if buftype ~= "" and buftype ~= "help" then
        autocmd_logger.log("BufEnter_SKIP", { buf = buf, reason = "special_buftype", buftype = buftype })
        autocmd_logger.log_end("BufEnter", start_time, { action = "skipped_special" })
        return
      end

      local is_real_buffer = buftype == "" and filetype ~= "" and filetype ~= "alpha" and bufname ~= ""

      if is_real_buffer then
        autocmd_logger.log("BufEnter_REAL_BUFFER", { buf = buf, filetype = filetype })

        alpha_manager.handle_alpha_close_for_real_buffer(buf, DELAYS.ALPHA_CLOSE, autocmd_logger)

        local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
        if ok then
          opencode_integration.handle_debounced_buffer_refresh(buf, autocmd_logger)
        else
          gitsigns.refresh_debounced()
        end

        autocmd_logger.log_end("BufEnter", start_time, { action = "refresh_scheduled" })
        autocmd_perf.track_autocmd("BufEnter", perf_start_time)
        return
      end

      alpha_manager.handle_alpha_dashboard_display({
        buf = buf,
        buftype = buftype,
        filetype = filetype,
        buflisted = buflisted,
        start_time = start_time,
        perf_start_time = perf_start_time,
        logger = autocmd_logger,
        perf_tracker = autocmd_perf,
        is_buffer_empty_fn = buffer_state.is_buffer_empty,
        delay = DELAYS.BUF_ENTER_DEBOUNCE,
      })
    end,
  })

  autocmd({ "BufDelete", "BufWipeout" }, {
    group = augroup("YodaBufferCacheInvalidation", { clear = true }),
    desc = "Invalidate buffer caches when buffers are removed",
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
end

function M.setup_commands()
  vim.api.nvim_create_user_command("Bd", function(opts)
    local buf = vim.api.nvim_get_current_buf()
    local autocmd_logger = require("yoda.autocmd_logger")
    local window_protection = require("yoda-window.protection")

    autocmd_logger.log("Bd_Start", { buf = buf, bang = opts.bang })

    if vim.bo[buf].buftype ~= "" then
      autocmd_logger.log("Bd_Special", { buf = buf, buftype = vim.bo[buf].buftype })
      vim.cmd("bdelete" .. (opts.bang and "!" or ""))
      return
    end

    local windows_with_buf = vim.fn.win_findbuf(buf)
    autocmd_logger.log("Bd_Windows", { buf = buf, window_count = #windows_with_buf })

    local normal_buffers = {}
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(b) and b ~= buf and vim.bo[b].buflisted and vim.bo[b].buftype == "" then
        table.insert(normal_buffers, b)
      end
    end

    autocmd_logger.log("Bd_Alternates", { buf = buf, alternate_count = #normal_buffers })

    if #normal_buffers > 0 then
      local alt = vim.fn.bufnr("#")
      local target_buf

      if alt ~= -1 and alt ~= buf and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buftype == "" then
        target_buf = alt
        autocmd_logger.log("Bd_UseAlternate", { buf = buf, target = alt })
      else
        target_buf = normal_buffers[1]
        autocmd_logger.log("Bd_UseFirst", { buf = buf, target = normal_buffers[1] })
      end

      for _, win in ipairs(windows_with_buf) do
        if vim.api.nvim_win_is_valid(win) then
          -- Check if buffer switch is allowed to this window
          if window_protection.is_buffer_switch_allowed(win, target_buf) then
            local ok = pcall(vim.api.nvim_win_set_buf, win, target_buf)
            autocmd_logger.log("Bd_SwitchWindow", { win = win, target = target_buf, success = ok })
          else
            autocmd_logger.log("Bd_SkipProtectedWindow", { win = win, target = target_buf })
            -- Protected window - let it handle the buffer deletion naturally
          end
        end
      end
    else
      autocmd_logger.log("Bd_NoAlternates", { buf = buf })
    end

    local delete_cmd = "bdelete" .. (opts.bang and "!" or "") .. " " .. buf
    autocmd_logger.log("Bd_Delete", { buf = buf, cmd = delete_cmd })

    local ok, err = pcall(vim.cmd, delete_cmd)
    if not ok then
      autocmd_logger.log("Bd_DeleteFailed", { buf = buf, error = tostring(err) })
      notify.notify("Buffer delete failed: " .. tostring(err), "error")
    else
      autocmd_logger.log("Bd_DeleteSuccess", { buf = buf })
    end
  end, { bang = true, desc = "Smart buffer delete that preserves window layout" })

  vim.api.nvim_create_user_command("BD", function(opts)
    vim.cmd("Bd" .. (opts.bang and "!" or ""))
  end, { bang = true, desc = "Alias for Bd" })

  vim.cmd([[
    cnoreabbrev <expr> bd getcmdtype() == ':' && getcmdline() == 'bd' ? 'Bd' : 'bd'
    cnoreabbrev <expr> bdelete getcmdtype() == ':' && getcmdline() == 'bdelete' ? 'Bd' : 'bdelete'
  ]])
end

return M
