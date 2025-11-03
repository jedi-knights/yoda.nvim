-- lua/autocmds.lua
-- Autocommands configuration for Yoda.nvim

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Load large file handler
local large_file = require("yoda.large_file")

-- Load autocmd logger for performance debugging
local autocmd_logger = require("yoda.autocmd_logger")

-- Load autocmd performance tracker
local autocmd_perf = require("yoda.autocmd_performance")

-- ============================================================================
-- Constants
-- ============================================================================

local DELAYS = {
  ALPHA_STARTUP = 200,
  ALPHA_BUFFER_CHECK = 100,
  YANK_HIGHLIGHT = 50,
  BUF_ENTER_DEBOUNCE = 50,
  ALPHA_CLOSE = 50,
  TELESCOPE_CLOSE = 50,
}

local THRESHOLDS = {
  MAX_LINES_FOR_YANK_HIGHLIGHT = 1000, -- Skip yank highlight for large files
}

local ALPHA_CONFIG = {
  HEADER_PADDING = 2,
  BUTTON_PADDING = 2,
  FOOTER_PADDING = 1,
}

-- ============================================================================
-- Helper Functions
-- ============================================================================

--- Create an autocommand with a named group
--- @param events string|table Event(s) to trigger on
--- @param opts table Autocommand options
local function create_autocmd(events, opts)
  opts.group = opts.group or augroup("YodaAutocmd", { clear = true })
  autocmd(events, opts)
end

--- Check if a buffer name indicates it's empty or unnamed
--- @param bufname string Buffer name to check
--- @return boolean
local function is_empty_buffer_name(bufname)
  return bufname == "" or bufname == "[No Name]"
end

--- Check if a buffer name indicates it's a scratch buffer
--- @param bufname string Buffer name to check
--- @return boolean
local function is_scratch_buffer(bufname)
  return bufname == "[Scratch]"
end

--- Check if a buffer is empty or unnamed (but not a scratch buffer)
--- @param bufnr number|nil Buffer number (default: current buffer)
--- @return boolean
local function is_buffer_empty(bufnr)
  bufnr = bufnr or 0
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  -- Don't consider scratch buffers as "empty" for alpha purposes
  if is_scratch_buffer(bufname) then
    return false
  end

  return is_empty_buffer_name(bufname)
end

-- Performance optimizations: cache expensive checks
local alpha_cache = {
  has_startup_files = nil,
  has_alpha_buffer = nil,
  normal_count = nil,
  last_check_time = 0,
  last_alpha_check_time = 0,
  check_interval = 150, -- ms - balance between freshness and performance
  alpha_check_interval = 100, -- ms - prevent flickering while maintaining responsiveness
}

-- Debounce state for BufEnter handler
local buf_enter_debounce = {}

--- Invalidate buffer caches
local function invalidate_buffer_caches()
  alpha_cache.has_alpha_buffer = nil
  alpha_cache.normal_count = nil
end

--- Check if alpha dashboard is already open (optimized with caching)
--- @return boolean
local function has_alpha_buffer()
  local current_time = vim.loop.hrtime() / 1000000

  -- Use cached result if recent enough
  if alpha_cache.has_alpha_buffer ~= nil and (current_time - alpha_cache.last_alpha_check_time) < alpha_cache.alpha_check_interval then
    return alpha_cache.has_alpha_buffer
  end

  -- Fast check: iterate only valid listed buffers
  local has_alpha = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].filetype == "alpha" then
      has_alpha = true
      break
    end
  end

  -- Cache result
  alpha_cache.has_alpha_buffer = has_alpha
  alpha_cache.last_alpha_check_time = current_time

  return has_alpha
end

--- Check if files were opened at startup (cached)
--- @return boolean
local function has_startup_files()
  if alpha_cache.has_startup_files == nil then
    alpha_cache.has_startup_files = vim.fn.argc() ~= 0
  end
  return alpha_cache.has_startup_files
end

--- Check if current buffer has a filetype (optimized)
--- @return boolean
local function has_filetype()
  return vim.bo.filetype ~= ""
end

--- Recenter alpha dashboard if visible
--- @return boolean true if alpha was recentered
local function recenter_alpha_dashboard()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "alpha" then
      -- Save current window
      local current_win = vim.api.nvim_get_current_win()

      -- Switch to alpha window
      vim.api.nvim_set_current_win(win)

      -- Restart alpha to recenter
      local ok, alpha = pcall(require, "alpha")
      if ok and alpha and alpha.start then
        -- Get stored config or start with defaults
        local alpha_config = vim.b[buf].alpha_config
        pcall(alpha.start, false, alpha_config)
      end

      -- Restore previous window if different
      if current_win ~= win and vim.api.nvim_win_is_valid(current_win) then
        vim.api.nvim_set_current_win(current_win)
      end

      return true
    end
  end
  return false
end

