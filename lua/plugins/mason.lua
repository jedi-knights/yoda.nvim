-- lua/plugins/mason.lua
-- Mason core + bridge plugins for LSP and DAP auto-installation.
-- Load order matters: mason.nvim must initialize before the bridge plugins
-- call into its registry, which lazy.nvim guarantees via dependencies.

return {
  -- Core Mason installer UI and registry.
  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    build = ":MasonUpdate",
    config = function()
      local mason_ok, mason = pcall(require, "mason")
      if not mason_ok then
        vim.notify("[yoda] Failed to load mason: " .. tostring(mason), vim.log.levels.WARN)
        return
      end
      local setup_ok, err = pcall(mason.setup)
      if not setup_ok then
        vim.notify("[yoda] mason.setup failed: " .. tostring(err), vim.log.levels.WARN)
      end
    end,
  },

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
      -- Configure all LSP servers first via vim.lsp.config() so that when
      -- mason-lspconfig calls vim.lsp.enable() below, the configs are already
      -- in place. This matters for buffers that are already open when VeryLazy
      -- fires — vim.lsp.enable() triggers doautoall immediately, so a nil
      -- config at that point means already-open buffers never get a server.
      require("yoda.lsp").setup()

      -- Enable installed servers. mason-lspconfig's automatic_enable feature
      -- calls vim.lsp.enable() for each installed server, which creates the
      -- FileType autocmd and starts the server for any already-open buffers.
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "lua_ls",
          "ts_ls",
          "basedpyright",
          "yamlls",
          "marksman", -- Markdown LSP server
          -- NOTE: jdtls (Java/Groovy) is intentionally absent — it requires
          -- manual installation (e.g. `brew install jdtls`) because Mason
          -- cannot configure the workspace directory and JVM flags it needs.
        },
        -- Override the default handler to prevent mason-lspconfig from
        -- auto-configuring servers. All vim.lsp.config calls are made
        -- exclusively by yoda.lsp.setup() above.
        handlers = {
          function(server_name)
            -- Skip pyright — we use basedpyright instead
            if server_name == "pyright" then
              return
            end
            -- All other servers: do nothing here; yoda.lsp.setup() configured them
          end,
        },
      })
    end,
  },

  -- Ensures DAP adapters (codelldb, debugpy, js-debug-adapter) are installed
  -- via Mason so nvim-dap language configs can reference them by name.
  {
    "jay-babu/mason-nvim-dap.nvim",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "debugpy", "delve", "js-debug-adapter" },
        automatic_installation = true,
        handlers = {},
      })
    end,
  },
}
