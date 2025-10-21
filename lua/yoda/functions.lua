-- lua/yoda/functions.lua
-- DEPRECATED: This module is being refactored for better SOLID compliance
-- New code should use the focused modules instead:
--   - require("yoda.terminal") for terminal operations
--   - require("yoda.diagnostics") for LSP/AI diagnostics
--   - require("yoda.testing") for test operations (coming soon)
--
-- This file maintains backwards compatibility but will show deprecation warnings

local M = {}

-- ============================================================================
-- DEPRECATION WARNING
-- ============================================================================

local shown_warnings = {}

local function show_deprecation_warning(old_function, new_module)
  if not shown_warnings[old_function] then
    vim.notify(
      string.format("DEPRECATED: yoda.functions.%s() - Use %s instead", old_function, new_module),
      vim.log.levels.WARN,
      { title = "Yoda Deprecation Warning" }
    )
    shown_warnings[old_function] = true
  end
end

-- ============================================================================
-- Constants
-- ============================================================================

local TERMINAL_CONFIG = {
  WIDTH = 0.9,
  HEIGHT = 0.85,
  BORDER = "rounded",
  TITLE_POS = "center",
}

local SHELL_TYPES = {
  BASH = "bash",
  ZSH = "zsh",
}

local ACTIVATE_PATHS = {
  UNIX = "/bin/activate",
  WINDOWS = "/Scripts/activate",
}

local FILE_PATHS = {
  ENVIRONMENTS_JSON = "environments.json",
  OUTPUT_LOG = "output.log",
  TESTPICKER_CACHE = "/yoda_testpicker_marker.json",
}

local FALLBACK_CONFIG = {
  -- Nested structure matching YAML parser output
  ENVIRONMENTS = {
    qa = { "auto", "use1" },
    fastly = { "auto" },
    prod = { "auto", "use1", "usw2", "euw1", "apse1" },
  },
  MARKER = {
    environment = "qa",
    region = "auto",
    markers = "bdd",
    open_allure = false,
  },
}

-- ============================================================================
-- Helper Functions
-- ============================================================================

--- Create terminal configuration with modifiable buffer setup
--- @param shell_cmd table Shell command and arguments
--- @param title string Terminal window title
--- @return table Terminal configuration
local function create_terminal_config(shell_cmd, title)
  return {
    cmd = shell_cmd,
    win = M.make_terminal_win_opts(title),
    start_insert = true,
    auto_insert = true,
    on_open = function(term)
      vim.opt_local.modifiable = true
      vim.opt_local.readonly = false
    end,
  }
end

--- Determine shell type from shell path
--- @param shell string Shell executable path
--- @return string|nil Shell type (bash/zsh) or nil for unknown
local function get_shell_type(shell)
  if shell:match(SHELL_TYPES.BASH) then
    return SHELL_TYPES.BASH
  elseif shell:match(SHELL_TYPES.ZSH) then
    return SHELL_TYPES.ZSH
  end
  return nil
end

--- Log debug message with consistent format
--- @param message string Debug message
--- @param level string Log level (default: INFO)
local function debug_log(message, level)
  -- Only show ERROR and WARN levels by default
  -- Set DEBUG_TERMINAL=true in your environment to see all debug messages
  local debug_enabled = os.getenv("DEBUG_TERMINAL") == "true"
  level = level or vim.log.levels.INFO

  if debug_enabled or level >= vim.log.levels.WARN then
    vim.notify(message, level, { title = "Terminal Debug" })
  end
end

--- Check if system is Windows
--- @return boolean True if Windows
local function is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

--- Get activate script path for virtual environment
--- @param venv_path string Virtual environment directory path
--- @return string Activate script path
local function get_activate_script_path(venv_path)
  local activate_subpath = is_windows() and ACTIVATE_PATHS.WINDOWS or ACTIVATE_PATHS.UNIX
  return venv_path .. activate_subpath
end

--- Create temporary file safely
--- @param content string File content
--- @return string|nil Temporary file path or nil on failure
local function create_temp_file(content)
  local temp_path = vim.fn.tempname()
  local file = io.open(temp_path, "w")
  if not file then
    debug_log("Failed to create temporary file: " .. temp_path, vim.log.levels.ERROR)
    return nil
  end
  file:write(content)
  file:close()
  return temp_path
end

