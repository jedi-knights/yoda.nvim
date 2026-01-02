-- lua/yoda/commands/opencode.lua
-- OpenCode integration commands

local M = {}

function M.setup()
  vim.api.nvim_create_user_command("OpenCodeReturn", function()
    -- Exit insert mode if needed
    if vim.fn.mode() == "i" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    end

    -- Get list of all buffers
    local buffers = vim.api.nvim_list_bufs()
    local current_buf = vim.api.nvim_get_current_buf()
    local target_buf = nil

    -- Find first non-special buffer (skip terminal, quickfix, help, etc.)
    for _, buf in ipairs(buffers) do
      if buf ~= current_buf and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
        local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
        local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

        -- Skip special buffer types
        if buftype == "" and filetype ~= "qf" and filetype ~= "help" and filetype ~= "man" and filetype ~= "fugitive" then
          target_buf = buf
          break
        end
      end
    end

    -- If we found a valid buffer, switch to it
    if target_buf then
      vim.api.nvim_set_current_buf(target_buf)
    else
      -- No valid buffer found, create a new empty buffer
      vim.cmd("enew")
    end
  end, { desc = "Return to main buffer from OpenCode" })
end

return M
