-- lua/yoda/terminal/config_di.lua
-- Terminal window configuration with Dependency Injection

local M = {}

local DEFAULTS = {
  WIDTH = 0.9,
  HEIGHT = 0.85,
  BORDER = "rounded",
  TITLE_POS = "center",
  START_INSERT = true,
  AUTO_INSERT = true,
}

--- Create terminal config instance with dependencies
--- @param deps table|nil Optional {notify}
--- @return table Config instance
function M.new(deps)
  deps = deps or {}
  local instance = {}

  --- Make window options for terminal
  --- @param title string Window title
  --- @param overrides table|nil Optional overrides
  --- @return table Window options
  function instance.make_win_opts(title, overrides)
    if not title or type(title) ~= "string" then
      if deps.notify then
        deps.notify("Terminal title must be a string, using default", vim.log.levels.WARN)
      end
      title = " Terminal "
    end

    overrides = overrides or {}

    return {
      width = overrides.width or DEFAULTS.WIDTH,
      height = overrides.height or DEFAULTS.HEIGHT,
      border = overrides.border or DEFAULTS.BORDER,
      title = title,
      title_pos = overrides.title_pos or DEFAULTS.TITLE_POS,
    }
  end

  --- Make complete terminal configuration
  --- @param cmd table Command array
  --- @param title string Terminal title
  --- @param opts table|nil Optional {win, env, start_insert, auto_insert, on_exit, on_open}
  --- @return table Complete terminal config
  function instance.make_config(cmd, title, opts)
    if type(cmd) ~= "table" then
      cmd = { vim.o.shell }
    end

    opts = opts or {}

    return {
      cmd = cmd,
      win = instance.make_win_opts(title, opts.win),
      env = opts.env,
      start_insert = opts.start_insert ~= false and DEFAULTS.START_INSERT,
      auto_insert = opts.auto_insert ~= false and DEFAULTS.AUTO_INSERT,
      on_exit = opts.on_exit,
      on_open = opts.on_open or function(term)
        vim.cmd("startinsert")
      end,
    }
  end

  return instance
end

return M
