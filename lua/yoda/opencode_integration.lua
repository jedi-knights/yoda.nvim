-- lua/yoda/opencode_integration.lua
-- OpenCode integration utilities for enhanced buffer management

local M = {}

local gitsigns = require("yoda.integrations.gitsigns")
local notify = require("yoda-adapters.notification")

-- Safe require with error handling
local buffer_state_ok, buffer_state = pcall(require, "yoda.buffer.state_checker")
if not buffer_state_ok then
  vim.notify("Failed to load buffer.state_checker: " .. tostring(buffer_state), vim.log.levels.ERROR)
  buffer_state = nil
end

-- Debounce state for buffer operations
local buf_debounce = {}
local BUF_DEBOUNCE_DELAY = 150 -- milliseconds

--- Check if a file should be excluded from auto-refresh
--- @param filepath string Full file path
--- @return boolean should_skip Whether to skip refreshing this file
local function should_skip_refresh(filepath)
  local filename = vim.fn.fnamemodify(filepath, ":t")
  local git_files = {
    "COMMIT_EDITMSG",
    "MERGE_MSG",
    "SQUASH_MSG",
    "TAG_EDITMSG",
    "git-rebase-todo",
    "addp-hunk-edit.diff",
  }

  for _, git_file in ipairs(git_files) do
    if filename == git_file then
      return true
    end
  end

  return false
end

--- Handle OpenCode exit
--- This function is called when OpenCode window is closed
function M.on_opencode_exit()
  -- Auto-save all modified buffers
  M.save_all_buffers()
end

--- Check if OpenCode is available
--- @return boolean
function M.is_available()
  local ok = pcall(require, "opencode")
  return ok
end

--- Check if buffer should be saved (complexity: 3)
--- @param buf number Buffer handle
--- @return boolean should_save Whether buffer should be saved
--- @return string|nil buf_name Buffer name if should save
local function should_save_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  if not vim.bo[buf].modified or vim.bo[buf].buftype ~= "" then
    return false
  end

  local buf_name = vim.api.nvim_buf_get_name(buf)
  if buf_name == "" then
    return false
  end

  -- Skip large files if configured
  local ok, large_file = pcall(require, "yoda.large_file")
  if ok and large_file.should_skip_autosave(buf) then
    return false
  end

  return true, buf_name
end

--- Check if error is keyboard interrupt (complexity: 2)
--- @param err any Error object
--- @return boolean is_interrupt Whether error is keyboard interrupt
local function is_keyboard_interrupt(err)
  return err and type(err) == "string" and err:match("Keyboard interrupt") ~= nil
end

--- Extract error message from error object (complexity: 1)
--- @param err any Error object
--- @return string error_message Short error message
local function extract_error_message(err)
  return err and tostring(err):match("^[^\n]+") or "unknown error"
end

--- Save single buffer (complexity: 2)
--- @param buffer_info table Buffer info {buf, name}
--- @return string result "success", "cancelled", or "error"
local function save_single_buffer(buffer_info)
  local ok, err = pcall(function()
    vim.api.nvim_buf_call(buffer_info.buf, function()
      vim.cmd("silent write")
    end)
  end)

  if ok then
    return "success"
  end

  if is_keyboard_interrupt(err) then
    notify.notify("Auto-save cancelled by user", "info")
    return "cancelled"
  end

  local short_err = extract_error_message(err)
  notify.notify("Failed to auto-save " .. vim.fn.fnamemodify(buffer_info.name, ":t") .. ": " .. short_err, "warn")
  return "error"
end

--- Save all modified buffers with progress notification (complexity: 3)
--- @return boolean success Whether all buffers were saved
function M.save_all_buffers()
  local saved_count = 0
  local error_count = 0

  -- Collect modified buffers first
  local buffers_to_save = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local should_save, buf_name = should_save_buffer(buf)
    if should_save then
      table.insert(buffers_to_save, { buf = buf, name = buf_name })
    end
  end

  -- Save each buffer
  for _, buffer_info in ipairs(buffers_to_save) do
    local result = save_single_buffer(buffer_info)

    if result == "success" then
      saved_count = saved_count + 1
    elseif result == "cancelled" then
      return false
    else
      error_count = error_count + 1
    end
  end

  -- Provide user feedback
  if saved_count > 0 then
    notify.notify("🤖 OpenCode: Auto-saved " .. saved_count .. " file(s)", "info")
  end

  return error_count == 0
end

