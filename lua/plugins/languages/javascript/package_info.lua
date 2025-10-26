-- lua/plugins/languages/javascript/package_info.lua
-- Package-info.nvim - Show package versions in package.json

return {
  "vuki656/package-info.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  event = { "BufRead package.json" },
  config = function()
    require("package-info").setup({
      colors = {
        up_to_date = "#3C4048",
        outdated = "#d19a66",
      },
      icons = {
        enable = true,
        style = {
          up_to_date = "|  ",
          outdated = "|  ",
        },
      },
      autostart = true,
      hide_up_to_date = false,
      hide_unstable_versions = false,
    })

    vim.api.nvim_create_autocmd("BufRead", {
      pattern = "package.json",
      callback = function()
        local pkg = require("package-info")
        vim.keymap.set("n", "<leader>js", pkg.show, { desc = "JS: Show package info", buffer = true, silent = true })
        vim.keymap.set("n", "<leader>ju", pkg.update, { desc = "JS: Update package", buffer = true, silent = true })
        vim.keymap.set("n", "<leader>jd", pkg.delete, { desc = "JS: Delete package", buffer = true, silent = true })
        vim.keymap.set("n", "<leader>ji", pkg.install, { desc = "JS: Install package", buffer = true, silent = true })
        vim.keymap.set("n", "<leader>jv", pkg.change_version, { desc = "JS: Change version", buffer = true, silent = true })
      end,
    })
  end,
}
