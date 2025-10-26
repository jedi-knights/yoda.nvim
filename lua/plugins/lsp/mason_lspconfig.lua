-- lua/plugins/lsp/mason_lspconfig.lua
-- LSP Configuration using built-in vim.lsp.config (Neovim 0.11+)

return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "gopls",
        "lua_ls",
        "ts_ls",
        "basedpyright",
        "yamlls",
        "omnisharp",
        "helm_ls",
        "marksman",
      },
    })

    require("yoda.lsp").setup()
  end,
}
