return {
  "NeogitOrg/neogit",
  keys = { "<leader>gg" },
  dependencies = {
    "nvim-lua/plenary.nvim",         -- required
    "sindrets/diffview.nvim",        -- optional - Diff integration

    -- Only one of these is needed.
    "nvim-telescope/telescope.nvim", -- optional
    "ibhagwan/fzf-lua",              -- optional
    "echasnovski/mini.pick",         -- optional
    "folke/snacks.nvim",             -- optional
  },
  config = function()
    local neogit = require("neogit")

    -- 🧼 DRY: Refresh Neo-tree helper
    local function refresh_neo_tree()
      local ok, manager = pcall(require, "neo-tree.sources.manager")
      if ok then
        vim.notify("Refreshing Neo-tree...", vim.log.levels.INFO)
        manager.refresh("filesystem")
        manager.refresh("git_status")
      else
        vim.notify("Neo-tree manager not available", vim.log.levels.ERROR)
      end
    end

    neogit.setup({
      disable_commit_confirmation = true,
      disable_insert_on_commit = false,
      integrations = {
        diffview = true,
        telescope = true,
        fzf = true,
        mini = true,
        snacks = true,
      },
      event_handlers = {
        {
          event = "post_commit",
          handler = refresh_neo_tree,
        },
        {
          event = "post_stage",
          handler = refresh_neo_tree,
        },
        {
          event = "post_unstage",
          handler = refresh_neo_tree,
        },
        {
          event = "post_push",
          handler = refresh_neo_tree,
        },
      },
    })

    -- 🔑 Keymaps
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    map("n", "<leader>gg", function()
      neogit.open()
    end, vim.tbl_extend("force", opts, { desc = "Neogit: Open" }))

    map("n", "<leader>gB", ":G blame<CR>", vim.tbl_extend("force", opts, {
      desc = "Git: Fugitive Blame",
    }))
  end,
}