--- Check if current buffer has a special buftype (optimized)
--- @return boolean
local function has_special_buftype()
  return vim.bo.buftype ~= ""
end

--- Count normal buffers (simplified and cached)
--- @return number
local function count_normal_buffers()
  local perf_start = vim.loop.hrtime()
  local current_time = perf_start / 1000000 -- convert to ms

  -- Use cached result if recent enough
  if alpha_cache.normal_count and (current_time - alpha_cache.last_check_time) < alpha_cache.check_interval then
    autocmd_perf.track_buffer_operation("count_normal_buffers_cached", perf_start)
    return alpha_cache.normal_count
  end

  local count = 0
  -- Only check listed buffers for performance
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      local buf_ft = vim.bo[buf].filetype
      if buf_ft ~= "alpha" and buf_ft ~= "" then
        count = count + 1
      end
    end
  end

  -- Cache result
  alpha_cache.normal_count = count
  alpha_cache.last_check_time = current_time

  autocmd_perf.track_buffer_operation("count_normal_buffers_full", perf_start)
  return count
end

--- Check if we're in a state where alpha should be shown (optimized)
--- @return boolean
local function should_show_alpha()
  -- Fastest checks first (single function calls)
  if has_startup_files() then
    return false
  end

  if has_filetype() then
    return false
  end

  if has_special_buftype() then
    return false
  end

  if not is_buffer_empty() then
    return false
  end

  -- More expensive checks last
  if has_alpha_buffer() then
    return false
  end

  -- Most expensive check last with caching
  return count_normal_buffers() == 0
end

--- Create alpha dashboard layout configuration
--- @param dashboard table Dashboard theme module
--- @return table Layout configuration
local function create_alpha_layout(dashboard)
  return {
    { type = "padding", val = ALPHA_CONFIG.HEADER_PADDING },
    dashboard.section.header,
    { type = "padding", val = ALPHA_CONFIG.BUTTON_PADDING },
    dashboard.section.buttons,
    { type = "padding", val = ALPHA_CONFIG.FOOTER_PADDING },
    dashboard.section.footer,
  }
end

--- Start the alpha dashboard with proper configuration
--- @return boolean success Whether alpha started successfully
local function start_alpha_dashboard()
  local ok, alpha = pcall(require, "alpha")
  if not ok or not alpha or not alpha.start then
    return false
  end

  local dashboard_ok, dashboard = pcall(require, "alpha.themes.dashboard")
  if not dashboard_ok or not dashboard then
    return false
  end

  local alpha_config = {
    redraw_on_resize = true,
    layout = create_alpha_layout(dashboard),
  }

  local config_ok = pcall(alpha.start, alpha_config)
  return config_ok
end

--- Attempt to show alpha dashboard with error notification
local function show_alpha_dashboard()
  local success = start_alpha_dashboard()
  if not success then
    vim.notify("Alpha dashboard failed to start", vim.log.levels.WARN)
  end
end

--- Change to directory if provided as argument
local function handle_directory_argument()
  if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
    vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
  end
end

--- Check if buffer can be reloaded safely
--- @return boolean
local function can_reload_buffer()
  return vim.bo.modifiable and vim.bo.buftype == "" and not vim.bo.readonly
end

--- Safely refresh git signs
local function safe_refresh_gitsigns()
  local gs = package.loaded.gitsigns
  if gs then
    vim.schedule(function()
      gs.refresh()
    end)
  end
end

--- Close all alpha dashboard buffers
local function close_all_alpha_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "alpha" then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

--- Handle closing alpha dashboard for real file buffers
--- @param buf number Buffer number
--- @param start_time number Start time for logging
local function handle_alpha_close_for_real_buffer(buf, start_time)
  vim.defer_fn(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      autocmd_logger.log("Alpha_Close_Skip", { buf = buf, reason = "invalid_buffer" })
      return
    end

    autocmd_logger.log("Alpha_Close_Check", { buf = buf, delay = DELAYS.ALPHA_CLOSE })

    if not has_alpha_buffer() then
      autocmd_logger.log("Alpha_Close_Skip", { buf = buf, reason = "no_alpha_buffer" })
      return
    end

    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(b) and b ~= buf then
        local ok, ft = pcall(function()
          return vim.bo[b].filetype
        end)

        if ok and ft == "alpha" then
          local is_listed = vim.bo[b].buflisted
          if is_listed then
            autocmd_logger.log("Alpha_Close_Delete", { buf = b })
            pcall(vim.api.nvim_buf_delete, b, { force = true })
          end
        end
      end
    end
  end, DELAYS.ALPHA_CLOSE)
end

