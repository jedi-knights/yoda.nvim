-- lua/yoda/lsp/servers/lua_ls.lua

return {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" }, -- Recognize the `vim` global
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true), -- Include runtime
        checkThirdParty = false, -- Avoid asking about third-party
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

