-- lua/plugins/crates.lua
-- Cargo.toml dependency management: shows version info and update actions.

return {
  "saecki/crates.nvim",
  event = { "BufRead Cargo.toml" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("crates").setup({
      popup = {
        autofocus = true,
        border = "rounded",
        show_version_date = true,
      },
      null_ls = {
        enabled = false, -- We're using conform.nvim + nvim-lint
      },
      completion = {
        cmp = {
          enabled = true,
        },
      },
    })

    -- Cargo.toml specific keymaps
    vim.api.nvim_create_autocmd("BufRead", {
      pattern = "Cargo.toml",
      callback = function()
        local crates = require("crates")
        local opts = { silent = true, buffer = true }

        vim.keymap.set("n", "<leader>rc", crates.show_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show popup" }))
        vim.keymap.set("n", "<leader>ru", crates.update_crate, vim.tbl_extend("force", opts, { desc = "Crates: Update crate" }))
        vim.keymap.set("n", "<leader>rU", crates.update_all_crates, vim.tbl_extend("force", opts, { desc = "Crates: Update all" }))
        vim.keymap.set("n", "<leader>rV", crates.show_versions_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show versions" }))
        vim.keymap.set("n", "<leader>rF", crates.show_features_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show features" }))
      end,
    })
  end,
}
