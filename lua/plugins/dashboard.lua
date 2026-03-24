-- lua/plugins/dashboard.lua
-- Startup dashboard shown when Neovim is opened with no file arguments

return {
  {
    "goolord/alpha-nvim",
    lazy = false,
    priority = 50,
    cond = function()
      return vim.fn.argc() == 0
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
}
