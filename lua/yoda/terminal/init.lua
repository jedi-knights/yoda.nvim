-- lua/yoda/terminal/init.lua
-- Terminal module public API
-- Provides clean interface for terminal operations with proper SRP

local M = {}

-- ============================================================================
-- Submodule Exports
-- ============================================================================

M.config = require("yoda.terminal.config")
M.shell = require("yoda.terminal.shell")
M.venv = require("yoda.terminal.venv")
M.builder = require("yoda.terminal.builder")

-- ============================================================================
-- Public API
-- ============================================================================

--- Open floating terminal with optional virtual environment
--- @param opts table|nil Options {venv_path, title, cmd, win, env, auto_detect}
function M.open_floating(opts)
  opts = opts or {}
  local notify = require("yoda.utils").notify

  -- If venv_path provided, use it directly
  if opts.venv_path then
    local activate_script = M.venv.get_activate_script_path(opts.venv_path)
    if activate_script then
      -- Get default shell
      local shell = M.shell.get_default()
      local shell_type = M.shell.get_type(shell)

      -- Instead of using env parameter, source the activate script in the shell command
      -- This is more reliable with snacks.terminal
      local cmd
      if shell_type == "bash" or shell_type == "zsh" then
        cmd = { shell, "-i", "-c", string.format("source '%s' && exec %s -i", activate_script, shell) }
      else
        -- Fallback: just open shell in venv directory
        cmd = { shell, "-i" }
      end

      opts.cmd = cmd
      opts.title = opts.title or string.format(" Terminal (venv: %s) ", vim.fn.fnamemodify(opts.venv_path, ":t"))

      notify("Activating venv: " .. opts.venv_path, "info")
      M.shell.open_simple(opts)
    else
      notify("No activate script found for: " .. opts.venv_path, "warn")
      M.shell.open_simple(opts)
    end
    return
  end

  -- Auto-detect .venv in current directory
  local cwd = vim.fn.getcwd()
  local default_venv = cwd .. "/.venv"
  local io = require("yoda.core.io")

  if io.is_dir(default_venv) and M.venv.get_activate_script_path(default_venv) then
    opts.venv_path = default_venv
    M.open_floating(opts)
    return
  end

  -- No .venv found, check for other venvs and prompt user
  M.venv.select_virtual_env(function(venv)
    if venv then
      opts.venv_path = venv
      M.open_floating(opts)
    else
      -- No venv selected, open simple terminal
      M.shell.open_simple(opts)
    end
  end)
end

--- Open simple terminal without venv detection
--- @param opts table|nil Options {title, cmd, win, env}
function M.open_simple(opts)
  M.shell.open_simple(opts)
end

-- Convenience exports
M.find_virtual_envs = M.venv.find_virtual_envs
M.get_activate_script_path = M.venv.get_activate_script_path
M.make_terminal_win_opts = M.config.make_win_opts

return M
