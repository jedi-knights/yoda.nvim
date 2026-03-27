-- lua/plugins/alpha.lua

return {
  "goolord/alpha-nvim",
  lazy = false,
  priority = 50,
  cond = function()
    return vim.fn.argc() == 0
  end,
  -- init always runs regardless of cond, so these autocmds are registered
  -- even when alpha doesn't load (argc > 0). The callbacks are safe:
  -- should_show_alpha() returns false when a file is already open, and
  -- has_alpha_buffer() short-circuits the BufEnter check immediately.
  init = function()
    local autocmd = vim.api.nvim_create_autocmd
    local augroup = vim.api.nvim_create_augroup

    -- Show alpha dashboard on startup if no files; cd into a directory arg.
    autocmd("VimEnter", {
      group = augroup("YodaStartup", { clear = true }),
      desc = "Show alpha dashboard on startup if no files",
      callback = function()
        if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
          vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
        end

        vim.defer_fn(function()
          local alpha_manager = require("yoda.ui.alpha_manager")
          if alpha_manager.should_show_alpha(require("yoda.buffer.state_checker").is_buffer_empty) then
            alpha_manager.show_alpha_dashboard()
          end
        end, 200)
      end,
    })

    -- Close alpha when a real file opens, then self-disable — once alpha is
    -- gone it can never re-appear, so the BufEnter check becomes a no-op.
    autocmd("BufEnter", {
      group = augroup("YodaAlphaClose", { clear = true }),
      desc = "Close alpha dashboard when opening real files",
      callback = function(args)
        local alpha_manager = require("yoda.ui.alpha_manager")
        if not alpha_manager.has_alpha_buffer() then
          return
        end

        local buf = args.buf
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        local bo = vim.bo[buf]
        local bufname = vim.api.nvim_buf_get_name(buf)
        if bo.buftype == "" and bo.filetype ~= "" and bo.filetype ~= "alpha" and bufname ~= "" then
          vim.schedule(function()
            alpha_manager.close_all_alpha_buffers()
            pcall(vim.api.nvim_del_augroup_by_name, "YodaAlphaClose")
          end)
        end
      end,
    })
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
      dashboard.button("a", "🤖  Open Code AI", "<cmd>ClaudeCode<CR>"),
      dashboard.button("e", "📁  Open Explorer", "<cmd>lua require('snacks').explorer.open()<CR>"),
      dashboard.button("f", "🔍  Find Files", "<cmd>FzfLua files<CR>"),
      dashboard.button("g", "🔎  Find Text", "<cmd>FzfLua live_grep<CR>"),
      dashboard.button("r", "📋  Recent Files", ":FzfLua oldfiles<CR>"),
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
