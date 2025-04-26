-- lua/yoda/core/autocmds.lua

-- Helper function to define autocommands more easily
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text briefly
autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = vim.api.nvim_create_augroup("YodaHighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Automatically reload file if changed outside of Neovim
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  desc = "Auto reload file if changed externally",
  group = vim.api.nvim_create_augroup("YodaAutoRead", { clear = true }),
  command = "checktime",
})

-- Restore cursor position when reopening a file
autocmd("BufReadPost", {
  desc = "Restore cursor to last known position",
  group = vim.api.nvim_create_augroup("YodaRestoreCursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, "\"")
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Resize splits when the window is resized
autocmd("VimResized", {
  desc = "Auto resize splits",
  group = vim.api.nvim_create_augroup("YodaResizeSplits", { clear = true }),
  command = "tabdo wincmd =",
})

-- Set filetype-specific settings (example for markdown)
autocmd("FileType", {
  pattern = "markdown",
  desc = "Settings for Markdown files",
  group = vim.api.nvim_create_augroup("YodaMarkdownSettings", { clear = true }),
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
