-- lua/plugins/mini.lua
-- Consolidated mini.nvim modules. Each entry keeps its own load strategy —
-- icons must be eager (devicons shim), pairs on InsertEnter, the rest VeryLazy.

return {
  -- File type icons. Loaded eagerly so icons are available at startup.
  {
    "echasnovski/mini.icons",
    lazy = false,
    config = function()
      require("mini.icons").setup()
    end,
  },

  -- Auto-close brackets, quotes, and other paired characters.
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Extended text objects using treesitter. n_lines=50 looks up to 50 lines
  -- away for object boundaries, handling long functions without missing closing braces.
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = { n_lines = 50 },
  },

  -- Add/change/delete surrounding characters.
  -- gz prefix chosen to avoid conflict with leap.nvim's s/S bindings.
  -- gza{motion}{char} — add, gzd{char} — delete, gzr{old}{new} — replace.
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "gza",
        delete = "gzd",
        replace = "gzr",
        find = "gzf",
        find_left = "gzF",
        highlight = "gzh",
        update_n_lines = "gzn",
      },
    },
  },
}
