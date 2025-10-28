-- lua/yoda/large_file.lua
-- Large file detection and optimization system

local M = {}

-- ============================================================================
-- Configuration
-- ============================================================================

local DEFAULT_CONFIG = {
  size_threshold = 100 * 1024, -- 100KB
  show_notification = true,
  disable = {
    editorconfig = true,
    treesitter = true,
    lsp = true,
    gitsigns = true,
    autosave = true,
    diagnostics = true,
    syntax = false, -- Keep basic syntax for now
    swap = true,
    undo = true,
    backup = true,
  },
}

-- ============================================================================
-- State Management
-- ============================================================================

local config = vim.deepcopy(DEFAULT_CONFIG)

--- Get configuration
--- @return table Configuration
function M.get_config()
  return config
end

--- Update configuration
--- @param user_config table User configuration
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", DEFAULT_CONFIG, user_config or {})
end

--- Check if buffer is marked as large file
--- @param buf number Buffer number
--- @return boolean
function M.is_large_file(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  return vim.b[buf].large_file == true
end

--- Get file size in bytes
--- @param filepath string File path
--- @return number|nil size File size in bytes or nil on error
local function get_file_size(filepath)
  if not filepath or filepath == "" then
    return nil
  end

  local ok, stats = pcall(vim.loop.fs_stat, filepath)
  if ok and stats then
    return stats.size
  end
  return nil
end

--- Format file size for display
--- @param bytes number File size in bytes
--- @return string Formatted size
local function format_size(bytes)
  if bytes < 1024 then
    return bytes .. "B"
  elseif bytes < 1024 * 1024 then
    return string.format("%.1fKB", bytes / 1024)
  else
    return string.format("%.1fMB", bytes / (1024 * 1024))
  end
end

-- ============================================================================
-- Feature Disabling
-- ============================================================================

--- Disable EditorConfig for buffer
--- @param buf number Buffer number
local function disable_editorconfig(buf)
  vim.b[buf].editorconfig = false
end

--- Disable TreeSitter for buffer
--- @param buf number Buffer number
local function disable_treesitter(buf)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      local ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
      if ok and ts_highlight then
        pcall(ts_highlight.detach, buf)
      end
    end
  end)
end

--- Disable LSP for buffer
--- @param buf number Buffer number
local function disable_lsp(buf)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      -- Stop all LSP clients attached to this buffer
      local clients = vim.lsp.get_clients({ bufnr = buf })
      for _, client in ipairs(clients) do
        vim.lsp.buf_detach_client(buf, client.id)
      end
    end
  end)
end

--- Disable git signs for buffer
--- @param buf number Buffer number
local function disable_gitsigns(buf)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      local gs = package.loaded.gitsigns
      if gs then
        pcall(gs.detach, buf)
      end
    end
  end)
end

--- Disable diagnostics for buffer
--- @param buf number Buffer number
local function disable_diagnostics(buf)
  vim.diagnostic.enable(false, { bufnr = buf })
end

--- Set buffer-local options for large files
--- @param buf number Buffer number
local function set_large_file_options(buf)
  -- Buffer-local options only (verified with nvim_get_option_info2)
  local buffer_opts = {
    swapfile = false, -- buf scope
    undofile = false, -- buf scope
    undolevels = -1, -- buf scope
    synmaxcol = 200, -- buf scope - Limit syntax highlighting columns
  }

  for opt, value in pairs(buffer_opts) do
    vim.api.nvim_set_option_value(opt, value, { buf = buf })
  end

  -- Window-local options (use scope = "local")
  vim.api.nvim_set_option_value("foldmethod", "manual", { scope = "local" })
  vim.api.nvim_set_option_value("foldenable", false, { scope = "local" })

  -- Global options (cannot use buf parameter)
  vim.opt.backup = false
  vim.opt.writebackup = false
  vim.opt.lazyredraw = true
  vim.opt.eventignore:append("FileType")
end

-- ============================================================================
-- Detection and Setup
-- ============================================================================

--- Enable large file mode for buffer
--- @param buf number Buffer number
--- @param size number File size in bytes
function M.enable_large_file_mode(buf, size)
  if M.is_large_file(buf) then
    return -- Already enabled
  end

  -- Mark buffer as large file
  vim.b[buf].large_file = true
  vim.b[buf].large_file_size = size

  -- Apply optimizations based on config
  if config.disable.editorconfig then
    disable_editorconfig(buf)
  end

  if config.disable.treesitter then
    disable_treesitter(buf)
  end

  if config.disable.lsp then
    disable_lsp(buf)
  end

  if config.disable.gitsigns then
    disable_gitsigns(buf)
  end

  if config.disable.diagnostics then
    disable_diagnostics(buf)
  end

  -- Set buffer options
  set_large_file_options(buf)

  -- Notify user
  if config.show_notification then
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
    local size_str = format_size(size)
    vim.notify(
      string.format("📊 Large file mode enabled for %s (%s)\nSome features disabled for better performance", filename, size_str),
      vim.log.levels.INFO,
      { title = "Large File" }
    )
  end
end

--- Disable large file mode for buffer
--- @param buf number Buffer number
function M.disable_large_file_mode(buf)
  buf = buf or vim.api.nvim_get_current_buf()

  if not M.is_large_file(buf) then
    return
  end

  -- Clear large file markers
  vim.b[buf].large_file = false
  vim.b[buf].large_file_size = nil

  -- Re-enable editorconfig
  vim.b[buf].editorconfig = true

  -- Notify user
  vim.notify("📊 Large file mode disabled - reload buffer to re-enable features", vim.log.levels.INFO, { title = "Large File" })
end

--- Check and handle large file on buffer read
--- @param buf number Buffer number
function M.on_buf_read(buf)
  local filepath = vim.api.nvim_buf_get_name(buf)
  local size = get_file_size(filepath)

  if size and size > config.size_threshold then
    M.enable_large_file_mode(buf, size)
  end
end

-- ============================================================================
-- Commands
-- ============================================================================

--- Setup user commands
function M.setup_commands()
  vim.api.nvim_create_user_command("LargeFileEnable", function()
    local buf = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(buf)
    local size = get_file_size(filepath) or 0
    M.enable_large_file_mode(buf, size)
  end, { desc = "Enable large file mode for current buffer" })

  vim.api.nvim_create_user_command("LargeFileDisable", function()
    M.disable_large_file_mode()
  end, { desc = "Disable large file mode for current buffer" })

  vim.api.nvim_create_user_command("LargeFileStatus", function()
    local buf = vim.api.nvim_get_current_buf()
    if M.is_large_file(buf) then
      local size = vim.b[buf].large_file_size or 0
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
      vim.notify(
        string.format("Large file mode: ENABLED\nFile: %s\nSize: %s\nThreshold: %s", filename, format_size(size), format_size(config.size_threshold)),
        vim.log.levels.INFO,
        { title = "Large File Status" }
      )
    else
      vim.notify("Large file mode: DISABLED", vim.log.levels.INFO, { title = "Large File Status" })
    end
  end, { desc = "Show large file mode status" })

  vim.api.nvim_create_user_command("LargeFileConfig", function()
    vim.notify(vim.inspect(config), vim.log.levels.INFO, { title = "Large File Configuration" })
  end, { desc = "Show large file configuration" })
end

-- ============================================================================
-- Auto-save Protection
-- ============================================================================

--- Check if auto-save should be skipped for buffer
--- @param buf number Buffer number
--- @return boolean should_skip
function M.should_skip_autosave(buf)
  if not config.disable.autosave then
    return false
  end
  return M.is_large_file(buf)
end

return M
