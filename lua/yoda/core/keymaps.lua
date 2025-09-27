-- lua/yoda/core/keymaps.lua
-- Main keymaps file - now uses consolidated keymaps

-- Load consolidated keymaps
local consolidated_keymaps = require("yoda.core.keymaps_consolidated")
consolidated_keymaps.setup()

-- Special keymaps that require custom logic
vim.keymap.set("n", "<leader>xt", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:match("Trouble") then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end, { desc = "Focus Trouble window" })

-- Snacks explorer focus
vim.keymap.set("n", "<leader>e", function()
  local found = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    if ft == "snacks-explorer" then
      vim.api.nvim_set_current_win(win)
      found = true
      return
    end
  end
  -- If not found, open/toggle the Snacks Explorer
  local ok, explorer = pcall(require, "snacks.explorer")
  if ok and explorer and explorer.open then
    explorer.open()
  else
    vim.notify("Snacks Explorer could not be opened", vim.log.levels.ERROR)
  end
end, { desc = "Focus or Open Snacks Explorer window" })

-- Copilot keymaps with proper error handling
vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    vim.keymap.set("i", "<C-j>", function()
      return vim.fn["copilot#Accept"]("")
    end, { expr = true, silent = true, replace_keycodes = false, desc = "Copilot Accept" })
    
    vim.keymap.set("i", "<C-k>", 'copilot#Dismiss()', { expr = true, silent = true, desc = "Copilot Dismiss" })
    
    vim.keymap.set("i", "<C-Space>", 'copilot#Complete()', { expr = true, silent = true, desc = "Copilot Complete" })
  end,
})
