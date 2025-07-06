return {
  "ThePrimeagen/harpoon",
  lazy = false,
  config = function()
    local harpoon = require("harpoon")
    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

    harpoon.setup({
      menu = {
        width = vim.api.nvim_win_get_width(0) - 20,
      },
    })

    -- Harpoon Keymaps
    vim.keymap.set("n", "<leader>ha", function()
      local filename = vim.fn.expand("%:p")
      if filename == "" then
        vim.notify("Cannot mark unnamed buffer.", vim.log.levels.WARN)
        return
      end
      require("harpoon.mark").add_file()
    end, { desc = "Add file to Harpoon" })

    vim.keymap.set("n", "<leader>h1", function() ui.nav_file(1) end, { desc = "Navigate to Harpoon file 1" })
    vim.keymap.set("n", "<leader>h2", function() ui.nav_file(2) end, { desc = "Navigate to Harpoon file 2" })
    vim.keymap.set("n", "<leader>h3", function() ui.nav_file(3) end, { desc = "Navigate to Harpoon file 3" })
    vim.keymap.set("n", "<leader>h4", function() ui.nav_file(4) end, { desc = "Navigate to Harpoon file 4" })

    vim.keymap.set("n", "<leader>hm", function()
      ui.toggle_quick_menu()
    end, { desc = "Toggle Harpoon menu" })
  end,
}

