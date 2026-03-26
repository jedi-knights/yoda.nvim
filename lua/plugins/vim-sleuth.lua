-- lua/plugins/vim-sleuth.lua
-- Detects and sets indentation settings (tabstop, shiftwidth, expandtab)
-- from file content and neighbouring files.

return {
  "tpope/vim-sleuth",
  event = "BufReadPost",
}
