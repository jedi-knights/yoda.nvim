return {
  "neovim/nvim-lspconfig",
  lazy = false,
  config = function()
    local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
    local lsp = require("yoda.lsp")

    if lspconfig_ok then
      local servers = {
        lua_ls = require("yoda.lsp.servers.lua_ls"),
        pyright = require("yoda.lsp.servers.pyright"),
        gopls = require("yoda.lsp.servers.gopls"),
        eslint = require("yoda.lsp.servers.eslint"),
        ts_ls = require("yoda.lsp.servers.ts_ls"), -- ✅ updated here too
      }

      for name, opts in pairs(servers) do
        lspconfig[name].setup(vim.tbl_deep_extend("force", {
          on_attach = lsp.on_attach,
          capabilities = lsp.capabilities(),
        }, opts))
      end
    end
  end,
}

