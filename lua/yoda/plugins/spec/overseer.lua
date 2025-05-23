return {
  "stevearc/overseer.nvim",
  config = function()
    require("overseer").setup()
    require("telescope").load_extension("overseer")
  end,
  dependencies = { "nvim-telescope/telescope.nvim" },
  keys = {
    { "<leader>tt", "<cmd>OverseerRun<CR>", desc = "Run Taskfile Task" },
    { "<leader>to", "<cmd>Telescope overseer<CR>", desc = "Overseer (Telescope)" },
    { "<leader>tl", "<cmd>OverseerToggle<CR>", desc = "Toggle Task List" },
  },
}

