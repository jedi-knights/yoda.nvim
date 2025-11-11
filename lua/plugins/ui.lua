-- lua/plugins_new/ui.lua
-- UI enhancement plugins (colorscheme, statusline, bufferline, dashboard, etc)

return {
  -- Tokyo Night - Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Bufferline - Visual buffer tabs
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          themable = true,
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,
          indicator = {
            icon = "▎",
            style = "icon",
          },
          buffer_close_icon = "󰅖",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level)
            local icon = level:match(vim.log.levels.ERROR) and " " or " "
            return " " .. icon .. count
          end,
          offsets = {
            {
              filetype = "snacks-explorer",
              text = "File Explorer",
              text_align = "center",
              separator = true,
            },
          },
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          separator_style = "thin",
          always_show_bufferline = true,
        },
      })
    end,
  },

  -- Alpha - Dashboard
  {
    "goolord/alpha-nvim",
    event = function()
      -- Only load alpha if no files were opened at startup
      if vim.fn.argc() == 0 then
        return "VimEnter"
      end
      return nil
    end,
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Set header
      dashboard.section.header.val = {
        "                                                     ",
        "        ██╗   ██╗ ██████╗ ██████╗  █████╗            ",
        "        ╚██╗ ██╔╝██╔═══██╗██╔══██╗██╔══██╗           ",
        "         ╚████╔╝ ██║   ██║██║  ██║███████║           ",
        "          ╚██╔╝  ██║   ██║██║  ██║██╔══██║           ",
        "           ██║   ╚██████╔╝██████╔╝██║  ██║           ",
        "           ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═╝           ",
        "                                                     ",
        "                                                     ",
      }

      -- Set menu
      dashboard.section.buttons.val = {
        dashboard.button("a", "🤖  Open Code AI", "<leader>ai"),
        dashboard.button("e", "📁  Open Explorer", "<leader>eo"),
        dashboard.button("f", "🔍  Find Files", "<leader>ff"),
        dashboard.button("g", "🔎  Find Text", "<leader>fg"),
        dashboard.button("r", "📋  Recent Files", ":Telescope oldfiles<CR>"),
        dashboard.button("l", "🔧  Lazy", ":Lazy<CR>"),
        dashboard.button("q", "❌  Quit", ":qa<CR>"),
      }

      -- Set footer
      dashboard.section.footer.val = "May the force be with you"

      -- Configure alpha options
      local alpha_config = {
        layout = {
          { type = "padding", val = 10 },
          dashboard.section.header,
          { type = "padding", val = 2 },
          dashboard.section.buttons,
          { type = "padding", val = 1 },
          dashboard.section.footer,
          { type = "padding", val = 2 },
        },
        opts = {
          margin = 5,
          redraw_on_resize = true, -- Enable to recenter when explorer opens
          setup = function()
            -- Use proper scopes for options that support them
            vim.opt_local.laststatus = 0
            vim.opt_local.ruler = false
            vim.opt_local.showcmd = false
            vim.opt_local.cmdheight = 0
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
          end,
        },
      }

      -- Send config to alpha
      alpha.setup(alpha_config)
    end,
  },

  -- Dressing.nvim - Better default UI for vim.ui.select and vim.ui.input
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = {
        enabled = true,
        border = "rounded",
      },
      select = {
        enabled = true,
        backend = { "builtin" }, -- Use simple builtin (no fancy UI that might crash)
        builtin = {
          border = "rounded",
          relative = "editor",
          mappings = {
            ["<Esc>"] = "Close",
            ["<C-c>"] = "Close",
            ["<CR>"] = "Confirm",
          },
        },
      },
    },
  },

  -- Noice - Enhanced UI components (minimal config for LSP only)
  {
    "folke/noice.nvim",
    priority = 1200, -- Load early to ensure vim.notify is set up before other plugins
    event = "VimEnter", -- Load earlier than VeryLazy to avoid conflicts
    enabled = true, -- Re-enabled: works with fzf-lua (fzf-lua doesn't conflict like Snacks/Telescope)
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

  -- Lualine - Statusline with git branch display
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            "branch", -- Shows current git branch
            "diff",
            "diagnostics",
          },
          lualine_c = {
            {
              function()
                return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
              end,
              icon = "📁",
            },
            "filename",
          },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "trouble", "aerial" },
      })
    end,
  },

  -- Aerial - Code outline window
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialNavToggle" },
    config = function()
      require("aerial").setup({
        backends = { "lsp", "treesitter", "markdown", "man" },
        layout = {
          max_width = { 40, 0.2 },
          width = nil,
          min_width = 30,
          default_direction = "prefer_right",
        },
        attach_mode = "global",
        filter_kind = false,
        show_guides = true,
        guides = {
          mid_item = "├─",
          last_item = "└─",
          nested_top = "│ ",
          whitespace = "  ",
        },
      })
    end,
  },
}
