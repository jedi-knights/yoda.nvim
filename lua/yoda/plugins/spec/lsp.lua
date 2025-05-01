-- lua/yoda/plugins/spec/lsp.lua

return {
  -- LSP configuration and installation manager
  {
    "williamboman/mason.nvim",
    lazy = false,
    build = ":MasonUpdate", -- Update installed servers on install
    config = function()
      require("mason").setup()
    end,
  },

  -- Bridges Mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",   -- Lua
          "pyright",  -- Python
          "gopls",    -- Go
          "ts_ls", -- JavaScript/TypeScript
        },
      })
    end,
  },

  -- Native LSP configuration
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local lspconfig = require("lspconfig")
      local lsp = require("yoda.lsp")

      -- List of language servers
      local servers = {
        lua_ls = require("yoda.lsp.servers.lua_ls"),
        pyright = require("yoda.lsp.servers.pyright"),
        gopls = require("yoda.lsp.servers.gopls"),
        eslint = require("yoda.lsp.servers.eslint"),
        ts_ls = require("yoda.lsp.servers.ts_ls"),
      }

      for name, opts in pairs(servers) do
        lspconfig[name].setup(vim.tbl_deep_extend("force", {
          on_attach = lsp.on_attach,
          capabilities = lsp.capabilities(),
        }, opts))
      end
    end,
  },

  -- Autocompletion engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
      "hrsh7th/cmp-buffer",   -- Buffer completions
      "hrsh7th/cmp-path",     -- Path completions
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
      "L3MON4D3/LuaSnip",     -- Snippet engine
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}

