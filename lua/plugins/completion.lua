-- lua/plugins/completion.lua
-- Completion and snippet plugins

return {
  {
    "saghen/blink.cmp",
    -- optional: provides snippets for the snippet source
    dependencies = { "rafamadriz/friendly-snippets", "folke/lazydev.nvim" },

    event = "InsertEnter",

    -- use a release tag to download pre-built binaries
    version = "1.*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        -- Accept blink item if selected, otherwise fall through to native <C-y>.
        ["<C-y>"] = { "select_and_accept", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = { border = "rounded" },
        },
        menu = {
          border = "rounded",
          draw = {
            columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
          },
          max_height = 15,
        },
        ghost_text = {
          enabled = true,
        },
        trigger = {
          show_on_x_blocked_trigger_characters = { " ", "\n", "\t" },
        },
        list = {
          max_items = 50,
        },
      },

      signature = {
        enabled = true,
        window = { border = "rounded" },
      },

      sources = {
        -- lazydev is intentionally absent here — it's ft=lua only (plugins/lsp.lua)
        -- and is added via per_filetype below. Including it in default would cause
        -- blink to attempt require("lazydev.integrations.blink") in every non-Lua buffer.
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          lua = { "lsp", "path", "snippets", "lazydev" },
          python = { "lsp", "path", "snippets" },
        },
        providers = {
          lsp = {
            score_offset = 100,
            max_items = 50,
            -- async = true: non-default; prevents slow servers (basedpyright, jdtls)
            -- from blocking the completion menu while they compute results.
            async = true,
            timeout_ms = 500,
          },
          buffer = {
            score_offset = -3,
            max_items = 5,
            min_keyword_length = 3,
          },
          path = {
            max_items = 10,
          },
          snippets = {
            max_items = 15,
          },
          lazydev = {
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
