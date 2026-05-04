-- lua/plugins/which-key.lua
-- Shows pending keymap completions after a brief delay.

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- 200ms: fast enough to catch deliberate pauses, won't flash on rapid sequences.
    -- delay = 0 showed the popup on every partial keystroke, creating visual noise.
    delay = 200,
    preset = "helix",
    icons = { mappings = true, keys = {} },
    spec = {
      -- Core groups
      { "<leader>a", group = "AI" },
      { "<leader>d", group = "Debug" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Git Hunk", mode = { "n", "v" } },
      { "<leader>l", group = "LSP" },
      { "<leader>n", group = "Notifications" },
      { "<leader>s", group = "Search" },
      { "<leader>t", group = "Toggle/Test" },
      { "<leader>w", group = "Window" },
      -- Utility groups
      { "<leader>c", group = "Coverage" },
      { "<leader>k", group = "Keymaps" },
      -- Language groups (buffer-local keymaps — registered by FileType autocmds)
      { "<leader>j", group = "JavaScript" },
      { "<leader>p", group = "Python" },
      { "<leader>r", group = "Rust" },
      -- Standalone entries that share a prefix with a group and need an explicit label
      { "<leader>D", desc = "Delete buffer content" },
    },
  },
}
