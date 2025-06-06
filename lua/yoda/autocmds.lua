-- lua/yoda/core/autocmds.lua

-- Helper function to define autocommands more easily
local autocmd = vim.api.nvim_create_autocmd

vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('yoda-terminal', { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})

-- Polished startup behaivor
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.cmd("cd " .. vim.fn.argv(0))
    end
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "AlphaReady",
  callback = function()
    vim.schedule(function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr) == "" and vim.bo[bufnr].buftype == "" then
        vim.cmd("bwipeout " .. bufnr)
      end
    end)
  end,
})

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

autocmd("FileType", {
  pattern = "markdown",
  desc = "Markdown formatting settings",
  group = vim.api.nvim_create_augroup("YodaMarkdownSettings", { clear = true }),
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
  end,
})
