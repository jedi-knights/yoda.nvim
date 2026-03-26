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
      { "<leader>a", group = "AI" },
      { "<leader>s", group = "Search" },
      { "<leader>t", group = "Toggle/Test" },
      { "<leader>d", group = "Debug" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Git Hunk", mode = { "n", "v" } },
      { "<leader>w", group = "Window" },
      { "<leader>x", group = "Diagnostics" },
      -- Explicit entry so leader-D isn't swallowed by the leader-d Debug group
      { "<leader>D", desc = "Delete buffer content" },
    },
  },
}
