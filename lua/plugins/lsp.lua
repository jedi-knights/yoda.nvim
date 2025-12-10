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
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    config = function()
      -- Setup mason-lspconfig first
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "lua_ls",
          "ts_ls",
          "basedpyright",
          "yamlls",
          "marksman", -- Markdown LSP server
        },
        -- Prevent mason from auto-configuring pyright (we use basedpyright)
        handlers = {
          -- Default handler for all servers
          function(server_name)
            -- Skip pyright - we use basedpyright instead
            if server_name == "pyright" then
              return
            end
          end,
        },
      })

      -- Then setup our modern LSP configuration
      require("yoda.lsp").setup()
    end,
  },
}
