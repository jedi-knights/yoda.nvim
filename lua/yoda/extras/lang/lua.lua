-- lua/yoda/extras/lang/lua.lua
-- Opt-in Lua stack: lazydev.nvim type annotations for Neovim plugin work.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.lua" }

return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
