return {
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
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
        "dockerfile",
        "css",
        "gitignore",
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
    })
  end,
}

