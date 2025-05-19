return {
  "nvim-telescope/telescope.nvim",
  lazy = false,                                                      -- load at startup (important for your keymaps)
  priority = 100,                                                    -- load before other UI
  dependencies = {
    "nvim-lua/plenary.nvim",                                         -- 🔥 mandatory dependency
    { "nvim-telescope/telescope-fzf-native.nvim",  build = "make" }, -- optional, for fzf support
    { "nvim-telescope/telescope-ui-select.nvim" },                   -- optional, for ui-select support
    { "nvim-telescope/telescope-file-browser.nvim" },                -- optional, for file browser support
    { "nvim-telescope/telescope-frecency.nvim" },                    -- optional, for frecency support
    { "nvim-telescope/telescope-github.nvim" },                      -- optional, for github support
    { "nvim-telescope/telescope-media-files.nvim" },                 -- optional, for media files support
    { "nvim-telescope/telescope-symbols.nvim" },                     -- optional, for symbols support
    { "nvim-telescope/telescope-project.nvim" },                     -- optional, for project support
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        -- optional: nice defaults
        path_display = { "smart" },
        layout_config = {
          horizontal = { width = 0.9 },
        },
        file_ignore_patterns = { "node_modules" },
      },
      pickers = {
        find_files = {
          theme = "ivy",
        }
      },
      extensions = {
        fzf = {},
      }
    })
    telescope.load_extension("fzf")          -- optional, for fzf support
    telescope.load_extension("ui-select")    -- optional, for ui-select support
    telescope.load_extension("file_browser") -- optional, for file browser support
    telescope.load_extension("frecency")     -- optional, for frecency support
    telescope.load_extension("media_files")  -- optional, for media files support
    telescope.load_extension("project")      -- optional, for project support

    local opts = { noremap = true, silent = true }

    local keymap = vim.keymap
    local builtin = require("telescope.builtin")

    keymap.set("n", "<leader>ff", builtin.find_files, opts)
    keymap.set("n", "<leader>fs", builtin.live_grep, opts)
    keymap.set("n", "<leader>fh", builtin.oldfiles, opts)

    -- search in current working directory
    keymap.set("n", "<leader>en", function()
      require('telescope.builtin').find_files({
        cwd = vim.fn.stdpath("config"),
      })
    end)

    -- search in lazy.nvim
    keymap.set("n", "<leader>ep", function()
      require('telescope.builtin').find_files({
        cwd = vim.fn.joinpath(vim.fn.stdpath("data"), "lazy"),
      })
    end)
  end,
}
