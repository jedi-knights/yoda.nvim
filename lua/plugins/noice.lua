-- lua/plugins/noice.lua
-- Loaded after the colorscheme (priority 900) so noice highlight groups
-- are registered after tokyonight applies its theme. noice intercepts
-- vim.notify directly — no adapter backend flag is needed.

return {
  "folke/noice.nvim",
  lazy = false,
  priority = 900,
  dependencies = {
    "MunifTanjim/nui.nvim",
    -- nvim-notify is intentionally excluded: noice uses its built-in mini
    -- backend for the "notify" view. The mini backend is lighter-weight and
    -- avoids an extra dependency. If nvim-notify is installed separately,
    -- noice will auto-detect and use it instead.
  },
  config = function()
    require("noice").setup({
      cmdline = {
        view = "cmdline_popup",
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
        view = "popup",
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
          -- cmp.entry.get_documentation not overridden: uses blink.cmp, not nvim-cmp
        },
        hover = {
          silent = false,
          view = "hover",
        },
        -- Signature help disabled: blink.cmp owns textDocument/signatureHelp.
        -- Both intercepting the same LSP response causes duplicate popups.
        signature = {
          enabled = false,
        },
      },
      views = {
        hover = {
          -- Noice sets its own border; the global winborder = "rounded" in
          -- options.lua also applies to noice floats on Neovim 0.12+. Both
          -- resolve to the same style, so there is no visual conflict.
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
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    })
  end,
}
