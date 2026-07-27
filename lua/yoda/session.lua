-- lua/yoda/session.lua
-- Session lifecycle: clean exit and state persistence.
--
-- WHY this module exists: Neovim's built-in SHADA write on exit can produce
-- "file already exists" warnings when a previous session left a stale temp file
-- (.shada.tmp.X) behind after a crash. Calling `wshada!` explicitly in
-- VimLeavePre forces an overwrite *before* Neovim's built-in exit write runs,
-- reducing the likelihood of those warnings. The pcall guard ensures a failing
-- write (read-only filesystem, permission denied) produces a WARN notification
-- rather than a confusing error message at quit time.

local M = {}

-- A hard kill (SIGKILL, crash, force-quit) skips VimLeavePre entirely, so
-- orphaned *.shada.tmp.* files can still accumulate despite the forced write
-- above. Sweep them on startup instead, since that's the one point every
-- session reliably passes through. Only remove tmp files older than 5
-- minutes so an in-progress write from another concurrent instance is never
-- touched.
local STALE_AFTER_SECONDS = 300

local function cleanup_stale_shada_tmp()
  local shada_dir = vim.fn.stdpath("state") .. "/shada"
  local now = os.time()
  for _, path in ipairs(vim.fn.glob(shada_dir .. "/*.tmp.*", false, true)) do
    local stat = vim.loop.fs_stat(path)
    if stat and (now - stat.mtime.sec) > STALE_AFTER_SECONDS then
      local ok, err = pcall(os.remove, path)
      if not ok then
        vim.notify(
          "[yoda] failed to remove stale ShaDa temp file "
            .. path
            .. ": "
            .. tostring(err),
          vim.log.levels.WARN
        )
      end
    end
  end
end

function M.setup()
  local group =
    vim.api.nvim_create_augroup("YodaSessionCleanup", { clear = true })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    desc = "Force-write ShaDa on exit to prevent 'file already exists' warnings",
    callback = function()
      local ok, err = pcall(vim.cmd, "wshada!")
      if not ok then
        vim.notify(
          "[yoda] ShaDa write failed: " .. tostring(err),
          vim.log.levels.WARN
        )
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    desc = "Remove stale orphaned ShaDa temp files left by hard-killed sessions",
    callback = cleanup_stale_shada_tmp,
  })
end

return M
