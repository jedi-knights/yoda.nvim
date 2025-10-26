-- lua/plugins/ui/showkeys.lua
-- Showkeys - Minimal keys screencaster for Neovim

return {
  "nvzone/showkeys",
  lazy = true,
  cmd = { "Showkeys", "ShowkeysToggle", "ShowkeysStart", "ShowkeysStop" },
  config = function()
    require("showkeys").setup({
      timeout = 5,
      maxkeys = 5,
      show_count = true,
      show_all_keys = false,
      show_key_sequence = true,
      show_leader = true,
      show_which_key = true,
      position = "top-center",
    })
  end,
}
