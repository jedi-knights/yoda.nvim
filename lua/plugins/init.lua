-- lua/plugins/init.lua
-- Main plugin loader - imports all categories

return {
  -- Core utilities
  { import = "plugins.core.plenary" },
  { import = "plugins.core.treesitter" },
  { import = "plugins.core.which_key" },
  { import = "plugins.core.fixcursorhold" },
  { import = "plugins.core.nio" },

  -- Motion & Navigation
  { import = "plugins.motion.leap" },
  { import = "plugins.motion.tmux_navigator" },

  -- UI & Colors
  { import = "plugins.ui.colorscheme" },
  { import = "plugins.ui.snacks" },
  { import = "plugins.ui.bufferline" },
  { import = "plugins.ui.alpha" },
  { import = "plugins.ui.noice" },
  { import = "plugins.ui.devicons" },
  { import = "plugins.ui.lualine" },
  { import = "plugins.ui.showkeys" },

  -- LSP & Completion
  { import = "plugins.lsp.mason" },
  { import = "plugins.lsp.mason_lspconfig" },
  { import = "plugins.lsp.nvim_cmp" },

  -- File Explorer & Picker
  { import = "plugins.explorer.nvim_tree" },
  { import = "plugins.explorer.telescope" },
  { import = "plugins.explorer.telescope_fzf" },

  -- AI Integration
  { import = "plugins.ai.copilot" },
  { import = "plugins.ai.opencode" },

  -- Git Integration
  { import = "plugins.git.gitsigns" },
  { import = "plugins.git.diffview" },
  { import = "plugins.git.neogit" },

  -- Testing & Debugging
  { import = "plugins.testing.neotest" },
  { import = "plugins.testing.pytest_atlas" },
  { import = "plugins.testing.coverage" },

  -- Debugging
  { import = "plugins.debugging.dap" },
  { import = "plugins.debugging.dap_ui" },
  { import = "plugins.debugging.mason_dap" },

  -- Development Tools
  { import = "plugins.dev_tools.trouble" },
  { import = "plugins.dev_tools.aerial" },
  { import = "plugins.dev_tools.todo_comments" },
  { import = "plugins.dev_tools.overseer" },

  -- Formatters & Linters
  { import = "plugins.formatters.conform" },
  { import = "plugins.formatters.lint" },

  -- Language-Specific
  { import = "plugins.languages.rust" },
  { import = "plugins.languages.python" },
  { import = "plugins.languages.javascript" },
  { import = "plugins.languages.csharp" },
}
