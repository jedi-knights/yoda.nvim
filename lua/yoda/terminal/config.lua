-- lua/yoda/terminal/config.lua
-- Terminal window configuration (extracted from functions.lua for better SRP)

local M = {}

-- ============================================================================
-- Constants (configurable via vim.g.yoda_terminal_*)
-- ============================================================================

-- Terminal window dimensions (percentages of screen size)
-- Users can override with: vim.g.yoda_terminal_width, vim.g.yoda_terminal_height
local TERMINAL_WIDTH_PERCENT = vim.g.yoda_terminal_width or 0.9 -- Use 90% of screen width for better readability
local TERMINAL_HEIGHT_PERCENT = vim.g.yoda_terminal_height or 0.85 -- Use 85% of screen height for comfortable viewing
local DEFAULT_BORDER_STYLE = vim.g.yoda_terminal_border or "rounded"
local DEFAULT_TITLE_POSITION = vim.g.yoda_terminal_title_pos or "center"

M.DEFAULTS = {
  WIDTH = TERMINAL_WIDTH_PERCENT,
  HEIGHT = TERMINAL_HEIGHT_PERCENT,
  BORDER = DEFAULT_BORDER_STYLE,
  TITLE_POS = DEFAULT_TITLE_POSITION,
}

-- ============================================================================
-- Public API
-- ============================================================================

--- Create window options for terminal
--- @param title string Window title
--- @param overrides table|nil Override default options
--- @return table Window configuration
function M.make_win_opts(title, overrides)
  -- Input validation for perfect assertiveness
  if type(title) ~= "string" then
    vim.notify("make_win_opts: title must be a string, got " .. type(title), vim.log.levels.WARN, { title = "Terminal Config Warning" })
    title = " Terminal " -- Fallback to default
  end

  if title == "" then
    title = " Terminal " -- Empty title fallback
  end

  overrides = overrides or {}

  return {
    relative = "editor",
    position = "float",
    width = overrides.width or M.DEFAULTS.WIDTH,
    height = overrides.height or M.DEFAULTS.HEIGHT,
    border = overrides.border or M.DEFAULTS.BORDER,
    title = title,
    title_pos = overrides.title_pos or M.DEFAULTS.TITLE_POS,
  }
end

--- Create full terminal configuration
--- @param cmd table Command to run
--- @param title string Terminal title
--- @param opts table|nil Additional options
--- @return table Terminal configuration
function M.make_config(cmd, title, opts)
  -- Input validation for perfect assertiveness
  if type(cmd) ~= "table" then
    vim.notify("make_config: cmd must be a table, got " .. type(cmd), vim.log.levels.ERROR, { title = "Terminal Config Error" })
    cmd = { vim.o.shell } -- Fallback
  end

  -- Validate cmd is a proper array (list) not a dict
  if cmd[1] == nil then
    vim.notify("make_config: cmd must be an array with at least one element", vim.log.levels.ERROR, { title = "Terminal Config Error" })
    cmd = { vim.o.shell }
  end

  opts = opts or {}

  -- Build config for snacks.terminal
  local config = {
    cmd = cmd,
    win = M.make_win_opts(title, opts.win or {}),
  }

  -- Only add optional fields if they're provided
  if opts.on_exit then
    config.on_exit = opts.on_exit
  end

  return config
end

return M
