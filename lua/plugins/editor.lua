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
      -- 200ms: fast enough to catch deliberate pauses, won't flash on rapid sequences.
      -- delay = 0 showed the popup on every partial keystroke, creating visual noise.
      delay = 200,
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
  -- VeryLazy (not InsertEnter): text objects are used in normal and operator-
  -- pending mode, so they must be available before insert mode is ever entered.
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = { n_lines = 50 },
  },

  -- mini.surround: add/change/delete surrounding characters.
  -- gz prefix chosen to avoid conflict with leap.nvim's `s`/`S` bindings:
  -- `s` is already leap-forward; using `sa` would force a 1s timeout on every
  -- bare `s` keystroke while Neovim waits to see if `a` follows.
  -- gza{motion}{char} — add, gzd{char} — delete, gzr{old}{new} — replace.
  -- e.g. gzaiw" wraps word in quotes, gzr'" changes ' to ", gzd" removes quotes.
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "gza",
        delete = "gzd",
        replace = "gzr",
        find = "gzf",
        find_left = "gzF",
        highlight = "gzh",
        update_n_lines = "gzn",
      },
    },
  },

  -- mini.pairs: auto-close brackets, quotes, and other paired characters.
  -- Loaded on InsertEnter so it does not add to startup time.
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- mini.comment: treesitter-aware commenting via gc/gcc.
  -- Neovim 0.10+ has native gc, but it uses &commentstring which breaks in
  -- embedded-language contexts (JSX, template strings, mixed HTML/JS).
  -- mini.comment detects the correct comment syntax from the treesitter node
  -- under the cursor, so gc works correctly regardless of nesting.
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = {},
  },

  -- vim-repeat: makes plugin-defined operators repeatable with `.`.
  -- Without it, `.` after a surround change or other plugin motion replays
  -- only the native portion of the action and silently ignores the rest.
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- yanky.nvim: persistent yank ring — cycle through past yanks after pasting.
  -- Replaces p/P with versions that remember history; after pasting, <C-p>/<C-n>
  -- cycle backward/forward through prior yanks without re-yanking anything.
  -- Solves the common case: yank A, yank B, paste — want A but get B.
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    opts = {
      ring = {
        history_length = 20,
        storage = "memory", -- no sqlite dependency
        sync_with_numbered_registers = true,
      },
      highlight = { on_put = true, on_yank = false, timer = 150 },
    },
    keys = {
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Paste after (yank ring)" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Paste before (yank ring)" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Paste after, cursor after" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Paste before, cursor after" },
      { "<C-p>", "<Plug>(YankyPreviousEntry)", desc = "Cycle to previous yank" },
      { "<C-n>", "<Plug>(YankyNextEntry)", desc = "Cycle to next yank" },
    },
  },
}
