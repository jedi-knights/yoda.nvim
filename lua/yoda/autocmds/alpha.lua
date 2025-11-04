local M = {}

local alpha_manager = require("yoda.ui.alpha_manager")
local buffer_state = require("yoda.buffer.state_checker")

local DELAYS = {
  ALPHA_STARTUP = 200,
  TELESCOPE_CLOSE = 50,
}

local function handle_directory_argument()
  if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
    vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
  end
end

function M.setup_all(autocmd, augroup)
  autocmd("VimEnter", {
    group = augroup("YodaStartup", { clear = true }),
    desc = "Initialize on startup",
    callback = function()
      handle_directory_argument()

      if alpha_manager.should_show_alpha(buffer_state.is_buffer_empty) then
        vim.defer_fn(function()
          if alpha_manager.should_show_alpha(buffer_state.is_buffer_empty) then
            alpha_manager.show_alpha_dashboard()
          end
        end, DELAYS.ALPHA_STARTUP)
      end
    end,
  })

  autocmd({ "BufReadPost", "BufNewFile" }, {
    group = augroup("AlphaCloseOnFile", { clear = true }),
    desc = "Close alpha dashboard when reading/creating files",
    callback = function(args)
      local filetype = vim.bo[args.buf].filetype
      local bufname = vim.api.nvim_buf_get_name(args.buf)

      if filetype == "alpha" or filetype == "" or bufname == "" then
        return
      end

      vim.schedule(function()
        alpha_manager.close_all_alpha_buffers()
      end)
    end,
  })

  autocmd("WinEnter", {
    group = augroup("AlphaCloseOnWinEnter", { clear = true }),
    desc = "Close alpha dashboard when entering non-alpha windows",
    callback = function()
      local current_filetype = vim.bo.filetype

      if current_filetype ~= "alpha" and current_filetype ~= "" and vim.api.nvim_buf_get_name(0) ~= "" then
        vim.schedule(function()
          alpha_manager.close_all_alpha_buffers()
        end)
      end
    end,
  })

  autocmd("BufHidden", {
    group = augroup("AlphaCloseOnPickerExit", { clear = true }),
    desc = "Close alpha when file pickers close",
    callback = function(args)
      local filetype = vim.bo[args.buf].filetype

      if filetype == "TelescopePrompt" or filetype:match("^telescope") then
        vim.defer_fn(function()
          local has_real_files = false
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
              local buf_filetype = vim.bo[buf].filetype
              local buf_name = vim.api.nvim_buf_get_name(buf)
              if buf_filetype ~= "alpha" and buf_filetype ~= "" and buf_name ~= "" and vim.bo[buf].buftype == "" then
                has_real_files = true
                break
              end
            end
          end

          if has_real_files then
            alpha_manager.close_all_alpha_buffers()
          end
        end, DELAYS.TELESCOPE_CLOSE)
      end
    end,
  })
end

return M
