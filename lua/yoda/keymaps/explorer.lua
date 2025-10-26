local map = vim.keymap.set
local handlers = require("yoda.keymaps.handlers.window")
local actions = require("yoda.keymaps.handlers.explorer_actions")

map("n", "<leader>eo", handlers.open_explorer_if_closed, { desc = "Explorer: Open (only if closed)" })

map("n", "<leader>ef", handlers.focus_explorer, { desc = "Explorer: Focus (if open)" })

map("n", "<leader>ec", handlers.close_explorer, { desc = "Explorer: Close (if open)" })

map("n", "<leader>er", handlers.refresh_explorer, { desc = "Explorer: Refresh" })

map("n", "<leader>e?", handlers.show_explorer_help, { desc = "Explorer: Show help" })

map("n", "<leader>e", actions.toggle_with_opencode, { desc = "Explorer: Toggle with OpenCode layout" })

return {}
