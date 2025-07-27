-- lua/yoda/plugins/spec/lsp.lua
-- Consolidated LSP plugin specifications

local plugins = {
  -- Mason - LSP, DAP, and linter installer
  {
    "williamboman/mason.nvim",
    lazy = false,
    -- Note: MasonUpdate build command disabled to avoid async issues
    config = function()
      local mason_ok, mason = pcall(require, "mason")
      if mason_ok then
        mason.setup()
      end
    end,
  },

  -- Mason LSP Config - Automatic LSP server installation
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

  -- Nvim LSP Config - LSP client configurations
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

  -- Mason Tool Installer - Automatic tool installation
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

  -- None LS - Format on save and linters
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

  -- Rust Tools - Enhanced Rust development
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

  -- Nvim Treesitter - Syntax highlighting and language parsing
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- Auto-update parsers when installing
    event = { "BufReadPost", "BufNewFile" }, -- Lazy-load after opening a file
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- Text objects for treesitter
      "JoosepAlviste/nvim-ts-context-commentstring", -- Context-aware commenting
      "windwp/nvim-ts-autotag", -- Auto-close HTML tags
      "nvim-treesitter/nvim-treesitter-refactor", -- Refactoring support
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "c",
          "cpp",
          "go",
          "html",
          "javascript",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "tsx",
          "rust",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
          "dockerfile",
          "css",
          "gitignore",
          -- Snacks.image additions:
          "latex",
          "norg",
          "scss",
          "svelte",
          "typst",
          "vue",
          "regex",
        },
        highlight = {
          enable = true,         -- Highlight code
          additional_vim_regex_highlighting = false, -- Don't mix Vim's regex highlighting
        },
        indent = {
          enable = true,         -- Smarter indentation
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",          -- Start selection with Enter
            node_incremental = "<CR>",         -- Expand to next node with Enter
            node_decremental = "<BS>",         -- Shrink node with Backspace
            scope_incremental = false,         -- No scope selection
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Enable lookahead for better selection
            keymaps = {
              ["af"] = "@function.outer", -- Select outer function
              ["if"] = "@function.inner",  -- Select inner function
              ["ac"] = "@class.outer",      -- Select outer class
              ["ic"] = "@class.inner",      -- Select inner class
              ["ap"] = "@parameter.outer",  -- Select outer parameter
              ["ip"] = "@parameter.inner",  -- Select inner parameter
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- Set jumps for easy navigation
            goto_next_start = {
              ["]m"] = "@function.outer", -- Go to next function start
            },
            goto_next_end = {
              ["]M"] = "@function.outer", -- Go to next function end
            },
            goto_previous_start = {
              ["[m"] = "@function.outer", -- Go to previous function start
            },
            goto_previous_end = {
              ["[M"] = "@function.outer", -- Go to previous function end
            },
          },
        },
      })
    end,
  },
}

return plugins 