--- Refresh a specific buffer from disk
--- @param buf number Buffer number
-- Prevent recursive refresh calls
local refresh_in_progress = {}

--- @return boolean success Whether the buffer was refreshed
function M.refresh_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  -- Prevent recursive calls
  if refresh_in_progress[buf] then
    return false
  end

  local buf_name = vim.api.nvim_buf_get_name(buf)
  if buf_name == "" or vim.fn.filereadable(buf_name) == 0 then
    return false
  end

  -- Don't refresh modified buffers to avoid data loss
  if vim.bo[buf].modified then
    return false
  end

  -- Check if buffer is suitable for reloading
  if not vim.bo[buf].modifiable or vim.bo[buf].buftype ~= "" or vim.bo[buf].readonly then
    return false
  end

  -- Skip special git files that shouldn't be auto-refreshed
  if should_skip_refresh(buf_name) then
    return false
  end

  refresh_in_progress[buf] = true

  local ok, err = pcall(function()
    vim.api.nvim_buf_call(buf, function()
      -- Reload buffer without triggering most autocmds to prevent BufEnter loop
      vim.cmd("silent noautocmd edit!")

      -- Manually re-initialize TreeSitter highlighting without triggering all FileType autocmds
      vim.schedule(function()
        local ok_ts, ts_highlight = pcall(require, "nvim-treesitter.highlight")
        if ok_ts and ts_highlight then
          -- Re-attach TreeSitter highlighting
          pcall(ts_highlight.attach, buf)
        end
      end)
    end)
  end)

  refresh_in_progress[buf] = nil

  if not ok then
    notify.notify("Failed to refresh " .. vim.fn.fnamemodify(buf_name, ":t") .. ": " .. err, "warn")
    return false
  end

  return true
end

--- Check if buffer should be refreshed (Complexity: 3)
--- @param buf number Buffer handle
--- @return boolean should_refresh Whether buffer should be refreshed
local function should_refresh_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
    return false
  end

  local buf_name = vim.api.nvim_buf_get_name(buf)
  if buf_name == "" or vim.fn.filereadable(buf_name) ~= 1 then
    return false
  end

  if should_skip_refresh(buf_name) then
    return false
  end

  return true
end

--- Refresh single buffer with checktime (Complexity: 1)
--- @param buf number Buffer handle
--- @return boolean success Whether refresh succeeded
local function refresh_buffer_checktime(buf)
  local ok = pcall(function()
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent noautocmd checktime")
    end)
  end)
  return ok
end

--- Refresh all buffers that might have been changed externally (Complexity: 2)
--- @return number count Number of buffers processed
function M.refresh_all_buffers()
  local processed_count = 0
  local refreshed_count = 0

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if should_refresh_buffer(buf) then
      processed_count = processed_count + 1

      if refresh_buffer_checktime(buf) then
        refreshed_count = refreshed_count + 1
      end
    end
  end

  return processed_count
end

-- Debounce state for git signs refresh
--- Refresh git signs if gitsigns is available (debounced to prevent flickering)
function M.refresh_git_signs()
  gitsigns.refresh_debounced()
end

--- Refresh file explorer if Snacks explorer is available
function M.refresh_explorer()
  local snacks = package.loaded.snacks
  if snacks and snacks.explorer then
    vim.schedule(function()
      pcall(snacks.explorer.refresh)
    end)
  end
end

--- Complete refresh cycle after OpenCode edits files
function M.complete_refresh()
  vim.schedule(function()
    -- Force global checktime without triggering autocmds
    pcall(vim.cmd, "silent noautocmd checktime")

    -- Refresh current buffer
    local current_buf = vim.api.nvim_get_current_buf()
    M.refresh_buffer(current_buf)

    -- Refresh all buffers
    M.refresh_all_buffers()

    -- Refresh integrations
    M.refresh_git_signs()
    M.refresh_explorer()

    -- Force redraw to ensure UI is updated
    vim.cmd("redraw!")
  end)
end

