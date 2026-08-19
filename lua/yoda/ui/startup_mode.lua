-- lua/yoda/ui/startup_mode.lua
--
-- Optional command-line startup modes for Yoda. Currently one mode: `claude`.
--
-- Running `nvim claude` (or the short alias `nvim c`) boots straight into an AI
-- workspace instead of the dashboard: the Snacks explorer opens as a left
-- sidebar and Claude Code is expanded to fill all horizontal space to its
-- right. This is the *startup* counterpart to the in-session `<leader>ai`
-- dashboard-expand behavior in lua/yoda/plugins/ai.lua, and it reuses the
-- same yoda-window.nvim reclaim_width helper so the two stay visually
-- consistent.
--
-- Passing any argument already suppresses the Snacks dashboard (it only
-- auto-shows with zero file args), so the only cleanup needed is wiping the
-- phantom `claude`/`c` buffer that Neovim opens for the positional argument.
--
-- Pure argument classification lives in yoda.core.startup_mode.

local core = require("yoda.core.startup_mode")

local M = {
  -- Re-export the pure classifier so callers/tests that pointed at
  -- yoda.startup_mode.mode_from_argv keep working through the top-level shim.
  mode_from_argv = core.mode_from_argv,
}

--- Build the claude-mode layout: Snacks explorer sidebar on the left, Claude
--- Code expanded to fill everything to its right, dashboard/phantom buffer
--- removed, focus in the Claude terminal.
---
--- Every external dependency is guarded so a missing plugin degrades to a plain
--- `:ClaudeCode` rather than erroring during startup.
function M.start_claude_layout()
  -- The window/buffer Neovim opened for the `claude`/`c` argument. We hand its
  -- space to Claude and then wipe the buffer.
  local phantom_win = vim.api.nvim_get_current_win()
  local phantom_buf = vim.api.nvim_get_current_buf()

  local snacks_ok, snacks = pcall(require, "snacks")
  if snacks_ok then
    pcall(function()
      snacks.explorer.open()
    end)
  end

  vim.cmd("ClaudeCode")

  -- Claude's terminal spawns asynchronously; defer until its window exists so
  -- reclaim_width can measure and resize it. Mirrors the pattern in
  -- lua/yoda/plugins/ai.lua.
  vim.schedule(function()
    local term_ok, terminal = pcall(require, "claudecode.terminal")
    local term_buf = term_ok and terminal.get_active_terminal_bufnr()
    local claude_win = term_buf and vim.fn.bufwinid(term_buf) or -1
    if claude_win == -1 then
      return
    end

    -- Grow Claude into the space right of the explorer, closing the phantom
    -- window in the process (reclaim_width stops short of the explorer
    -- sidebar). Degrades gracefully if yoda-window.nvim is unavailable.
    local win_ok, win_utils = pcall(require, "yoda-window.utils")
    if win_ok and vim.api.nvim_win_is_valid(phantom_win) then
      pcall(win_utils.reclaim_width, phantom_win, claude_win)
    end

    if vim.api.nvim_buf_is_valid(phantom_buf) then
      pcall(vim.api.nvim_buf_delete, phantom_buf, { force = true })
    end

    -- Defer the final focus + terminal-insert to the next tick so it lands
    -- *after* every other startup focus handler that runs later in the loop
    -- (snacks picker `p:focus()`, ClaudeCode's own scheduled start_insert,
    -- any dashboard eviction). A plain vim.schedule here fires too early --
    -- claude gets focus, then one of those handlers steals it back and the
    -- user boots into the sidebar/normal mode instead of typing to Claude.
    -- Re-resolve the claude window at defer time because the buffer may
    -- have been swapped during the intervening focus dance.
    vim.defer_fn(function()
      local ok, terminal_mod = pcall(require, "claudecode.terminal")
      local buf = ok and terminal_mod.get_active_terminal_bufnr()
      local win = buf and vim.fn.bufwinid(buf) or -1
      if win == -1 or not vim.api.nvim_win_is_valid(win) then
        return
      end
      -- pcall: window may close between the valid-check and the focus call
      -- (async terminal spawn); silent failure is the intended degrade.
      pcall(vim.api.nvim_set_current_win, win)
      -- pcall: non-fatal if the buffer isn't yet a terminal in degraded
      -- startup (missing plugin, spawn failure); the user just presses `i`.
      pcall(vim.cmd, "startinsert")
    end, 50)
  end)
end

--- Register the VimEnter hook that activates a startup mode when the
--- command-line arguments select one. Idempotent: the augroup is cleared on
--- each call and the autocmd fires once.
function M.setup()
  local group = vim.api.nvim_create_augroup("YodaStartupMode", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    desc = "Activate Yoda claude startup mode when `nvim claude`/`nvim c` is run",
    callback = function()
      if core.mode_from_argv(vim.fn.argv()) == "claude" then
        M.start_claude_layout()
      end
    end,
  })
end

return M
