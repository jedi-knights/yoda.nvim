-- lua/yoda/opencode_integration.lua
-- OpenCode integration utilities for enhanced buffer management

local M = {}

local gitsigns = require("yoda.integrations.gitsigns")
local notify = require("yoda.adapters.notification")

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

--- Save all modified buffers with progress notification
--- @return boolean success Whether all buffers were saved
function M.save_all_buffers()
  local saved_count = 0
  local error_count = 0
  local buffers_to_save = {}

  -- Collect modified buffers first
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified and vim.bo[buf].buftype == "" then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name ~= "" then
        -- Skip large files if configured
        local ok, large_file = pcall(require, "yoda.large_file")
        if ok and large_file.should_skip_autosave(buf) then
          -- Don't auto-save large files
        else
          table.insert(buffers_to_save, { buf = buf, name = buf_name })
        end
      end
    end
  end

  -- Save each buffer
  for _, buffer_info in ipairs(buffers_to_save) do
    local ok, err = pcall(function()
      vim.api.nvim_buf_call(buffer_info.buf, function()
        vim.cmd("silent write")
      end)
    end)

    if ok then
      saved_count = saved_count + 1
    else
      error_count = error_count + 1
      -- Check if error is from keyboard interrupt (Ctrl-C)
      if err and type(err) == "string" and err:match("Keyboard interrupt") then
        -- User cancelled with Ctrl-C, stop processing
        notify.notify("Auto-save cancelled by user", "info")
        return false
      else
        -- Extract just the error message, not the full stack trace
        local short_err = err and tostring(err):match("^[^\n]+") or "unknown error"
        notify.notify("Failed to auto-save " .. vim.fn.fnamemodify(buffer_info.name, ":t") .. ": " .. short_err, "warn")
      end
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
      vim.cmd("silent edit!")
    end)
  end)

  refresh_in_progress[buf] = nil

  if not ok then
    notify.notify("Failed to refresh " .. vim.fn.fnamemodify(buf_name, ":t") .. ": " .. err, "warn")
    return false
  end

  return true
end

--- Refresh all buffers that might have been changed externally
--- @return number count Number of buffers processed
function M.refresh_all_buffers()
  local processed_count = 0
  local refreshed_count = 0

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name ~= "" and vim.fn.filereadable(buf_name) == 1 then
        -- Skip special git files that shouldn't be auto-refreshed
        if not should_skip_refresh(buf_name) then
          processed_count = processed_count + 1

          -- Use checktime to detect changes
          local ok = pcall(function()
            vim.api.nvim_buf_call(buf, function()
              vim.cmd("silent checktime")
            end)
          end)

          if ok then
            refreshed_count = refreshed_count + 1
          end
        end
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
    -- Force global checktime
    pcall(vim.cmd, "silent checktime")

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

return M
