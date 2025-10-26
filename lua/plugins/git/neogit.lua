-- lua/plugins/git/neogit.lua
-- Neogit - Git interface

return {
  "TimUntersberger/neogit",
  lazy = true,
  cmd = "Neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "sindrets/diffview.nvim",
  },
  config = function()
    require("neogit").setup({
      disable_signs = false,
      disable_context_highlighting = false,
      disable_commit_confirmation = false,
      auto_refresh = true,
      sort_branches = "-committerdate",
      disable_builtin_notifications = false,
      use_magit_keybindings = false,
      commit_popup = {
        kind = "split",
      },
      popup = {
        kind = "split",
      },
      signs = {
        hunk = { "", "" },
        item = { ">", "v" },
        section = { ">", "v" },
      },
      integrations = {
        diffview = true,
      },
      sections = {
        untracked = { folded = false, hidden = false },
        unstaged = { folded = false, hidden = false },
        staged = { folded = false, hidden = false },
        stashes = { folded = true, hidden = false },
        unpulled = { folded = true, hidden = false },
        unmerged = { folded = false, hidden = false },
        recent = { folded = true, hidden = false },
      },
    })
  end,
}
