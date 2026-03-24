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
          -- "comment" intentionally omitted: it is a pure injection parser
          -- that runs over every buffer in every language, adding injection
          -- query overhead on every file open. Per-language comment
          -- highlighting is already handled natively by each language's own
          -- parser, so the extra parser provides no benefit.
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

  -- vim-sleuth: detect indentation settings (tabstop, shiftwidth, expandtab)
  -- from the file content and neighbouring files. Silently corrects for
  -- projects that use tabs when options.lua defaults to spaces and vice-versa.
  { "tpope/vim-sleuth", event = "BufReadPost" },

  -- which-key: shows pending keymap completions after a brief delay.
  -- Group labels turn the raw key list into a navigable menu.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 0,
      preset = "helix",
      icons = { mappings = true, keys = {} },
      spec = {
        { "<leader>a", group = "AI" },
        { "<leader>s", group = "Search" },
        { "<leader>t", group = "Toggle/Test" },
        { "<leader>d", group = "Debug" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git Hunk", mode = { "n", "v" } },
        { "<leader>w", group = "Window" },
        { "<leader>x", group = "Diagnostics" },
        -- Explicit entry so leader-D isn't swallowed by the leader-d Debug group
        { "<leader>D", desc = "Delete buffer content" },
      },
    },
  },

  -- mini.ai: extended text objects using treesitter.
  -- Adds `an`/`in` (next), `af`/`if` (function), `ac`/`ic` (class), etc.
  -- n_lines = 50 means it looks up to 50 lines away for the object boundary,
  -- which handles long functions without missing the closing brace.
  -- Deferred to InsertEnter because text objects are only relevant while editing.
  {
    "echasnovski/mini.ai",
    event = "InsertEnter",
    opts = { n_lines = 50 },
  },

  -- mini.pairs: auto-close brackets, quotes, and other paired characters.
  -- Loaded on InsertEnter so it does not add to startup time.
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },
}
