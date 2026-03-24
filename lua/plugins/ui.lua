-- lua/plugins/ui.lua
-- Core UI chrome: colorscheme, buffer tabs, input/select widgets, key screencaster

return {
  -- Tokyo Night - Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.schedule(function()
        local ok = pcall(vim.cmd, "colorscheme tokyonight")
        if not ok then
          vim.notify("Colorscheme 'tokyonight' not found!", vim.log.levels.ERROR)
        end
      end)
    end,
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

  -- Showkeys - Minimal keys screencaster
  {
    "nvzone/showkeys",
    cmd = { "ShowkeysToggle", "Showkeys" },
    opts = {
      timeout = 1,
      maxkeys = 5,
      position = "top-right",
    },
  },
}