--- Setup OpenCode integration hooks and commands
function M.setup()
  if not M.is_available() then
    return
  end

  -- Create user commands with auto-save functionality
  local opencode_commands = {
    { "OpencodeToggle", "Toggle OpenCode panel" },
    { "OpencodePrompt", "Send prompt to OpenCode" },
    { "OpencodeAsk", "Ask OpenCode a question" },
    { "OpencodeSelect", "Send selection to OpenCode" },
  }

  for _, cmd_info in ipairs(opencode_commands) do
    local cmd = cmd_info[1]
    local desc = cmd_info[2]

    vim.api.nvim_create_user_command(cmd .. "WithSave", function(opts)
      -- Auto-save before OpenCode operations
      M.save_all_buffers()

      -- Execute the original command
      vim.cmd(cmd .. " " .. (opts.args or ""))
    end, {
      nargs = "*",
      desc = desc .. " (with auto-save)",
    })
  end

  -- Set up autocmd for OpenCode start event
  vim.api.nvim_create_autocmd("User", {
    pattern = "OpencodeStart",
    desc = "Auto-save buffers when OpenCode starts",
    callback = function()
      M.save_all_buffers()
    end,
  })
end

--- Handle debounced buffer refresh operations
--- @param buf number Buffer number
--- @param logger table Optional logger instance
function M.handle_debounced_buffer_refresh(buf, logger)
  -- Cancel any pending debounce for this buffer
  if buf_debounce[buf] then
    pcall(vim.fn.timer_stop, buf_debounce[buf])
    buf_debounce[buf] = nil
  end

  -- Schedule debounced operation
  buf_debounce[buf] = vim.fn.timer_start(BUF_DEBOUNCE_DELAY, function()
    if not vim.api.nvim_buf_is_valid(buf) then
      if logger then
        logger.log("Refresh_Skip", { buf = buf, reason = "invalid_buffer" })
      end
      buf_debounce[buf] = nil
      return
    end

    if logger then
      logger.log("Refresh_Start", { buf = buf })
    end
    buf_debounce[buf] = nil

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      -- Refresh buffer if it's reloadable
      if buffer_state and buffer_state.can_reload_buffer() and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
        if logger then
          logger.log("Refresh_Buffer", { buf = buf })
        end
        M.refresh_buffer(buf)
      end

      -- Refresh git signs
      if logger then
        logger.log("Refresh_GitSigns", { buf = buf })
      end
      M.refresh_git_signs()
    end)
  end)
end

--- Setup OpenCode integration autocmds
--- @param autocmd function vim.api.nvim_create_autocmd
--- @param augroup function vim.api.nvim_create_augroup
--- @param gitsigns table GitSigns module
--- @param buffer_state table Buffer state checker module
function M.setup_autocmds(autocmd, augroup, gitsigns, buffer_state)
  -- OpenCode exit handler
  autocmd("User", {
    group = augroup("YodaOpenCodeIntegration", { clear = true }),
    pattern = "OpencodeExit",
    desc = "Handle OpenCode exit",
    callback = function()
      M.on_opencode_exit()
    end,
  })

  -- Auto-save on OpenCode start
  autocmd("User", {
    group = augroup("YodaOpenCodeAutoSave", { clear = true }),
    pattern = "OpencodeStart",
    desc = "Auto-save all buffers when OpenCode starts",
    callback = function()
      vim.schedule(function()
        pcall(M.save_all_buffers)
      end)
    end,
  })

  -- Focus gained - refresh buffers
  autocmd("FocusGained", {
    group = augroup("YodaOpenCodeFocusRefresh", { clear = true }),
    desc = "Refresh buffers and git signs when focus is gained",
    callback = function()
      vim.schedule(function()
        pcall(vim.cmd, "checktime")
        if buffer_state and buffer_state.can_reload_buffer() and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
          M.refresh_buffer(vim.api.nvim_get_current_buf())
        end
        M.refresh_git_signs()
      end)
    end,
  })

  -- Buffer written - refresh git signs
  autocmd("BufWritePost", {
    group = augroup("YodaGitSignsWriteRefresh", { clear = true }),
    desc = "Refresh git signs after buffer is written",
    callback = function()
      M.refresh_git_signs()
    end,
  })

  -- File changed externally
  autocmd("FileChangedShell", {
    group = augroup("YodaOpenCodeFileChange", { clear = true }),
    desc = "Handle files changed by external tools",
    callback = function(args)
      vim.schedule(function()
        if args.buf and vim.api.nvim_buf_is_valid(args.buf) then
          M.refresh_buffer(args.buf)
        end
        M.complete_refresh()
      end)
    end,
  })

  -- Post-process file changes
  autocmd("FileChangedShellPost", {
    group = augroup("YodaOpenCodeFileChangePost", { clear = true }),
    desc = "Post-process file changes from external tools",
    callback = function()
      vim.schedule(function()
        vim.cmd("redraw!")
        M.refresh_git_signs()
      end)
    end,
  })
end

return M
