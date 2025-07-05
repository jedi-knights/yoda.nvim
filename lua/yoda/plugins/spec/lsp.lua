-- lua/yoda/plugins/spec/lsp.lua
-- Consolidated LSP plugins configuration

return {
  -- Mason package manager
  {
    "williamboman/mason.nvim",
    lazy = false,
    -- build = ":MasonUpdate", -- Temporarily removed to avoid async issues
    config = function()
      local mason_ok, mason = pcall(require, "mason")
      if mason_ok then
        mason.setup()
      end
    end,
  },

  -- Mason LSP config
  {
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
            --"rust-analyzer", -- Rust
          },
        })
      end
    end,
  },

  -- LSP config
  {
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
  },

  -- Mason tool installer
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    lazy = false,
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- LSP servers
          "lua-language-server",
          "pyright",
          "gopls",
          "typescript-language-server",

          -- Linters
          "pylint",
          "ruff",
          "mypy",

          -- Formatters
          "stylua",
          "black",
          "autoflake",
          "prettier",

          -- Debuggers
          "debugpy",
          "delve",
          "debugpy",
        },
        auto_update = false,  -- set to true if you want automatic updates
        run_on_start = true,  -- install tools on startup if they're missing
      })
    end,
  },

  -- None-ls for formatting and linting
  {
    'nvimtools/none-ls.nvim',
    dependencies = {
      'nvimtools/none-ls-extras.nvim',
      'jayp0521/mason-null-ls.nvim', -- ensure dependencies are installed
    },
    config = function()
      local null_ls = require 'null-ls'
      local formatting = null_ls.builtins.formatting   -- to setup formatters
      local diagnostics = null_ls.builtins.diagnostics -- to setup linters

      -- list of formatters & linters for mason to install
      require('mason-null-ls').setup {
        ensure_installed = {
          'checkmake',
          --'prettier', -- ts/js formatter
          'stylua',   -- lua formatter
          'eslint_d', -- ts/js linter
          'eslint',   -- ts/js linter
          'shfmt',
          'ruff',
          --'black',
          'mypy',
          'flake8',
          'autoflake',
          'pylint',
        },
        -- auto-install configured formatters & linters (with null-ls)
        automatic_installation = true,
      }

      local sources = {
        -- Shell and general
        diagnostics.checkmake,
        formatting.prettier.with { filetypes = { 'html', 'json', 'yaml', 'markdown' } },
        formatting.stylua,
        formatting.shfmt.with { args = { '-i', '4' } },
        formatting.terraform_fmt,
        require('none-ls.formatting.ruff').with { extra_args = { '--extend-select', 'I' } },
        require 'none-ls.formatting.ruff_format',

        -- Python formatting
        formatting.black,
        formatting.autoflake,
        require('none-ls.formatting.ruff').with { extra_args =  { '--extend-select', 'I' } },
        require('none-ls.formatting.ruff_format'),

        -- Python diagnostics
        diagnostics.mypy,
        diagnostics.pylint,
      }

      local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
      null_ls.setup {
        debug = true, -- Enable debug mode. Inspect logs with :NullLsLog.
        log_level = "debug", -- Set log level to debug for more detailed logs
        sources = sources,
        -- you can reuse a shared lspconfig on_attach callback here
        on_attach = function(client, bufnr)
          if client.supports_method 'textDocument/formatting' then
            vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
            vim.api.nvim_create_autocmd('BufWritePre', {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format { async = false }
              end,
            })
          end
        end,
      }
    end,
  },

  -- Rust tools
  {
    "simrat39/rust-tools.nvim",
    ft = "rust", -- Lazy-load only when editing Rust files
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap", -- optional, only if you want debugging
    },
    config = function()
      local rt = require("rust-tools")

      rt.setup({
        server = {
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = {
                command = "clippy",
              },
            },
          },
          on_attach = function(_, bufnr)
            local bufmap = function(mode, lhs, rhs)
              vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
            end
            bufmap("n", "<leader>ca", rt.code_action_group.code_action_group)
          end,
        },
      })
    end,
  },
} 