-- lua/yoda/buffer/state_checker.lua
-- Buffer state checking utilities

local M = {}

-- ============================================================================
-- Buffer Name Checks
-- ============================================================================

--- Check if a buffer name indicates it's empty or unnamed
--- @param bufname string Buffer name to check
--- @return boolean
function M.is_empty_buffer_name(bufname)
  if type(bufname) ~= "string" then
    return true
  end
  return bufname == "" or bufname == "[No Name]"
end

--- Check if a buffer name indicates it's a scratch buffer
--- @param bufname string Buffer name to check
--- @return boolean
function M.is_scratch_buffer(bufname)
  if type(bufname) ~= "string" then
    return false
  end
  return bufname == "[Scratch]"
end

-- ============================================================================
-- Buffer State Checks
-- ============================================================================

--- Check if a buffer is empty or unnamed (but not a scratch buffer)
--- @param bufnr number|nil Buffer number (default: current buffer)
--- @return boolean
function M.is_buffer_empty(bufnr)
  bufnr = bufnr or 0

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end

  local bufname = vim.api.nvim_buf_get_name(bufnr)

  -- Don't consider scratch buffers as "empty" for alpha purposes
  if M.is_scratch_buffer(bufname) then
    return false
  end

  return M.is_empty_buffer_name(bufname)
end

--- Check if buffer can be reloaded safely
--- @param bufnr number|nil Buffer number (default: current buffer)
--- @return boolean
function M.can_reload_buffer(bufnr)
  bufnr = bufnr or 0

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local bo = vim.bo[bufnr]
  return bo.modifiable and bo.buftype == "" and not bo.readonly
end

--- Check if buffer is a special buffer type (not a regular file)
--- @param bufnr number|nil Buffer number (default: current buffer)
--- @return boolean
function M.is_special_buffer(bufnr)
  bufnr = bufnr or 0

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  return vim.bo[bufnr].buftype ~= ""
end

--- Check if buffer is a real file buffer
--- @param bufnr number|nil Buffer number (default: current buffer)
--- @return boolean
function M.is_real_file_buffer(bufnr)
  bufnr = bufnr or 0

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local bo = vim.bo[bufnr]
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  return bo.buftype == "" and bo.filetype ~= "" and bo.filetype ~= "alpha" and bufname ~= ""
end

--- Check if buffer is modified
--- @param bufnr number|nil Buffer number (default: current buffer)
--- @return boolean
function M.is_modified(bufnr)
  bufnr = bufnr or 0

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  return vim.bo[bufnr].modified
end

--- Check if buffer is listed
--- @param bufnr number|nil Buffer number (default: current buffer)
--- @return boolean
function M.is_listed(bufnr)
  bufnr = bufnr or 0

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  return vim.bo[bufnr].buflisted
end

return M
