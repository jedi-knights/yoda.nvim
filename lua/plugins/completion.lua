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
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        -- Accept blink item if selected, otherwise fall through to native LSP
        -- inline completion (e.g. Copilot). Returns true on success to stop the
        -- chain; false falls through to 'fallback' which passes <C-y> normally.
        ["<C-y>"] = {
          "select_and_accept",
          function()
            return vim.lsp.inline_completion.get()
          end,
          "fallback",
        },
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
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        per_filetype = {
          lua = { "lsp", "path", "snippets", "lazydev" },
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
