-- lua/yoda/core/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Helper to create autocommands with named groups
local function create_autocmd(events, opts)
  autocmd(events, opts)
end

-- Add auto commands to refresh neo-tree after git operations
local neotree_utils = require("yoda.utils.neo-tree")
for _, event in ipairs({ "NeogitCommitComplete", "NeogitPushComplete", "NeogitPullComplete" }) do
  create_autocmd("User", {
    pattern = event,
    callback = neotree_utils.refresh_neotree,
    desc = "Refresh Neo-tree after " .. event,
  })
end

-- Terminal: Hide line numbers
create_autocmd("TermOpen", {
  group = augroup("YodaTerminal", { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})

-- Change to directory if opened with directory argument
create_autocmd("VimEnter", {
  group = augroup("YodaStartup", { clear = true }),
  callback = function()
    if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
    end
  end,
})

-- Close empty buffer after Alpha loads
create_autocmd("User", {
  group = augroup("YodaAlpha", { clear = true }),
  pattern = "AlphaReady",
  callback = function()
    vim.schedule(function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.api.nvim_buf_is_valid(bufnr)
        and vim.api.nvim_buf_get_name(bufnr) == ""
        and vim.bo[bufnr].buftype == "" then
        vim.cmd("bwipeout " .. bufnr)
      end
    end)
  end,
})

-- Highlight on yank
create_autocmd("TextYankPost", {
  group = augroup("YodaHighlightYank", { clear = true }),
  desc = "Highlight on yank",
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Auto reload changed files
create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = augroup("YodaAutoRead", { clear = true }),
  desc = "Reload file changed outside",
  command = "checktime",
})

-- Restore last known cursor position
create_autocmd("BufReadPost", {
  group = augroup("YodaRestoreCursor", { clear = true }),
  desc = "Restore cursor position",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto resize splits
create_autocmd("VimResized", {
  group = augroup("YodaResizeSplits", { clear = true }),
  desc = "Auto resize splits",
  command = "tabdo wincmd =",
})

-- Markdown settings
create_autocmd("FileType", {
  group = augroup("YodaMarkdown", { clear = true }),
  pattern = "markdown",
  desc = "Enable wrap, spell, conceal for markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
  end,
})
