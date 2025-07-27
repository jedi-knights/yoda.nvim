-- lua/yoda/utils/keymap_utils.lua
-- Utility functions for keymap management with integrated logging

local M = {}

--- Set a keymap with logging
--- @param mode string The keymap mode (n, v, i, t, etc.)
--- @param lhs string The left-hand side (key combination)
--- @param rhs string|function The right-hand side (command or function)
--- @param opts table Optional keymap options
function M.set(mode, lhs, rhs, opts)
  opts = opts or {}
  
  -- Log the keymap for debugging purposes
  local info = debug.getinfo(2, "Sl")
  local log_record = {
    mode = mode,
    lhs = lhs,
    rhs = (type(rhs) == "string") and rhs or "<function>",
    desc = opts.desc or "",
    source = info.short_src .. ":" .. info.currentline,
  }
  
  -- Store in global log if available
  if _G.yoda_keymap_log then
    table.insert(_G.yoda_keymap_log, log_record)
  end
  
  vim.keymap.set(mode, lhs, rhs, opts)
end

--- Print keymap statistics
function M.print_stats()
  if not _G.yoda_keymap_log then
    print("No keymap log available")
    return
  end
  
  local stats = {
    total = #_G.yoda_keymap_log,
    by_mode = {},
    by_source = {}
  }
  
  for _, keymap in ipairs(_G.yoda_keymap_log) do
    -- Count by mode
    stats.by_mode[keymap.mode] = (stats.by_mode[keymap.mode] or 0) + 1
    
    -- Count by source file
    local source_file = keymap.source:match("([^/]+)$") or keymap.source
    stats.by_source[source_file] = (stats.by_source[source_file] or 0) + 1
  end
  
  print("=== Keymap Statistics ===")
  print(string.format("Total keymaps: %d", stats.total))
  
  print("\nBy mode:")
  for mode, count in pairs(stats.by_mode) do
    print(string.format("  %s: %d", mode, count))
  end
  
  print("\nBy source file:")
  for source, count in pairs(stats.by_source) do
    print(string.format("  %s: %d", source, count))
  end
  
  print("========================")
end

return M 