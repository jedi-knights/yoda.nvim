-- lua/yoda/core/startup_mode.lua
-- Pure argument-classification for the `nvim claude` / `nvim c` startup mode.
-- vim.fn.filereadable / vim.fn.isdirectory are filesystem existence checks,
-- not editor state, so the module remains headless-testable with an injected
-- argv table. Autocmd + layout wiring lives in yoda.ui.startup_mode.

local M = {}

-- Bare arguments that select claude mode. A guard in mode_from_argv ensures a
-- real file/directory of the same name still opens normally, so these short
-- tokens never hijack an actual `claude` or `c` path in the cwd.
M.TRIGGERS = {
  claude = true,
  c = true,
}

--- Decide which startup mode (if any) a set of command-line arguments selects.
--- @param argv string[] Command-line file arguments (as from vim.fn.argv())
--- @return string|nil mode "claude" when claude mode is selected, else nil
function M.mode_from_argv(argv)
  if type(argv) ~= "table" or #argv ~= 1 then
    return nil
  end

  local arg = argv[1]
  if not M.TRIGGERS[arg] then
    return nil
  end

  -- Collision guard: if the user actually has a file or directory named
  -- "claude"/"c" in the cwd, treat the argument as a normal path to edit.
  if vim.fn.filereadable(arg) == 1 or vim.fn.isdirectory(arg) == 1 then
    return nil
  end

  return "claude"
end

return M
