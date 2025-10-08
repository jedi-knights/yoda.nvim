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

-- ============================================================================
-- TEST PICKER FUNCTIONALITY
-- ============================================================================

--- Test picker for environment and region selection
--- @param callback function
M.test_picker = function(callback)
  local Path = require("plenary.path")
  local json = vim.json

  -- Pre-load the picker module to avoid delay during selection
  local picker = require("snacks.picker")

  local log_path = "output.log"
  local cache_file = vim.fn.stdpath("cache") .. "/yoda_testpicker_marker.json"

  local function parse_json_config(path)
    local ok, content = pcall(Path.new(path).read, Path.new(path))
    if not ok then
      return nil
    end
    local ok_json, parsed = pcall(json.decode, content)
    if not ok_json then
      return nil
    end
    return parsed
  end

  local function load_env_region()
    local fallback = {
      environments = { "qa", "prod" },
      regions = { "auto", "use1", "usw2", "euw1", "apse1" },
    }

    local file_path = "environments.json"
    if vim.fn.filereadable(file_path) ~= 1 then
      return fallback
    end

    local config = parse_json_config(file_path)
    return config or fallback
  end

  local function load_marker()
    local config = parse_json_config(cache_file)
    return config or { environment = "qa", region = "auto" }
  end

  local function save_marker(env, region)
    local config = { environment = env, region = region }
    local ok = pcall(function()
      Path.new(cache_file):write(vim.json.encode(config), "w")
    end)
    if not ok then
      vim.notify("Failed to save test picker marker", vim.log.levels.WARN)
    end
  end

  local env_region = load_env_region()
  local marker = load_marker()

  -- Create picker items
  local items = {}
  for _, env in ipairs(env_region.environments) do
    for _, region in ipairs(env_region.regions) do
      local label = env .. " (" .. region .. ")"
      local is_selected = env == marker.environment and region == marker.region
      table.insert(items, {
        label = label,
        value = { environment = env, region = region },
        selected = is_selected,
      })
    end
  end

  -- Show picker
  picker.show({
    title = "Select Test Environment",
    items = items,
    on_select = function(item)
      save_marker(item.value.environment, item.value.region)
      callback(item.value)
    end,
  })
end

-- ============================================================================
-- DIAGNOSTIC UTILITIES
-- ============================================================================

--- Check if LSP servers are running
--- @return boolean
M.check_lsp_status = function()
  local clients = vim.lsp.get_active_clients()
  if #clients == 0 then
    vim.notify("❌ No LSP clients are currently active", vim.log.levels.WARN)
    return false
  else
    vim.notify("✅ Active LSP clients:", vim.log.levels.INFO)
    for _, client in ipairs(clients) do
      vim.notify("  - " .. client.name, vim.log.levels.INFO)
    end
    return true
  end
end

--- Check AI integration status
--- @return boolean
M.check_ai_status = function()
  local ok, utils = pcall(require, "yoda.lib.utils")
  if not ok then
    vim.notify("❌ Yoda utils not available", vim.log.levels.ERROR)
    return false
  end

  local claude_available = utils.is_claude_available()
  if claude_available then
    local version, err = utils.get_claude_version()
    if version then
      vim.notify("✅ Claude CLI " .. version .. " available", vim.log.levels.INFO)
    else
      vim.notify("⚠️ Claude CLI available but version check failed: " .. (err or "unknown"), vim.log.levels.WARN)
    end
  else
    vim.notify("❌ Claude CLI not available", vim.log.levels.WARN)
  end

  return claude_available
end

--- Run comprehensive diagnostics
M.run_diagnostics = function()
  vim.notify("🔍 Running Yoda diagnostics...", vim.log.levels.INFO)

  -- Check LSP status
  M.check_lsp_status()

  -- Check AI status
  M.check_ai_status()

  -- Check plugin health
  vim.cmd("checkhealth")
end

return M
