-- lua/yoda/utils/keymap_utils.lua
-- Utility functions for keymap management with logging

local M = {}

-- Initialize global keymap log if it doesn't exist
if not _G.yoda_keymap_log then
  _G.yoda_keymap_log = {}
end

--- Set a keymap with logging
--- @param mode string The mode (n, i, v, t, etc.)
--- @param lhs string The left-hand side (key combination)
--- @param rhs string|function The right-hand side (command or function)
--- @param opts table Optional parameters
function M.set(mode, lhs, rhs, opts)
  local info = debug.getinfo(2, "Sl")  -- get caller's file and line
  opts = vim.deepcopy(opts or {})
  local desc = opts.desc or ""

  local record = {
    mode = mode,
    lhs = lhs,
    rhs = (type(rhs) == "string") and rhs or "<function>",
    desc = desc,
    source = info.short_src .. ":" .. info.currentline,
  }

  table.insert(_G.yoda_keymap_log, record)
  vim.keymap.set(mode, lhs, rhs, opts)
end

--- Register multiple keymaps with logging
--- @param mode string The mode
--- @param mappings table Table of keymap definitions
function M.register(mode, mappings)
  for key, config in pairs(mappings) do
    local rhs = config[1]
    local opts = config[2] or {}
    M.set(mode, key, rhs, opts)
  end
end

--- Get all logged keymaps
--- @return table Array of keymap records
function M.get_log()
  return vim.deepcopy(_G.yoda_keymap_log or {})
end

--- Clear the keymap log
function M.clear_log()
  _G.yoda_keymap_log = {}
end

--- Find keymap conflicts
--- @return table Array of conflict descriptions
function M.find_conflicts()
  local seen = {}
  local conflicts = {}
  local log = _G.yoda_keymap_log or {}

  for _, map in ipairs(log) do
    local key = map.mode .. ":" .. map.lhs
    if seen[key] then
      table.insert(conflicts, string.format("❌ Conflict: %s (%s)", map.lhs, map.mode))
    else
      seen[key] = true
    end
  end

  return conflicts
end

--- Dump keymaps to a new buffer
--- @param mode_filter string Optional mode filter
function M.dump_to_buffer(mode_filter)
  local lines = {}
  local filtered = {}

  for _, map in ipairs(_G.yoda_keymap_log) do
    if not mode_filter or map.mode == mode_filter then
      table.insert(filtered, map)
    end
  end

  -- Sort alphabetically by lhs
  table.sort(filtered, function(a, b)
    return a.lhs < b.lhs
  end)

  for _, map in ipairs(filtered) do
    table.insert(lines, string.format(
      "%s %s → %s [%s] (%s)",
      map.mode, map.lhs, map.rhs, map.desc or "", map.source
    ))
  end

  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "keymap-dump"
end

--- Print keymap statistics
function M.print_stats()
  local log = _G.yoda_keymap_log or {}
  local stats = {
    total = #log,
    modes = {},
    sources = {},
  }

  for _, map in ipairs(log) do
    -- Count by mode
    stats.modes[map.mode] = (stats.modes[map.mode] or 0) + 1
    
    -- Count by source file
    local source = map.source:match("([^:]+):")
    if source then
      stats.sources[source] = (stats.sources[source] or 0) + 1
    end
  end

  vim.notify(string.format("Total keymaps: %d", stats.total), vim.log.levels.INFO)
  
  for mode, count in pairs(stats.modes) do
    vim.notify(string.format("  %s mode: %d", mode, count), vim.log.levels.INFO)
  end
end

return M 