-- lua/yoda/lsp/configs/lua_ls.lua
-- Lua language server configuration

local M = {}

--- Create lua_ls configuration
--- @param builder LSPConfigBuilder
--- @return table
function M.create_config(builder)
  return builder
    :with_filetypes({ "lua" })
    :with_settings({
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    })
    :build()
end

return M
