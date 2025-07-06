-- lua/yoda/core/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Helper to create autocommands with named groups
local function create_autocmd(events, opts)
  autocmd(events, opts)
end

-- Terminal: Hide line numbers (local to buffer)
create_autocmd("TermOpen", {
  group = augroup("YodaTerminal", { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
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

-- Highlight on yank (throttled and limited to reasonable buffer sizes)
create_autocmd("TextYankPost", {
  group = augroup("YodaHighlightYank", { clear = true }),
  desc = "Highlight on yank",
  callback = function()
    if vim.api.nvim_buf_line_count(0) < 1000 then
      vim.highlight.on_yank({ timeout = 50 })
    end
  end,
})

-- Auto reload changed files on focus/buffer enter, with guard
create_autocmd({ "FocusGained", "BufEnter" }, {
  group = augroup("YodaAutoRead", { clear = true }),
  desc = "Reload file changed outside",
  callback = function()
    if vim.bo.modifiable and vim.bo.buftype == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Restore last known cursor position, only for normal buffers
create_autocmd("BufReadPost", {
  group = augroup("YodaRestoreCursor", { clear = true }),
  desc = "Restore cursor position",
  callback = function()
    if vim.bo.buftype ~= "" then return end
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto resize splits on Vim resize
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

-- Git commit settings
create_autocmd("FileType", {
  group = augroup("YodaGitCommit", { clear = true }),
  pattern = { "gitcommit", "gitrebase" },
  desc = "Git commit settings",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
  end,
})

-- JSON settings
create_autocmd("FileType", {
  group = augroup("YodaJSON", { clear = true }),
  pattern = "json",
  desc = "JSON settings",
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- YAML settings
create_autocmd("FileType", {
  group = augroup("YodaYAML", { clear = true }),
  pattern = "yaml",
  desc = "YAML settings",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Auto-format on save for specific file types
create_autocmd("BufWritePre", {
  group = augroup("YodaAutoFormat", { clear = true }),
  pattern = { "*.lua", "*.py", "*.js", "*.ts", "*.json", "*.yaml", "*.yml" },
  desc = "Auto-format on save",
  callback = function()
    -- Only process modifiable buffers
    if not vim.bo.modifiable or vim.bo.buftype ~= "" then
      return
    end
    local client = vim.lsp.get_active_clients({ bufnr = 0 })[1]
    if client and client.supports_method("textDocument/formatting") then
      vim.lsp.buf.format({ async = false })
    end
  end,
})

-- Remove trailing whitespace on save
create_autocmd("BufWritePre", {
  group = augroup("YodaTrimWhitespace", { clear = true }),
  pattern = "*",
  desc = "Remove trailing whitespace",
  callback = function()
    -- Only process modifiable buffers
    if not vim.bo.modifiable or vim.bo.buftype ~= "" then
      return
    end
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Auto-close quickfix and location list when leaving
create_autocmd("WinLeave", {
  group = augroup("YodaAutoClose", { clear = true }),
  pattern = "*",
  desc = "Auto-close quickfix/location list",
  callback = function()
    if vim.bo.filetype == "qf" then
      vim.cmd("close")
    end
  end,
})
