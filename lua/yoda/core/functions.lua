-- lua/yoda/core/functions.lua
-- Utility functions for Neovim configuration

local M = {}

-- Toggle relative line numbers
function M.toggle_relative_line_numbers()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
  vim.notify("Relative line numbers: " .. (vim.opt.relativenumber:get() and "ON" or "OFF"), vim.log.levels.INFO)
end

-- Toggle spell checking
function M.toggle_spell()
  vim.opt.spell = not vim.opt.spell:get()
  vim.notify("Spell checking: " .. (vim.opt.spell:get() and "ON" or "OFF"), vim.log.levels.INFO)
end

-- Toggle cursor line
function M.toggle_cursor_line()
  vim.opt.cursorline = not vim.opt.cursorline:get()
  vim.notify("Cursor line: " .. (vim.opt.cursorline:get() and "ON" or "OFF"), vim.log.levels.INFO)
end

-- Toggle color column
function M.toggle_color_column()
  if vim.opt.colorcolumn:get() == "" then
    vim.opt.colorcolumn = "80"
    vim.notify("Color column: ON (80)", vim.log.levels.INFO)
  else
    vim.opt.colorcolumn = ""
    vim.notify("Color column: OFF", vim.log.levels.INFO)
  end
end

-- Toggle list (show whitespace)
function M.toggle_list()
  vim.opt.list = not vim.opt.list:get()
  vim.notify("Show whitespace: " .. (vim.opt.list:get() and "ON" or "OFF"), vim.log.levels.INFO)
end

-- Get current file info
function M.get_file_info()
  local file = vim.fn.expand("%:p")
  local size = vim.fn.getfsize(file)
  local lines = vim.api.nvim_buf_line_count(0)
  local encoding = vim.bo.fileencoding
  local filetype = vim.bo.filetype
  
  local info = string.format(
    "File: %s\nSize: %s bytes\nLines: %d\nEncoding: %s\nType: %s",
    file, size, lines, encoding, filetype
  )
  
  vim.notify(info, vim.log.levels.INFO, { title = "File Info" })
end

-- Toggle terminal
function M.toggle_terminal()
  local term_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      term_buf = buf
      break
    end
  end
  
  if term_buf then
    -- Find terminal window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == term_buf then
        vim.api.nvim_win_close(win, true)
        return
      end
    end
  else
    -- Create new terminal
    vim.cmd("terminal")
  end
end

-- Clear search highlights
function M.clear_search_highlights()
  vim.cmd("nohlsearch")
  vim.notify("Search highlights cleared", vim.log.levels.INFO)
end

-- Toggle diagnostics
function M.toggle_diagnostics()
  local current = vim.diagnostic.is_disabled(0)
  vim.diagnostic.enable(0, not current)
  vim.notify("Diagnostics: " .. (current and "ENABLED" or "DISABLED"), vim.log.levels.INFO)
end

-- Format current buffer
function M.format_buffer()
  local client = vim.lsp.get_active_clients({ bufnr = 0 })[1]
  if client and client.supports_method("textDocument/formatting") then
    vim.lsp.buf.format({ async = false })
    vim.notify("Buffer formatted", vim.log.levels.INFO)
  else
    vim.notify("No LSP client with formatting support", vim.log.levels.WARN)
  end
end

-- Copy current file path
function M.copy_file_path()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("File path copied to clipboard: " .. path, vim.log.levels.INFO)
end

-- Copy current file name
function M.copy_file_name()
  local name = vim.fn.expand("%:t")
  vim.fn.setreg("+", name)
  vim.notify("File name copied to clipboard: " .. name, vim.log.levels.INFO)
end

-- Toggle word wrap
function M.toggle_wrap()
  vim.opt.wrap = not vim.opt.wrap:get()
  vim.notify("Word wrap: " .. (vim.opt.wrap:get() and "ON" or "OFF"), vim.log.levels.INFO)
end

return M


