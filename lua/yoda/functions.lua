-- lua/yoda/core/functions.lua
-- Utility functions for Neovim configuration

local M = {}

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
    open_allure = false
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
  level = level or vim.log.levels.INFO
  vim.notify(message, level, { title = "Terminal Debug" })
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
  local rcfile_content = "source " .. venv_activate .. "\nexec bash -i\n"
  local rcfile = create_temp_file(rcfile_content)
  if not rcfile then
    return nil
  end
  
  return {
    args = { os.getenv("SHELL") or vim.o.shell, "--rcfile", rcfile, "-i" },
    env = nil
  }
end

--- Create zsh configuration for virtual environment
--- @param venv_activate string Virtual environment activation script path
--- @return table|nil Shell arguments and environment, or nil on failure
local function create_zsh_config(venv_activate)
  local tmpdir = create_temp_directory()
  if not tmpdir then
    return nil
  end
  
  local rcfile = tmpdir .. "/.zshrc"
  local rcfile_content = "source " .. venv_activate .. "\n[ -f ~/.zshrc ] && source ~/.zshrc\n"
  local file = io.open(rcfile, "w")
  if not file then
    debug_log("Failed to create temporary zsh rcfile: " .. rcfile, vim.log.levels.ERROR)
    return nil
  end
  file:write(rcfile_content)
  file:close()
  
  return {
    args = { os.getenv("SHELL") or vim.o.shell },
    env = { ZDOTDIR = tmpdir }
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
  
  local terminal_config = create_terminal_config(config.args, win_title)
  terminal_config.env = config.env
  
  require("snacks.terminal").open(terminal_config.cmd, terminal_config)
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
    snacks_terminal.open({ shell, "-i" }, create_terminal_config({ shell, "-i" }, " Simple Terminal Fallback "))
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
    snacks_terminal.open({ shell, "-i" }, create_terminal_config({ shell, "-i" }, " Simple Terminal "))
  else
    snacks_terminal.open({ shell }, create_terminal_config({ shell }, " Simple Terminal "))
  end
end

M.open_floating_terminal = function()
  M.select_virtual_env(function(venv)
    local shell = os.getenv("SHELL") or vim.o.shell
    debug_log("Using shell: " .. shell)
    
    if venv then
      if not open_terminal_with_venv(shell, venv) then
        open_simple_terminal(shell)
      end
    else
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
    timestamp = os.time()
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
          type = "environment"
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
          type = "environment"
        }
      end
    end
  end
  
  return items, lookup
end

--- Load markers with fallback to defaults
--- @return table Available markers
local function load_markers()
  local config_loader = require("yoda.config_loader")
  local markers = config_loader.load_pytest_markers("pytest.ini")
  return markers or {
    "bdd",           -- Default BDD tests
    "unit",          -- Unit tests
    "functional",    -- Functional tests
    "smoke",         -- Smoke tests
    "critical",      -- Critical path tests
    "performance",   -- Performance tests
    "regression",    -- Regression tests
    "integration",   -- Integration tests
  }
end

--- Test picker for environment, region, markers, and Allure selection
--- @param callback function
M.test_picker = function(callback)
  local picker = require("snacks.picker")
  
  local env_region = load_env_region_config()
  local cached = load_cached_marker()
  local items, lookup = generate_picker_items(env_region, cached)

  -- Step 1: Select environment (with cached default)
  local default_env = cached.environment
  picker.select(items, {
    prompt = "Select Environment",
    default = default_env,
  }, function(selected_env)
    if not selected_env then
      callback(nil)
      return
    end
    
    local env_data = lookup[selected_env]
    if not env_data or not env_data.regions then
      callback(nil)
      return
    end
    
    -- Step 2: Select region for the chosen environment (with cached default)
    local default_region = (selected_env == cached.environment) and cached.region or nil
    picker.select(env_data.regions, {
      prompt = "Select Region for " .. selected_env,
      default = default_region,
    }, function(selected_region)
      if not selected_region then
        callback(nil)
        return
      end
      
      -- Step 3: Select markers (with cached default)
      local markers = load_markers()
      local default_marker = cached.markers
      picker.select(markers, {
        prompt = "Select Test Markers",
        default = default_marker,
      }, function(selected_markers)
        if not selected_markers then
          callback(nil)
          return
        end
        
        -- Step 4: Select Allure preference (with cached default)
        local allure_options = {
          "Yes, open Allure report",
          "No, skip Allure report"
        }
        local default_allure = cached.open_allure and "Yes, open Allure report" or "No, skip Allure report"
        picker.select(allure_options, {
          prompt = "Generate Allure Report?",
          default = default_allure,
        }, function(allure_choice)
          if allure_choice == nil then
            callback(nil)
            return
          end
          
          local open_allure = allure_choice == "Yes, open Allure report"
          
          -- Save complete selection to cache
          save_cached_marker(selected_env, selected_region, selected_markers, open_allure)
          callback({
            environment = selected_env,
            region = selected_region,
            markers = selected_markers,
            open_allure = open_allure
          })
        end)
      end)
    end)
  end)
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
