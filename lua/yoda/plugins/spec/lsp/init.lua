-- lua/yoda/plugins/spec/lsp/init.lua

return {
    require("yoda.plugins.spec.lsp.mason"),
    require("yoda.plugins.spec.lsp.mason-lspconfig"),
    require("yoda.plugins.spec.lsp.nvim-lspconfig"),
    require("yoda.plugins.spec.lsp.mason-tool-installer"),
    require("yoda.plugins.spec.lsp.none-ls"),
    require("yoda.plugins.spec.lsp.rust-tools")
}

