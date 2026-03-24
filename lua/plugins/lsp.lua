-- lua/plugins_new/lsp.lua
-- LSP configuration plugins

return {
  -- lazydev.nvim — fast Lua type annotations and API completion for Neovim plugins.
  -- Replaces neodev.nvim. Only active for Lua files; blink.cmp sources it via
  -- the lazydev.integrations.blink module.
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

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
}
