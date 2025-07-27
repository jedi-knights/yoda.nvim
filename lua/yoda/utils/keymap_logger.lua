local M = {}

-- Initialize global keymap log if it doesn't exist
if not _G.yoda_keymap_log then
  _G.yoda_keymap_log = {}
end

--- Wrapped version of `vim.keymap.set` that tracks source file and line
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

--- Print all logged keymaps (optionally filtered by mode)
function M.dump(mode_filter)
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
  vim.bo.filetype = "keymap-logged"
end

return M
