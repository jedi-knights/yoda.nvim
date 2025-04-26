-- lua/yoda/plugins/spec/treesitter.lua

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- Auto-update parsers when installing
    event = { "BufReadPost", "BufNewFile" }, -- Lazy-load after opening a file
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
          },
        },
      })
    end,
  },
}

