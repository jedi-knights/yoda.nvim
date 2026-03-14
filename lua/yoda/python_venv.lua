-- lua/yoda/python_venv.lua
-- Async Python virtual environment detection

local M = {}

local notify = require("yoda-adapters.notification")
local lsp_perf = require("yoda.lsp_performance")

-- Cache for venv detection results (TTL: 5 minutes)
local venv_cache = {}
local CACHE_TTL = 300000000000 -- 5 minutes in nanoseconds

--- Check if cached venv is still valid
--- @param root_dir string Project root directory
--- @return string|nil cached_venv Cached venv path or nil
local function get_cached_venv(root_dir)
  local cached = venv_cache[root_dir]
  if not cached then
    return nil
  end

  local now = vim.loop.hrtime()
  if now - cached.timestamp < CACHE_TTL then
    return cached.venv_path
  end

  -- Cache expired
  venv_cache[root_dir] = nil
  return nil
end

--- Cache venv detection result
--- @param root_dir string Project root directory
--- @param venv_path string|nil Virtual environment path
local function cache_venv(root_dir, venv_path)
  venv_cache[root_dir] = {
    venv_path = venv_path,
    timestamp = vim.loop.hrtime(),
  }
end

--- Build possible venv paths for a project
--- @param root_dir string Project root directory
--- @return table paths List of possible venv paths
local function build_venv_paths(root_dir)
  local function join_path(...)
    return table.concat({ ... }, "/")
  end

  local cwd = vim.fn.getcwd()
  return {
    join_path(root_dir, ".venv", "bin", "python"),
    join_path(root_dir, "venv", "bin", "python"),
    join_path(root_dir, "env", "bin", "python"),
    join_path(cwd, ".venv", "bin", "python"),
    join_path(cwd, "venv", "bin", "python"),
    join_path(cwd, "env", "bin", "python"),
  }
end

--- Walk a list of paths using non-blocking libuv fs_stat.
--- Invokes callback(path) with the first executable found, or callback(nil) if none.
--- vim.schedule is used for the final invocation so callers can safely call Neovim APIs.
--- @param paths table List of paths to check
--- @param idx number Current index (start at 1)
--- @param callback function Called with first executable path or nil
local function find_first_executable_async(paths, idx, callback)
  if idx > #paths then
    vim.schedule(function()
      callback(nil)
    end)
    return
  end

  vim.uv.fs_stat(paths[idx], function(err, stat)
    if not err and stat and stat.type == "file" and (stat.mode % 512 >= 64) then
      vim.schedule(function()
        callback(paths[idx])
      end)
    else
      find_first_executable_async(paths, idx + 1, callback)
    end
  end)
end

--- Detect virtual environment asynchronously
--- @param root_dir string Project root directory
--- @param callback function Callback function(venv_path or nil)
function M.detect_venv_async(root_dir, callback)
  -- Check cache first
  local cached = get_cached_venv(root_dir)
  if cached then
    vim.schedule(function()
      callback(cached)
    end)
    return
  end

  local venv_start_time = vim.loop.hrtime()
  local possible_paths = build_venv_paths(root_dir)

  find_first_executable_async(possible_paths, 1, function(venv_path)
    -- Track performance
    local found = venv_path ~= nil
    lsp_perf.track_venv_detection(root_dir, venv_start_time, found)

    -- Cache result
    cache_venv(root_dir, venv_path)

    -- Notify result
    if venv_path then
      notify.notify(string.format("Python LSP: Using venv at %s", venv_path), "info")
    else
      notify.notify("Python LSP: No venv found, using system Python", "info")
    end

    -- Execute callback
    callback(venv_path)
  end)
end

--- Apply venv to basedpyright LSP clients
--- @param root_dir string Project root directory
--- @param venv_path string Virtual environment path
function M.apply_venv_to_lsp(root_dir, venv_path)
  local clients = vim.lsp.get_clients({ name = "basedpyright" })
  for _, client in ipairs(clients) do
    if client.config.root_dir == root_dir then
      client.config.settings.basedpyright.analysis.pythonPath = venv_path
      client.config.settings.python.pythonPath = venv_path
      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
  end
end

--- Detect and apply venv for a project (main entry point)
--- @param root_dir string Project root directory
function M.detect_and_apply(root_dir)
  if not root_dir then
    return
  end

  M.detect_venv_async(root_dir, function(venv_path)
    if venv_path then
      M.apply_venv_to_lsp(root_dir, venv_path)
    end
  end)
end

--- Clear venv cache (useful for testing or forcing re-detection)
--- @param root_dir string|nil Specific root dir to clear, or nil for all
function M.clear_cache(root_dir)
  if root_dir then
    venv_cache[root_dir] = nil
  else
    venv_cache = {}
  end
end

--- Get cache statistics (for debugging)
--- @return table stats Cache statistics
function M.get_cache_stats()
  local count = 0
  local expired = 0
  local now = vim.loop.hrtime()

  for _, cached in pairs(venv_cache) do
    count = count + 1
    if now - cached.timestamp >= CACHE_TTL then
      expired = expired + 1
    end
  end

  return {
    total = count,
    expired = expired,
    valid = count - expired,
    ttl_seconds = CACHE_TTL / 1000000000,
  }
end

--- Setup user commands for venv management
function M.setup_commands()
  vim.api.nvim_create_user_command("PythonVenvDetect", function()
    local root_dir = vim.fs.root(0, { "pyproject.toml", "setup.py", "requirements.txt", ".git" })
    if not root_dir then
      notify.notify("No Python project root detected", "warn")
      return
    end

    -- Force re-detection by clearing cache
    M.clear_cache(root_dir)
    M.detect_and_apply(root_dir)
  end, { desc = "Manually detect and apply Python virtual environment" })

  vim.api.nvim_create_user_command("PythonVenvCache", function()
    local stats = M.get_cache_stats()
    local lines = {
      "=== Python Venv Cache ===",
      string.format("Total entries: %d", stats.total),
      string.format("Valid entries: %d", stats.valid),
      string.format("Expired entries: %d", stats.expired),
      string.format("TTL: %d seconds", stats.ttl_seconds),
      "",
      "Cached venvs:",
    }

    for root_dir, cached in pairs(venv_cache) do
      local age = (vim.loop.hrtime() - cached.timestamp) / 1000000000
      local status = age < stats.ttl_seconds and "✓" or "✗"
      table.insert(lines, string.format("  %s %s: %s (age: %.1fs)", status, root_dir, cached.venv_path or "none", age))
    end

    notify.notify(table.concat(lines, "\n"), "info", { title = "Venv Cache" })
  end, { desc = "Show Python venv cache status" })

  vim.api.nvim_create_user_command("PythonVenvClear", function()
    M.clear_cache()
    notify.notify("Python venv cache cleared", "info")
  end, { desc = "Clear Python venv cache" })
end

return M
