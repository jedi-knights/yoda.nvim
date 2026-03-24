-- lua/plugins/notifications.lua
-- Enhanced notification and command-line UI via noice.nvim
-- Loaded early (priority 1200) so it can intercept vim.notify before other plugins use it

return {
  {
    "folke/noice.nvim",
    lazy = false,
    priority = 1200,
    enabled = true,
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      -- Ensure vim.notify is available before setting up noice
      if not vim.notify then
        vim.notify = function(msg, level, opts)
          print(string.format("[%s] %s", level or "INFO", msg))
        end
      end

      -- Save reference to detect override conflicts
      local pre_noice_notify = vim.notify

      require("noice").setup({
        -- UI overrides (with dressing.nvim handling vim.ui.select, these should be safe)
        cmdline = {
          enabled = true, -- Re-enable noice cmdline (dressing handles vim.ui.select)
          view = "cmdline_popup", -- Use popup view
          opts = {}, -- Default options
        },
        messages = {
          enabled = true, -- Re-enable messages
          view = "notify", -- Use notify view
          view_error = "notify", -- Errors in notify
          view_warn = "notify", -- Warnings in notify
        },
        popupmenu = {
          enabled = true, -- Use noice popup menu for completion
          backend = "nui", -- Use nui backend
        },
        notify = {
          enabled = true, -- Enable noice notify (for better notifications)
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
        -- Disable the override warning since we've properly configured the notification system
        health = {
          checker = false, -- Disable health checks that might show vim.notify override warnings
        },
        -- LSP enhancements
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
          hover = {
            enabled = true,
            silent = false,
            view = "hover",
          },
          signature = {
            enabled = true,
            auto_open = {
              enabled = true,
              trigger = true,
              luasnip = true,
              throttle = 200,
            },
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
            opts = { skip = true }, -- Skip noice, let dressing handle
          },
        },
      })

      -- Verify that Noice has properly taken control of vim.notify
      vim.schedule(function()
        if vim.notify and type(vim.notify) == "function" and vim.notify ~= pre_noice_notify then
          -- Force our notification adapter to use noice
          vim.g.yoda_notify_backend = "noice"

          -- Set a flag to indicate noice is in control
          vim.g.yoda_noice_initialized = true
        else
          -- Fallback if noice didn't properly override
          vim.g.yoda_notify_backend = "native"
        end
      end)
    end,
  },
}
