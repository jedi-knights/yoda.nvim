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

-- Change to directory if opened with directory argument and show dashboard
create_autocmd("VimEnter", {
  group = augroup("YodaStartup", { clear = true }),
  callback = function()
    -- Handle directory argument
    if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
    end
    
    -- Show dashboard if no files were opened
    if vim.fn.argc() == 0 then
      vim.schedule(function()
        local ok, snacks = pcall(require, "snacks")
        if ok and snacks.dashboard then
          snacks.dashboard()
        end
      end)
    end
    
    -- Auto update dependencies on startup (DISABLED)
    -- Uncomment the following block to re-enable auto-updates
    --[[
    vim.defer_fn(function()
      local lazy = require("lazy")
      if lazy then
        vim.notify("Checking for plugin updates...", vim.log.levels.INFO, { title = "Yoda.nvim" })
        lazy.sync()
      end
    end, 1000) -- 1 second delay to ensure everything is loaded
    --]]
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

-- Update tool indicators when directory changes
vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    vim.defer_fn(function()
      local tool_indicators = require("yoda.utils.tool_indicators")
      tool_indicators.update_statusline()
    end, 100) -- Small delay to ensure directory change is complete
  end,
})

-- Update tool indicators when entering a buffer
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.defer_fn(function()
      local tool_indicators = require("yoda.utils.tool_indicators")
      tool_indicators.update_statusline()
    end, 100)
  end,
})

-- Snacks Explorer: Force normal mode
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("YodaSnacksExplorer", { clear = true }),
  pattern = { "snacks_explorer", "snacks-explorer" },
  callback = function()
    -- Force normal mode immediately
    vim.cmd("stopinsert")
    -- Schedule another check to override any delayed inserts
    vim.schedule(function()
      if vim.fn.mode() ~= "n" then
        vim.cmd("stopinsert")
      end
    end)
  end,
})
