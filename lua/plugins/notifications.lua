-- lua/plugins/notifications.lua
-- Enhanced notification and command-line UI via noice.nvim
-- Loaded early (priority 1200) so it can intercept vim.notify before other plugins use it

return {
  {
    "folke/noice.nvim",
    lazy = false,
    priority = 1200,
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("noice").setup({
        cmdline = {
          view = "cmdline_popup",
          opts = {},
        },
        messages = {
          view = "notify",
          view_error = "notify",
          view_warn = "notify",
        },
        popupmenu = {
          backend = "nui",
        },
        notify = {
          view = "notify",
        },
        history = {
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {
            any = {
              { event = "notify" },
              { error = true },
              { warning = true },
              { event = "msg_show", kind = { "" } },
              { event = "lsp", kind = "message" },
            },
          },
        },
        health = {
          checker = false,
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            -- ["cmp.entry.get_documentation"] removed: nvim-cmp not installed (uses blink.cmp)
          },
          hover = {
            silent = false,
            view = "hover",
          },
          -- Signature help disabled here: blink.cmp owns textDocument/signatureHelp.
          -- Both intercepting the same LSP response causes duplicate popups.
          signature = {
            enabled = false,
          },
        },
        views = {
          hover = {
            border = {
              style = "rounded",
            },
            position = { row = 2, col = 0 },
            win_options = {
              winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
            },
          },
        },
        presets = {
          bottom_search = true, -- Noice bottom search
          command_palette = true, -- Noice command palette
          long_message_to_split = true, -- Split long messages
          inc_rename = false,
          lsp_doc_border = true, -- Borders on LSP docs
        },
        routes = {
          -- Route vim.ui.select to dressing (prevent noice from intercepting)
          {
            filter = {
              event = "msg_show",
              kind = "confirm",
            },
            opts = { skip = true },
          },
        },
      })

      -- noice is loaded unconditionally (lazy = false, priority = 1200) and always
      -- overrides vim.notify; tell the notification adapter which backend is active.
      vim.g.yoda_notify_backend = "noice"
    end,
  },
}