--- Handle debounced operations for real buffers (OpenCode integration, git signs)
--- @param buf number Buffer number
local function handle_debounced_buffer_operations(buf)
  if buf_enter_debounce[buf] then
    pcall(vim.fn.timer_stop, buf_enter_debounce[buf])
    buf_enter_debounce[buf] = nil
  end

  buf_enter_debounce[buf] = vim.fn.timer_start(DELAYS.BUF_ENTER_DEBOUNCE, function()
    if not vim.api.nvim_buf_is_valid(buf) then
      autocmd_logger.log("Refresh_Skip", { buf = buf, reason = "invalid_buffer" })
      buf_enter_debounce[buf] = nil
      return
    end

    autocmd_logger.log("Refresh_Start", { buf = buf })
    buf_enter_debounce[buf] = nil

    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        if can_reload_buffer() and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
          autocmd_logger.log("Refresh_Buffer", { buf = buf })
          opencode_integration.refresh_buffer(buf)
        end
        autocmd_logger.log("Refresh_GitSigns", { buf = buf })
        opencode_integration.refresh_git_signs()
      end)
    else
      safe_refresh_gitsigns()
    end
  end)
end

--- Handle real buffer enter (files with content)
--- @param buf number Buffer number
--- @param filetype string File type
--- @param start_time number Start time for logging
--- @param perf_start_time number Performance tracking start time
--- @return boolean true if handled
local function handle_real_buffer_enter(buf, filetype, start_time, perf_start_time)
  autocmd_logger.log("BufEnter_REAL_BUFFER", { buf = buf, filetype = filetype })

  handle_alpha_close_for_real_buffer(buf, start_time)
  handle_debounced_buffer_operations(buf)

  autocmd_logger.log_end("BufEnter", start_time, { action = "refresh_scheduled" })
  autocmd_perf.track_autocmd("BufEnter", perf_start_time)
  return true
end

--- Check if filetype should skip alpha display logic
--- @param filetype string File type to check
--- @return boolean true if should skip
local function should_skip_alpha_for_filetype(filetype)
  local skip_filetypes = {
    "gitcommit",
    "gitrebase",
    "gitconfig",
    "NeogitCommitMessage",
    "NeogitPopup",
    "NeogitStatus",
    "fugitive",
    "fugitiveblame",
    "markdown",
  }

  for _, ft in ipairs(skip_filetypes) do
    if filetype == ft then
      return true
    end
  end

  return false
end

--- Handle alpha dashboard display logic
--- @param buf number Buffer number
--- @param buftype string Buffer type
--- @param filetype string File type
--- @param buflisted boolean Whether buffer is listed
--- @param start_time number Start time for logging
--- @param perf_start_time number Performance tracking start time
local function handle_alpha_dashboard_display(buf, buftype, filetype, buflisted, start_time, perf_start_time)
  if filetype == "alpha" then
    autocmd_logger.log_end("BufEnter", start_time, { action = "alpha_skip" })
    autocmd_perf.track_autocmd("BufEnter", perf_start_time)
    return
  end

  if not buflisted then
    autocmd_logger.log_end("BufEnter", start_time, { action = "not_listed" })
    autocmd_perf.track_autocmd("BufEnter", perf_start_time)
    return
  end

  if buftype ~= "" then
    autocmd_perf.track_autocmd("BufEnter", perf_start_time)
    return
  end

  if should_skip_alpha_for_filetype(filetype) then
    autocmd_perf.track_autocmd("BufEnter", perf_start_time)
    return
  end

  if not should_show_alpha() then
    autocmd_perf.track_autocmd("BufEnter", perf_start_time)
    return
  end

  vim.defer_fn(function()
    if should_show_alpha() then
      show_alpha_dashboard()
    end
  end, DELAYS.ALPHA_BUFFER_CHECK)

  autocmd_perf.track_autocmd("BufEnter", perf_start_time)
end

-- ============================================================================
-- Filetype Detection
-- ============================================================================

-- Jenkinsfile detection with enhanced syntax support
create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("YodaJenkinsfile", { clear = true }),
  desc = "Detect Jenkinsfile and configure for Jenkins Pipeline syntax",
  pattern = {
    "Jenkinsfile",
    "*.Jenkinsfile",
    "jenkinsfile",
    "*.jenkinsfile",
    "*.jenkins",
    "*jenkins*",
  },
  callback = function()
    vim.bo.filetype = "groovy"
    vim.bo.syntax = "groovy"

    -- Add Jenkins-specific keywords for better syntax highlighting
    vim.cmd([[
      syntax keyword groovyKeyword pipeline agent stages stage steps script sh bat powershell
      syntax keyword groovyKeyword when environment parameters triggers tools options
      syntax keyword groovyKeyword post always success failure unstable changed cleanup
      syntax keyword groovyKeyword parallel matrix node checkout scm git svn
      syntax keyword groovyKeyword build publishHTML archiveArtifacts publishTestResults
      syntax keyword groovyKeyword junit testReport emailext slackSend
      syntax match groovyFunction /\w\+\s*(/
    ]])
  end,
})

-- ============================================================================
-- Performance Profiles
-- ============================================================================

