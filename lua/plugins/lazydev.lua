-- lua/plugins/lazydev.lua
-- Fast Lua type annotations and API completion for Neovim plugins.
-- Only active for Lua files; blink.cmp sources it via lazydev.integrations.blink.

return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
