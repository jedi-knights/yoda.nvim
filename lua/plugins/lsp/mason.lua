-- lua/plugins/lsp/mason.lua
-- Mason - LSP, DAP, and linter installer

return {
  "williamboman/mason.nvim",
  lazy = true,
  event = "VeryLazy",
  build = ":MasonUpdate",
  config = function()
    local mason_ok, mason = pcall(require, "mason")
    if mason_ok then
      mason.setup()
    end
  end,
}