local PERFORMANCE_PROFILES = {
  aggressive = function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.updatetime = 4000
    vim.opt_local.timeoutlen = 1000
    vim.opt_local.ttimeoutlen = 0
    vim.opt_local.lazyredraw = true
    vim.opt_local.synmaxcol = 200
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
    vim.opt_local.relativenumber = false
  end,

  commit = function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.updatetime = 2000
    vim.opt_local.lazyredraw = true
    vim.opt_local.synmaxcol = 200
    vim.opt_local.timeoutlen = 1000
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
    vim.opt_local.relativenumber = false
    vim.opt_local.complete = ""
    vim.opt_local.completeopt = ""
  end,

  neogit = function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.updatetime = 2000
    vim.opt_local.lazyredraw = true
    vim.opt_local.cursorline = false
    vim.opt_local.synmaxcol = 200
  end,
}

-- ============================================================================
-- Filetype-specific Settings Configuration
-- ============================================================================

local FILETYPE_SETTINGS = {
  markdown = function()
    PERFORMANCE_PROFILES.aggressive()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
    vim.opt_local.conceallevel = 0
    vim.opt_local.number = false
    vim.opt_local.colorcolumn = ""
  end,

  gitcommit = function()
    PERFORMANCE_PROFILES.commit()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 72
  end,

  NeogitCommitMessage = function()
    PERFORMANCE_PROFILES.commit()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 72
  end,

  NeogitStatus = function()
    PERFORMANCE_PROFILES.neogit()
  end,

  NeogitPopup = function()
    PERFORMANCE_PROFILES.neogit()
  end,

  ["snacks-explorer"] = function()
    vim.cmd("stopinsert")
    vim.schedule(function()
      if vim.fn.mode() ~= "n" then
        vim.cmd("stopinsert")
      end

      -- Recenter alpha dashboard if it's open
      recenter_alpha_dashboard()
    end)
  end,

  -- Helm template files: use YAML syntax with helm-specific settings
  helm = function()
    vim.opt_local.commentstring = "# %s"
    vim.opt_local.syntax = "yaml" -- Use YAML syntax highlighting as base
    vim.opt_local.wrap = false
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,

  -- Regular YAML files
  yaml = function()
    vim.opt_local.commentstring = "# %s"
    vim.opt_local.wrap = false
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,

  -- Groovy files (including Jenkinsfiles)
  groovy = function()
    vim.opt_local.commentstring = "// %s"
    vim.opt_local.wrap = false
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    -- Enable syntax highlighting
    vim.opt_local.syntax = "groovy"
  end,

  -- Properties files (disable treesitter, use simple syntax)
  properties = function()
    vim.opt_local.commentstring = "# %s"
    vim.opt_local.wrap = false
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    -- Disable treesitter explicitly to prevent temp file errors
    vim.b.ts_highlight = false
    -- Use basic syntax highlighting
    vim.opt_local.syntax = "conf"
  end,
}

--- Apply filetype-specific settings
--- @param filetype string The filetype to configure
local function apply_filetype_settings(filetype)
  local settings_fn = FILETYPE_SETTINGS[filetype]
  if settings_fn then
    settings_fn()
  end
end

-- ============================================================================
-- Autocommand Definitions
-- ============================================================================

-- Large File Detection (must be first to run before other expensive operations)
create_autocmd("BufReadPre", {
  group = augroup("YodaLargeFile", { clear = true }),
  desc = "Detect and optimize for large files",
  callback = function(args)
    large_file.on_buf_read(args.buf)
  end,
})

