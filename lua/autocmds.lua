-- lua/yoda/core/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Helper to create autocommands with named groups
local function create_autocmd(events, opts)
  opts.group = opts.group or augroup("YodaAutocmd", { clear = true })
  autocmd(events, opts)
end

-- Helper function to start alpha dashboard with proper configuration
local function start_alpha_dashboard()
  local ok, alpha = pcall(require, "alpha")
  if not ok or not alpha or not alpha.start then
    return false
  end

  local dashboard_ok, dashboard = pcall(require, "alpha.themes.dashboard")
  if not dashboard_ok or not dashboard then
    return false
  end

  -- Build the configuration
  local alpha_config = {
    redraw_on_resize = true,
    layout = {
      { type = "padding", val = 2 },
      dashboard.section.header,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    },
  }

  -- Start alpha with configuration
  local config_ok, _ = pcall(alpha.start, alpha_config)
  return config_ok
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
      -- Use a longer delay to ensure all plugins are loaded
      vim.defer_fn(function()
        -- Only show dashboard if we're in an empty buffer
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname == "" or bufname == "[No Name]" then
          local success = start_alpha_dashboard()
          if not success then
            vim.notify("Alpha dashboard failed to start", vim.log.levels.WARN)
          end
        end
      end, 200) -- Increased delay to ensure plugin is fully loaded
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

-- Prevent plugins from interfering with alpha dashboard
create_autocmd("BufEnter", {
  group = augroup("AlphaBuffer", { clear = true }),
  callback = function()
    -- Only run for the first buffer and when no files are open
    if vim.fn.argc() ~= 0 then
      return
    end

    local bufname = vim.api.nvim_buf_get_name(0)
    local filetype = vim.bo.filetype

    -- Only start alpha if we're in a truly empty buffer and not already in alpha
    if (bufname == "" or bufname == "[No Name]") and filetype ~= "alpha" and filetype == "" then
      local ok, alpha = pcall(require, "alpha")
      if ok and alpha and alpha.start then
        -- Use a small delay to prevent conflicts
        vim.defer_fn(function()
          -- Double-check conditions before starting
          if vim.bo.filetype ~= "alpha" and vim.api.nvim_buf_get_name(0) == "" then
            local success = start_alpha_dashboard()
            if not success then
              vim.notify("Alpha dashboard failed to start", vim.log.levels.WARN)
            end
          end
        end, 100) -- Increased delay for better reliability
      end
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
    -- Additional safety checks
    if vim.bo.modifiable and vim.bo.buftype == "" and vim.bo.readonly == false then
      pcall(vim.cmd, "checktime")
    end
  end,
})

-- Restore last known cursor position, only for normal buffers
create_autocmd("BufReadPost", {
  group = augroup("YodaRestoreCursor", { clear = true }),
  desc = "Restore cursor position",
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
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

-- Filetype-specific settings
create_autocmd("FileType", {
  group = augroup("YodaFileTypes", { clear = true }),
  desc = "Apply filetype-specific settings",
  callback = function()
    local filetype = vim.bo.filetype

    if filetype == "markdown" then
      -- Markdown settings
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
      vim.opt_local.conceallevel = 2
    elseif filetype == "snacks-explorer" then
      -- Snacks Explorer: Force normal mode
      vim.cmd("stopinsert")
      -- Schedule another check to override any delayed inserts
      vim.schedule(function()
        if vim.fn.mode() ~= "n" then
          vim.cmd("stopinsert")
        end
      end)
    end
  end,
})
