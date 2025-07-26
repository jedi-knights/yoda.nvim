-- lua/yoda/plugins/spec/markdown.lua
-- Consolidated markdown and obsidian plugin specifications

local plugins = {
  -- Render Markdown - Markdown rendering and preview
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    config = function(_, opts)
      local plugin_loader = require("yoda.utils.plugin_loader")
      plugin_loader.safe_plugin_setup("render-markdown", opts)
    end,
    opts = {
      render_modes = { 'n', 'c', 't' }, -- render modes to use
    },
  },

  -- Obsidian - Obsidian vault integration and note-taking
  {
    "epwalsh/obsidian.nvim",
    version = "*",  -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",

      -- see below for full list of optional dependencies 👇
    },
    config = function(_, opts)
      local plugin_loader = require("yoda.utils.plugin_loader")
      plugin_loader.safe_plugin_setup("obsidian", opts)
    end,
    opts = {
      workspaces = {
        {
          name = "main",
          path = "~/Documents/Obsidian",
        },
      },
    },
  },
}

return plugins 