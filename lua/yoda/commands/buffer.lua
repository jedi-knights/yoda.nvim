-- lua/yoda/commands/buffer.lua
-- Buffer management commands
--
-- Provides :Bd / :BD — smart buffer delete that preserves window layout.
-- Regular :bdelete closes the window when the buffer is the last one visible;
-- :Bd instead switches each window showing the buffer to an alternate buffer
-- first, so the window layout survives. Falls back to :bdelete for
-- non-normal buffer types (e.g. terminals, quickfix) where the simple
-- behaviour is fine.

local M = {}

function M.setup()
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
      require("yoda-adapters.notification").notify("Buffer delete failed: " .. tostring(err), "error")
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