--- Create temporary directory safely
--- @return string|nil Temporary directory path or nil on failure
local function create_temp_directory()
  local temp_path = vim.fn.tempname()
  local success = vim.fn.mkdir(temp_path)
  if success ~= 1 then
    debug_log("Failed to create temporary directory: " .. temp_path, vim.log.levels.ERROR)
    return nil
  end
  return temp_path
end

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

  debug_log("Scanning directory: " .. cwd)
  debug_log("Directory entries: " .. vim.inspect(entries))

  -- Common virtual environment directory names
  local venv_names = { ".venv", "venv", "env", ".env", "virtualenv" }

  -- First, check for .venv specifically (most common)
  local venv_path = cwd .. "/.venv"
  if vim.fn.isdirectory(venv_path) == 1 then
    local activate_path = venv_path .. "/bin/activate"
    debug_log("Checking .venv specifically: " .. venv_path)
    debug_log("Activate script exists: " .. tostring(vim.fn.filereadable(activate_path) == 1))
    if vim.fn.filereadable(activate_path) == 1 then
      debug_log("Added .venv: " .. venv_path)
      table.insert(venvs, venv_path)
    end
  end

  -- Then check other entries
  for _, entry in ipairs(entries) do
    local dir_path = cwd .. "/" .. entry

    -- Skip .venv since we already checked it
    if entry ~= ".venv" and vim.fn.isdirectory(dir_path) == 1 then
      debug_log("Checking directory: " .. entry)
      local is_venv_dir = false

      -- Check if it matches common venv directory names
      for _, venv_name in ipairs(venv_names) do
        if entry == venv_name then
          debug_log("Found venv directory by name: " .. entry)
          is_venv_dir = true
          break
        end
      end

      -- If it matches venv name or has activate script, add it
      if is_venv_dir then
        local unix_activate = dir_path .. "/bin/activate"
        local win_activate = dir_path .. "/Scripts/activate"
        debug_log("Checking activate scripts for " .. entry .. ": " .. unix_activate .. " or " .. win_activate)
        if vim.fn.filereadable(unix_activate) == 1 or vim.fn.filereadable(win_activate) == 1 then
          debug_log("Added venv by name: " .. dir_path)
          table.insert(venvs, dir_path)
        end
      else
        -- Check for activate script even if name doesn't match
        local unix_activate = dir_path .. "/bin/activate"
        local win_activate = dir_path .. "/Scripts/activate"
        if vim.fn.filereadable(unix_activate) == 1 or vim.fn.filereadable(win_activate) == 1 then
          debug_log("Added venv by activate script: " .. dir_path)
          table.insert(venvs, dir_path)
        end
      end
    end
  end

  debug_log("Final venv list: " .. vim.inspect(venvs))
  return venvs
end

