-- lua/plugins_new/completion.lua
-- Completion and snippet plugins

return {
  {
    "saghen/blink.cmp",
    -- optional: provides snippets for the snippet source
    dependencies = { "rafamadriz/friendly-snippets" },

    -- use a release tag to download pre-built binaries
    version = "1.*",
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "default" },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 500,
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
          show_on_insert_on_trigger_character = true,
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
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          lua = { "lsp", "path", "snippets" },
          python = { "lsp", "path" },
        },
        providers = {
          lsp = {
            score_offset = 100,
            max_items = 50,
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
        },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
