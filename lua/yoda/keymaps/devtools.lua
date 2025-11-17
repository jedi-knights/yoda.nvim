local notify = require("yoda-adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

if not _G.yoda_keymap_log then
  _G.yoda_keymap_log = {}
end

map("n", "<leader>kd", function()
  local log = vim.deepcopy(_G.yoda_keymap_log or {})

  table.sort(log, function(a, b)
    return a.lhs == b.lhs and a.mode < b.mode or a.lhs < b.lhs
  end)

  local lines = {}
  for _, map in ipairs(log) do
    table.insert(lines, string.format("%s %s → %s [%s] (%s)", map.mode, map.lhs, map.rhs, map.desc or "", map.source))
  end

  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "keymap-dump"
end, { desc = "DevTools: Dump Keymaps" })

map("n", "<leader>kc", function()
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
    notify.notify("✅ No keymap conflicts detected!", "info")
  else
    vim.cmd("new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, conflicts)
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false
    vim.bo.filetype = "keymap-conflicts"
  end
end, { desc = "DevTools: Find Keymap Conflicts" })