---
--- Finds the correct Python interpreter for a virtual environment.
--- Checks pyvenv.cfg to determine the correct Python version and returns the appropriate interpreter path.
--
-- @param venv_path string The path to the virtual environment directory.
-- @return string|nil The path to the correct Python interpreter, or nil if not found.
M.find_python_interpreter = function(venv_path)
  local pyvenv_cfg_path = venv_path .. "/pyvenv.cfg"

  if vim.fn.filereadable(pyvenv_cfg_path) ~= 1 then
    debug_log("pyvenv.cfg not found at: " .. pyvenv_cfg_path)
    return venv_path .. "/bin/python"
  end

  -- Read pyvenv.cfg to get the Python version
  local file = io.open(pyvenv_cfg_path, "r")
  if not file then
    debug_log("Failed to read pyvenv.cfg: " .. pyvenv_cfg_path)
    return venv_path .. "/bin/python"
  end

  local content = file:read("*all")
  file:close()

  -- Extract version from pyvenv.cfg
  local version = content:match("version%s*=%s*(%d+%.%d+%.%d+)")
  if version then
    debug_log("Found Python version in pyvenv.cfg: " .. version)
    local major_minor = version:match("(%d+%.%d+)")
    if major_minor then
      local python_interpreter = venv_path .. "/bin/python" .. major_minor
      if vim.fn.filereadable(python_interpreter) == 1 then
        debug_log("Using Python interpreter: " .. python_interpreter)
        return python_interpreter
      end
    end
  end

  -- Fallback to default python
  debug_log("Using fallback Python interpreter: " .. venv_path .. "/bin/python")
  return venv_path .. "/bin/python"
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
  debug_log("Found " .. #venvs .. " virtual environments: " .. vim.inspect(venvs))

  if #venvs == 0 then
    local ok, noice = pcall(require, "noice")
    if ok and noice and noice.notify then
      noice.notify("No Python virtual environments found in project root.", "warn", { title = "Virtualenv" })
    else
      vim.notify("No Python virtual environments found in project root.", vim.log.levels.WARN, { title = "Virtualenv" })
    end
    callback(nil)
  elseif #venvs == 1 then
    debug_log("Using single virtual environment: " .. venvs[1])
    callback(venvs[1])
  else
    local ok, picker = pcall(require, "snacks.picker")
    if not ok then
      vim.notify("snacks.picker not available", vim.log.levels.ERROR)
      callback(nil)
      return
    end
    debug_log("Multiple virtual environments found, showing picker")
    picker.select(venvs, { prompt = "Select a Python virtual environment:" }, function(choice)
      debug_log("Selected virtual environment: " .. (choice or "none"))
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
    width = TERMINAL_CONFIG.WIDTH,
    height = TERMINAL_CONFIG.HEIGHT,
    border = TERMINAL_CONFIG.BORDER,
    title = title,
    title_pos = TERMINAL_CONFIG.TITLE_POS,
  }
end

--- Create bash configuration for virtual environment
--- @param venv_activate string Virtual environment activation script path
--- @return table|nil Shell arguments and environment, or nil on failure
local function create_bash_config(venv_activate)
  debug_log("Creating bash config for venv: " .. venv_activate)

  -- Read the activate script to extract environment variables
  local venv_dir = venv_activate:match("(.*)/bin/activate")
  local python_path = venv_dir .. "/bin/python"
  local venv_bin = venv_dir .. "/bin"

  debug_log("Venv directory: " .. venv_dir)
  debug_log("Python path: " .. python_path)
  debug_log("Venv bin: " .. venv_bin)

  return {
    args = { "bash", "-i" },
    env = {
      VIRTUAL_ENV = venv_dir,
      PATH = venv_bin .. ":" .. os.getenv("PATH"),
      PYTHONPATH = venv_dir .. "/lib/python*/site-packages",
    },
  }
end

--- Create zsh configuration for virtual environment
--- @param venv_activate string Virtual environment activation script path
--- @return table|nil Shell arguments and environment, or nil on failure
local function create_zsh_config(venv_activate)
  debug_log("Creating zsh config for venv: " .. venv_activate)

  -- Read the activate script to extract environment variables
  local venv_dir = venv_activate:match("(.*)/bin/activate")
  local python_path = venv_dir .. "/bin/python"
  local venv_bin = venv_dir .. "/bin"

  debug_log("Venv directory: " .. venv_dir)
  debug_log("Python path: " .. python_path)
  debug_log("Venv bin: " .. venv_bin)

  return {
    args = { "zsh", "-i" },
    env = {
      VIRTUAL_ENV = venv_dir,
      PATH = venv_bin .. ":" .. os.getenv("PATH"),
      PYTHONPATH = venv_dir .. "/lib/python*/site-packages",
    },
  }
end

--- Open shell with virtual environment activation
--- @param shell string Shell executable path
--- @param venv_activate string Virtual environment activation script path
--- @param shell_type string Shell type (bash/zsh)
--- @param win_title string Terminal window title
local function open_shell_with_venv(shell, venv_activate, shell_type, win_title)
  debug_log("Opening " .. shell_type .. " with venv: " .. venv_activate)

  local config
  if shell_type == SHELL_TYPES.BASH then
    config = create_bash_config(venv_activate)
  elseif shell_type == SHELL_TYPES.ZSH then
    config = create_zsh_config(venv_activate)
  else
    config = { args = { shell, "-i" }, env = nil }
  end

  if not config then
    debug_log("Failed to create shell configuration", vim.log.levels.ERROR)
    return
  end

  debug_log("Executing: " .. table.concat(config.args, " "))
  debug_log("Terminal title: " .. win_title)

  local terminal_config = create_terminal_config(config.args, win_title)
  terminal_config.env = config.env

  debug_log("Terminal config: " .. vim.inspect(terminal_config))

  local snacks_terminal = require("snacks.terminal")
  snacks_terminal.open(terminal_config.cmd, {
    cmd = terminal_config.cmd,
    win = terminal_config.win,
    env = terminal_config.env,
    start_insert = terminal_config.start_insert,
    auto_insert = terminal_config.auto_insert,
    on_open = terminal_config.on_open,
  })
end

--- Open terminal with virtual environment
--- @param shell string Shell executable path
--- @param venv string Virtual environment path
--- @return boolean Success status
local function open_terminal_with_venv(shell, venv)
  local venv_activate = M.get_activate_script_path(venv)
  if not venv_activate then
    debug_log("No activate script found for " .. venv, vim.log.levels.WARN)
    return false
  end

  debug_log("Using venv: " .. venv .. " with activate script: " .. venv_activate)

  local shell_type = get_shell_type(shell)
  if shell_type then
    local title = shell_type == SHELL_TYPES.BASH and "Bash Python Environment" or "Zshell Python Environment"
    open_shell_with_venv(shell, venv_activate, shell_type, title)
    return true
  else
    debug_log("Unknown shell type, using fallback: " .. shell, vim.log.levels.WARN)
    local snacks_terminal = require("snacks.terminal")
    local terminal_config = create_terminal_config({ shell, "-i" }, " Simple Terminal Fallback ")
    snacks_terminal.open(terminal_config.cmd, {
      cmd = terminal_config.cmd,
      win = terminal_config.win,
      env = terminal_config.env,
      start_insert = terminal_config.start_insert,
      auto_insert = terminal_config.auto_insert,
      on_open = terminal_config.on_open,
    })
    return true
  end
end

--- Open simple terminal without virtual environment
--- @param shell string Shell executable path
local function open_simple_terminal(shell)
  debug_log("Opening simple terminal with shell: " .. shell)

  local snacks_terminal = require("snacks.terminal")
  local shell_type = get_shell_type(shell)

  if shell_type then
    local terminal_config = create_terminal_config({ shell, "-i" }, " Simple Terminal ")
    snacks_terminal.open(terminal_config.cmd, {
      cmd = terminal_config.cmd,
      win = terminal_config.win,
      env = terminal_config.env,
      start_insert = terminal_config.start_insert,
      auto_insert = terminal_config.auto_insert,
      on_open = terminal_config.on_open,
    })
  else
    local terminal_config = create_terminal_config({ shell }, " Simple Terminal ")
    snacks_terminal.open(terminal_config.cmd, {
      cmd = terminal_config.cmd,
      win = terminal_config.win,
      env = terminal_config.env,
      start_insert = terminal_config.start_insert,
      auto_insert = terminal_config.auto_insert,
      on_open = terminal_config.on_open,
    })
  end
end

M.open_floating_terminal = function()
  M.select_virtual_env(function(venv)
    local shell = os.getenv("SHELL") or vim.o.shell
    debug_log("Using shell: " .. shell)

    if venv then
      debug_log("Found virtual environment: " .. venv)
      if not open_terminal_with_venv(shell, venv) then
        debug_log("Failed to open terminal with venv, falling back to simple terminal", vim.log.levels.WARN)
        open_simple_terminal(shell)
      end
    else
      debug_log("No virtual environment found, opening simple terminal")
      open_simple_terminal(shell)
    end
  end)
end

---
--- Returns the path to the activate script for a given Python virtual environment directory.
-- Handles both Unix (bin/activate) and Windows (Scripts/activate) conventions.
-- @param venv_path string The absolute path to the virtual environment directory.
-- @return string|nil The path to the activate script, or nil if not found.
M.get_activate_script_path = function(venv_path)
  local activate_path = get_activate_script_path(venv_path)
  if vim.fn.filereadable(activate_path) == 1 then
    return activate_path
  end
  return nil
end

-- ============================================================================
-- DEBUGGING & TESTING FUNCTIONS
-- ============================================================================

--- Test snacks.terminal directly
--- Usage: :lua require("yoda.functions").test_snacks_terminal()
M.test_snacks_terminal = function()
  local snacks_terminal = require("snacks.terminal")

  print("Testing snacks.terminal with simple command...")

  snacks_terminal.open({ "echo", "Hello from snacks terminal" }, {
    cmd = { "echo", "Hello from snacks terminal" },
    win = {
      relative = "editor",
      position = "float",
      width = 0.6,
      height = 0.4,
      border = "rounded",
      title = "Test Terminal",
      title_pos = "center",
    },
    start_insert = false,
    auto_insert = false,
    on_open = function(term)
      vim.opt_local.modifiable = true
      vim.opt_local.readonly = false
    end,
  })
end

-- ============================================================================
-- TEST PICKER FUNCTIONALITY
-- ============================================================================

--- Parse JSON configuration file
--- @param path string File path
--- @return table|nil Parsed configuration or nil on failure
local function parse_json_config(path)
  local Path = require("plenary.path")
  local json = vim.json

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

--- Load environment and region configuration
--- @return table Configuration with environments and regions
local function load_env_region_config()
  local file_path = FILE_PATHS.ENVIRONMENTS_JSON
  if vim.fn.filereadable(file_path) ~= 1 then
    return {
      environments = FALLBACK_CONFIG.ENVIRONMENTS,
    }
  end

  local config = parse_json_config(file_path)
  return config or {
    environments = FALLBACK_CONFIG.ENVIRONMENTS,
  }
end

--- Load cached marker configuration
--- @return table Cached marker configuration
local function load_cached_marker()
  local cache_file = vim.fn.stdpath("cache") .. FILE_PATHS.TESTPICKER_CACHE
  local config = parse_json_config(cache_file)
  return config or FALLBACK_CONFIG.MARKER
end

--- Save complete test picker configuration to cache
--- @param env string Environment name
--- @param region string Region name
--- @param markers string|table Selected markers
--- @param open_allure boolean Allure preference
local function save_cached_marker(env, region, markers, open_allure)
  local cache_file = vim.fn.stdpath("cache") .. FILE_PATHS.TESTPICKER_CACHE
  local config = {
    environment = env,
    region = region,
    markers = markers,
    open_allure = open_allure,
    timestamp = os.time(),
  }

  local Path = require("plenary.path")
  local ok = pcall(function()
    Path.new(cache_file):write(vim.json.encode(config), "w")
  end)

  if not ok then
    vim.notify("Failed to save test picker cache", vim.log.levels.WARN)
  end
end

--- Generate picker items from configuration
--- @param env_region table Environment and region configuration
--- @param marker table Cached marker configuration
--- @return table, table Picker items (strings) and lookup table
local function generate_picker_items(env_region, marker)
  local items = {}
  local lookup = {}

  -- Define the correct environment order (matching ingress mapping document)
  local env_order = { "qa", "fastly", "prod" }

  -- Handle nested structure (from YAML parser)
  if env_region.environments and type(env_region.environments) == "table" and env_region.environments.qa then
    -- Nested structure: {qa = {"auto", "use1"}, fastly = {"auto"}, prod = {...}}
    -- Process environments in the correct order - show only environments
    for _, env_name in ipairs(env_order) do
      local regions = env_region.environments[env_name]
      if regions then
        table.insert(items, env_name)
        lookup[env_name] = {
          environment = env_name,
          regions = regions,
          type = "environment",
        }
      end
    end
  else
    -- Flat structure: {environments = {"qa", "prod"}, regions = {"auto", "use1"}}
    -- Use the defined order for environments - show only environments
    for _, env in ipairs(env_order) do
      -- Check if this environment exists in the config
      local env_exists = false
      for _, config_env in ipairs(env_region.environments or {}) do
        if config_env == env then
          env_exists = true
          break
        end
      end

      if env_exists then
        table.insert(items, env)
        lookup[env] = {
          environment = env,
          regions = env_region.regions or {},
          type = "environment",
        }
      end
    end
  end

  return items, lookup
end

-- NOTE: Test picker functionality has been moved to pytest-atlas.nvim plugin

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
--- @deprecated Use require("yoda.diagnostics").run_all() instead
M.run_diagnostics = function()
  show_deprecation_warning("run_diagnostics", "require('yoda.diagnostics').run_all()")
  return require("yoda.diagnostics").run_all()
end

--- Check LSP status (wrapper for backwards compatibility)
--- @deprecated Use require("yoda.diagnostics.lsp").check_status() instead
M.check_lsp_status = function()
  show_deprecation_warning("check_lsp_status", "require('yoda.diagnostics.lsp').check_status()")
  return require("yoda.diagnostics.lsp").check_status()
end

--- Check AI status (wrapper for backwards compatibility)
--- @deprecated Use require("yoda.diagnostics.ai").check_status() instead
M.check_ai_status = function()
  show_deprecation_warning("check_ai_status", "require('yoda.diagnostics.ai').check_status()")
  return require("yoda.diagnostics.ai").check_status()
end

return M
