local notify = require("yoda.adapters.notification")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

local OPENCODE_STARTUP_DELAY_MS = 100
local win_utils = require("yoda.window_utils")

local function with_auto_save(operation_fn)
  return function(...)
    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      local save_ok, save_result = pcall(opencode_integration.save_all_buffers)
      if not save_ok or save_result == false then
        return
      end
    end

    operation_fn(...)
  end
end

map(
  "n",
  "<leader>ai",
  with_auto_save(function()
    local win, _ = win_utils.find_opencode()
    if win then
      vim.api.nvim_set_current_win(win)
      vim.schedule(function()
        vim.cmd("startinsert")
      end)
    else
      require("opencode").toggle()
      vim.defer_fn(function()
        local new_win, _ = win_utils.find_opencode()
        if new_win then
          vim.api.nvim_set_current_win(new_win)
          vim.cmd("startinsert")
        end
      end, OPENCODE_STARTUP_DELAY_MS)
    end
  end),
  { desc = "AI: Toggle/Focus OpenCode (auto-save + insert mode)" }
)

map({ "n", "i" }, "<leader>ab", function()
  if vim.fn.mode() == "i" then
    vim.cmd("stopinsert")
  end

  local win_utils = require("yoda.window_utils")
  local current_win = vim.api.nvim_get_current_win()

  local found = win_utils.focus_window(function(win, buf, buf_name, ft)
    return win ~= current_win and not buf_name:match("[Oo]pen[Cc]ode") and not buf_name:match("^$") and vim.bo[buf].buftype == ""
  end)

  if not found then
    vim.cmd("wincmd p")
  end
end, { desc = "AI: Return to previous buffer from OpenCode" })

map("i", "<C-q>", function()
  local buf_name = vim.api.nvim_buf_get_name(0)
  if buf_name:match("[Oo]pen[Cc]ode") then
    vim.cmd("stopinsert")
    vim.schedule(function()
      local win_utils = require("yoda.window_utils")
      local found = win_utils.focus_window(function(win, buf, buf_name, ft)
        return not buf_name:match("[Oo]pen[Cc]ode") and vim.bo[buf].buftype == ""
      end)
      if not found then
        vim.cmd("wincmd p")
      end
    end)
  else
    vim.cmd("stopinsert")
  end
end, { desc = "Smart escape: Exit insert mode (return to buffer if in OpenCode)" })

map({ "n", "i" }, "<A-q>", function()
  if vim.fn.mode() == "i" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end

  vim.schedule(function()
    local win_utils = require("yoda.window_utils")
    local current_win = vim.api.nvim_get_current_win()

    local found = win_utils.focus_window(function(win, buf, buf_name, ft)
      return win ~= current_win and not buf_name:match("[Oo]pen[Cc]ode") and vim.bo[buf].buftype == "" and buf_name ~= ""
    end)

    if found then
      notify.notify("← Returned to main buffer", "info")
    else
      pcall(vim.cmd, "wincmd p")
      notify.notify("← Switched to previous window", "info")
    end
  end)
end, { desc = "Exit OpenCode and return to main buffer (Alt+q)" })

map({ "n", "i" }, "<leader>aq", ":OpenCodeReturn<CR>", { desc = "Return to main buffer from OpenCode (command-based)", silent = true })

map(
  { "n", "x" },
  "<leader>oa",
  with_auto_save(function()
    require("opencode").ask("@this: ", { submit = true })
  end),
  { desc = "OpenCode: Ask about this (auto-save)" }
)

map(
  { "n", "x" },
  "<leader>o+",
  with_auto_save(function()
    require("opencode").prompt("@this")
  end),
  { desc = "OpenCode: Add this to prompt (auto-save)" }
)

map(
  { "n", "x" },
  "<leader>oe",
  with_auto_save(function()
    require("opencode").prompt("Explain @this and its context", { submit = true })
  end),
  { desc = "OpenCode: Explain this (auto-save)" }
)

map(
  { "n", "x" },
  "<leader>os",
  with_auto_save(function()
    require("opencode").select()
  end),
  { desc = "OpenCode: Select prompt (auto-save)" }
)

map(
  "n",
  "<leader>ot",
  with_auto_save(function()
    local win, _ = win_utils.find_opencode()
    if win then
      vim.api.nvim_set_current_win(win)
      vim.schedule(function()
        vim.cmd("startinsert")
      end)
    else
      require("opencode").toggle()
      vim.defer_fn(function()
        local new_win, _ = win_utils.find_opencode()
        if new_win then
          vim.api.nvim_set_current_win(new_win)
          vim.cmd("startinsert")
        end
      end, OPENCODE_STARTUP_DELAY_MS)
    end
  end),
  { desc = "OpenCode: Toggle/Focus embedded (auto-save + insert mode)" }
)

map("n", "<S-C-u>", function()
  require("opencode").command("session.half.page.up")
end, { desc = "OpenCode: Messages half page up" })

map("n", "<S-C-d>", function()
  require("opencode").command("session.half.page.down")
end, { desc = "OpenCode: Messages half page down" })

map("n", "<leader>cop", function()
  require("lazy").load({ plugins = { "copilot.lua" } })

  local ok, copilot_suggestion = pcall(require, "copilot.suggestion")
  if not ok then
    notify.notify("❌ Copilot is not available", "error")
    return
  end

  if copilot_suggestion.is_visible() then
    copilot_suggestion.dismiss()
    notify.notify("🚫 Copilot disabled", "info")
  else
    notify.notify("✅ Copilot enabled - suggestions will appear as you type", "info")
  end
end, { desc = "Copilot: Toggle/Dismiss" })

vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    local ok, copilot_suggestion = pcall(require, "copilot.suggestion")
    if not ok then
      return
    end

    map("i", "<leader>a", function()
      copilot_suggestion.accept()
    end, { silent = true, desc = "Copilot: Accept" })

    map("i", "<leader>n", function()
      copilot_suggestion.next()
    end, { silent = true, desc = "Copilot: Next" })

    map("i", "<leader>p", function()
      copilot_suggestion.prev()
    end, { silent = true, desc = "Copilot: Previous" })

    map("i", "<leader>d", function()
      copilot_suggestion.dismiss()
    end, { silent = true, desc = "Copilot: Dismiss" })
  end,
})
