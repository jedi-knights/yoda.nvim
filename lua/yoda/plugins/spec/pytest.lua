return {
  "richardhapb/pytest.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {}, -- Define the options here
  config = function(_, opts)
    require('nvim-treesitter.configs').setup {
      ensure_installed = { 'python', 'xml' },
    }

    require('pytest').setup(opts)

    vim.keymap.set("n", "<leader>tt", function()
      require("pytest").test_class()
    end, { desc = "Pytest: Run Class" })

    vim.keymap.set("n", "<leader>tn", function()
      require("pytest").test_method()
    end, { desc = "Pytest: Run Nearest Test Method" })

    vim.keymap.set("n", "<leader>tf", function()
      require("pytest").test_file()
    end, { desc = "Pytest: Run File" })
  end
}

