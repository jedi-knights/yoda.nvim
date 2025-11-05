-- lua/yoda/terminal/builder.lua
-- Builder pattern for terminal configuration
-- Provides fluent interface for creating complex terminal configurations

local M = {}

--- Create new terminal builder instance
--- @return table Builder instance with fluent interface
function M:new()
  local instance = {
    _cmd = nil,
    _title = " Terminal ",
    _win = {},
    _env = nil,
    _start_insert = true,
    _auto_insert = true,
    _on_exit = nil,
    _on_open = nil,
  }
  setmetatable(instance, { __index = M })
  return instance
end

--- Set command to execute
--- @param cmd table|string Command array or single command
--- @return table Self for chaining
function M:with_command(cmd)
  if type(cmd) == "string" then
    self._cmd = { cmd }
  elseif type(cmd) == "table" then
    self._cmd = cmd
  else
    error("Command must be string or table")
  end
  return self
end

--- Set terminal title
--- @param title string Window title
--- @return table Self for chaining
function M:with_title(title)
  assert(type(title) == "string", "Title must be a string")
  self._title = title
  return self
end

--- Set window options
--- @param win_opts table Window options {width, height, border, title_pos}
--- @return table Self for chaining
function M:with_window(win_opts)
  assert(type(win_opts) == "table", "Window options must be a table")
  self._win = win_opts
  return self
end

--- Set environment variables
--- @param env table Environment variables
--- @return table Self for chaining
function M:with_env(env)
  assert(type(env) == "table", "Environment must be a table")
  self._env = env
  return self
end

--- Enable or disable auto-insert mode
--- @param enabled boolean Auto-insert enabled
--- @return table Self for chaining
function M:auto_insert(enabled)
  self._auto_insert = enabled
  return self
end

--- Enable or disable start-insert mode
--- @param enabled boolean Start-insert enabled
--- @return table Self for chaining
function M:start_insert(enabled)
  self._start_insert = enabled
  return self
end

--- Set on_exit callback
--- @param callback function Callback when terminal exits
--- @return table Self for chaining
function M:on_exit(callback)
  assert(type(callback) == "function", "on_exit must be a function")
  self._on_exit = callback
  return self
end

--- Set on_open callback
--- @param callback function Callback when terminal opens
--- @return table Self for chaining
function M:on_open(callback)
  assert(type(callback) == "function", "on_open must be a function")
  self._on_open = callback
  return self
end

--- Build terminal configuration
--- @return table Terminal configuration ready for snacks.terminal
function M:build()
  local config = require("yoda.terminal.config")

  -- Use default shell if no command specified
  local cmd = self._cmd
  if not cmd then
    local shell = require("yoda.terminal.shell")
    cmd = { shell.get_default(), "-i" }
  end

  return config.make_config(cmd, self._title, {
    win = self._win,
    env = self._env,
    start_insert = self._start_insert,
    auto_insert = self._auto_insert,
    on_exit = self._on_exit,
    on_open = self._on_open,
  })
end

--- Convenience method: build and open terminal
--- @return nil
function M:open()
  local config = require("yoda.terminal.config")

  -- Use default shell if no command specified
  local cmd = self._cmd
  if not cmd then
    local shell = require("yoda.terminal.shell")
    cmd = { shell.get_default(), "-i" }
  end

  -- Try snacks terminal (preferred)
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.terminal then
    local term_opts = {
      win = config.make_win_opts(self._title, self._win),
    }
    snacks.terminal.open(cmd, term_opts)
  else
    -- Fallback to native terminal
    vim.cmd("terminal " .. table.concat(cmd, " "))
  end
end

return M
