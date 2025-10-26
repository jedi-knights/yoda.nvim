-- lua/plugins/ui/alpha.lua
-- Alpha - Dashboard

return {
  "goolord/alpha-nvim",
  event = function()
    if vim.fn.argc() == 0 then
      return "VimEnter"
    end
    return nil
  end,
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

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

    dashboard.section.buttons.val = {
      dashboard.button("a", "🤖  Open Code AI", "<leader>ai"),
      dashboard.button("e", "📁  Open Explorer", "<leader>eo"),
      dashboard.button("f", "🔍  Find Files", "<leader>ff"),
      dashboard.button("g", "🔎  Find Text", "<leader>fg"),
      dashboard.button("r", "📋  Recent Files", ":Telescope oldfiles<CR>"),
      dashboard.button("l", "🔧  Lazy", ":Lazy<CR>"),
      dashboard.button("q", "❌  Quit", ":qa<CR>"),
    }

    dashboard.section.footer.val = "May the force be with you"

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
        redraw_on_resize = true,
        setup = function()
          vim.opt_local.laststatus = 0
          vim.opt_local.ruler = false
          vim.opt_local.showcmd = false
          vim.opt_local.cmdheight = 0
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
        end,
      },
    }

    alpha.setup(alpha_config)
  end,
}
