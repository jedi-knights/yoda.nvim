return {
  "nvim-telescope/telescope.nvim",
  lazy = false,
  priority = 100,
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-telescope/telescope-file-browser.nvim" },
    { "nvim-telescope/telescope-frecency.nvim" },
    { "nvim-telescope/telescope-github.nvim" },
    { "nvim-telescope/telescope-media-files.nvim" },
    { "nvim-telescope/telescope-symbols.nvim" },
    { "nvim-telescope/telescope-project.nvim" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        path_display = { "smart" },
        layout_config = {
          horizontal = { width = 0.9 },
        },
        file_ignore_patterns = {
          "^.git/",
          "node_modules",
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--no-ignore",
        },
      },
      pickers = {
        find_files = {
          theme = "ivy",
          hidden = true,
          no_ignore = true,
        },
      },
      extensions = {
        fzf = {},
      },
    })

    -- Load extensions
    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")
    telescope.load_extension("file_browser")
    telescope.load_extension("frecency")
    telescope.load_extension("media_files")
    telescope.load_extension("project")

    local opts = { noremap = true, silent = true }
    local keymap = vim.keymap
    local builtin = require("telescope.builtin")

    -- General file finding
    keymap.set("n", "<leader>ff", builtin.find_files, opts)
    keymap.set("n", "<leader>fs", builtin.live_grep, opts)
    keymap.set("n", "<leader>fh", builtin.oldfiles, opts)

    -- Project/user-specific
    keymap.set("n", "<leader>uc", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config"), hidden = true, no_ignore = true })
    end, { desc = "Find User Config" })

    keymap.set("n", "<leader>up", function()
      builtin.find_files({ cwd = vim.fn.stdpath("data") .. "/lazy", hidden = true, no_ignore = true })
    end, { desc = "Find Plugin Files" })
  end,
}
