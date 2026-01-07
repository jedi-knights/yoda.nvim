-- lua/plugins_new/explorer.lua
-- File explorer and navigation plugins

return {
  -- Snacks - Modern UI framework with explorer
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("snacks").setup({
        bigfile = {
          enabled = true,
          size = 1.5 * 1024 * 1024,
          setup = function(ctx)
            vim.cmd("syntax off")
            vim.opt_local.spell = false
            vim.opt_local.foldmethod = "manual"
            vim.opt_local.undolevels = -1
            vim.opt_local.swapfile = false
            vim.opt_local.list = false
            vim.schedule(function()
              vim.bo[ctx.buf].syntax = ctx.ft
            end)
          end,
        },
        quickfile = {
          enabled = true,
        },
        statuscolumn = {
          enabled = true,
          left = { "mark", "sign" },
          right = { "fold", "git" },
          folds = {
            open = true,
            git_hl = true,
          },
          git = {
            patterns = { "GitSign", "MiniDiffSign" },
          },
        },
        explorer = {
          enabled = true,
          show_hidden = true,
          show_ignored = true,
          win = {
            position = "left",
            width = 30,
            wo = {
              winfixwidth = true,
              winfixheight = true,
              number = false,
              relativenumber = false,
              wrap = false,
            },
          },
          on_buf_enter = function(buf, win)
            local ft = vim.bo[buf].filetype
            local bt = vim.bo[buf].buftype

            if ft ~= "snacks-explorer" and bt == "" then
              local main_win = nil
              for _, w in ipairs(vim.api.nvim_list_wins()) do
                local w_buf = vim.api.nvim_win_get_buf(w)
                local w_ft = vim.bo[w_buf].filetype
                if w ~= win and w_ft ~= "snacks-explorer" and w_ft ~= "opencode" then
                  main_win = w
                  break
                end
              end

              if not main_win then
                vim.cmd("rightbelow vsplit")
                main_win = vim.api.nvim_get_current_win()
              end

              vim.api.nvim_win_set_buf(main_win, buf)
              vim.api.nvim_set_current_win(main_win)
              return false
            end
            return true
          end,
        },
        notifier = {
          enabled = false,
        },
        picker = {
          enabled = false,
          ui_select = false,
        },
        terminal = {
          enabled = true,
          auto_close = true,
        },
        input = {
          enabled = true,
          win = {
            border = "rounded",
          },
        },
      })

      -- Global autocmd to handle file opening from explorer context
      vim.api.nvim_create_augroup("ExplorerFileOpen", { clear = true })
      vim.api.nvim_create_autocmd("BufReadPost", {
        group = "ExplorerFileOpen",
        callback = function(args)
          local buf = args.buf
          local current_win = vim.api.nvim_get_current_win()
          local current_buf = vim.api.nvim_win_get_buf(current_win)
          local current_ft = vim.bo[current_buf].filetype

          -- If we're opening a regular file but current window is explorer
          if current_ft == "snacks-explorer" and vim.bo[buf].buftype == "" then
            -- Find a non-explorer window or create one
            local target_win = nil
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local win_buf = vim.api.nvim_win_get_buf(win)
              local win_ft = vim.bo[win_buf].filetype
              if win_ft ~= "snacks-explorer" and win_ft ~= "opencode" then
                target_win = win
                break
              end
            end

            if not target_win then
              vim.cmd("rightbelow vsplit")
              target_win = vim.api.nvim_get_current_win()
            end

            vim.api.nvim_win_set_buf(target_win, buf)
            vim.api.nvim_set_current_win(target_win)
          end
        end,
      })
    end,
  },

  -- Devicons - File type icons
  {
    "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
      require("nvim-web-devicons").setup({
        default = true,
        strict = false,
      })
    end,
  },
}
