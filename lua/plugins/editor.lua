-- lua/plugins/editor.lua
-- editor plugins

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        lazy = true,
      },
    },
    config = function()
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.gherkin = {
        install_info = {
          url = "https://github.com/binhtran432k/tree-sitter-gherkin",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "main",
        },
        filetype = "feature",
      }

      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "python",
          "rust",
          "go",
          "javascript",
          "typescript",
          "c_sharp",
          "json",
          "yaml",
          "toml",
          "markdown",
          "markdown_inline",
          "bash",
          "regex",
          "gherkin",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
        },
      })

      vim.treesitter.language.register("gherkin", "feature")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "feature",
        callback = function()
          vim.bo.commentstring = "# %s"
        end,
      })

      -- Treesitter foldexpr disabled: setting foldmethod=expr causes Neovim to
      -- re-evaluate the foldexpr on every text change, adding measurable typing
      -- lag. Manual folding (set in options.lua) is used instead.
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = true,
  },
}
