-- lua/lazy-plugins.lua
-- Setup lazy.nvim with plugins

require("lazy").setup({
  -- Core specs: one plugin per file in lua/yoda/plugins/. Includes
  -- foundation.lua, which carries the six first-party yoda-* siblings
  -- that used to be declared inline here.
  { import = "yoda.plugins" },

  -- Opt-in language stacks. In the v1.0.0 plugin+starter shape these lines
  -- live in the starter and users delete the ones they do not want (see
  -- ARCHITECTURE.md "Extras loading"). This repo is still its own config
  -- until Step 3 publishes yoda-starter, so it imports all five: every one
  -- of these plugins was unconditionally installed before the extras split.
  { import = "yoda.extras.lang.lua" },
  { import = "yoda.extras.lang.go" },
  { import = "yoda.extras.lang.node" },
  { import = "yoda.extras.lang.python" },
  { import = "yoda.extras.lang.rust" },

  -- User customizations: add your own plugins in lua/custom/plugins/
  -- This directory is gitignored so your changes won't conflict with upstream
  -- yoda updates.
  -- See lua/custom/plugins/init.lua for instructions.
  { import = "custom.plugins" },
}, {
  defaults = {
    lazy = true,
    version = false,
  },
  install = {
    colorscheme = { "tokyonight" },
  },
  checker = { enabled = false },
  change_detection = {
    enabled = false,
    notify = false,
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      -- Plugins removed from the runtimepath after lazy.setup() resets it.
      -- This is stronger than vim.g["loaded_*"] guards: those prevent sourcing
      -- but leave the files in rtp; this physically excludes the dirs.
      --
      -- RELATION TO options.lua: entries marked (*) also appear in that file's
      -- disabled_built_ins list as early loaded guards. Both layers are kept
      -- intentionally — the loaded guard fires before rtp reset; this list
      -- enforces exclusion permanently after. Entries unique to THIS list
      -- (matchparen, rplugin, tohtml) don't need early guards because they
      -- are not auto-loaded before lazy.setup() runs.
      disabled_plugins = {
        "gzip", -- (*)
        "matchit", -- (*)
        "matchparen", -- not in options.lua; no early-guard needed
        "netrwPlugin", -- (*)
        "rplugin", -- not in options.lua; no early-guard needed
        "tarPlugin", -- (*)
        "tohtml", -- not in options.lua; no early-guard needed
        "zipPlugin", -- (*)
        -- (*) note: options.lua uses "spellfile_plugin" (guard name differs)
        "spellfile",
        "2html_plugin", -- (*)
        "getscript", -- (*)
        "getscriptPlugin", -- (*)
        "logipat", -- (*)
        "rrhelper", -- (*)
        "vimball", -- (*)
        "vimballPlugin", -- (*)
      },
    },
  },
  ui = {
    border = "rounded",
    backdrop = 100,
  },
})