-- Smart Buffer Delete Command
vim.api.nvim_create_user_command("Bd", function(opts)
  local buf = vim.api.nvim_get_current_buf()
  local autocmd_logger = require("yoda.autocmd_logger")

  autocmd_logger.log("Bd_Start", { buf = buf, bang = opts.bang })

  -- Skip special buffers
  if vim.bo[buf].buftype ~= "" then
    autocmd_logger.log("Bd_Special", { buf = buf, buftype = vim.bo[buf].buftype })
    vim.cmd("bdelete" .. (opts.bang and "!" or ""))
    return
  end

  -- Find which window(s) are displaying this buffer
  local windows_with_buf = vim.fn.win_findbuf(buf)
  autocmd_logger.log("Bd_Windows", { buf = buf, window_count = #windows_with_buf })

  -- Get list of normal buffers (excluding current)
  local normal_buffers = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and b ~= buf and vim.bo[b].buflisted and vim.bo[b].buftype == "" then
      table.insert(normal_buffers, b)
    end
  end

  autocmd_logger.log("Bd_Alternates", { buf = buf, alternate_count = #normal_buffers })

  -- If there are other normal buffers, switch windows before deleting
  if #normal_buffers > 0 then
    -- Determine which buffer to switch to
    local alt = vim.fn.bufnr("#")
    local target_buf

    if alt ~= -1 and alt ~= buf and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buftype == "" then
      target_buf = alt -- Use alternate buffer
      autocmd_logger.log("Bd_UseAlternate", { buf = buf, target = alt })
    else
      target_buf = normal_buffers[1] -- Use first available buffer
      autocmd_logger.log("Bd_UseFirst", { buf = buf, target = normal_buffers[1] })
    end

    -- Switch each window to the target buffer BEFORE deletion
    for _, win in ipairs(windows_with_buf) do
      if vim.api.nvim_win_is_valid(win) then
        local ok = pcall(vim.api.nvim_win_set_buf, win, target_buf)
        autocmd_logger.log("Bd_SwitchWindow", { win = win, target = target_buf, success = ok })
      end
    end
  else
    autocmd_logger.log("Bd_NoAlternates", { buf = buf })
  end

  -- Now delete the buffer
  local delete_cmd = "bdelete" .. (opts.bang and "!" or "") .. " " .. buf
  autocmd_logger.log("Bd_Delete", { buf = buf, cmd = delete_cmd })

  local ok, err = pcall(vim.cmd, delete_cmd)
  if not ok then
    autocmd_logger.log("Bd_DeleteFailed", { buf = buf, error = tostring(err) })
    vim.notify("Buffer delete failed: " .. tostring(err), vim.log.levels.ERROR)
  else
    autocmd_logger.log("Bd_DeleteSuccess", { buf = buf })
  end
end, { bang = true, desc = "Smart buffer delete that preserves window layout" })

-- Create alias for standard :bd command
vim.api.nvim_create_user_command("BD", function(opts)
  vim.cmd("Bd" .. (opts.bang and "!" or ""))
end, { bang = true, desc = "Alias for Bd" })

-- Buffer Cache Invalidation: Clear caches when buffer state changes
create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = augroup("YodaBufferCacheInvalidation", { clear = true }),
  desc = "Invalidate buffer caches when buffers are removed",
  callback = function(args)
    -- Only invalidate if it's a real buffer being deleted
    local buf = args.buf
    if vim.api.nvim_buf_is_valid(buf) then
      local buftype = vim.bo[buf].buftype
      local filetype = vim.bo[buf].filetype
      -- Only invalidate for real buffers or alpha dashboard
      if buftype == "" or filetype == "alpha" then
        invalidate_buffer_caches()
      end
    end
  end,
})

-- Terminal: Hide line numbers and ensure modifiable
create_autocmd("TermOpen", {
  group = augroup("YodaTerminal", { clear = true }),
  desc = "Configure terminal buffers",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    -- Ensure terminal buffers are modifiable for proper operation
    vim.opt_local.modifiable = true
  end,
})

-- Startup: Handle directory argument and show dashboard
create_autocmd("VimEnter", {
  group = augroup("YodaStartup", { clear = true }),
  desc = "Initialize on startup",
  callback = function()
    handle_directory_argument()

    if should_show_alpha() then
      vim.defer_fn(function()
        if should_show_alpha() then
          show_alpha_dashboard()
        end
      end, DELAYS.ALPHA_STARTUP)
    end
  end,
})

create_autocmd("BufEnter", {
  group = augroup("YodaConsolidatedBufEnter", { clear = true }),
  desc = "Consolidated buffer enter handler for alpha, refresh, and git signs",
  callback = function(args)
    local perf_start_time = vim.loop.hrtime()
    local start_time = autocmd_logger.log_start("BufEnter", { buf = args.buf })
    local buf = args.buf

    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:match("snacks_") or bufname:match("^%[.-%]$") then
      autocmd_logger.log("BufEnter_SKIP", { buf = buf, reason = "snacks_buffer" })
      autocmd_logger.log_end("BufEnter", start_time, { action = "skipped_snacks" })
      return
    end

    local buftype = vim.bo[buf].buftype
    local filetype = vim.bo[buf].filetype
    local buflisted = vim.bo[buf].buflisted

    if buftype ~= "" and buftype ~= "help" then
      autocmd_logger.log("BufEnter_SKIP", { buf = buf, reason = "special_buftype", buftype = buftype })
      autocmd_logger.log_end("BufEnter", start_time, { action = "skipped_special" })
      return
    end

    local is_real_buffer = buftype == "" and filetype ~= "" and filetype ~= "alpha" and bufname ~= ""

    if is_real_buffer then
      handle_real_buffer_enter(buf, filetype, start_time, perf_start_time)
      return
    end

    handle_alpha_dashboard_display(buf, buftype, filetype, buflisted, start_time, perf_start_time)
  end,
})

-- Additional Alpha closing for file pickers and external commands
create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = augroup("AlphaCloseOnFile", { clear = true }),
  desc = "Close alpha dashboard when reading/creating files",
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype
    local bufname = vim.api.nvim_buf_get_name(args.buf)

    -- Skip alpha and special buffers
    if filetype == "alpha" or filetype == "" or bufname == "" then
      return
    end

    vim.schedule(function()
      close_all_alpha_buffers()
    end)
  end,
})

