-- lua/yoda/terminal/shell.lua
-- Shell detection and management (extracted from functions.lua for better SRP)

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

local SHELL_TYPES = {
  BASH = "bash",
  ZSH = "zsh",
}

-- ============================================================================
-- Public API
-- ============================================================================

--- Determine shell type from shell path
--- @param shell string Shell executable path
--- @return string|nil Shell type (bash/zsh) or nil for unknown
function M.get_type(shell)
  if shell:match(SHELL_TYPES.BASH) then
    return SHELL_TYPES.BASH
  elseif shell:match(SHELL_TYPES.ZSH) then
    return SHELL_TYPES.ZSH
  end
  return nil
end

--- Get default shell
--- @return string Shell path
function M.get_default()
  return os.getenv("SHELL") or vim.o.shell
end

--- Open simple terminal without venv
--- @param opts table|nil Options {cmd, title, win, env}
function M.open_simple(opts)
  opts = opts or {}
  local config = require("yoda.terminal.config")
  
  local shell = opts.cmd or { M.get_default(), "-i" }
  local title = opts.title or " Terminal "
  
  local term_config = config.make_config(shell, title, opts)
  
  -- Try snacks terminal (preferred)
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.terminal then
    snacks.terminal.open(term_config.cmd, term_config)
  else
    -- Fallback to native terminal
    local notify = require("yoda.utils").notify
    notify("Using native terminal (snacks not available)", "info")
    vim.cmd("terminal " .. table.concat(term_config.cmd, " "))
  end
end

return M

