local M = {}

-- Initialize global keymap log if it doesn't exist
if not _G.yoda_keymap_log then
  _G.yoda_keymap_log = {}
end

-- 🧾 Dump all tracked keymaps from vim.keymap.set()
function M.dump_all_keymaps()
  local log = vim.deepcopy(_G.yoda_keymap_log or {})

  -- Alphabetically sort by mode then lhs
  table.sort(log, function(a, b)
    return a.lhs == b.lhs and a.mode < b.mode or a.lhs < b.lhs
  end)

  local lines = {}
  for _, map in ipairs(log) do
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

-- ⚠️ Detect conflicts in tracked keymaps from vim.keymap.set()
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

  if #conflicts == 0 then
    vim.notify("✅ No keymap conflicts detected!", vim.log.levels.INFO)
  else
    vim.cmd("new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, conflicts)
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false
    vim.bo.filetype = "keymap-conflicts"
  end
end

return M
