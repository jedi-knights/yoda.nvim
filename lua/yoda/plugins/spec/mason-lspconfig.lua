return {
  "williamboman/mason-lspconfig.nvim",
  lazy = false,
  config = function()
    local mason_lsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
    if mason_lsp_ok then
      mason_lspconfig.setup({
        ensure_installed = {
          "lua_ls",   -- Lua
          "pyright",  -- Python
          "gopls",    -- Go
          "ts_ls",    -- JavaScript/TypeScript (correct, future-safe)
          --"eslint",   -- JavaScript/TypeScript (correct, future-safe)
          "ruff",   -- Python
        },
      })
    end
  end,
}

