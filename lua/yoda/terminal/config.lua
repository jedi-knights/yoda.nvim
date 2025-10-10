-- lua/yoda/terminal/config.lua
-- Terminal window configuration (extracted from functions.lua for better SRP)

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

-- Terminal window dimensions (percentages of screen size)
local TERMINAL_WIDTH_PERCENT = 0.9 -- Use 90% of screen width for better readability
local TERMINAL_HEIGHT_PERCENT = 0.85 -- Use 85% of screen height for comfortable viewing
local DEFAULT_BORDER_STYLE = "rounded"
local DEFAULT_TITLE_POSITION = "center"

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

  opts = opts or {}

  return {
    cmd = cmd,
    win = M.make_win_opts(title, opts.win or {}),
    start_insert = opts.start_insert ~= false,
    auto_insert = opts.auto_insert ~= false,
    env = opts.env,
    on_open = opts.on_open or function(term)
      vim.opt_local.modifiable = true
      vim.opt_local.readonly = false
    end,
    on_exit = opts.on_exit,
  }
end

return M
