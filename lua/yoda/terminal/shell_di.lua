-- lua/yoda/terminal/shell_di.lua
-- Shell detection and management with Dependency Injection

local M = {}

local SHELL_TYPES = {
  BASH = "bash",
  ZSH = "zsh",
}

--- Create shell manager instance with dependencies
--- @param deps table|nil Optional {config, notify}
--- @return table Shell manager instance
function M.new(deps)
  deps = deps or {}

  local instance = {}

  --- Determine shell type from shell path
  --- @param shell string Shell executable path
  --- @return string|nil Shell type (bash/zsh) or nil for unknown
  function instance.get_type(shell)
    if shell:match(SHELL_TYPES.BASH) then
      return SHELL_TYPES.BASH
    elseif shell:match(SHELL_TYPES.ZSH) then
      return SHELL_TYPES.ZSH
    end
    return nil
  end

  --- Get default shell
  --- @return string Shell path
  function instance.get_default()
    return os.getenv("SHELL") or vim.o.shell
  end

  --- Open simple terminal without venv
  --- @param opts table|nil Options {cmd, title, win, env}
  function instance.open_simple(opts)
    opts = opts or {}

    -- Use injected config or fallback
    local config = deps.config or require("yoda.terminal.config")
    local notify = deps.notify or function(msg, level)
      vim.notify(msg, level or vim.log.levels.INFO)
    end

    local cmd = opts.cmd or { instance.get_default(), "-i" }
    local title = opts.title or " Terminal "

    -- Try snacks terminal (preferred)
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.terminal then
      local term_opts = {
        win = config.make_win_opts(title, opts.win or {}),
      }
      snacks.terminal.open(cmd, term_opts)
    else
      -- Fallback to native terminal
      notify("Using native terminal (snacks not available)", vim.log.levels.INFO)
      vim.cmd("terminal " .. table.concat(cmd, " "))
    end
  end

  return instance
end

return M
