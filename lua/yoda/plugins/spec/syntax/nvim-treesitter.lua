-- lua/yoda/plugins/spec/nvim-treesitter.lua
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
        "rust",
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
}

