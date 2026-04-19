-- lua/plugins/snacks.lua

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("snacks").setup({
      dashboard = {
        enabled = true,
        -- Only show on startup with no files (matches previous alpha cond).
        -- snacks handles this natively via its own startup detection.
        preset = {
          header = [[

        ██╗   ██╗ ██████╗ ██████╗  █████╗
        ╚██╗ ██╔╝██╔═══██╗██╔══██╗██╔══██╗
         ╚████╔╝ ██║   ██║██║  ██║███████║
          ╚██╔╝  ██║   ██║██║  ██║██╔══██║
           ██║   ╚██████╔╝██████╔╝██║  ██║
           ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═╝
                                                     ]],
          keys = {
            { icon = "🤖", key = "a", desc = "Open Code AI", action = "<cmd>ClaudeCode<CR>" },
            {
              icon = "📁",
              key = "e",
              desc = "Open Explorer",
              action = function()
                require("snacks").explorer.open()
              end,
            },
            {
              icon = "🔍",
              key = "f",
              desc = "Find Files",
              action = function()
                require("mini.pick").builtin.files()
              end,
            },
            {
              icon = "🔎",
              key = "g",
              desc = "Find Text",
              action = function()
                require("mini.pick").builtin.grep_live()
              end,
            },
            {
              icon = "📋",
              key = "r",
              desc = "Recent Files",
              action = function()
                require("mini.extra").pickers.oldfiles()
              end,
            },
            { icon = "🔧", key = "l", desc = "Lazy", action = "<cmd>Lazy<CR>" },
            { icon = "❌", key = "q", desc = "Quit", action = "<cmd>qa<CR>" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
          { text = { { "May the force be with you", hl = "DashboardFooter" } }, align = "center", padding = 1 },
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
        -- Prevent buffers from being loaded into explorer window
        on_buf_enter = function(buf, win)
          local ft = vim.bo[buf].filetype
          local bt = vim.bo[buf].buftype

          -- If a regular file buffer tries to enter the explorer window, redirect it
          if ft ~= "snacks-explorer" and bt == "" then
            -- Find a suitable main window for this buffer
            local main_win = nil
            for _, w in ipairs(vim.api.nvim_list_wins()) do
              local w_buf = vim.api.nvim_win_get_buf(w)
              local w_ft = vim.bo[w_buf].filetype
              if w ~= win and w_ft ~= "snacks-explorer" then
                main_win = w
                break
              end
            end

            -- Create new window if none found
            if not main_win then
              vim.cmd("rightbelow vsplit")
              main_win = vim.api.nvim_get_current_win()
            end

            -- Switch buffer to main window immediately
            vim.api.nvim_win_set_buf(main_win, buf)
            vim.api.nvim_set_current_win(main_win)
            return false -- Prevent buffer from entering explorer
          end
          return true
        end,
      },
      notifier = {
        enabled = false, -- Disabled: noice.nvim handles vim.notify display
      },
      picker = {
        enabled = true,
        -- Keep ui_select off — mini.pick is the primary picker
        ui_select = false,
      },
      terminal = {
        enabled = true,
        auto_close = true,
      },
      image = {
        enabled = false, -- Disabled: causes treesitter range errors on picker/dashboard buffers
      },
      input = {
        enabled = true,
        win = {
          border = "rounded",
        },
      },
    })

    -- zoxide project picker — jumps to any directory in your zoxide history.
    -- Requires zoxide: brew install zoxide
    vim.keymap.set("n", "<leader>sp", function()
      if vim.fn.executable("zoxide") == 0 then
        vim.notify("zoxide is not installed. See: https://github.com/ajeetdsouza/zoxide", vim.log.levels.WARN)
        return
      end
      require("snacks").picker.zoxide({
        confirm = function(picker, item)
          picker:close()
          if item then
            vim.cmd("cd " .. vim.fn.fnameescape(item.file))
            require("snacks").dashboard()
          end
        end,
      })
    end, { desc = "[S]earch [P]rojects (zoxide)" })

    -- Global autocmd to handle file opening from explorer context
    local explorer_group = vim.api.nvim_create_augroup("ExplorerFileOpen", { clear = true })
    vim.api.nvim_create_autocmd("BufReadPost", {
      group = explorer_group,
      desc = "Redirect files opened in the explorer window to the main window",
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
            if win_ft ~= "snacks-explorer" then
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
}
