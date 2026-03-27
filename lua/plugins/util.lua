-- lua/plugins/util.lua
-- Small utility plugins: repeat operator support, auto-indent detection, key display.

return {
  -- Makes plugin-defined operators repeatable with `.`.
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },

  -- Detects and sets indentation settings (tabstop, shiftwidth, expandtab)
  -- from file content and neighbouring files.
  {
    "tpope/vim-sleuth",
    event = "BufReadPost",
  },

  {
    "nvzone/showkeys",
    cmd = { "ShowkeysToggle", "Showkeys" },
    opts = {
      timeout = 1,
      maxkeys = 5,
      position = "top-right",
    },
  },
}
