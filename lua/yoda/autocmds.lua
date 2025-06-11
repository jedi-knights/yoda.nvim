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

-- Dynamically resize vim-dadbod-ui width based on editor width
autocmd("FileType", {
  pattern = "dbui",
  desc = "Auto-resize vim-dadbod-ui window width",
  group = vim.api.nvim_create_augroup("YodaDadbodResize", { clear = true }),
  callback = function()
    vim.g.db_ui_winwidth = math.floor(vim.o.columns * 0.4) -- 40% of total width
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "dbui",
  desc = "Close Neo-tree when DBUI opens",
  group = vim.api.nvim_create_augroup("YodaDBUICloseNeoTree", { clear = true }),
  callback = function()
    -- Close Neo-tree if it's open
    vim.cmd("Neotree close")
  end,
})


-- Optional: Recalculate vim-dadbod-ui width on VimResized
autocmd("VimResized", {
  desc = "Adjust vim-dadbod-ui width on resize",
  group = vim.api.nvim_create_augroup("YodaDadbodResizeOnResize", { clear = true }),
  callback = function()
    local has_dbui = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "dbui" then
        has_dbui = true
        break
      end
    end

    if has_dbui then
      vim.g.db_ui_winwidth = math.floor(vim.o.columns * 0.4)
      vim.cmd("DBUI")          -- Refresh DBUI
      vim.cmd("wincmd p")      -- Restore focus
    end
  end,
})

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("CursorMoved", {
  pattern = "*",
  group = augroup("YodaDadbodAutoExpand", { clear = true }),
  callback = function()
    local ft = vim.bo.filetype
    if ft ~= "dbui" then return end

    local line = vim.api.nvim_get_current_line()
    local indent = line:match("^(%s*)") or ""
    local depth = math.floor(#indent / 2)

    -- Base width + extra per depth level
    local new_width = math.min(math.floor(vim.o.columns * 0.4) + depth * 5, math.floor(vim.o.columns * 0.8))
    vim.g.db_ui_winwidth = new_width
  end,
})

