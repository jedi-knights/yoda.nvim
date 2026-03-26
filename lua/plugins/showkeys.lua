-- lua/plugins/showkeys.lua

return {
  "nvzone/showkeys",
  cmd = { "ShowkeysToggle", "Showkeys" },
  opts = {
    timeout = 1,
    maxkeys = 5,
    position = "top-right",
  },
}
