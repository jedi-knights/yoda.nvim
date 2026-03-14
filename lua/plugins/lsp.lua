-- lua/plugins_new/lsp.lua
-- LSP configuration plugins

return {
  -- Mason - LSP, DAP, and linter installer
  {
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
  },

  -- LSP Configuration using built-in vim.lsp.config (Neovim 0.11+)
  --
  -- Separation of concerns:
  --   ensure_installed  → Mason installs the server binaries
  --   handlers          → Overrides mason-lspconfig auto-configuration (we opt out
  --                        of auto-setup so that yoda.lsp owns all vim.lsp.config calls)
  --   yoda.lsp.setup()  → Single source of truth for all vim.lsp.config configuration
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    config = function()
      -- Setup mason-lspconfig first (installation only — not configuration)
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "lua_ls",
          "ts_ls",
          "basedpyright",
          "yamlls",
          "marksman", -- Markdown LSP server
        },
        -- Override the default handler to prevent mason-lspconfig from
        -- auto-configuring servers. All vim.lsp.config calls are made
        -- exclusively by yoda.lsp.setup() below.
        handlers = {
          function(server_name)
            -- Skip pyright — we use basedpyright instead
            if server_name == "pyright" then
              return
            end
            -- All other servers: do nothing here; yoda.lsp.setup() configures them
          end,
        },
      })

      -- Single source of truth for LSP server configuration
      require("yoda.lsp").setup()
    end,
  },
}