-- Close alpha when window layout changes (e.g., from Telescope)
create_autocmd("WinEnter", {
  group = augroup("AlphaCloseOnWinEnter", { clear = true }),
  desc = "Close alpha dashboard when entering non-alpha windows",
  callback = function()
    local current_filetype = vim.bo.filetype

    if current_filetype ~= "alpha" and current_filetype ~= "" and vim.api.nvim_buf_get_name(0) ~= "" then
      vim.schedule(function()
        close_all_alpha_buffers()
      end)
    end
  end,
})

-- Force close alpha when Telescope or other pickers close
create_autocmd("BufHidden", {
  group = augroup("AlphaCloseOnPickerExit", { clear = true }),
  desc = "Close alpha when file pickers close",
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype

    -- If a telescope or picker buffer is being hidden, likely a file was selected
    if filetype == "TelescopePrompt" or filetype:match("^telescope") then
      vim.defer_fn(function()
        -- Check if any real files are now open
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
          close_all_alpha_buffers()
        end
      end, DELAYS.TELESCOPE_CLOSE)
    end
  end,
})

-- Ensure Python syntax highlighting is enabled
create_autocmd("FileType", {
  group = augroup("YodaPythonSyntax", { clear = true }),
  desc = "Ensure Python syntax highlighting is properly enabled",
  pattern = "python",
  callback = function()
    -- Ensure treesitter is enabled for Python
    local ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
    if ok and ts_highlight then
      ts_highlight.attach(0, "python")
    end

    -- Fallback to vim syntax if treesitter fails
    if not vim.treesitter.highlighter.active[0] then
      vim.cmd("syntax enable")
      vim.bo.syntax = "python"
    end
  end,
})

-- Highlight on yank
create_autocmd("TextYankPost", {
  group = augroup("YodaHighlightYank", { clear = true }),
  desc = "Highlight yanked text briefly",
  callback = function()
    if vim.api.nvim_buf_line_count(0) < THRESHOLDS.MAX_LINES_FOR_YANK_HIGHLIGHT then
      vim.highlight.on_yank({ timeout = DELAYS.YANK_HIGHLIGHT })
    end
  end,
})

-- Auto reload changed files on focus
create_autocmd("FocusGained", {
  group = augroup("YodaAutoRead", { clear = true }),
  desc = "Reload files changed outside of Neovim and refresh git signs",
  callback = function()
    if can_reload_buffer() then
      pcall(vim.cmd, "checktime")
      safe_refresh_gitsigns()
    end
  end,
})

