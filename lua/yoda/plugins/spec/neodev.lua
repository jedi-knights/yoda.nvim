-- lua/yoda/plugins/spec/neodev.lua

return {
  "folke/neodev.nvim",
  lazy = false,        -- Load eagerly at startup (important to patch LSP before it runs)
  priority = 1000,     -- Load early, before other plugins

  config = function()
    -- Neodev.nvim integrates Neovim runtime, plugin, and Lua API metadata
    -- into the Lua language server (lua_ls / sumneko_lua).
    --
    -- This gives you:
    -- ✅ No more 'undefined global vim' errors in your Lua configs
    -- ✅ Autocomplete for Neovim API, user config, and plugin namespaces
    -- ✅ Type checking and better LSP support in your Lua files
    --
    -- It's highly recommended for anyone writing Neovim Lua configs or plugins.
    --
    -- Website: https://github.com/folke/neodev.nvim

    require("neodev").setup({})
  end,
}
