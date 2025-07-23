-- lua/yoda/core/functions.lua
-- Utility functions for Neovim configuration

local M = {}

---
--- Scans all directories in the project root for Python virtual environments.
--
-- A directory is considered a virtual environment if it contains either:
--   - bin/activate (Unix/macOS)
--   - Scripts/activate (Windows)
--
-- @return table A list of absolute paths to detected virtual environment directories.
--               Returns an empty table if none are found.
M.find_virtual_envs = function()
  local cwd = vim.fn.getcwd()
  local entries = vim.fn.readdir(cwd)
  local venvs = {}

  for _, entry in ipairs(entries) do
    local dir_path = cwd .. "/" .. entry
    if vim.fn.isdirectory(dir_path) == 1 then
      local unix_activate = dir_path .. "/bin/activate"
      local win_activate = dir_path .. "/Scripts/activate"
      if vim.fn.filereadable(unix_activate) == 1 or vim.fn.filereadable(win_activate) == 1 then
        table.insert(venvs, dir_path)
      end
    end
  end

  return venvs
end

---
--- Prompts the user to select a Python virtual environment from those detected in the project root.
--
-- Calls find_virtual_envs() to scan for venvs. If none are found, notifies the user and returns nil.
-- If one is found, returns its path. If multiple are found, shows a Snacks picker and returns the selected path.
--
-- @param callback function A function to call with the selected venv path (or nil if none selected).
M.select_virtual_env = function(callback)
  local venvs = M.find_virtual_envs()
  if #venvs == 0 then
    local ok, noice = pcall(require, "noice")
    if ok and noice and noice.notify then
      noice.notify("No Python virtual environments found in project root.", "warn", { title = "Virtualenv" })
    else
      vim.notify("No Python virtual environments found in project root.", vim.log.levels.WARN, { title = "Virtualenv" })
    end
    callback(nil)
  elseif #venvs == 1 then
    callback(venvs[1])
  else
    local ok, picker = pcall(require, "snacks.picker")
    if not ok then
      vim.notify("snacks.picker not available", vim.log.levels.ERROR)
      callback(nil)
      return
    end
    picker.select(venvs, { prompt = "Select a Python virtual environment:" }, function(choice)
      callback(choice)
    end)
  end
end

---
--- Returns a table of window options for snacks.terminal, with a custom title.
-- @param title string The title to display at the top of the terminal window.
-- @return table The window options table.
M.make_terminal_win_opts = function(title)
  return {
    relative = "editor",
    position = "float",
    width = 0.9,
    height = 0.85,
    border = "rounded",
    title = title,
    title_pos = "center",
  }
end

local function open_shell_with_venv(shell, venv_activate, shell_type, win_title)
  local tmpdir, rcfile, env, args
  if shell_type == "bash" then
    rcfile = vim.fn.tempname()
    local f = io.open(rcfile, "w")
    f:write("source " .. venv_activate .. "\nexec bash -i\n")
    f:close()
    args = { shell, "--rcfile", rcfile, "-i" }
    env = nil
  elseif shell_type == "zsh" then
    tmpdir = vim.fn.tempname()
    vim.fn.mkdir(tmpdir)
    rcfile = tmpdir .. "/.zshrc"
    local f = io.open(rcfile, "w")
    f:write("source " .. venv_activate .. "\n")
    f:write("[ -f ~/.zshrc ] && source ~/.zshrc\n")
    f:close()
    args = { shell }
    env = { ZDOTDIR = tmpdir }
  else
    args = { shell, "-i" }
    env = nil
  end
  require("snacks.terminal").open(args, {
    env = env,
    win = M.make_terminal_win_opts(win_title),
    start_insert = true,
    auto_insert = true,
  })
end

M.open_floating_terminal = function()
  M.select_virtual_env(function(venv)
    local snacks_terminal = require("snacks.terminal")
    local shell = os.getenv("SHELL") or vim.o.shell
    if venv then
      local venv_activate = M.get_activate_script_path(venv)
      if venv_activate then
        if shell:match("bash") then
          open_shell_with_venv(shell, venv_activate, "bash", "Bash Python Environment")
        elseif shell:match("zsh") then
          open_shell_with_venv(shell, venv_activate, "zsh", "Zshell Python Environment")
        else
          -- fallback: just open the shell interactively if possible
          -- this should never happen
          snacks_terminal.open({ shell, "-i" }, {
            win = M.make_terminal_win_opts(" Simple Terminal Fallback "),
            start_insert = true,
            auto_insert = true,
          })
        end
        return
      end
      print("No activate script found for " .. venv)
    end
    -- Open simple terminal (interactive if possible)
    if shell:match("bash") or shell:match("zsh") then
      snacks_terminal.open({ shell, "-i" }, {
        win = M.make_terminal_win_opts(" Simple Terminal "),
        start_insert = true,
        auto_insert = true,
      })
    else
      snacks_terminal.open({ shell }, {
        win = M.make_terminal_win_opts(" Simple Terminal "),
        start_insert = true,
        auto_insert = true,
      })
    end
  end)
end

---
--- Returns the path to the activate script for a given Python virtual environment directory.
-- Handles both Unix (bin/activate) and Windows (Scripts/activate) conventions.
-- @param venv_path string The absolute path to the virtual environment directory.
-- @return string|nil The path to the activate script, or nil if not found.
M.get_activate_script_path = function(venv_path)
  local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
  local activate_path
  if is_windows then
    activate_path = venv_path .. "/Scripts/activate"
  else
    activate_path = venv_path .. "/bin/activate"
  end
  if vim.fn.filereadable(activate_path) == 1 then
    return activate_path
  end
  return nil
end

return M