-- Restore last cursor position
create_autocmd("BufReadPost", {
  group = augroup("YodaRestoreCursor", { clear = true }),
  desc = "Restore cursor to last known position",
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)

    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto resize splits on window resize (with alpha dashboard support)
create_autocmd("VimResized", {
  group = augroup("YodaResizeSplits", { clear = true }),
  desc = "Automatically resize splits on window resize and recenter alpha dashboard",
  callback = function()
    -- Equalize all windows
    vim.cmd("tabdo wincmd =")

    -- Check if alpha dashboard is visible and recenter it
    vim.schedule(function()
      recenter_alpha_dashboard()
    end)
  end,
})

-- Filetype-specific settings
create_autocmd("FileType", {
  group = augroup("YodaFileTypes", { clear = true }),
  desc = "Apply filetype-specific settings",
  callback = function()
    apply_filetype_settings(vim.bo.filetype)
  end,
})

-- MARKDOWN PERFORMANCE: Balanced performance and functionality
create_autocmd("FileType", {
  group = augroup("YodaMarkdownPerformance", { clear = true }),
  desc = "Balanced performance optimizations for markdown",
  pattern = "markdown",
  callback = function()
    -- Keep basic syntax highlighting but disable expensive inline parsing
    vim.cmd("silent! TSDisable markdown_inline")

    -- Disable ALL autocmds that might trigger on typing events
    vim.cmd("autocmd! TextChanged,TextChangedI,TextChangedP <buffer>")
    vim.cmd("autocmd! InsertEnter,InsertLeave <buffer>")
    vim.cmd("autocmd! CursorMoved,CursorMovedI <buffer>")
    vim.cmd("autocmd! BufEnter,BufWritePost <buffer>")
    vim.cmd("autocmd! LspAttach <buffer>")

    -- Disable all completion
    vim.opt_local.complete = ""
    vim.opt_local.completeopt = ""

    -- Disable all diagnostics
    vim.diagnostic.disable()

    -- Disable all statusline updates
    vim.opt_local.statusline = ""

    -- Disable all cursor movements that might trigger events
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false

    -- Disable copilot and other AI assistants (only if available)
    local ok, copilot = pcall(require, "copilot")
    if ok and copilot then
      vim.cmd("silent! Copilot disable")
    end

    -- Disable linting
    vim.cmd("silent! LintDisable")

    -- Maximum performance settings
    vim.opt_local.updatetime = 4000
    vim.opt_local.timeoutlen = 1000
    vim.opt_local.ttimeoutlen = 0
    vim.opt_local.lazyredraw = true
    vim.opt_local.synmaxcol = 200
    vim.opt_local.maxmempattern = 1000 -- Limit regex memory usage

    -- Disable all plugin loading
    vim.opt_local.eventignore = "all"

    print("🚀 AGGRESSIVE MARKDOWN PERFORMANCE MODE ENABLED")
    print("📝 ALL autocmds, plugins, and features disabled")
  end,
})

-- ============================================================================
-- OpenCode Integration - Enhanced Buffer Management
-- ============================================================================

-- Auto-save all modified buffers when OpenCode launches
create_autocmd("User", {
  group = augroup("YodaOpenCodeAutoSave", { clear = true }),
  pattern = "OpencodeStart",
  desc = "Auto-save all buffers when OpenCode starts",
  callback = function()
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      vim.schedule(function()
        pcall(opencode_integration.save_all_buffers)
      end)
    end
  end,
})

-- Enhanced buffer refresh when focus is gained (OpenCode integration)
create_autocmd("FocusGained", {
  group = augroup("YodaOpenCodeFocusRefresh", { clear = true }),
  desc = "Refresh buffers and git signs when focus is gained",
  callback = function()
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      vim.schedule(function()
        -- Force check for external changes
        pcall(vim.cmd, "checktime")

        -- Refresh current buffer if needed
        if can_reload_buffer() and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
          local current_buf = vim.api.nvim_get_current_buf()
          opencode_integration.refresh_buffer(current_buf)
        end

        -- Refresh git signs
        opencode_integration.refresh_git_signs()
      end)
    else
      if can_reload_buffer() then
        pcall(vim.cmd, "checktime")
        safe_refresh_gitsigns()
      end
    end
  end,
})

-- Refresh git signs when buffer is written (covers OpenCode auto-reload)
create_autocmd("BufWritePost", {
  group = augroup("YodaGitSignsWriteRefresh", { clear = true }),
  desc = "Refresh git signs after buffer is written",
  callback = function()
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      opencode_integration.refresh_git_signs()
    else
      if vim.bo.buftype == "" then
        safe_refresh_gitsigns()
      end
    end
  end,
})

-- Enhanced file change detection with complete refresh cycle
create_autocmd("FileChangedShell", {
  group = augroup("YodaOpenCodeFileChange", { clear = true }),
  desc = "Handle files changed by external tools like OpenCode with complete refresh",
  callback = function(args)
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      vim.schedule(function()
        -- Refresh the specific changed buffer first
        if args.buf and vim.api.nvim_buf_is_valid(args.buf) then
          opencode_integration.refresh_buffer(args.buf)
        end

        -- Complete refresh cycle
        opencode_integration.complete_refresh()
      end)
    else
      -- Fallback behavior
      vim.schedule(function()
        pcall(vim.cmd, "checktime")
        safe_refresh_gitsigns()
      end)
    end
  end,
})

-- Post-process file changes for UI consistency
create_autocmd("FileChangedShellPost", {
  group = augroup("YodaOpenCodeFileChangePost", { clear = true }),
  desc = "Post-process file changes from external tools",
  callback = function()
    vim.schedule(function()
      -- Ensure UI is properly updated
      vim.cmd("redraw!")

      -- Final git signs refresh for consistency
      local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
      if ok then
        opencode_integration.refresh_git_signs()
      else
        local gs = package.loaded.gitsigns
        if gs and vim.bo.buftype == "" then
          gs.refresh()
        end
      end
    end)
  end,
})

-- ============================================================================
-- PERFORMANCE OPTIMIZATION: Disable expensive text change events for commit buffers
-- ============================================================================

-- Disable expensive text change autocmds for git commit buffers to prevent lag
create_autocmd("FileType", {
  group = augroup("YodaGitCommitPerformance", { clear = true }),
  desc = "Disable expensive autocmds for git commit buffers to prevent typing lag",
  pattern = { "gitcommit", "NeogitCommitMessage" },
  callback = function()
    -- Disable text change events that might cause lag
    vim.cmd("autocmd! TextChanged,TextChangedI,TextChangedP <buffer>")
    vim.cmd("autocmd! CursorMoved,CursorMovedI <buffer>")
    vim.cmd("autocmd! InsertEnter,InsertLeave <buffer>")
    vim.cmd("autocmd! BufWritePost <buffer>")

    -- Disable completion-related events
    vim.cmd("autocmd! CompleteChanged,CompleteDone <buffer>")

    -- Note: LSP is already disabled for git commit buffers via filetype exclusion

    vim.notify("🔥 Disabled expensive autocmds for git commit buffer", vim.log.levels.DEBUG)
  end,
})

-- ============================================================================
-- SESSION MANAGEMENT
-- ============================================================================

-- Enhanced OpenCode integration
create_autocmd("User", {
  group = augroup("YodaOpenCodeIntegration", { clear = true }),
  pattern = "OpencodeExit",
  desc = "Handle OpenCode exit",
  callback = function()
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      opencode_integration.on_opencode_exit()
    end
  end,
})

-- ============================================================================
-- WINDOW LAYOUT MANAGEMENT: Snacks Explorer + OpenCode
-- ============================================================================

create_autocmd("BufWinEnter", {
  group = augroup("YodaWindowLayout", { clear = true }),
  desc = "Ensure proper window placement with Snacks explorer and OpenCode",
  callback = function(args)
    local buf = args.buf
    local bufname = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.bo[buf].filetype

    -- Skip special buffers
    if filetype == "snacks-explorer" or filetype == "opencode" or filetype == "alpha" or bufname == "" then
      return
    end

    -- Skip if this is not a real file buffer
    if vim.bo[buf].buftype ~= "" then
      return
    end

    vim.schedule(function()
      -- Find all relevant windows
      local explorer_win = nil
      local opencode_win = nil
      local current_win = vim.api.nvim_get_current_win()
      local regular_wins = {}

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local win_buf = vim.api.nvim_win_get_buf(win)
        local win_ft = vim.bo[win_buf].filetype
        local win_name = vim.api.nvim_buf_get_name(win_buf)

        if win_ft == "snacks-explorer" or win_name:match("snacks%-explorer") then
          explorer_win = win
        elseif win_ft == "opencode" or win_name:match("opencode") then
          opencode_win = win
        elseif vim.api.nvim_win_get_config(win).relative == "" then
          -- Regular window (not floating)
          table.insert(regular_wins, win)
        end
      end

      -- If both explorer and OpenCode are open, and we're opening a new file
      if explorer_win and opencode_win then
        -- Check if the current window is the OpenCode window
        if current_win == opencode_win then
          -- Find or create a main edit window between explorer and OpenCode
          local main_win = nil
          for _, win in ipairs(regular_wins) do
            if win ~= explorer_win and win ~= opencode_win then
              main_win = win
              break
            end
          end

          if main_win then
            -- Use existing main window
            vim.api.nvim_set_current_win(main_win)
            vim.api.nvim_win_set_buf(main_win, buf)
          else
            -- Create new window between explorer and OpenCode
            vim.api.nvim_set_current_win(explorer_win)
            vim.cmd("rightbelow vsplit")
            main_win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(main_win, buf)
          end
        end
      end
    end)
  end,
})

-- ============================================================================
-- CMDLINE PERFORMANCE: Disable LSP in cmdline mode
-- ============================================================================

local cmdline_perf_group = augroup("YodaCmdlinePerformance", { clear = true })

create_autocmd("CmdlineEnter", {
  group = cmdline_perf_group,
  desc = "Disable LSP features in cmdline mode for performance",
  callback = function()
    vim.g.cmdline_mode = true
  end,
})

create_autocmd("CmdlineLeave", {
  group = cmdline_perf_group,
  desc = "Re-enable LSP features after leaving cmdline mode",
  callback = function()
    vim.g.cmdline_mode = false
  end,
})

-- ============================================================================
-- Autocmd Logging Commands (for debugging)
-- ============================================================================

vim.api.nvim_create_user_command("YodaAutocmdLogEnable", function()
  autocmd_logger.enable()
end, { desc = "Enable detailed autocmd logging for debugging" })

vim.api.nvim_create_user_command("YodaAutocmdLogDisable", function()
  autocmd_logger.disable()
end, { desc = "Disable autocmd logging" })

vim.api.nvim_create_user_command("YodaAutocmdLogToggle", function()
  autocmd_logger.toggle()
end, { desc = "Toggle autocmd logging" })

vim.api.nvim_create_user_command("YodaAutocmdLogView", function()
  autocmd_logger.view_log()
end, { desc = "View autocmd log file" })

vim.api.nvim_create_user_command("YodaAutocmdLogClear", function()
  autocmd_logger.clear_log()
end, { desc = "Clear autocmd log file" })

-- Setup autocmd performance tracking commands
autocmd_perf.setup_commands()

-- ============================================================================
-- Command Aliases for Better Buffer Management
-- ============================================================================

-- Make :bd use our smart buffer delete
vim.cmd([[
  cnoreabbrev <expr> bd getcmdtype() == ':' && getcmdline() == 'bd' ? 'Bd' : 'bd'
  cnoreabbrev <expr> bdelete getcmdtype() == ':' && getcmdline() == 'bdelete' ? 'Bd' : 'bdelete'
]])
