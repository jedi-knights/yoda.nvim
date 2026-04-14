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

function M.setup()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("YodaSessionCleanup", { clear = true }),
    desc = "Force-write ShaDa on exit to prevent 'file already exists' warnings",
    callback = function()
      local ok, err = pcall(vim.cmd, "wshada!")
      if not ok then
        vim.notify("[yoda] ShaDa write failed: " .. tostring(err), vim.log.levels.WARN)
      end
    end,
  })
end

return M
