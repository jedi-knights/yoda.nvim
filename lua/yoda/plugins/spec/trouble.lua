return {
  "folke/trouble.nvim",
  opts = {}, -- for default options, refer to the configuration section for custom setup.
  cmd = "Trouble",
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>xX",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>cs",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>cl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    {
      "<leader>xL",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>xQ",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
    {
      "<leader>xj",
      function()
        vim.cmd("Trouble toggle mode=jumplist")
        vim.defer_fn(function()
          for win = 1, vim.fn.winnr('$') do
            local bufname = vim.fn.bufname(vim.fn.winbufnr(win))
            if bufname:match("Trouble") then
              vim.fn.win_gotoid(vim.fn.win_getid(win))
              break
            end
          end
        end, 50)
      end,
      desc = "Jumplist (Trouble) + Jump Focus",
    },
  },
}

