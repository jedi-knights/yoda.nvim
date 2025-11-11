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
        explorer = {
          enabled = true,
          win = {
            position = "left",
            width = 30,
            wo = {
              winfixwidth = true,
              winfixheight = true, -- Prevent height changes
              number = false,
              relativenumber = false,
              wrap = false,
            },
          },
          -- Prevent buffers from being loaded into explorer window
          on_buf_enter = function(buf, win)
            local ft = vim.bo[buf].filetype
            local bt = vim.bo[buf].buftype

            -- If a regular file buffer tries to enter the explorer window, redirect it
            if ft ~= "snacks-explorer" and bt == "" then
              vim.schedule(function()
                -- Find a suitable main window for this buffer
                local main_win = nil
                for _, w in ipairs(vim.api.nvim_list_wins()) do
                  local w_buf = vim.api.nvim_win_get_buf(w)
                  local w_ft = vim.bo[w_buf].filetype
                  if w ~= win and w_ft ~= "snacks-explorer" and w_ft ~= "opencode" then
                    main_win = w
                    break
                  end
                end

                -- Create new window if none found
                if not main_win then
                  vim.cmd("rightbelow vsplit")
                  main_win = vim.api.nvim_get_current_win()
                end

                -- Switch buffer to main window
                vim.api.nvim_win_set_buf(main_win, buf)
                vim.api.nvim_set_current_win(main_win)
              end)
              return false -- Prevent buffer from entering explorer
            end
            return true
          end,
        },
        notifier = {
          enabled = false, -- Disabled: Using Noice for notifications to avoid vim.notify conflicts
        },
        picker = {
          enabled = false, -- Disabled: Snacks picker causes crashes in Neovim 0.11.x - use Telescope instead
          ui_select = false, -- Disabled: Using dressing.nvim instead
        },
        terminal = {
          enabled = true,
          auto_close = true, -- Auto-close terminal buffer when process exits (no "Process Exited" message)
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
            vim.schedule(function()
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
            end)
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
