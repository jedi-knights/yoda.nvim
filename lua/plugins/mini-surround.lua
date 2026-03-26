-- lua/plugins/mini-surround.lua
-- Add/change/delete surrounding characters.
-- gz prefix chosen to avoid conflict with leap.nvim's s/S bindings.
-- gza{motion}{char} — add, gzd{char} — delete, gzr{old}{new} — replace.

return {
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
}
