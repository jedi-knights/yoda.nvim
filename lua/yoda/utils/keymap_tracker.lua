-- lua/yoda/utils/keymap_tracker.lua

local M = {}

M.keymaps = {}

function M.track(mode, lhs, rhs, opts)
  table.insert(M.keymaps, {
    mode = mode,
    lhs = lhs,
    rhs = rhs,
    desc = opts and opts.desc or "",
  })

  -- Actually set the keymap too
  vim.keymap.set(mode, lhs, rhs, opts)
end

return M
